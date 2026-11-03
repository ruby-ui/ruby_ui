import { CircleAlertIcon, InfoIcon } from "lucide-react"

import {
  Alert,
  AlertAction,
  AlertDescription,
  AlertTitle,
} from "@/components/ui/alert"

export default function AlertFixture() {
  return (
    <div className="flex w-96 flex-col gap-4">
      <Alert>
        <InfoIcon />
        <AlertTitle>Heads up!</AlertTitle>
        <AlertDescription>You can add components to your app using the CLI.</AlertDescription>
        <AlertAction>
          <button type="button" data-audit-trigger="">Undo</button>
        </AlertAction>
      </Alert>
      <Alert variant="destructive">
        <CircleAlertIcon />
        <AlertTitle>Something went wrong</AlertTitle>
        <AlertDescription>Your session has expired. Please log in again.</AlertDescription>
      </Alert>
    </div>
  )
}
