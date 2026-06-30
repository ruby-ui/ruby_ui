import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="ruby-ui--message-scroller"
//
// A chat transcript scroller. Owns scroll state and behavior for a
// height-constrained message list:
//
//   - autoScroll: follows the live edge while the reader is pinned to the
//     bottom, and releases the moment they scroll, wheel, drag, or key away.
//   - scrollAnchor: when a new anchored turn is appended, settles it near the
//     top of the viewport keeping a peek of the previous turn above it.
//   - defaultScrollPosition: where a freshly mounted transcript opens
//     ("end", "start" or "last-anchor").
//   - preserveScrollOnPrepend: keeps the visible row fixed when older messages
//     are loaded in above the current view.
//
// Public API (callable from other controllers/outlets or future
// streaming/ActionCable code): scrollToEnd(), scrollToStart(),
// scrollToMessage(id). New rows appended to the content target are picked up
// automatically via MutationObserver — no manual call needed.
export default class extends Controller {
  static targets = ["viewport", "content", "button"];

  static values = {
    autoScroll: { type: Boolean, default: true },
    previousItemPeek: { type: Number, default: 64 },
    defaultPosition: { type: String, default: "end" },
    preserveOnPrepend: { type: Boolean, default: true },
    endThreshold: { type: Number, default: 32 },
  };

  connect() {
    // Reader is considered "following" the live edge until they move away.
    this.following = true;
    // True only while a programmatic scroll is in flight, so reader-intent
    // handlers don't mistake our own scrolling for the reader's.
    this.programmatic = false;

    this.onScroll = this.onScroll.bind(this);
    this.onWheel = this.onWheel.bind(this);
    this.onTouchStart = this.onTouchStart.bind(this);
    this.onKeydown = this.onKeydown.bind(this);

    if (this.hasViewportTarget) {
      this.viewportTarget.addEventListener("scroll", this.onScroll, { passive: true });
      this.viewportTarget.addEventListener("wheel", this.onWheel, { passive: true });
      this.viewportTarget.addEventListener("touchstart", this.onTouchStart, { passive: true });
      this.viewportTarget.addEventListener("keydown", this.onKeydown);
    }

    if (this.hasContentTarget) {
      // Announce streamed/added messages to assistive tech at a calm pace.
      if (!this.contentTarget.hasAttribute("role")) {
        this.contentTarget.setAttribute("role", "log");
      }
      if (!this.contentTarget.hasAttribute("aria-relevant")) {
        this.contentTarget.setAttribute("aria-relevant", "additions text");
      }

      this.observer = new MutationObserver((records) => this.onMutations(records));
      this.observer.observe(this.contentTarget, {
        childList: true,
        subtree: true,
        characterData: true,
      });
    }

    // Apply the opening position after layout settles.
    requestAnimationFrame(() => {
      this.applyDefaultPosition();
      this.updateButton();
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
    if (this.animationFrame) cancelAnimationFrame(this.animationFrame);
  }

  // --- Reader intent -------------------------------------------------------

  onScroll() {
    if (this.programmatic) return;
    this.following = this.isAtEnd();
    this.updateButton();
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

  release() {
    if (this.programmatic) return;
    this.following = false;
  }

  // --- Mutations (new / prepended / streamed rows) -------------------------

  onMutations(records) {
    let appended = null;
    let prependedHeight = 0;
    let streamed = false;
    const gap = this.rowGap();

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
        if (node.nodeType !== Node.ELEMENT_NODE) continue;
        if (record.previousSibling === null && record.nextSibling !== null) {
          // Inserted above existing rows → history prepend. Account for the
          // flex row gap each prepended row introduces, or the preserved row
          // drifts down by one gap per insertion.
          prependedHeight += (node.offsetHeight || 0) + gap;
        } else {
          // Inserted at (or after) the end → new turn.
          appended = node;
        }
      }
    }

    if (prependedHeight > 0 && this.preserveOnPrependValue) {
      // Keep the reader's current row fixed while history loads in above.
      this.viewportTarget.scrollTop += prependedHeight;
    }

    // Only move for new/streamed content while the reader is at the live edge.
    // If they scrolled away, leave them there and let the button surface it.
    const follow = this.autoScrollValue && this.following;
    if (appended && follow) {
      const anchor = appended.matches?.("[data-scroll-anchor]")
        ? appended
        : appended.querySelector?.("[data-scroll-anchor]");
      if (anchor) {
        this.scrollToAnchor(anchor);
      } else {
        this.scrollToEnd();
      }
    } else if (!appended && streamed && follow) {
      // Text streamed into the last row. Stay pinned.
      this.scrollToEnd("auto");
    }

    this.updateButton();
  }

  rowGap() {
    if (!this.hasContentTarget) return 0;
    const value = parseFloat(getComputedStyle(this.contentTarget).rowGap);
    return Number.isFinite(value) ? value : 0;
  }

  // --- Public scroll commands ---------------------------------------------

  scrollToEnd(behavior = "smooth") {
    if (!this.hasViewportTarget) return;
    this.following = true;
    this.scrollTo(this.viewportTarget.scrollHeight, behavior);
  }

  scrollToStart(behavior = "smooth") {
    if (!this.hasViewportTarget) return;
    this.following = false;
    this.scrollTo(0, behavior);
  }

  // Scroll a row with a matching messageId into view. Returns false when the
  // target is not mounted.
  scrollToMessage(id, behavior = "smooth") {
    if (!this.hasContentTarget) return false;
    const item = this.contentTarget.querySelector(`[data-message-id="${CSS.escape(id)}"]`);
    if (!item) return false;
    this.following = false;
    this.scrollToAnchor(item, behavior);
    return true;
  }

  scrollToAnchor(item, behavior = "smooth") {
    const top = Math.max(0, item.offsetTop - this.previousItemPeekValue);
    this.scrollTo(top, behavior);
  }

  // Bound to the scroll button's click action. Honors the button's
  // data-direction so a start-direction button jumps to the start.
  jump(event) {
    if (event?.currentTarget?.dataset.direction === "start") {
      this.scrollToStart();
    } else {
      this.scrollToEnd();
    }
  }

  // --- Internals -----------------------------------------------------------

  // Native scrollTo({ behavior: "smooth" }) is unreliable on a contained,
  // virtualized viewport, so we animate scrollTop ourselves with rAF. This
  // gives us full control over completion (no scrollend dependency) and lets
  // us honor reduced-motion.
  scrollTo(top, behavior = "smooth") {
    if (!this.hasViewportTarget) return;
    const max = this.viewportTarget.scrollHeight - this.viewportTarget.clientHeight;
    const target = Math.max(0, Math.min(top, max));

    this.programmatic = true;
    this.element.setAttribute("data-autoscrolling", "");
    this.viewportTarget.setAttribute("data-autoscrolling", "");
    if (this.animationFrame) cancelAnimationFrame(this.animationFrame);

    if (behavior === "auto" || this.prefersReducedMotion()) {
      this.viewportTarget.scrollTop = target;
      this.finishScroll();
      return;
    }

    const start = this.viewportTarget.scrollTop;
    const distance = target - start;
    const duration = 300;
    let startTime = null;

    const step = (now) => {
      if (startTime === null) startTime = now;
      const t = Math.min(1, (now - startTime) / duration);
      // easeOutCubic
      const eased = 1 - Math.pow(1 - t, 3);
      this.viewportTarget.scrollTop = start + distance * eased;
      if (t < 1) {
        this.animationFrame = requestAnimationFrame(step);
      } else {
        this.finishScroll();
      }
    };
    this.animationFrame = requestAnimationFrame(step);
  }

  finishScroll() {
    this.programmatic = false;
    this.element.removeAttribute("data-autoscrolling");
    this.viewportTarget?.removeAttribute("data-autoscrolling");
    this.following = this.isAtEnd();
    this.updateButton();
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
        ? this.contentTarget.querySelectorAll("[data-scroll-anchor]")
        : [];
      const last = anchors[anchors.length - 1];
      // Fall back to the end when there's no anchor, or the last turn already
      // fits in the viewport.
      if (last && last.offsetTop - this.previousItemPeekValue > 0) {
        this.following = false;
        this.viewportTarget.scrollTop = Math.max(0, last.offsetTop - this.previousItemPeekValue);
        this.updateButton();
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
    return scrollHeight - (scrollTop + clientHeight) <= this.endThresholdValue;
  }

  isAtStart() {
    if (!this.hasViewportTarget) return true;
    return this.viewportTarget.scrollTop <= this.endThresholdValue;
  }

  hasOverflow() {
    if (!this.hasViewportTarget) return false;
    return this.viewportTarget.scrollHeight - this.viewportTarget.clientHeight > this.endThresholdValue;
  }

  // Each button activates based on its own direction: an end button when the
  // reader is away from the bottom, a start button when away from the top.
  updateButton() {
    if (!this.hasButtonTarget) return;
    const overflow = this.hasOverflow();
    this.buttonTargets.forEach((button) => {
      const toStart = button.dataset.direction === "start";
      const active = overflow && (toStart ? !this.isAtStart() : !this.isAtEnd());
      button.setAttribute("data-active", active ? "true" : "false");
      // Remove the inert button from the tab order so there are no ghost stops.
      button.setAttribute("tabindex", active ? "0" : "-1");
    });
  }
}
