import { Progress, ProgressLabel, ProgressValue } from "@/components/ui/progress"

export default function ProgressFixture() {
  return (
    <div id="progress-fixture" className="flex w-96 flex-col gap-4">
      <Progress value={0} />
      <Progress value={25} />
      <Progress value={50} data-audit-trigger="" />
      <Progress value={75} />
      <Progress value={100} />
      <Progress value={56}>
        <ProgressLabel>Upload progress</ProgressLabel>
        <ProgressValue />
      </Progress>
    </div>
  )
}
