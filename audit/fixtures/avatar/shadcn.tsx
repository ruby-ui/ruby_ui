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
    </div>
  )
}
