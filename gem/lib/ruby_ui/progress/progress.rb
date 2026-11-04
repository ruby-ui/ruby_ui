# frozen_string_literal: true

require "securerandom"

module RubyUI
  # A progress bar (role progressbar) mirroring shadcn's Base UI Progress:
  # the root holds optional ProgressLabel / ProgressValue children and always
  # renders the track and indicator after them.
  #
  # value: nil makes it indeterminate (no aria-valuenow). min:/max: set the
  # range; the indicator width and the default aria-valuetext use the
  # percentage of value between them. Pass aria: {valuetext: "..."} to
  # replace the text.
  class Progress < Base
    # data-slot plus the status attribute Base UI puts on every part
    # (data-progressing, data-complete or data-indeterminate).
    def self.state_data(context, slot)
      status = context[:ruby_ui_progress]&.dig(:status)
      {data: {slot: slot, **(status ? {status => true} : {})}}
    end

    def initialize(value: 0, min: 0, max: 100, **attrs)
      @min = min.to_f
      @max = max.to_f
      @value = finite(value)&.clamp(*[@min, @max].sort)
      # A given aria-valuetext replaces the default one (mix would join them).
      aria = attrs[:aria]
      if aria.is_a?(Hash) && aria.key?(:valuetext)
        @valuetext = aria[:valuetext]
        attrs = attrs.merge(aria: aria.except(:valuetext))
      end
      super(**attrs)
    end

    # Children are captured first so aria-labelledby only points at a
    # ProgressLabel that actually rendered.
    def view_template(&block)
      previous = context[:ruby_ui_progress]
      state = context[:ruby_ui_progress] = {
        status: status,
        value: @value,
        formatted_value: formatted_value,
        percentage: percentage,
        label_id: "progress-#{SecureRandom.hex(4)}-label"
      }
      body = block ? capture(&block) : ""
      root_attrs = state[:labelledby] ? mix({aria: {labelledby: state[:labelledby]}}, attrs) : attrs
      div(**root_attrs) do
        raw(safe(body))
        ProgressTrack { ProgressIndicator() }
      end
    ensure
      context[:ruby_ui_progress] = previous
    end

    private

    def finite(value)
      return nil if value.nil?
      number = value.to_f
      number.finite? ? number : nil
    end

    def status
      return :indeterminate if @value.nil?
      (@value == @max) ? :complete : :progressing
    end

    def percentage
      return nil if @value.nil?
      range = @max - @min
      return 0.0 unless range.positive?
      ((@value - @min) / range * 100).clamp(0.0, 100.0)
    end

    # What Base UI's default Intl percent format gives: "56%".
    def formatted_value
      percentage ? "#{percentage.round}%" : ""
    end

    def number(value)
      ((value % 1).zero? ? value.to_i : value).to_s
    end

    def default_attrs
      {
        role: "progressbar",
        aria: {
          valuemin: number(@min),
          valuemax: number(@max),
          valuenow: @value && number(@value),
          valuetext: @valuetext || (@value ? formatted_value : "indeterminate progress")
        },
        data: {slot: "progress"}.merge(status => true),
        class: "flex flex-wrap gap-3"
      }
    end
  end
end
