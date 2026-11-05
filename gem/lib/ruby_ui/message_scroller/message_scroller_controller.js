import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="ruby-ui--message-scroller"
//
// A chat transcript scroller, after shadcn's MessageScroller. Owns scroll
// state and behavior for a height-constrained message list:
//
//   - autoScroll (off by default, as in shadcn): follows the live edge while
//     the reader is pinned to the bottom, and releases the moment they
//     scroll, wheel, drag, or key away.
//   - scrollAnchor: when a new anchored turn is appended, settles it near the
//     top of the viewport keeping a peek of the previous turn above it. The
//     content's spacer gives it room while the reply is still short.
//   - defaultPosition: where a freshly mounted transcript opens
//     ("end", "start" or "last-anchor").
//   - Prepending older rows keeps the visible row in place through the
//     browser's own scroll anchoring (CSS overflow-anchor), not here.
//
// State for styling: data-scrollable ("start", "end", "start end") on the
// root and viewport, data-autoscrolling while a programmatic scroll runs,
// data-pending-scroll on the viewport until the first positioning.
//
// Public API (callable from other controllers/outlets or future
// streaming/ActionCable code): scrollToEnd(), scrollToStart(),
// scrollToMessage(id). New rows appended to the content target are picked up
// automatically via MutationObserver — no manual call needed.
export default class extends Controller {
  static targets = ["viewport", "content", "spacer", "button"];

  static values = {
    autoScroll: { type: Boolean, default: false },
    defaultPosition: { type: String, default: "end" },
    scrollEdgeThreshold: { type: Number, default: 8 },
    previousItemPeek: { type: Number, default: 64 },
    scrollMargin: { type: Number, default: 0 },
    // Deprecated: MessageScrollerViewport(preserve_scroll_on_prepend:).
    preserveOnPrepend: Boolean,
  };

  connect() {
    // Reader is considered "following" the live edge until they move away.
    this.following = true;
    // True only while a programmatic scroll is in flight, so reader-intent
    // handlers don't mistake our own scrolling for the reader's.
    this.programmatic = false;
    // The anchored row held near the top, if any, and where it was put.
    this.anchored = null;
    this.heldTop = null;

    this.onScroll = this.onScroll.bind(this);
    this.onWheel = this.onWheel.bind(this);
    this.onTouchStart = this.onTouchStart.bind(this);
    this.onKeydown = this.onKeydown.bind(this);

    if (this.hasViewportTarget) {
      this.viewportTarget.addEventListener("scroll", this.onScroll, { passive: true });
      this.viewportTarget.addEventListener("wheel", this.onWheel, { passive: true });
      this.viewportTarget.addEventListener("touchstart", this.onTouchStart, { passive: true });
      this.viewportTarget.addEventListener("keydown", this.onKeydown);

      if (this.hasPreserveOnPrependValue && !this.preserveOnPrependValue) {
        this.viewportTarget.style.overflowAnchor = "none";
      }
    }

    // A blank copy of the spacer, to put back if the rows are replaced
    // wholesale (e.g. a Turbo Stream update on the content).
    if (this.hasSpacerTarget && !this.spacerTemplate) {
      this.spacerTemplate = this.spacerTarget.cloneNode(false);
      this.spacerTemplate.hidden = true;
      this.spacerTemplate.removeAttribute("style");
    }

    if (this.hasContentTarget) {
      // Announce added messages to assistive tech at a calm pace.
      if (!this.contentTarget.hasAttribute("role")) {
        this.contentTarget.setAttribute("role", "log");
      }
      if (!this.contentTarget.hasAttribute("aria-relevant")) {
        this.contentTarget.setAttribute("aria-relevant", "additions");
      }

      this.observer = new MutationObserver((records) => this.onMutations(records));
      this.observer.observe(this.contentTarget, {
        childList: true,
        subtree: true,
        characterData: true,
      });

      // Rows with content-visibility: auto start at an estimated height and
      // settle once rendered; keep a held anchor in place when that happens.
      if (typeof ResizeObserver !== "undefined") {
        this.resizeObserver = new ResizeObserver(() => this.onResize());
        this.resizeObserver.observe(this.contentTarget);
        if (this.hasViewportTarget) this.resizeObserver.observe(this.viewportTarget);
      }
    }

    // Apply the opening position after layout settles.
    this.positionFrame = requestAnimationFrame(() => {
      this.positionFrame = null;
      this.applyDefaultPosition();
      if (this.hasViewportTarget) this.viewportTarget.removeAttribute("data-pending-scroll");
      this.updateState();
    });
  }

  disconnect() {
    if (this.hasViewportTarget) {
      this.viewportTarget.removeEventListener("scroll", this.onScroll);
      this.viewportTarget.removeEventListener("wheel", this.onWheel);
      this.viewportTarget.removeEventListener("touchstart", this.onTouchStart);
      this.viewportTarget.removeEventListener("keydown", this.onKeydown);
    }
    this.observer?.disconnect();
    this.resizeObserver?.disconnect();
    if (this.positionFrame) cancelAnimationFrame(this.positionFrame);
    if (this.releaseFrame) cancelAnimationFrame(this.releaseFrame);
    this.releaseFrame = null;
    this.forcedRows?.forEach((row) => (row.style.contentVisibility = ""));
    this.forcedRows?.clear();
    // Leave no visible state behind for a reconnect (Turbo snapshot restore):
    // the spacer would skew the opening position.
    this.abortScroll();
    this.clearSpacer();
  }

  // --- Reader intent -------------------------------------------------------

  onScroll() {
    if (this.programmatic) return;
    if (this.anchored) {
      // Our own correction, or the browser clamping scrollTop after a row
      // settled to a smaller height: keep holding the turn.
      const { scrollTop, scrollHeight, clientHeight } = this.viewportTarget;
      const clamped = scrollTop < this.heldTop && scrollTop >= scrollHeight - clientHeight - 1;
      if (Math.abs(scrollTop - this.heldTop) < 1 || clamped) {
        this.updateState();
        return;
      }
      // The reader moved: stop holding (the spacer stays until the next turn).
      this.anchored = null;
      this.heldTop = null;
    }
    this.following = this.isAtEnd();
    this.updateState();
  }

  // Any upward wheel is a deliberate move away from the live edge.
  onWheel(event) {
    if (event.deltaY < 0) this.release();
  }

  onTouchStart() {
    // A touch that turns into an upward drag surfaces through onScroll; this
    // just makes the release feel immediate when the reader grabs the list.
    if (!this.isAtEnd()) this.release();
  }

  onKeydown(event) {
    const navKeys = ["ArrowUp", "PageUp", "Home", "ArrowDown", "PageDown", "End", " "];
    if (navKeys.includes(event.key)) this.release();
  }

  // An explicit move by the reader wins over a scroll in flight: stop it and
  // let go of the held turn instead of pulling them back when it ends.
  release() {
    if (this.programmatic) this.abortScroll();
    this.following = false;
    this.anchored = null;
    this.heldTop = null;
  }

  // --- Mutations (new / prepended / streamed rows) -------------------------

  onMutations(records) {
    let appended = null;
    let anchorRow = null;
    let streamed = false;
    if (!this.hasSpacerTarget && this.spacerTemplate) {
      this.contentTarget.appendChild(this.spacerTemplate.cloneNode(false));
    }
    const spacer = this.hasSpacerTarget ? this.spacerTarget : null;

    // Our own move of the spacer to the end: nothing to react to.
    const onlySpacer = (record) =>
      record.type === "childList" &&
      [...record.addedNodes, ...record.removedNodes].every((node) => node === spacer);
    if (spacer && records.every(onlySpacer)) return;

    for (const record of records) {
      // Text streamed into an existing row (e.g. tokens) — not a new turn.
      if (record.type === "characterData") {
        streamed = true;
        continue;
      }
      if (record.type !== "childList") continue;
      // Only direct children of the content element are transcript rows.
      // Markup inserted *inside* a message must not be mistaken for history.
      if (record.target !== this.contentTarget) {
        streamed = true;
        continue;
      }
      for (const node of record.addedNodes) {
        if (node.nodeType !== Node.ELEMENT_NODE || node === spacer) continue;
        // Inserted above existing rows → history prepend. The browser's
        // scroll anchoring keeps the reader's row in place; nothing to do.
        const prepended = record.previousSibling === null && record.nextSibling !== null && record.nextSibling !== spacer;
        if (prepended) continue;
        appended = node;
        if (!anchorRow && (node.matches?.('[data-scroll-anchor="true"]') || node.querySelector?.('[data-scroll-anchor="true"]'))) {
          anchorRow = node;
        }
      }
    }

    // Keep the spacer as the last child when rows land after it.
    if (spacer && spacer !== this.contentTarget.lastElementChild) {
      this.contentTarget.appendChild(spacer);
    }

    // Only move for new/streamed content while the reader is at the live edge.
    // If they scrolled away, leave them there and let the button surface it.
    const follow = this.autoScrollValue && this.following;
    if (appended && follow) {
      // Several rows in one go (a question and its answer): the first
      // anchored one settles, as in shadcn.
      const anchor = anchorRow?.matches('[data-scroll-anchor="true"]')
        ? anchorRow
        : anchorRow?.querySelector('[data-scroll-anchor="true"]');
      if (anchor) {
        this.scrollToAnchor(anchor);
      } else if (this.anchored) {
        // The reply to a held turn: keep the turn in place while the spacer
        // gives way to the reply. A scroll in flight re-holds when it ends.
        if (!this.programmatic) this.hold();
      } else {
        this.scrollToEnd();
      }
    } else if (this.anchored) {
      if (!this.programmatic) this.hold();
    } else if (!appended && streamed && follow) {
      // Text streamed into the last row. Stay pinned.
      this.scrollToEnd("auto");
    }

    this.updateState();
  }

  onResize() {
    if (this.programmatic || this.positionFrame || !this.hasViewportTarget) return;
    if (this.anchored) {
      this.hold();
    } else if (this.autoScrollValue && this.following && !this.isAtEnd()) {
      // A row grew (an image loaded, a reply re-rendered): stay pinned.
      this.viewportTarget.scrollTop = this.viewportTarget.scrollHeight;
    }
    this.updateState();
  }

  // Re-sizes the spacer for the held turn and puts the turn back on its
  // target. Rows with content-visibility: auto start at an estimated height,
  // so the target moves once they render.
  hold() {
    if (!this.anchored || !this.hasViewportTarget) return;
    // The held row was removed (transcript reset, Turbo replace): let go.
    if (!this.anchored.isConnected) {
      this.clearSpacer();
      return;
    }
    const hadRoom = this.hasSpacerTarget && !this.spacerTarget.hidden;
    const target = this.sizeSpacer(this.anchored);
    // The reply has filled the room below the turn: with autoScroll on and
    // the reader still following, go back to following the live edge (as
    // shadcn does when its spacer reaches 0).
    if (hadRoom && this.spacerTarget.hidden && this.autoScrollValue && this.following) {
      this.scrollToEnd("auto");
      return;
    }
    this.heldTop = target;
    if (Math.abs(this.viewportTarget.scrollTop - target) >= 1) {
      this.viewportTarget.scrollTop = target;
    }
  }

  // --- Public scroll commands ---------------------------------------------

  scrollToEnd(behavior = "smooth") {
    if (!this.hasViewportTarget) return false;
    this.clearSpacer();
    this.following = true;
    this.scrollTo(this.viewportTarget.scrollHeight, behavior);
    return true;
  }

  scrollToStart(behavior = "smooth") {
    if (!this.hasViewportTarget) return false;
    this.clearSpacer();
    this.following = false;
    this.scrollTo(0, behavior);
    return true;
  }

  // Scroll a row with a matching messageId into view. Returns false when the
  // target is not mounted.
  scrollToMessage(id, behavior = "smooth") {
    if (!this.hasContentTarget || !this.hasViewportTarget) return false;
    const item = this.contentTarget.querySelector(`[data-message-id="${CSS.escape(id)}"]`);
    if (!item) return false;
    this.following = false;
    this.scrollToAnchor(item, behavior);
    return true;
  }

  scrollToAnchor(item, behavior = "smooth") {
    this.anchored = item;
    this.heldTop = this.sizeSpacer(item);
    this.scrollTo(this.heldTop, behavior);
  }

  // Bound to the scroll button's click action; direction and behavior come
  // from its action params. The button goes inactive once the scroll lands,
  // so drop focus first (as shadcn does) instead of leaving it on a hidden,
  // inert element.
  jump(event) {
    event?.currentTarget?.blur();
    const { direction, behavior = "smooth" } = event?.params || {};
    if (direction === "start") {
      this.scrollToStart(behavior);
    } else {
      this.scrollToEnd(behavior);
    }
  }

  // --- Internals -----------------------------------------------------------

  // Where an anchored row should land: its top minus the peek of the
  // previous row and the scroll margin.
  anchorTop(item) {
    if (!this.hasViewportTarget) return 0;
    return Math.max(0, this.scrollOffset(item) - this.previousItemPeekValue - this.scrollMarginValue);
  }

  // An element's top in the viewport's scroll coordinates.
  scrollOffset(element) {
    const viewport = this.viewportTarget;
    return element.getBoundingClientRect().top - viewport.getBoundingClientRect().top + viewport.scrollTop;
  }

  // Grows the spacer just enough for the anchored row to reach its target
  // even when there isn't enough content below it (hides it when there is),
  // and returns the target.
  sizeSpacer(item) {
    const target = this.anchorTop(item);
    if (!this.hasSpacerTarget || !this.hasViewportTarget || !this.hasContentTarget) return target;

    const spacer = this.spacerTarget;
    // The rows' bottom must reach this for the anchor to sit at its target.
    const needed = target + this.viewportTarget.clientHeight;
    const rows = [...this.contentTarget.children].filter((el) => el !== spacer);
    const padding = parseFloat(getComputedStyle(this.contentTarget).paddingBottom) || 0;

    // Walk down from the anchor, rendering each row so it measures for real
    // (content-visibility: auto keeps off-screen rows at an estimated height),
    // and stop once the rows already fill the viewport: no spacer needed, and
    // a long transcript below the anchor is never rendered all at once.
    // scrollHeight won't do: min-h-full stretches a short transcript.
    let end = 0;
    for (let i = Math.max(0, rows.indexOf(item)); i < rows.length; i++) {
      const row = rows[i];
      this.renderRows([row]);
      end = this.scrollOffset(row) + row.offsetHeight + (i === rows.length - 1 ? padding : 0);
      if (end >= needed) break;
    }
    const missing = needed - end;

    if (missing > 0) {
      // The flex gap before the spacer counts toward the room it adds; when
      // the room needed is smaller than the gap, pull the spacer back over it.
      const gap = this.rowGap();
      spacer.hidden = false;
      spacer.style.height = `${Math.max(0, missing - gap)}px`;
      spacer.style.marginTop = missing < gap ? `${missing - gap}px` : "";
    } else {
      spacer.hidden = true;
      spacer.style.height = "";
      spacer.style.marginTop = "";
    }
    return target;
  }

  // Keeps rows rendered until after the next paint, when
  // contain-intrinsic-size: auto has recorded their real size; until then
  // the browser would fall back to the estimate.
  renderRows(rows) {
    this.forcedRows ??= new Set();
    rows.forEach((row) => {
      row.style.contentVisibility = "visible";
      this.forcedRows.add(row);
    });
    if (this.releaseFrame) return;
    this.releaseFrame = requestAnimationFrame(() => {
      this.releaseFrame = requestAnimationFrame(() => {
        this.releaseFrame = null;
        this.forcedRows.forEach((row) => (row.style.contentVisibility = ""));
        this.forcedRows.clear();
      });
    });
  }

  clearSpacer() {
    this.anchored = null;
    this.heldTop = null;
    if (!this.hasSpacerTarget) return;
    this.spacerTarget.hidden = true;
    this.spacerTarget.style.height = "";
    this.spacerTarget.style.marginTop = "";
  }

  rowGap() {
    if (!this.hasContentTarget) return 0;
    const value = parseFloat(getComputedStyle(this.contentTarget).rowGap);
    return Number.isFinite(value) ? value : 0;
  }

  // Native smooth scrolling (Element.scrollTo), done on scrollend. Browsers
  // without scrollend get a timeout instead.
  scrollTo(top, behavior = "smooth") {
    if (!this.hasViewportTarget) return;
    const viewport = this.viewportTarget;
    // Stimulus actions pass the event as the first argument.
    if (behavior !== "auto" && behavior !== "smooth" && behavior !== "instant") behavior = "smooth";
    if (this.prefersReducedMotion()) behavior = "auto";

    const max = viewport.scrollHeight - viewport.clientHeight;
    const target = Math.max(0, Math.min(top, max));

    this.cancelPendingScroll?.();
    if (Math.abs(viewport.scrollTop - target) < 1) {
      this.finishScroll();
      return;
    }

    this.programmatic = true;
    this.element.setAttribute("data-autoscrolling", "");
    viewport.setAttribute("data-autoscrolling", "");

    if (behavior !== "smooth") {
      viewport.scrollTop = target;
      this.finishScroll();
      return;
    }

    const done = () => {
      this.cancelPendingScroll();
      this.finishScroll();
    };
    // Without scrollend, call it done once scroll events stop arriving.
    const native = "onscrollend" in viewport;
    let timer = null;
    const idle = () => {
      clearTimeout(timer);
      timer = setTimeout(done, 150);
    };
    viewport.addEventListener(native ? "scrollend" : "scroll", native ? done : idle);
    if (!native) idle();
    this.cancelPendingScroll = () => {
      clearTimeout(timer);
      viewport.removeEventListener(native ? "scrollend" : "scroll", native ? done : idle);
      this.cancelPendingScroll = null;
    };
    viewport.scrollTo({ top: target, behavior: "smooth" });
  }

  finishScroll() {
    // Rows measured during the scroll may have settled to their real height:
    // land the held turn on its target.
    this.hold();
    this.programmatic = false;
    this.element.removeAttribute("data-autoscrolling");
    if (this.hasViewportTarget) this.viewportTarget.removeAttribute("data-autoscrolling");
    // A turn settled while following stays followed even when its reply runs
    // past the bottom: the reader hasn't moved, so the next turn is theirs
    // too. Leaving the held turn (onScroll, release) ends it.
    if (!(this.anchored && this.following)) this.following = this.isAtEnd();
    this.updateState();
  }

  // Drops a programmatic scroll in flight without landing it.
  abortScroll() {
    if (this.cancelPendingScroll && this.hasViewportTarget) {
      // Halt the native smooth scroll where it is; the reader's own input
      // takes over from there.
      const viewport = this.viewportTarget;
      viewport.scrollTo({ top: viewport.scrollTop, behavior: "instant" });
    }
    this.cancelPendingScroll?.();
    this.programmatic = false;
    this.element.removeAttribute("data-autoscrolling");
    if (this.hasViewportTarget) this.viewportTarget.removeAttribute("data-autoscrolling");
  }

  prefersReducedMotion() {
    return window.matchMedia("(prefers-reduced-motion: reduce)").matches;
  }

  applyDefaultPosition() {
    if (!this.hasViewportTarget) return;
    const position = this.defaultPositionValue;

    if (position === "start") {
      this.following = false;
      this.viewportTarget.scrollTop = 0;
      return;
    }

    if (position === "last-anchor") {
      // Stimulus' contentTarget getter throws when missing — guard explicitly.
      const anchors = this.hasContentTarget
        ? this.contentTarget.querySelectorAll('[data-scroll-anchor="true"]')
        : [];
      const last = anchors[anchors.length - 1];
      // Fall back to the end when there's no anchor, or the last turn already
      // fits in the viewport.
      if (last && this.anchorTop(last) > 0) {
        this.following = false;
        this.anchored = last;
        this.heldTop = this.sizeSpacer(last);
        this.viewportTarget.scrollTop = this.heldTop;
        return;
      }
    }

    // Default: open at the live edge.
    this.following = true;
    this.viewportTarget.scrollTop = this.viewportTarget.scrollHeight;
  }

  isAtEnd() {
    if (!this.hasViewportTarget) return true;
    const { scrollTop, clientHeight, scrollHeight } = this.viewportTarget;
    return scrollHeight - (scrollTop + clientHeight) <= this.scrollEdgeThresholdValue;
  }

  isAtStart() {
    if (!this.hasViewportTarget) return true;
    return this.viewportTarget.scrollTop <= this.scrollEdgeThresholdValue;
  }

  // data-scrollable on the root and viewport, and each button's active state:
  // an end button when the reader is away from the bottom, a start button
  // when away from the top.
  updateState() {
    if (!this.hasViewportTarget) return;
    const toStart = !this.isAtStart();
    const toEnd = !this.isAtEnd();
    const scrollable = [toStart && "start", toEnd && "end"].filter(Boolean).join(" ");

    const root = this.viewportTarget.closest('[data-slot="message-scroller"]');
    for (const el of [root, this.viewportTarget]) {
      if (!el) continue;
      if (scrollable) el.setAttribute("data-scrollable", scrollable);
      else el.removeAttribute("data-scrollable");
    }

    this.buttonTargets.forEach((button) => {
      const active = button.dataset.direction === "start" ? toStart : toEnd;
      button.setAttribute("data-active", active ? "true" : "false");
      // Hidden buttons leave the tab order and the accessibility tree.
      button.setAttribute("tabindex", active ? "0" : "-1");
      button.inert = !active;
    });
  }
}
