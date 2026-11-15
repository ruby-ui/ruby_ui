# frozen_string_literal: true

module ShadcnAuditFixtures
  # RubyUI side of audit/fixtures/attachment (strings in content.yml).
  # Icons are lucide's file-text / x / circle-alert as lucide-react renders
  # them (24x24, aria-hidden, no size class), so both sides get the same SVG.
  # shadcn render={<a />} on AttachmentTrigger maps to RubyUI's as: :a.
  class Attachment < Phlex::HTML
    include RubyUI

    IMAGE = "data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='80' height='80'%3E%3Crect width='80' height='80' fill='%2394a3b8'/%3E%3C/svg%3E"

    def view_template
      div(class: "flex w-[480px] flex-col items-start gap-3 p-6") do
        Attachment do
          AttachmentMedia { file_text_icon }
          AttachmentContent do
            AttachmentTitle { "quarterly-report.pdf" }
            AttachmentDescription { "PDF · 2.4 MB" }
          end
          AttachmentActions do
            AttachmentAction(aria_label: "Remove quarterly-report.pdf") { x_icon }
          end
          AttachmentTrigger(aria_label: "Open quarterly-report.pdf", data: {audit_trigger: true})
        end
        Attachment(state: :idle, size: :sm) do
          AttachmentMedia { file_text_icon }
          AttachmentContent do
            AttachmentTitle { "selected-file.pdf" }
            AttachmentDescription { "Ready to upload" }
          end
        end
        Attachment(state: :uploading, size: :xs) do
          AttachmentMedia { file_text_icon }
          AttachmentContent do
            AttachmentTitle { "design-system.zip" }
            AttachmentDescription { "Uploading · 64%" }
          end
        end
        Attachment(state: :error, class: "w-full") do
          AttachmentMedia { circle_alert_icon }
          AttachmentContent do
            AttachmentTitle { "financials.xlsx" }
            AttachmentDescription { "Upload failed. File is too large." }
          end
        end
        Attachment(state: :processing) do
          AttachmentMedia { file_text_icon }
          AttachmentContent do
            AttachmentTitle { "market-research.pdf" }
            AttachmentDescription { "Processing document" }
          end
          AttachmentTrigger(as: :a, href: "#", aria_label: "Open market-research.pdf")
        end
        div(class: "flex gap-3") do
          Attachment(orientation: :vertical) do
            AttachmentMedia(variant: :image) { img(src: IMAGE, alt: "") }
            AttachmentActions do
              AttachmentAction(variant: :secondary, aria_label: "Remove office.svg") { x_icon }
            end
          end
          Attachment(orientation: :vertical, state: :uploading) do
            AttachmentMedia(variant: :image) { img(src: IMAGE, alt: "") }
            AttachmentContent do
              AttachmentTitle { "office.svg" }
              AttachmentDescription { "SVG · 1 KB" }
            end
          end
        end
        AttachmentGroup(class: "w-64") do
          Attachment do
            AttachmentContent { AttachmentTitle { "notes.md" } }
          end
          Attachment do
            AttachmentContent { AttachmentTitle { "roadmap.pdf" } }
          end
        end
      end
    end

    private

    def lucide_icon(&)
      svg(xmlns: "http://www.w3.org/2000/svg", width: "24", height: "24", viewbox: "0 0 24 24", fill: "none",
        stroke: "currentColor", stroke_width: "2", stroke_linecap: "round", stroke_linejoin: "round", aria_hidden: "true", &)
    end

    def file_text_icon
      lucide_icon do |s|
        s.path(d: "M6 22a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h8a2.4 2.4 0 0 1 1.704.706l3.588 3.588A2.4 2.4 0 0 1 20 8v12a2 2 0 0 1-2 2z")
        s.path(d: "M14 2v5a1 1 0 0 0 1 1h5")
        s.path(d: "M10 9H8")
        s.path(d: "M16 13H8")
        s.path(d: "M16 17H8")
      end
    end

    def x_icon
      lucide_icon do |s|
        s.path(d: "M18 6 6 18")
        s.path(d: "m6 6 12 12")
      end
    end

    def circle_alert_icon
      lucide_icon do |s|
        s.circle(cx: "12", cy: "12", r: "10")
        s.line(x1: "12", x2: "12", y1: "8", y2: "12")
        s.line(x1: "12", x2: "12.01", y1: "16", y2: "16")
      end
    end
  end
end
