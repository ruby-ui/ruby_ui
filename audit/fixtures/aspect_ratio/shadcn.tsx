import { AspectRatio } from "@/components/ui/aspect-ratio"

const IMAGE_SRC =
  "data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='640' height='360' viewBox='0 0 640 360'%3E%3Crect width='640' height='360' fill='%23737373'/%3E%3Ccircle cx='320' cy='180' r='120' fill='%23d4d4d4'/%3E%3C/svg%3E"

export default function AspectRatioFixture() {
  return (
    <div id="aspect-ratio-fixture" className="w-96">
      <AspectRatio ratio={16 / 9} className="rounded-lg bg-muted">
        {/* next/image fill renders this inline style */}
        <img
          src={IMAGE_SRC}
          alt="Photo"
          data-audit-trigger=""
          style={{ position: "absolute", height: "100%", width: "100%", inset: 0, color: "transparent" }}
          className="h-full w-full rounded-lg object-cover"
        />
      </AspectRatio>
    </div>
  )
}
