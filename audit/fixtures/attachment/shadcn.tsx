import { CircleAlertIcon, FileTextIcon, XIcon } from "lucide-react"

import {
  Attachment,
  AttachmentAction,
  AttachmentActions,
  AttachmentContent,
  AttachmentDescription,
  AttachmentGroup,
  AttachmentMedia,
  AttachmentTitle,
  AttachmentTrigger,
} from "@/components/ui/attachment"

const IMAGE =
  "data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='80' height='80'%3E%3Crect width='80' height='80' fill='%2394a3b8'/%3E%3C/svg%3E"

export default function AttachmentFixture() {
  return (
    <div className="flex w-[480px] flex-col items-start gap-3 p-6">
      <Attachment>
        <AttachmentMedia>
          <FileTextIcon />
        </AttachmentMedia>
        <AttachmentContent>
          <AttachmentTitle>quarterly-report.pdf</AttachmentTitle>
          <AttachmentDescription>PDF · 2.4 MB</AttachmentDescription>
        </AttachmentContent>
        <AttachmentActions>
          <AttachmentAction aria-label="Remove quarterly-report.pdf">
            <XIcon />
          </AttachmentAction>
        </AttachmentActions>
        <AttachmentTrigger
          aria-label="Open quarterly-report.pdf"
          data-audit-trigger=""
        />
      </Attachment>
      <Attachment state="idle" size="sm">
        <AttachmentMedia>
          <FileTextIcon />
        </AttachmentMedia>
        <AttachmentContent>
          <AttachmentTitle>selected-file.pdf</AttachmentTitle>
          <AttachmentDescription>Ready to upload</AttachmentDescription>
        </AttachmentContent>
      </Attachment>
      <Attachment state="uploading" size="xs">
        <AttachmentMedia>
          <FileTextIcon />
        </AttachmentMedia>
        <AttachmentContent>
          <AttachmentTitle>design-system.zip</AttachmentTitle>
          <AttachmentDescription>Uploading · 64%</AttachmentDescription>
        </AttachmentContent>
      </Attachment>
      <Attachment state="error" className="w-full">
        <AttachmentMedia>
          <CircleAlertIcon />
        </AttachmentMedia>
        <AttachmentContent>
          <AttachmentTitle>financials.xlsx</AttachmentTitle>
          <AttachmentDescription>
            Upload failed. File is too large.
          </AttachmentDescription>
        </AttachmentContent>
      </Attachment>
      <Attachment state="processing">
        <AttachmentMedia>
          <FileTextIcon />
        </AttachmentMedia>
        <AttachmentContent>
          <AttachmentTitle>market-research.pdf</AttachmentTitle>
          <AttachmentDescription>Processing document</AttachmentDescription>
        </AttachmentContent>
        <AttachmentTrigger
          render={<a href="#" aria-label="Open market-research.pdf" />}
        />
      </Attachment>
      <div className="flex gap-3">
        <Attachment orientation="vertical">
          <AttachmentMedia variant="image">
            <img src={IMAGE} alt="" />
          </AttachmentMedia>
          <AttachmentActions>
            <AttachmentAction variant="secondary" aria-label="Remove office.svg">
              <XIcon />
            </AttachmentAction>
          </AttachmentActions>
        </Attachment>
        <Attachment orientation="vertical" state="uploading">
          <AttachmentMedia variant="image">
            <img src={IMAGE} alt="" />
          </AttachmentMedia>
          <AttachmentContent>
            <AttachmentTitle>office.svg</AttachmentTitle>
            <AttachmentDescription>SVG · 1 KB</AttachmentDescription>
          </AttachmentContent>
        </Attachment>
      </div>
      <AttachmentGroup className="w-64">
        <Attachment>
          <AttachmentContent>
            <AttachmentTitle>notes.md</AttachmentTitle>
          </AttachmentContent>
        </Attachment>
        <Attachment>
          <AttachmentContent>
            <AttachmentTitle>roadmap.pdf</AttachmentTitle>
          </AttachmentContent>
        </Attachment>
      </AttachmentGroup>
    </div>
  )
}
