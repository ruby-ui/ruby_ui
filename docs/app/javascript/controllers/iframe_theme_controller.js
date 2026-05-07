import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["iframe"]

  connect() {
    this.setupThemeObserver()
    this.setupIframeListeners()
    this.syncAllIframes()
  }

  disconnect() {
    this.observer?.disconnect()
  }

  iframeTargetConnected(iframe) {
    this.setupIframeListener(iframe)
    this.syncThemeToIframe(iframe)
  }

  setupThemeObserver() {
    this.observer = new MutationObserver(() => this.syncAllIframes())
    this.observer.observe(document.documentElement, {
      attributes: true,
      attributeFilter: ['class']
    })
  }

  setupIframeListeners() {
    this.iframeTargets.forEach(iframe => this.setupIframeListener(iframe))
  }

  setupIframeListener(iframe) {
    if (!iframe.src) return

    iframe.addEventListener('load', () => this.syncThemeToIframe(iframe))
    
    if (this.isIframeLoaded(iframe)) {
      this.syncThemeToIframe(iframe)
    }
  }

  syncAllIframes() {
    this.iframeTargets.forEach(iframe => this.syncThemeToIframe(iframe))
  }

  syncThemeToIframe(iframe) {
    if (!iframe.src) return

    const iframeDoc = this.getIframeDocument(iframe)
    if (!iframeDoc?.documentElement) return

    iframeDoc.documentElement.classList.toggle('dark', this.isDarkMode)
  }

  getIframeDocument(iframe) {
    try {
      return iframe.contentDocument || iframe.contentWindow?.document
    } catch (e) {
      return null
    }
  }

  isIframeLoaded(iframe) {
    const doc = this.getIframeDocument(iframe)
    return doc && doc.readyState === 'complete'
  }

  get isDarkMode() {
    return document.documentElement.classList.contains('dark')
  }
}

