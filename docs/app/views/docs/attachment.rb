# frozen_string_literal: true

class Views::Docs::Attachment < Views::Base
  IMAGE = "https://images.unsplash.com/photo-1497366754035-f200968a6e72?w=900&auto=format&fit=crop&q=80"

  def view_template
    component = "Attachment"

    div(class: "max-w-2xl mx-auto w-full py-10 space-y-10") do
      render Docs::Header.new(title: "Attachment", description: "Displays a file or image attached to a message or form, with upload states, actions, and an optional trigger.")

      Heading(level: 2) { "Usage" }

      render Docs::VisualCodeExample.new(title: "File", context: self) do
        <<~RUBY
          Attachment do
            AttachmentMedia { file_text_icon }
            AttachmentContent do
              AttachmentTitle { "quarterly-report.pdf" }
              AttachmentDescription { "PDF · 2.4 MB" }
            end
            AttachmentActions do
              AttachmentAction(aria_label: "Remove quarterly-report.pdf") { x_icon }
            end
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Content only", description: "Leave out AttachmentMedia for a compact chip.", context: self) do
        <<~RUBY
          div(class: "flex flex-wrap gap-2") do
            Attachment do
              AttachmentContent do
                AttachmentTitle { "notes.md" }
                AttachmentDescription { "Markdown · 4 KB" }
              end
            end
            Attachment do
              AttachmentContent { AttachmentTitle { "brand-guidelines.pdf" } }
              AttachmentActions do
                AttachmentAction(aria_label: "Remove brand-guidelines.pdf") { x_icon }
              end
            end
          end
        RUBY
      end

      Heading(level: 2) { "States" }

      render Docs::VisualCodeExample.new(title: "Upload states", description: "state: :idle shows a dashed border, :uploading and :processing make the title shimmer, :error tints the attachment.", context: self) do
        <<~RUBY
          div(class: "flex w-full flex-col gap-2") do
            Attachment(state: :idle, class: "w-full") do
              AttachmentMedia { clock_icon }
              AttachmentContent do
                AttachmentTitle { "selected-file.pdf" }
                AttachmentDescription { "Ready to upload" }
              end
              AttachmentActions do
                AttachmentAction(aria_label: "Remove selected-file.pdf") { x_icon }
              end
            end
            Attachment(state: :uploading, class: "w-full") do
              AttachmentMedia { spinner_icon }
              AttachmentContent do
                AttachmentTitle { "design-system.zip" }
                AttachmentDescription { "Uploading · 64%" }
              end
              AttachmentActions do
                AttachmentAction(aria_label: "Remove design-system.zip") { x_icon }
              end
            end
            Attachment(state: :processing, class: "w-full") do
              AttachmentMedia { file_text_icon }
              AttachmentContent do
                AttachmentTitle { "market-research.pdf" }
                AttachmentDescription { "Processing document" }
              end
              AttachmentActions do
                AttachmentAction(aria_label: "Remove market-research.pdf") { x_icon }
              end
            end
            Attachment(state: :error, class: "w-full") do
              AttachmentMedia { circle_alert_icon }
              AttachmentContent do
                AttachmentTitle { "financials.xlsx" }
                AttachmentDescription { "Upload failed. File is too large." }
              end
              AttachmentActions do
                AttachmentAction(aria_label: "Remove financials.xlsx") { x_icon }
              end
            end
            Attachment(state: :done, class: "w-full") do
              AttachmentMedia { file_text_icon }
              AttachmentContent do
                AttachmentTitle { "meeting-notes.pdf" }
                AttachmentDescription { "PDF · 1.1 MB" }
              end
              AttachmentActions do
                AttachmentAction(aria_label: "Remove meeting-notes.pdf") { x_icon }
              end
            end
          end
        RUBY
      end

      Heading(level: 2) { "Images" }

      render Docs::VisualCodeExample.new(title: "Image tiles", description: "orientation: :vertical with AttachmentMedia(variant: :image). The image is dimmed until the upload is done.", context: self) do
        <<~RUBY
          div(class: "flex flex-wrap gap-3") do
            Attachment(orientation: :vertical) do
              AttachmentMedia(variant: :image) { img(src: "#{IMAGE}", alt: "Office") }
              AttachmentActions do
                AttachmentAction(variant: :secondary, aria_label: "Remove office.jpg") { x_icon }
              end
            end
            Attachment(orientation: :vertical, state: :uploading) do
              AttachmentMedia(variant: :image) { img(src: "#{IMAGE}", alt: "Office") }
              AttachmentContent do
                AttachmentTitle { "office.jpg" }
                AttachmentDescription { "Uploading" }
              end
            end
            Attachment(orientation: :vertical) do
              AttachmentMedia(variant: :image) { img(src: "#{IMAGE}", alt: "Office") }
              AttachmentContent do
                AttachmentTitle { "office.jpg" }
                AttachmentDescription { "JPG · 1.8 MB" }
              end
            end
          end
        RUBY
      end

      Heading(level: 2) { "Sizes" }

      render Docs::VisualCodeExample.new(title: "Sizes", context: self) do
        <<~RUBY
          div(class: "flex flex-col items-start gap-3") do
            [:default, :sm, :xs].each do |size|
              Attachment(size: size) do
                AttachmentMedia { file_text_icon }
                AttachmentContent do
                  AttachmentTitle { "proposal.pdf" }
                  AttachmentDescription { "PDF · 640 KB" }
                end
                AttachmentActions do
                  AttachmentAction(aria_label: "Remove proposal.pdf") { x_icon }
                end
              end
            end
          end
        RUBY
      end

      Heading(level: 2) { "Group" }

      render Docs::VisualCodeExample.new(title: "Scrollable group", description: "AttachmentGroup scrolls sideways and snaps to each attachment, fading the edge that has more to show.", context: self) do
        <<~RUBY
          AttachmentGroup(class: "w-full max-w-md") do
            %w[roadmap.pdf budget.xlsx contract.docx kickoff.pptx notes.md].each do |name|
              Attachment do
                AttachmentMedia { file_text_icon }
                AttachmentContent do
                  AttachmentTitle { name }
                  AttachmentDescription { "Shared file" }
                end
                AttachmentActions do
                  AttachmentAction(aria_label: "Remove \#{name}") { x_icon }
                end
              end
            end
          end
        RUBY
      end

      Heading(level: 2) { "Triggers" }

      render Docs::VisualCodeExample.new(title: "Open in a new tab", description: "AttachmentTrigger stretches a link or button over the attachment; its actions stay clickable on top.", context: self) do
        <<~RUBY
          Attachment(class: "w-full") do
            AttachmentMedia { file_text_icon }
            AttachmentContent do
              AttachmentTitle { "contract-review.pdf" }
              AttachmentDescription { "PDF · 820 KB" }
            end
            AttachmentActions do
              AttachmentAction(aria_label: "Download contract-review.pdf") { download_icon }
            end
            AttachmentTrigger(as: :a, href: "#", target: "_blank", rel: "noreferrer", aria_label: "Open contract-review.pdf")
          end
        RUBY
      end

      render Docs::VisualCodeExample.new(title: "Open a dialog", description: "Wrap the trigger in DialogTrigger(class: \"contents\") so it still covers the attachment.", context: self) do
        <<~RUBY
          Dialog do
            Attachment(class: "w-full hover:bg-muted/50") do
              AttachmentMedia { file_text_icon }
              AttachmentContent do
                AttachmentTitle { "research-summary.pdf" }
                AttachmentDescription { "Open preview dialog" }
              end
              AttachmentActions do
                AttachmentAction(aria_label: "Copy link to research-summary.pdf") { copy_icon }
              end
              DialogTrigger(class: "contents") do
                AttachmentTrigger(aria_label: "Preview research-summary.pdf")
              end
            end
            DialogContent(class: "sm:max-w-md") do
              DialogHeader do
                DialogTitle { "research-summary.pdf" }
                DialogDescription { "Attachment triggers can open dialogs while actions remain independently reachable." }
              end
            end
          end
        RUBY
      end

      render Components::ComponentSetup::Tabs.new(component_name: component)

      # components
      render Docs::ComponentsTable.new(component_files(component))
    end
  end

  private

  # lucide icons, as lucide-react renders them (24x24, aria-hidden, no size
  # class): AttachmentMedia and AttachmentAction size them.
  def lucide_icon(**attrs, &)
    defaults = {
      xmlns: "http://www.w3.org/2000/svg",
      width: "24",
      height: "24",
      viewbox: "0 0 24 24",
      fill: "none",
      stroke: "currentColor",
      stroke_width: "2",
      stroke_linecap: "round",
      stroke_linejoin: "round",
      aria_hidden: "true"
    }
    svg(**defaults.merge(attrs).compact, &)
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

  def clock_icon
    lucide_icon do |s|
      s.circle(cx: "12", cy: "12", r: "10")
      s.path(d: "M12 6v6l4 2")
    end
  end

  def circle_alert_icon
    lucide_icon do |s|
      s.circle(cx: "12", cy: "12", r: "10")
      s.line(x1: "12", x2: "12", y1: "8", y2: "12")
      s.line(x1: "12", x2: "12.01", y1: "16", y2: "16")
    end
  end

  def download_icon
    lucide_icon do |s|
      s.path(d: "M12 15V3")
      s.path(d: "M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4")
      s.path(d: "m7 10 5 5 5-5")
    end
  end

  def copy_icon
    lucide_icon do |s|
      s.rect(width: "14", height: "14", x: "8", y: "8", rx: "2", ry: "2")
      s.path(d: "M4 16c-1.1 0-2-.9-2-2V4c0-1.1.9-2 2-2h10c1.1 0 2 .9 2 2")
    end
  end

  # shadcn's Spinner: a spinning loader-circle announced as "Loading".
  def spinner_icon
    lucide_icon(role: "status", aria_hidden: nil, aria_label: "Loading", class: "size-4 animate-spin", data: {slot: "spinner"}) do |s|
      s.path(d: "M21 12a9 9 0 1 1-6.219-8.56")
    end
  end
end
