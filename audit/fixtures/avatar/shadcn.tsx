import {
  Avatar,
  AvatarBadge,
  AvatarFallback,
  AvatarGroup,
  AvatarGroupCount,
  AvatarImage,
} from "@/components/ui/avatar"

const IMAGE_SRC =
  "data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='64' height='64'%3E%3Crect width='64' height='64' fill='%233b82f6'/%3E%3C/svg%3E"
const BROKEN_SRC = "data:image/png;base64,AAAA"
const LOGO_SRC =
  "data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='128' height='32' viewBox='0 0 128 32'%3E%3Crect width='43' height='32' fill='%23ef4444'/%3E%3Crect x='43' width='42' height='32' fill='%233b82f6'/%3E%3Crect x='85' width='43' height='32' fill='%2322c55e'/%3E%3C/svg%3E"

export default function AvatarFixture() {
  return (
    <div className="flex items-center gap-4" data-audit-trigger="">
      <Avatar>
        <AvatarImage src={IMAGE_SRC} alt="@shadcn" />
        <AvatarFallback>CN</AvatarFallback>
      </Avatar>
      <Avatar>
        <AvatarFallback>JD</AvatarFallback>
      </Avatar>
      <Avatar>
        <AvatarImage src={BROKEN_SRC} alt="@broken" />
        <AvatarFallback>ER</AvatarFallback>
      </Avatar>
      <Avatar size="sm">
        <AvatarFallback>SM</AvatarFallback>
      </Avatar>
      <Avatar size="lg">
        <AvatarFallback>LG</AvatarFallback>
      </Avatar>
      <Avatar>
        <AvatarFallback>BG</AvatarFallback>
        <AvatarBadge />
      </Avatar>
      <AvatarGroup>
        <Avatar>
          <AvatarFallback>AB</AvatarFallback>
        </Avatar>
        <Avatar>
          <AvatarFallback>CD</AvatarFallback>
        </Avatar>
        <AvatarGroupCount>+2</AvatarGroupCount>
      </AvatarGroup>
      <Avatar>
        <AvatarImage src={LOGO_SRC} alt="@logo" className="object-contain" />
        <AvatarFallback>LO</AvatarFallback>
      </Avatar>
    </div>
  )
}
