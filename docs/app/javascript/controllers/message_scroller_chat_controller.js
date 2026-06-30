import { Controller } from "@hotwired/stimulus";

// Docs-only demo harness for the Message Scroller chat window.
//
// On submit it clones the server-rendered user/assistant <template> rows into
// the scroller content and clears the empty state. The MessageScroller
// controller observes the content and handles autoscroll/anchoring — this
// controller only produces rows, the way a real ActionCable/streaming source
// would. Connects to data-controller="message-scroller-chat".
export default class extends Controller {
  static targets = ["content", "empty", "scroller", "input", "userTemplate", "assistantTemplate"];
  static values = {
    replies: { type: Array, default: [] },
  };

  connect() {
    this.turn = 0;
  }

  send(event) {
    event.preventDefault();
    const text = this.hasInputTarget ? this.inputTarget.value.trim() : "";
    if (!text) return;

    this.reveal();
    this.appendRow(this.userTemplateTarget, text);
    this.inputTarget.value = "";

    const reply = this.repliesValue[this.turn % this.repliesValue.length] || "Got it — thanks!";
    this.turn += 1;
    // Let the assistant reply land a beat later, like a streamed response.
    this.replyTimer = setTimeout(() => {
      this.appendRow(this.assistantTemplateTarget, reply);
    }, 500);
  }

  reset() {
    if (this.replyTimer) clearTimeout(this.replyTimer);
    if (this.hasContentTarget) this.contentTarget.replaceChildren();
    this.scrollerTarget?.classList.add("hidden");
    this.emptyTarget?.classList.remove("hidden");
    this.turn = 0;
  }

  reveal() {
    this.emptyTarget?.classList.add("hidden");
    this.scrollerTarget?.classList.remove("hidden");
  }

  appendRow(template, text) {
    if (!template || !this.hasContentTarget) return;
    const row = template.content.firstElementChild.cloneNode(true);
    const content = row.querySelector("[data-slot=bubble-content]");
    if (content) content.textContent = text;
    this.contentTarget.appendChild(row);
  }

  disconnect() {
    if (this.replyTimer) clearTimeout(this.replyTimer);
  }
}
