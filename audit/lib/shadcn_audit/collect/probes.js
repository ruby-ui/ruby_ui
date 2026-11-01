// Probes run by ShadcnAudit::Collect::Driver through page.evaluate. Each
// entry is a function expression; the driver picks one by name.
({
  // Same facts on both sides (interactions.md "Environment probe").
  environment: () => ({
    w: innerWidth, h: innerHeight, dpr: devicePixelRatio,
    font: getComputedStyle(document.body).fontFamily,
    fonts: [...new Set([...document.fonts].filter(f => f.status === "loaded").map(f => f.family))].sort(),
    body: getComputedStyle(document.body).backgroundColor + " / " + getComputedStyle(document.body).color,
    forms: (() => { const i = document.createElement("input"); i.type = "text"; document.body.append(i);
      const s = getComputedStyle(i); const r = s.appearance + " " + s.borderRadius + " " + s.borderColor; i.remove(); return r })(),
    dark: document.documentElement.classList.contains("dark"),
  }),

  // Waits for running animations (capped) and two frames.
  settle: async () => {
    const done = Promise.all(document.getAnimations().map(a => a.finished.catch(() => null)))
    await Promise.race([done, new Promise(r => setTimeout(r, 2000))])
    await new Promise(r => requestAnimationFrame(() => requestAnimationFrame(r)))
  },

  // Whether keyboard focus is on (or inside) the trigger.
  triggerFocused: () => {
    const t = document.querySelector("[data-audit-trigger]"), a = document.activeElement
    return !!(t && a && (t === a || t.contains(a)))
  },

  // Visible elements for a selector: index in querySelectorAll, computed
  // styles and the checked ARIA attributes (ID refs resolved, never raw).
  part: ({ selector, props, attrs }) => {
    const text = (id) => { const n = id && document.getElementById(id); return n ? n.textContent.trim().replace(/\s+/g, " ") : null }
    return [...document.querySelectorAll(selector)].map((e, index) => ({ e, index }))
      .filter(({ e }) => e.checkVisibility())
      .map(({ e, index }) => {
        const s = getComputedStyle(e)
        const a = {}
        for (const name of attrs) {
          const v = e.getAttribute(name)
          if (v === null) a[name] = null
          else if (name === "aria-controls") a[name] = v.split(/\s+/).every(id => document.getElementById(id)) ? "resolves" : "dangling"
          else if (name === "aria-describedby") a[name] = v.split(/\s+/).map(text).join(" ")
          else a[name] = v
        }
        return { index, styles: Object.fromEntries(props.map(p => [p, s.getPropertyValue(p)])), attrs: a }
      })
  },
})
