import { Toggle } from "@/components/ui/toggle"

function Bold() {
  return (
    <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none"
      stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" aria-hidden="true">
      <path d="M6 12h9a4 4 0 0 1 0 8H7a1 1 0 0 1-1-1V5a1 1 0 0 1 1-1h7a4 4 0 0 1 0 8" />
    </svg>
  )
}

function Underline() {
  return (
    <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none"
      stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" aria-hidden="true"
      data-icon="inline-start">
      <path d="M6 4v6a6 6 0 0 0 12 0V4" />
      <line x1="4" x2="20" y1="20" y2="20" />
    </svg>
  )
}

function Italic() {
  return (
    <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none"
      stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" aria-hidden="true">
      <line x1="19" x2="10" y1="4" y2="4" />
      <line x1="14" x2="5" y1="20" y2="20" />
      <line x1="15" x2="9" y1="4" y2="20" />
    </svg>
  )
}

export default function ToggleFixture() {
  return (
    <div className="flex flex-wrap items-center gap-2">
      <Toggle aria-label="Toggle bold" data-audit-trigger=""><Bold /></Toggle>
      <Toggle aria-label="Toggle italic" defaultPressed><Italic /></Toggle>
      <Toggle variant="outline"><Italic />Italic</Toggle>
      <Toggle variant="outline" defaultPressed><Bold />Bold</Toggle>
      <Toggle variant="outline"><Underline />Underline</Toggle>
      <Toggle variant="outline" size="sm">Small</Toggle>
      <Toggle variant="outline" size="default">Default</Toggle>
      <Toggle variant="outline" size="lg">Large</Toggle>
      <Toggle disabled>Disabled</Toggle>
      <Toggle variant="outline" aria-invalid="true">Invalid</Toggle>
    </div>
  )
}
