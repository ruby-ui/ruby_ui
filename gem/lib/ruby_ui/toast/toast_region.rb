# frozen_string_literal: true

module RubyUI
  # The toast viewport: a fixed, labelled live region that hosts the toasts.
  # Mount it once per page (layout). Mirrors shadcn's Base UI Toaster
  # (toast-viewport); positions other than bottom-right are a RubyUI extra.
  #
  # The region is a popover="manual" so each new toast can lift it into the
  # top layer, above a RubyUI Dialog/Sheet opened with showModal().
  class ToastRegion < Base
    SKELETON_VARIANTS = %i[default success error warning info loading].freeze
    POSITIONS = %i[top_left top_center top_right bottom_left bottom_center bottom_right].freeze
    SWIPE_DIRECTIONS = %i[up down left right].freeze
    REMOVED_KWARGS = %i[offset theme rich_colors dir].freeze

    def initialize(
      position: :bottom_right,
      expand: false,
      max: 3,
      duration: 5000,
      gap: 12,
      close_button: true,
      hotkey: %w[F6],
      swipe_directions: nil,
      flash: nil,
      **attrs
    )
      removed = attrs.keys & REMOVED_KWARGS
      unless removed.empty?
        raise ArgumentError, "RubyUI::ToastRegion: #{removed.map { |k| "#{k}:" }.join(", ")} " \
          "#{(removed.size == 1) ? "was" : "were"} removed (it never had an effect). See the Toast changelog."
      end

      @position = position.to_sym
      raise ArgumentError, "RubyUI::ToastRegion: unknown position #{position.inspect}" unless POSITIONS.include?(@position)

      @expand = expand
      @max = max
      @duration = duration
      @gap = gap
      @close_button = close_button
      @hotkey = hotkey
      @swipe_directions = swipe_directions && Array(swipe_directions).map(&:to_sym)
      @flash = flash
      super(**attrs)
    end

    def view_template(&block)
      div(**attrs) do
        div(id: "ruby-ui-toaster", class: "relative") do
          render_flash if @flash
          yield(self) if block
        end
        SKELETON_VARIANTS.each { |v| skeleton(v) }
        slot_template("actionTpl") { render RubyUI::ToastAction.new(label: "") }
        slot_template("cancelTpl") { render RubyUI::ToastCancel.new(label: "") }
        slot_template("closeTpl") { render RubyUI::ToastClose.new }
      end
    end

    private

    def render_flash
      @flash.each do |key, message|
        next if message.nil? || message.to_s.empty?
        variant = RubyUI::Toast.flash_variant(key)
        render RubyUI::ToastItem.new(variant: variant, id: "flash-#{key}") do
          render RubyUI::ToastIcon.new(variant: variant)
          div(class: "flex min-w-0 flex-1 flex-col gap-1") do
            render RubyUI::ToastTitle.new { message.to_s }
          end
          render RubyUI::ToastClose.new if @close_button
        end
      end
    end

    def skeleton(variant)
      template(data: {ruby_ui__toaster_target: "skeleton", variant: variant.to_s}) do
        render RubyUI::ToastItem.new(variant: variant) do
          render RubyUI::ToastIcon.new(variant: variant)
          div(class: "flex min-w-0 flex-1 flex-col gap-1") do
            render RubyUI::ToastTitle.new
            render RubyUI::ToastDescription.new
          end
          render RubyUI::ToastClose.new if @close_button
        end
      end
    end

    def slot_template(target_name, &)
      template(data: {ruby_ui__toaster_target: target_name}, &)
    end

    def default_attrs
      position = @position.to_s.tr("_", "-")
      data = {
        slot: "toast-viewport",
        controller: "ruby-ui--toaster",
        turbo_permanent: "",
        position: position,
        ruby_ui__toaster_position_value: position,
        ruby_ui__toaster_expand_value: @expand.to_s,
        ruby_ui__toaster_max_value: @max.to_s,
        ruby_ui__toaster_duration_value: @duration.to_s,
        ruby_ui__toaster_gap_value: @gap.to_s,
        ruby_ui__toaster_close_button_value: @close_button.to_s,
        ruby_ui__toaster_hotkey_value: Array(@hotkey).join("+")
      }
      # "none" disables swipe; leaving it unset derives it from the position.
      if @swipe_directions
        data[:ruby_ui__toaster_swipe_directions_value] = @swipe_directions.empty? ? "none" : @swipe_directions.join(" ")
      end
      {
        id: "ruby-ui-toaster-region",
        role: "region",
        aria_label: "Notifications",
        aria_live: "polite",
        aria_relevant: "additions text",
        aria_atomic: "false",
        tabindex: "-1",
        popover: "manual",
        data: data,
        class: region_classes
      }
    end

    # Base UI's toast-viewport classes (bottom-right), plus resets for the
    # popover UA styles (inset: 0, margin: auto, border, padding, background)
    # and the other five positions.
    def region_classes
      <<~CLASSES.tr("\n", " ").squeeze(" ").strip
        pointer-events-none fixed z-50 m-0 h-auto w-auto max-w-sm overflow-visible
        border-0 bg-transparent p-0 text-inherit outline-none
        inset-x-4 mx-auto sm:mx-0 sm:w-full
        data-[position^=bottom]:top-auto data-[position^=bottom]:bottom-4
        data-[position^=top]:top-4 data-[position^=top]:bottom-auto
        data-[position$=right]:sm:right-4 data-[position$=right]:sm:left-auto
        data-[position$=left]:sm:left-4 data-[position$=left]:sm:right-auto
        data-[position$=center]:sm:left-1/2 data-[position$=center]:sm:right-auto data-[position$=center]:sm:-translate-x-1/2
      CLASSES
    end
  end
end
