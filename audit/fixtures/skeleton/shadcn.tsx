import { Skeleton } from "@/components/ui/skeleton"

export default function SkeletonFixture() {
  return (
    <div id="skeleton-fixture" className="flex w-96 flex-col gap-8">
      <div className="flex flex-col gap-3">
        <div className="text-sm font-medium" data-audit-trigger="">Avatar</div>
        <div className="flex w-full items-center gap-4">
          <Skeleton className="size-10 shrink-0 rounded-full" data-audit-skeleton="" />
          <div className="grid gap-2">
            <Skeleton className="h-4 w-[150px]" data-audit-skeleton="" />
            <Skeleton className="h-4 w-[100px]" data-audit-skeleton="" />
          </div>
        </div>
      </div>
      <div className="flex flex-col gap-3">
        <div className="text-sm font-medium">Text</div>
        <div className="flex w-full flex-col gap-2">
          <Skeleton className="h-4 w-full" data-audit-skeleton="" />
          <Skeleton className="h-4 w-full" data-audit-skeleton="" />
          <Skeleton className="h-4 w-3/4" data-audit-skeleton="" />
        </div>
      </div>
      <div className="flex flex-col gap-3">
        <div className="text-sm font-medium">Form</div>
        <div className="flex w-full flex-col gap-7">
          <div className="flex flex-col gap-3">
            <Skeleton className="h-4 w-20" data-audit-skeleton="" />
            <Skeleton className="h-10 w-full" data-audit-skeleton="" />
          </div>
          <Skeleton className="h-9 w-24" data-audit-skeleton="" />
        </div>
      </div>
      <div className="flex flex-col gap-3">
        <div className="text-sm font-medium">Table</div>
        <div className="flex w-full flex-col gap-2">
          <div className="flex gap-4">
            <Skeleton className="h-4 flex-1" data-audit-skeleton="" />
            <Skeleton className="h-4 w-24" data-audit-skeleton="" />
            <Skeleton className="h-4 w-20" data-audit-skeleton="" />
          </div>
          <div className="flex gap-4">
            <Skeleton className="h-4 flex-1" data-audit-skeleton="" />
            <Skeleton className="h-4 w-24" data-audit-skeleton="" />
            <Skeleton className="h-4 w-20" data-audit-skeleton="" />
          </div>
        </div>
      </div>
    </div>
  )
}
