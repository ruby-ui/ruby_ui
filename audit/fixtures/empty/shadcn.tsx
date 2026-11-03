import { FolderIcon } from "lucide-react"

import {
  Empty,
  EmptyContent,
  EmptyDescription,
  EmptyHeader,
  EmptyMedia,
  EmptyTitle,
} from "@/components/ui/empty"

export default function EmptyFixture() {
  return (
    <div className="flex w-[32rem]">
      <Empty>
        <EmptyHeader>
          <EmptyMedia variant="icon">
            <FolderIcon />
          </EmptyMedia>
          <EmptyTitle>No projects yet</EmptyTitle>
          <EmptyDescription>
            {"You haven't created any projects yet. "}
            <a href="#">Learn more</a>
          </EmptyDescription>
        </EmptyHeader>
        <EmptyContent>
          <button type="button" data-audit-trigger="">Create project</button>
        </EmptyContent>
      </Empty>
    </div>
  )
}
