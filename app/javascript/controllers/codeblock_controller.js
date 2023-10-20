import { Controller } from "@hotwired/stimulus"
import hljs from 'highlight.js'; // Ensure you have this installed via npm or yarn

// Connects to data-controller="codeblock"
export default class extends Controller {  
  connect() {
    this.highlight();
  }

  highlight() {
    hljs.highlightElement(this.element);
  }
}
