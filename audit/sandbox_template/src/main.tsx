import type { ComponentType } from "react"
import { createRoot } from "react-dom/client"

import "./parity.css"

// src/fixtures/<folder>.tsx are copied from audit/fixtures/<folder>/shadcn.tsx.
const fixtures = import.meta.glob<{ default: ComponentType }>("./fixtures/*.tsx", { eager: true })

const params = new URLSearchParams(window.location.search)
const folder = params.get("c") ?? ""
const theme = params.get("theme") === "dark" ? "dark" : "light"

document.documentElement.classList.toggle("dark", theme === "dark")

const Fixture = fixtures[`./fixtures/${folder}.tsx`]?.default
const available = Object.keys(fixtures).map((path) => path.replace(/^\.\/fixtures\/|\.tsx$/g, ""))

createRoot(document.getElementById("root")!).render(
  <div data-audit-fixture={folder}>
    {Fixture ? <Fixture /> : <p data-audit-missing>Unknown fixture "{folder}". Available: {available.join(", ")}</p>}
  </div>
)
