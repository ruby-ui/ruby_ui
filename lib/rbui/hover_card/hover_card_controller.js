import { Controller } from "@hotwired/stimulus";
import { computePosition, offset, autoUpdate } from "@floating-ui/dom";

export default class extends Controller {
  static targets = ["trigger", "content", "menuItem"];
  static values = {
    options: {
      type: Object,
      default: {},
    },
    matchWidth: {
      type: Boolean,
      default: false,
    }
  }

  connect() {
    this.boundHandleKeydown = this.handleKeydown.bind(this); // Bind the function so we can remove it later
    this.initializeTooltip();
    this.selectedIndex = -1;
  }

  disconnect() {
    this.destroyTooltip();
  }

  initializeTooltip() {
    this.triggerTarget.addEventListener('click', this.open.bind(this));
    this.triggerTarget.addEventListener('mouseenter', this.open.bind(this));
    document.addEventListener('click', this.handleDocumentClick.bind(this));
    document.addEventListener('keydown', this.handleEscape.bind(this));
  }

  destroyTooltip() {
    this.triggerTarget.removeEventListener('click', this.open.bind(this));
    this.triggerTarget.removeEventListener('mouseenter', this.open.bind(this));
    document.removeEventListener('click', this.handleDocumentClick.bind(this));
    document.removeEventListener('keydown', this.handleEscape.bind(this));
    if (this.cleanup) {
      this.cleanup();
    }
    if (this.tooltipElement) {
      this.tooltipElement.remove();
    }
  }

  createTooltipElement() {
    const tooltipElement = document.createElement('div');
    tooltipElement.setAttribute('data-floating-ui-root', '');
    tooltipElement.style.position = 'absolute';
    tooltipElement.style.zIndex = '9999';
    tooltipElement.style.visibility = 'hidden';
    tooltipElement.classList.add('opacity-0', 'transition-opacity', 'duration-300', 'ease-in-out');
  
    const tooltipBox = document.createElement('div');
    tooltipBox.setAttribute('role', 'tooltip');
    tooltipBox.style.maxWidth = '350px';
  
    const tooltipContent = document.createElement('div');
    tooltipContent.innerHTML = this.contentTarget.innerHTML;
  
    tooltipBox.appendChild(tooltipContent);
    tooltipElement.appendChild(tooltipBox);
    document.body.appendChild(tooltipElement);
  
    this.tooltipElement = tooltipElement;
    this.tooltipContent = tooltipContent;
  }

  open() {
    if (!this.tooltipElement) {
      this.createTooltipElement();
    }
  
    setTimeout(() => {
      this.tooltipElement.style.visibility = 'visible';
      this.tooltipElement.classList.remove('opacity-0');
      this.tooltipElement.classList.add('opacity-100');
      this.updateTooltipPosition();
      this.addEventListeners();
    }, 700);
  }

  close() {
    if (this.tooltipElement) {
      this.tooltipElement.classList.remove('opacity-100');
      this.tooltipElement.classList.add('opacity-0');
      setTimeout(() => {
        this.tooltipElement.style.visibility = 'hidden';
      }, 300);
    }
    this.removeEventListeners();
    this.deselectAll();
  }

  handleDocumentClick(event) {
    if (!this.element.contains(event.target) && !this.tooltipElement.contains(event.target)) {
      this.close();
    }
  }

  handleEscape(event) {
    if (event.key === 'Escape') {
      this.close();
    }
  }

  updateTooltipPosition() {
    this.cleanup = autoUpdate(this.triggerTarget, this.tooltipElement, () => {
      computePosition(this.triggerTarget, this.tooltipElement, {
        placement: 'bottom',
        middleware: [offset(4)],
      }).then(({ x, y }) => {
        Object.assign(this.tooltipElement.style, {
          left: `${x}px`,
          top: `${y}px`,
        });

        if (this.matchWidthValue) {
          this.tooltipContent.style.width = `${this.triggerTarget.offsetWidth}px`;
        }
      });
    });
  }

  handleKeydown(e) {
    if (this.menuItemTargets.length === 0) { return; }

    if (e.key === 'ArrowDown') {
      e.preventDefault();
      this.updateSelectedItem(1);
    } else if (e.key === 'ArrowUp') {
      e.preventDefault();
      this.updateSelectedItem(-1);
    } else if (e.key === 'Enter' && this.selectedIndex !== -1) {
      e.preventDefault();
      this.menuItemTargets[this.selectedIndex].click();
    }
  }

  updateSelectedItem(direction) {
    // Check if any of the menuItemTargets have aria-selected="true" and set the selectedIndex to that index
    this.menuItemTargets.forEach((item, index) => {
      if (item.getAttribute('aria-selected') === 'true') {
        this.selectedIndex = index;
      }
    });

    if (this.selectedIndex >= 0) {
      this.toggleAriaSelected(this.menuItemTargets[this.selectedIndex], false);
    }

    this.selectedIndex += direction;

    if (this.selectedIndex < 0) {
      this.selectedIndex = this.menuItemTargets.length - 1;
    } else if (this.selectedIndex >= this.menuItemTargets.length) {
      this.selectedIndex = 0;
    }

    this.toggleAriaSelected(this.menuItemTargets[this.selectedIndex], true);
  }

  toggleAriaSelected(element, isSelected) {
    // Add or remove attribute
    if (isSelected) {
      element.setAttribute('aria-selected', 'true');
    } else {
      element.removeAttribute('aria-selected');
    }
  }

  deselectAll() {
    this.menuItemTargets.forEach(item => this.toggleAriaSelected(item, false));
    this.selectedIndex = -1;
  }

  addEventListeners() {
    document.addEventListener('keydown', this.boundHandleKeydown);
  }

  removeEventListeners() {
    document.removeEventListener('keydown', this.boundHandleKeydown);
  }
}