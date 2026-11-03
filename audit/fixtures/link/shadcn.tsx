import { Button } from "@/components/ui/button"

function ChevronRight() {
  return (
    <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none"
      stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" aria-hidden="true">
      <path d="m9 18 6-6-6-6" />
    </svg>
  )
}

function Send() {
  return (
    <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none"
      stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" aria-hidden="true"
      data-icon="inline-start">
      <path d="m22 2-7 20-4-9-9-4Z" />
      <path d="M22 2 11 13" />
    </svg>
  )
}

export default function LinkFixture() {
  return (
    <div className="flex flex-wrap items-center gap-2">
      <Button nativeButton={false} render={<a href="#" data-audit-trigger="" />}>Button</Button>
      <Button nativeButton={false} render={<a href="#" />} variant="outline">Outline</Button>
      <Button nativeButton={false} render={<a href="#" />} variant="secondary">Secondary</Button>
      <Button nativeButton={false} render={<a href="#" />} variant="ghost">Ghost</Button>
      <Button nativeButton={false} render={<a href="#" />} variant="destructive">Destructive</Button>
      <Button nativeButton={false} render={<a href="#" />} variant="link">Link</Button>
      <Button nativeButton={false} render={<a href="#" />} size="sm">Small</Button>
      <Button nativeButton={false} render={<a href="#" />} size="lg">Large</Button>
      <Button nativeButton={false} render={<a href="#" />} variant="outline" size="icon" aria-label="Next"><ChevronRight /></Button>
      <Button nativeButton={false} render={<a href="#" />}><Send />Send</Button>
      <Button nativeButton={false} render={<a href="#" />} disabled>Disabled</Button>
      <Button nativeButton={false} render={<a href="#" />} disabled focusableWhenDisabled>Focusable</Button>
    </div>
  )
}
