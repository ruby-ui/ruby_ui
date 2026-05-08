# frozen_string_literal: true

require "set"

module TailwindMerge
  module Config
    include Validators

    THEME_KEYS = [
      "color",
      "font",
      "text",
      "font-weight",
      "tracking",
      "leading",
      "breakpoint",
      "container",
      "spacing",
      "radius",
      "shadow",
      "inset-shadow",
      "text-shadow",
      "drop-shadow",
      "blur",
      "perspective",
      "aspect",
      "ease",
      "animate",
    ].freeze
    THEME_KEYS.each do |key|
      const_set("THEME_#{key.upcase.tr("-", "_")}", ->(config) {
                                                      config[:theme].fetch(key, nil)
                                                    })
    end

    VALID_THEME_IDS = Set.new(THEME_KEYS.map { |theme_key| const_get("THEME_#{theme_key.upcase.tr("-", "_")}").object_id }).freeze

    SCALE_BREAK = -> { ["auto", "avoid", "all", "avoid-page", "page", "left", "right", "column"] }
    SCALE_POSITION = -> {
      [
        "center",
        "top",
        "bottom",
        "left",
        "right",
        "top-left",
        # Deprecated since Tailwind CSS v4.1.0, see https://github.com/tailwindlabs/tailwindcss/pull/17378
        "left-top",
        "top-right",
        # Deprecated since Tailwind CSS v4.1.0, see https://github.com/tailwindlabs/tailwindcss/pull/17378
        "right-top",
        "bottom-right",
        # Deprecated since Tailwind CSS v4.1.0, see https://github.com/tailwindlabs/tailwindcss/pull/17378
        "right-bottom",
        "bottom-left",
        # Deprecated since Tailwind CSS v4.1.0, see https://github.com/tailwindlabs/tailwindcss/pull/17378
        "left-bottom",
      ]
    }
    SCALE_POSITION_WITH_ARBITRARY = -> { [*SCALE_POSITION.call, IS_ARBITRARY_VARIABLE, IS_ARBITRARY_VALUE] }
    SCALE_OVERFLOW = -> { ["auto", "hidden", "clip", "visible", "scroll"] }
    SCALE_OVERSCROLL = -> { ["auto", "contain", "none"] }
    SCALE_UNAMBIGUOUS_SPACING = -> { [IS_ARBITRARY_VARIABLE, IS_ARBITRARY_VALUE, THEME_SPACING] }
    SCALE_INSET = ->(_config) {
      [
        IS_FRACTION,
        "full",
        "auto",
        *SCALE_UNAMBIGUOUS_SPACING.call,
      ]
    }

    SCALE_GRID_TEMPLATE_COLS_ROWS = -> { [IS_INTEGER, "none", "subgrid", IS_ARBITRARY_VARIABLE, IS_ARBITRARY_VALUE] }
    SCALE_GRID_COL_ROW_START_AND_END = -> {
      [
        "auto",
        { "span" => ["full", IS_INTEGER, IS_ARBITRARY_VARIABLE, IS_ARBITRARY_VALUE] },
        IS_INTEGER,
        IS_ARBITRARY_VARIABLE,
        IS_ARBITRARY_VALUE,
      ]
    }
    SCALE_GRID_COL_ROW_START_OR_END = -> { [IS_INTEGER, "auto", IS_ARBITRARY_VARIABLE, IS_ARBITRARY_VALUE] }
    SCALE_GRID_AUTO_COLS_ROWS = -> { ["auto", "min", "max", "fr", IS_ARBITRARY_VARIABLE, IS_ARBITRARY_VALUE] }
    SCALE_ALIGN_PRIMARY_AXIS = -> { ["start", "end", "center", "between", "around", "evenly", "stretch", "baseline", "center-safe", "end-safe"] }
    SCALE_ALIGN_SECONDARY_AXIS = -> { ["start", "end", "center", "stretch", "center-safe", "end-safe"] }
    SCALE_MARGIN = -> { ["auto", *SCALE_UNAMBIGUOUS_SPACING.call] }
    SCALE_SIZING = -> {
      [
        IS_FRACTION,
        "auto",
        "full",
        "dvw",
        "dvh",
        "lvw",
        "lvh",
        "svw",
        "svh",
        "min",
        "max",
        "fit",
        *SCALE_UNAMBIGUOUS_SPACING.call,
      ]
    }
    SCALE_SIZING_INLINE = -> {
      [
        IS_FRACTION,
        "screen",
        "full",
        "dvw",
        "lvw",
        "svw",
        "min",
        "max",
        "fit",
        *SCALE_UNAMBIGUOUS_SPACING.call,
      ]
    }
    SCALE_SIZING_BLOCK = -> {
      [
        IS_FRACTION,
        "screen",
        "full",
        "lh",
        "dvh",
        "lvh",
        "svh",
        "min",
        "max",
        "fit",
        *SCALE_UNAMBIGUOUS_SPACING.call,
      ]
    }
    SCALE_COLOR = -> { [THEME_COLOR, IS_ARBITRARY_VARIABLE, IS_ARBITRARY_VALUE] }
    SCALE_BG_POSITION = -> { [*SCALE_POSITION.call, IS_ARBITRARY_VARIABLE_POSITION, IS_ARBITRARY_POSITION, "position" => [IS_ARBITRARY_VARIABLE, IS_ARBITRARY_VALUE]] }
    SCALE_BG_REPEAT = -> { ["no-repeat", "repeat" => ["", "x", "y", "space", "round"]] }
    SCALE_BG_SIZE = -> { ["auto", "cover", "contain", IS_ARBITRARY_VARIABLE_SIZE, IS_ARBITRARY_SIZE, "size" => [IS_ARBITRARY_VARIABLE, IS_ARBITRARY_VALUE]] }
    SCALE_GRADIENT_STOP_POSITION = -> { [IS_PERCENT, IS_ARBITRARY_VARIABLE_LENGTH, IS_ARBITRARY_LENGTH] }
    SCALE_RADIUS = -> {
      [
        # Deprecated since Tailwind CSS v4.0.0
        "",
        "none",
        "full",
        THEME_RADIUS,
        IS_ARBITRARY_VARIABLE,
        IS_ARBITRARY_VALUE,
      ]
    }
    SCALE_BORDER_WIDTH = -> { ["", IS_NUMBER, IS_ARBITRARY_VARIABLE_LENGTH, IS_ARBITRARY_LENGTH] }
    SCALE_LINE_STYLE = -> { ["solid", "dashed", "dotted", "double"] }
    SCALE_BLEND_MODE = -> {
      [
        "normal",
        "multiply",
        "screen",
        "overlay",
        "darken",
        "lighten",
        "color-dodge",
        "color-burn",
        "hard-light",
        "soft-light",
        "difference",
        "exclusion",
        "hue",
        "saturation",
        "color",
        "luminosity",
      ]
    }
    SCALE_MASK_IMAGE_POSITION = -> { [IS_NUMBER, IS_PERCENT, IS_ARBITRARY_VARIABLE_POSITION, IS_ARBITRARY_POSITION] }
    SCALE_BLUR = -> {
      [
        "",
        "none",
        THEME_BLUR,
        IS_ARBITRARY_VARIABLE,
        IS_ARBITRARY_VALUE,
      ]
    }

    SCALE_ROTATE = -> { ["none", IS_NUMBER, IS_ARBITRARY_VARIABLE, IS_ARBITRARY_VALUE] }
    SCALE_SCALE = -> { ["none", IS_NUMBER, IS_ARBITRARY_VARIABLE, IS_ARBITRARY_VALUE] }
    SCALE_SKEW = -> { [IS_NUMBER, IS_ARBITRARY_VARIABLE, IS_ARBITRARY_VALUE] }
    SCALE_TRANSLATE = -> { [IS_FRACTION, "full", *SCALE_UNAMBIGUOUS_SPACING.call] }

    DEFAULTS = {
      cache_size: 500,
      prefix: nil,
      ignore_empty_cache: true,
      theme: {
        "animate" => ["spin", "ping", "pulse", "bounce"],
        "aspect" => ["video"],
        "blur" => [IS_TSHIRT_SIZE],
        "breakpoint" => [IS_TSHIRT_SIZE],
        "color" => [IS_ANY],
        "container" => [IS_TSHIRT_SIZE],
        "drop-shadow" => [IS_TSHIRT_SIZE],
        "ease" => ["in", "out", "in-out"],
        "font" => [IS_ANY_NON_ARBITRARY],
        "font-weight" => [
          "thin",
          "extralight",
          "light",
          "normal",
          "medium",
          "semibold",
          "bold",
          "extrabold",
          "black",
        ],
        "inset-shadow" => [IS_TSHIRT_SIZE],
        "leading" => ["none", "tight", "snug", "normal", "relaxed", "loose"],
        "perspective" => ["dramatic", "near", "normal", "midrange", "distant", "none"],
        "radius" => [IS_TSHIRT_SIZE],
        "shadow" => [IS_TSHIRT_SIZE],
        "spacing" => ["px", IS_NUMBER],
        "text" => [IS_TSHIRT_SIZE],
        "text-shadow" => [IS_TSHIRT_SIZE],
        "tracking" => ["tighter", "tight", "normal", "wide", "wider", "widest"],
      },
      class_groups: {
        ##########
        # Layout
        ##########

        ##
        # Aspect Ratio
        # @see https://tailwindcss.com/docs/aspect-ratio
        ##
        "aspect" => [
          {
            "aspect" => [
              "auto",
              "square",
              IS_FRACTION,
              IS_ARBITRARY_VALUE,
              IS_ARBITRARY_VARIABLE,
              THEME_ASPECT,
            ],
          },
        ],
        ##
        # Container
        # @see https://tailwindcss.com/docs/container
        # @deprecated since Tailwind CSS v4.0.0
        ##
        "container" => ["container"],
        ##
        # Columns
        # @see https://tailwindcss.com/docs/columns
        ##
        "columns" => [{ "columns" => [IS_TSHIRT_SIZE] }],
        ##
        # Break After
        # @see https://tailwindcss.com/docs/break-after
        ##
        "break-after" => [{ "break-after" => SCALE_BREAK.call }],
        ##
        # Break Before
        # @see https://tailwindcss.com/docs/break-before
        ##
        "break-before" => [{ "break-before" => SCALE_BREAK.call }],
        ##
        # Break Inside
        # @see https://tailwindcss.com/docs/break-inside
        ##
        "break-inside" => [{ "break-inside" => ["auto", "avoid", "avoid-page", "avoid-column"] }],
        ##
        # Box Decoration Break
        # @see https://tailwindcss.com/docs/box-decoration-break
        ##
        "box-decoration" => [{ "box-decoration" => ["slice", "clone"] }],
        ##
        # Box Sizing
        # @see https://tailwindcss.com/docs/box-sizing
        ##
        "box" => [{ "box" => ["border", "content"] }],
        ##
        # Display
        # @see https://tailwindcss.com/docs/display
        ##
        "display" => [
          "block",
          "inline-block",
          "inline",
          "flex",
          "inline-flex",
          "table",
          "inline-table",
          "table-caption",
          "table-cell",
          "table-column",
          "table-column-group",
          "table-footer-group",
          "table-header-group",
          "table-row-group",
          "table-row",
          "flow-root",
          "grid",
          "inline-grid",
          "contents",
          "list-item",
          "hidden",
        ],
        ##
        # Screen Reader Only
        # @see https://tailwindcss.com/docs/display#screen-reader-only
        ##
        "sr" => ["sr-only", "not-sr-only"],
        ##
        # Floats
        # @see https://tailwindcss.com/docs/float
        ##
        "float" => [{ "float" => ["right", "left", "none", "start", "end"] }],
        ##
        # Clear
        # @see https://tailwindcss.com/docs/clear
        ##
        "clear" => [{ "clear" => ["left", "right", "both", "none", "start", "end"] }],
        ##
        # Isolation
        # @see https://tailwindcss.com/docs/isolation
        ##
        "isolation" => ["isolate", "isolation-auto"],
        ##
        # Object Fit
        # @see https://tailwindcss.com/docs/object-fit
        ##
        "object-fit" => [{ "object" => ["contain", "cover", "fill", "none", "scale-down"] }],
        ##
        # Object Position
        # @see https://tailwindcss.com/docs/object-position
        ##
        "object-position" => [{ "object" => SCALE_POSITION_WITH_ARBITRARY.call }],
        ##
        # Overflow
        # @see https://tailwindcss.com/docs/overflow
        ##
        "overflow" => [{ "overflow" => SCALE_OVERFLOW.call }],
        ##
        # Overflow X
        # @see https://tailwindcss.com/docs/overflow
        ##
        "overflow-x" => [{ "overflow-x" => SCALE_OVERFLOW.call }],
        ##
        # Overflow Y
        # @see https://tailwindcss.com/docs/overflow
        ##
        "overflow-y" => [{ "overflow-y" => SCALE_OVERSCROLL.call }],
        ##
        # Overscroll Behavior
        # @see https://tailwindcss.com/docs/overscroll-behavior
        ##
        "overscroll" => [{ "overscroll" => SCALE_OVERSCROLL.call }],
        ##
        # Overscroll Behavior X
        # @see https://tailwindcss.com/docs/overscroll-behavior
        ##
        "overscroll-x" => [{ "overscroll-x" => SCALE_OVERSCROLL.call }],
        ##
        # Overscroll Behavior Y
        # @see https://tailwindcss.com/docs/overscroll-behavior
        ##
        "overscroll-y" => [{ "overscroll-y" => SCALE_OVERSCROLL.call }],
        ##
        # Position
        # @see https://tailwindcss.com/docs/position
        ##
        "position" => ["static", "fixed", "absolute", "relative", "sticky"],
        ##
        # Top / Right / Bottom / Left
        # @see https://tailwindcss.com/docs/top-right-bottom-left
        ##
        "inset" => [{ "inset" => [SCALE_INSET] }],
        ##
        # Right / Left
        # @see https://tailwindcss.com/docs/top-right-bottom-left
        ##
        "inset-x" => [{ "inset-x" => [SCALE_INSET] }],
        ##
        # Top / Bottom
        # @see https://tailwindcss.com/docs/top-right-bottom-left
        ##
        "inset-y" => [{ "inset-y" => [SCALE_INSET] }],
        #
        # Start
        # @see https://tailwindcss.com/docs/top-right-bottom-left
        #
        "start" => [{ "inset-s" => [SCALE_INSET], "start" => [SCALE_INSET] }],
        #
        # End
        # @see https://tailwindcss.com/docs/top-right-bottom-left
        #
        "end" => [{ "inset-e" => [SCALE_INSET], "end" => [SCALE_INSET] }],
        #
        # Inset Block Start
        # @see https://tailwindcss.com/docs/top-right-bottom-left
        #
        "inset-bs" => [{ "inset-bs" => [SCALE_INSET] }],
        #
        # Inset Block End
        # @see https://tailwindcss.com/docs/top-right-bottom-left
        #
        "inset-be" => [{ "inset-be" => [SCALE_INSET] }],
        ##
        # Top
        # @see https://tailwindcss.com/docs/top-right-bottom-left
        ##
        "top" => [{ "top" => [SCALE_INSET] }],
        ##
        # Right
        # @see https://tailwindcss.com/docs/top-right-bottom-left
        ##
        "right" => [{ "right" => [SCALE_INSET] }],
        ##
        # Bottom
        # @see https://tailwindcss.com/docs/top-right-bottom-left
        ##
        "bottom" => [{ "bottom" => [SCALE_INSET] }],
        ##
        # Left
        # @see https://tailwindcss.com/docs/top-right-bottom-left
        ##
        "left" => [{ "left" => [SCALE_INSET] }],
        ##
        # Visibility
        # @see https://tailwindcss.com/docs/visibility
        ##
        "visibility" => ["visible", "invisible", "collapse"],
        ##
        # Z-Index
        # @see https://tailwindcss.com/docs/z-index
        ##
        "z" => [{ "z" => [IS_INTEGER, "auto", IS_ARBITRARY_VARIABLE, IS_ARBITRARY_VALUE] }],

        ##########
        # Flexbox and Grid
        ##########

        # Flex Basis
        # @see https://tailwindcss.com/docs/flex-basis
        ##
        "basis" => [{
          "basis" => [
            IS_FRACTION,
            "full",
            "auto",
            THEME_CONTAINER,
            *SCALE_UNAMBIGUOUS_SPACING.call,
          ],
        }],
        ##
        # Flex Direction
        # @see https://tailwindcss.com/docs/flex-direction
        ##
        "flex-direction" => [{ "flex" => ["row", "row-reverse", "col", "col-reverse"] }],
        ##
        # Flex Wrap
        # @see https://tailwindcss.com/docs/flex-wrap
        ##
        "flex-wrap" => [{ "flex" => ["nowrap", "wrap", "wrap-reverse"] }],
        ##
        # Flex
        # @see https://tailwindcss.com/docs/flex
        ##
        "flex" => [{ "flex" => [IS_NUMBER, IS_FRACTION, "auto", "initial", "none", Validators::IS_ARBITRARY_VALUE] }],
        ##
        # Flex Grow
        # @see https://tailwindcss.com/docs/flex-grow
        ##
        "grow" => [{ "grow" => ["", IS_NUMBER, IS_ARBITRARY_VARIABLE, IS_ARBITRARY_VALUE] }],
        ##
        # Flex Shrink
        # @see https://tailwindcss.com/docs/flex-shrink
        ##
        "shrink" => [{ "shrink" => ["", IS_NUMBER, IS_ARBITRARY_VARIABLE, IS_ARBITRARY_VALUE] }],
        ##
        # Order
        # @see https://tailwindcss.com/docs/order
        ##
        "order" => [{
          "order" => [
            IS_INTEGER,
            "first",
            "last",
            "none",
            IS_ARBITRARY_VARIABLE,
            IS_ARBITRARY_VALUE,
          ],
        }],
        ##
        # Grid Template Columns
        # @see https://tailwindcss.com/docs/grid-template-columns
        ##
        "grid-cols" => [{ "grid-cols" => SCALE_GRID_TEMPLATE_COLS_ROWS.call }],
        ##
        # Grid Column Start / End
        # @see https://tailwindcss.com/docs/grid-column
        ##
        "col-start-end" => [{ "col" => SCALE_GRID_COL_ROW_START_AND_END.call }],

        ##
        # Grid Column Start
        # @see https://tailwindcss.com/docs/grid-column
        ##
        "col-start" => [{ "col-start" => SCALE_GRID_COL_ROW_START_OR_END.call }],
        ##
        # Grid Column End
        # @see https://tailwindcss.com/docs/grid-column
        ##
        "col-end" => [{ "col-end" => SCALE_GRID_COL_ROW_START_OR_END.call }],
        ##
        # Grid Template Rows
        # @see https://tailwindcss.com/docs/grid-template-rows
        ##
        "grid-rows" => [{ "grid-rows" => SCALE_GRID_TEMPLATE_COLS_ROWS.call }],
        ##
        # Grid Row Start / End
        # @see https://tailwindcss.com/docs/grid-row
        ##
        "row-start-end" => [{ "row" => SCALE_GRID_COL_ROW_START_AND_END.call }],
        ##
        # Grid Row Start
        # @see https://tailwindcss.com/docs/grid-row
        ##
        "row-start" => [{ "row-start" => SCALE_GRID_COL_ROW_START_OR_END.call }],
        ##
        # Grid Row End
        # @see https://tailwindcss.com/docs/grid-row
        ##
        "row-end" => [{ "row-end" => SCALE_GRID_COL_ROW_START_OR_END.call }],
        ##
        # Grid Auto Flow
        # @see https://tailwindcss.com/docs/grid-auto-flow
        ##
        "grid-flow" => [{ "grid-flow" => ["row", "col", "dense", "row-dense", "col-dense"] }],
        ##
        # Grid Auto Columns
        # @see https://tailwindcss.com/docs/grid-auto-columns
        ##
        "auto-cols" => [{ "auto-cols" => SCALE_GRID_AUTO_COLS_ROWS.call }],
        ##
        # Grid Auto Rows
        # @see https://tailwindcss.com/docs/grid-auto-rows
        ##
        "auto-rows" => [{ "auto-rows" => SCALE_GRID_AUTO_COLS_ROWS.call }],
        ##
        # Gap
        # @see https://tailwindcss.com/docs/gap
        ##
        "gap" => [{ "gap" => SCALE_UNAMBIGUOUS_SPACING.call }],
        ##
        # Gap X
        # @see https://tailwindcss.com/docs/gap
        ##
        "gap-x" => [{ "gap-x" => SCALE_UNAMBIGUOUS_SPACING.call }],
        ##
        # Gap Y
        # @see https://tailwindcss.com/docs/gap
        ##
        "gap-y" => [{ "gap-y" => SCALE_UNAMBIGUOUS_SPACING.call }],
        ##
        # Justify Content
        # @see https://tailwindcss.com/docs/justify-content
        ##
        "justify-content" => [{ "justify" => [*SCALE_ALIGN_PRIMARY_AXIS.call, "normal"] }],
        ##
        # Justify Items
        # @see https://tailwindcss.com/docs/justify-items
        ##
        "justify-items" => [{ "justify-items" => [*SCALE_ALIGN_SECONDARY_AXIS.call, "normal"] }],
        ##
        # Justify Self
        # @see https://tailwindcss.com/docs/justify-self
        ##
        "justify-self" => [{ "justify-self" => ["auto", *SCALE_ALIGN_SECONDARY_AXIS.call] }],
        ##
        # Align Content
        # @see https://tailwindcss.com/docs/align-content
        ##
        "align-content" => [{ "content" => ["normal", *SCALE_ALIGN_PRIMARY_AXIS.call] }],
        ##
        # Align Items
        # @see https://tailwindcss.com/docs/align-items
        ##
        "align-items" => [{ "items" => [*SCALE_ALIGN_SECONDARY_AXIS.call, "baseline" => ["", "last"]] }],
        ##
        # Align Self
        # @see https://tailwindcss.com/docs/align-self
        ##
        "align-self" => [{ "self" => ["auto", *SCALE_ALIGN_SECONDARY_AXIS.call, { "baseline" => ["", "last"] }] }],
        ##
        # Place Content
        # @see https://tailwindcss.com/docs/place-content
        ##
        "place-content" => [{ "place-content" => SCALE_ALIGN_PRIMARY_AXIS.call }],
        ##
        # Place Items
        # @see https://tailwindcss.com/docs/place-items
        ##
        "place-items" => [{ "place-items" => [*SCALE_ALIGN_SECONDARY_AXIS.call, "baseline"] }],
        ##
        # Place Self
        # @see https://tailwindcss.com/docs/place-self
        ##
        "place-self" => [{ "place-self" => ["auto", *SCALE_ALIGN_SECONDARY_AXIS.call] }],
        # Spacing
        ##
        # Padding
        # @see https://tailwindcss.com/docs/padding
        ##
        "p" => [{ "p" => SCALE_UNAMBIGUOUS_SPACING.call }],
        ##
        # Padding X
        # @see https://tailwindcss.com/docs/padding
        ##
        "px" => [{ "px" => SCALE_UNAMBIGUOUS_SPACING.call }],
        ##
        # Padding Y
        # @see https://tailwindcss.com/docs/padding
        ##
        "py" => [{ "py" => SCALE_UNAMBIGUOUS_SPACING.call }],
        #
        # Padding Start
        # @see https://tailwindcss.com/docs/padding
        #
        "ps" => [{ "ps" => SCALE_UNAMBIGUOUS_SPACING.call }],
        #
        # Padding End
        # @see https://tailwindcss.com/docs/padding
        #
        "pe" => [{ "pe" => SCALE_UNAMBIGUOUS_SPACING.call }],
        #
        # Padding Block Start
        # @see https://tailwindcss.com/docs/padding
        #
        "pbs" => [{ "pbs" => SCALE_UNAMBIGUOUS_SPACING.call }],
        #
        # Padding Block End
        # @see https://tailwindcss.com/docs/padding
        #
        "pbe" => [{ "pbe" => SCALE_UNAMBIGUOUS_SPACING.call }],
        ##
        # Padding Top
        # @see https://tailwindcss.com/docs/padding
        ##
        "pt" => [{ "pt" => SCALE_UNAMBIGUOUS_SPACING.call }],
        ##
        # Padding Right
        # @see https://tailwindcss.com/docs/padding
        ##
        "pr" => [{ "pr" => SCALE_UNAMBIGUOUS_SPACING.call }],
        ##
        # Padding Bottom
        # @see https://tailwindcss.com/docs/padding
        ##
        "pb" => [{ "pb" => SCALE_UNAMBIGUOUS_SPACING.call }],
        ##
        # Padding Left
        # @see https://tailwindcss.com/docs/padding
        ##
        "pl" => [{ "pl" => SCALE_UNAMBIGUOUS_SPACING.call }],
        ##
        # Margin
        # @see https://tailwindcss.com/docs/margin
        ##
        "m" => [{ "m" => SCALE_MARGIN.call }],
        ##
        # Margin X
        # @see https://tailwindcss.com/docs/margin
        ##
        "mx" => [{ "mx" => SCALE_MARGIN.call  }],
        ##
        # Margin Y
        # @see https://tailwindcss.com/docs/margin
        ##
        "my" => [{ "my" => SCALE_MARGIN.call  }],
        #
        # Margin Start
        # @see https://tailwindcss.com/docs/margin
        #
        "ms" => [{ "ms" => SCALE_MARGIN.call  }],
        #
        # Margin End
        # @see https://tailwindcss.com/docs/margin
        #
        "me" => [{ "me" => SCALE_MARGIN.call  }],
        #
        # Margin Block Start
        # @see https://tailwindcss.com/docs/margin
        #
        "mbs" => [{ "mbs" => SCALE_MARGIN.call }],
        #
        # Margin Block End
        # @see https://tailwindcss.com/docs/margin
        #
        "mbe" => [{ "mbe" => SCALE_MARGIN.call }],
        ##
        # Margin Top
        # @see https://tailwindcss.com/docs/margin
        ##
        "mt" => [{ "mt" => SCALE_MARGIN.call }],
        ##
        # Margin Right
        # @see https://tailwindcss.com/docs/margin
        ##
        "mr" => [{ "mr" => SCALE_MARGIN.call  }],
        ##
        # Margin Bottom
        # @see https://tailwindcss.com/docs/margin
        ##
        "mb" => [{ "mb" => SCALE_MARGIN.call  }],
        ##
        # Margin Left
        # @see https://tailwindcss.com/docs/margin
        ##
        "ml" => [{ "ml" => SCALE_MARGIN.call  }],
        ##
        # Space Between X
        # @see https://tailwindcss.com/docs/margin#adding-space-between-children
        ##
        "space-x" => [{ "space-x" => SCALE_UNAMBIGUOUS_SPACING.call }],
        ##
        # Space Between X Reverse
        # @see https://tailwindcss.com/docs/margin#adding-space-between-children
        ##
        "space-x-reverse" => ["space-x-reverse"],
        ##
        # Space Between Y
        # @see https://tailwindcss.com/docs/margin#adding-space-between-children
        ##
        "space-y" => [{ "space-y" => SCALE_UNAMBIGUOUS_SPACING.call }],
        ##
        # Space Between Y Reverse
        # @see https://tailwindcss.com/docs/margin#adding-space-between-children
        ##
        "space-y-reverse" => ["space-y-reverse"],

        ##########
        # Sizing
        ##########

        ##
        # Size
        # @see https://tailwindcss.com/docs/width#setting-both-width-and-height
        ##
        "size" => [{ "size" => SCALE_SIZING.call }],
        ##
        # Inline Size
        ##
        "inline-size" => [{ "inline" => ["auto", *SCALE_SIZING_INLINE.call] }],
        ##
        # Min Inline Size
        ##
        "min-inline-size" => [{ "min-inline" => ["auto", *SCALE_SIZING_INLINE.call] }],
        ##
        # Max Inline Size
        ##
        "max-inline-size" => [{ "max-inline" => ["none", *SCALE_SIZING_INLINE.call] }],
        ##
        # Block Size
        ##
        "block-size" => [{ "block" => ["auto", *SCALE_SIZING_BLOCK.call] }],
        ##
        # Min Block Size
        ##
        "min-block-size" => [{ "min-block" => ["auto", *SCALE_SIZING_BLOCK.call] }],
        ##
        # Max Block Size
        ##
        "max-block-size" => [{ "max-block" => ["none", *SCALE_SIZING_BLOCK.call] }],
        # Width
        # @see https://tailwindcss.com/docs/width
        ##
        "w" => [{
          "w" => [
            THEME_CONTAINER, "screen", *SCALE_SIZING.call,
          ],
        }],
        ##
        # Min-Width
        # @see https://tailwindcss.com/docs/min-width
        ##
        "min-w" => [{
          "min-w" => [
            THEME_CONTAINER,
            "screen",
            # Deprecated. @see https://github.com/tailwindlabs/tailwindcss.com/issues/2027#issuecomment-2620152757 ##
            "none",
            *SCALE_SIZING.call,
          ],
        }],
        ##
        # Max-Width
        # @see https://tailwindcss.com/docs/max-width
        ##
        "max-w" => [
          {
            "max-w" => [
              THEME_CONTAINER,
              "screen",
              "none",
              # Deprecated since Tailwind CSS v4.0.0. @see https://github.com/tailwindlabs/tailwindcss.com/issues/2027#issuecomment-2620152757 ##
              "prose",
              # Deprecated since Tailwind CSS v4.0.0. @see https://github.com/tailwindlabs/tailwindcss.com/issues/2027#issuecomment-2620152757 ##
              { "screen" => [THEME_BREAKPOINT] },
              *SCALE_SIZING.call,
            ],
          },
        ],
        ##
        # Height
        # @see https://tailwindcss.com/docs/height
        ##
        "h" => [{ "h" => ["screen", "lh", *SCALE_SIZING.call] }],
        ##
        # Min-Height
        # @see https://tailwindcss.com/docs/min-height
        ##
        "min-h" => [{ "min-h" => ["screen", "none", "lh", *SCALE_SIZING.call] }],
        ##
        # Max-Height
        # @see https://tailwindcss.com/docs/max-height
        ##
        "max-h" => [{ "max-h" => ["screen", "lh", *SCALE_SIZING.call] }],

        ############
        # Typography
        ############

        # Font Size
        # @see https://tailwindcss.com/docs/font-size
        ##
        "font-size" => [{ "text" => ["base", THEME_TEXT, IS_ARBITRARY_VARIABLE_LENGTH, IS_ARBITRARY_LENGTH] }],
        ##
        # Font Smoothing
        # @see https://tailwindcss.com/docs/font-smoothing
        ##
        "font-smoothing" => ["antialiased", "subpixel-antialiased"],
        ##
        # Font Style
        # @see https://tailwindcss.com/docs/font-style
        ##
        "font-style" => ["italic", "not-italic"],
        ##
        # Font Weight
        # @see https://tailwindcss.com/docs/font-weight
        ##
        "font-weight" => [
          {
            "font" => [
              THEME_FONT_WEIGHT,
              IS_ARBITRARY_VARIABLE_WEIGHT,
              IS_ARBITRARY_WEIGHT,
            ],
          },
        ],
        ##
        # Font Stretch
        # @see https://tailwindcss.com/docs/font-stretch
        ##
        "font-stretch" => [
          {
            "font-stretch" => [
              "ultra-condensed",
              "extra-condensed",
              "condensed",
              "semi-condensed",
              "normal",
              "semi-expanded",
              "expanded",
              "extra-expanded",
              "ultra-expanded",
              IS_PERCENT,
              IS_ARBITRARY_VALUE,
            ],
          },
        ],
        ##
        # Font Family
        # @see https://tailwindcss.com/docs/font-family
        ##
        "font-family" => [{ "font" => [IS_ARBITRARY_VARIABLE_FAMILY_NAME, IS_ARBITRARY_FAMILY_NAME, THEME_FONT] }],
        ##
        # Font Feature Settings
        ##
        "font-features" => [{ "font-features" => [IS_ARBITRARY_VALUE] }],
        ##
        # Font Variant Numeric
        # @see https://tailwindcss.com/docs/font-variant-numeric
        ##
        "fvn-normal" => ["normal-nums"],
        ##
        # Font Variant Numeric
        # @see https://tailwindcss.com/docs/font-variant-numeric
        ##
        "fvn-ordinal" => ["ordinal"],
        ##
        # Font Variant Numeric
        # @see https://tailwindcss.com/docs/font-variant-numeric
        ##
        "fvn-slashed-zero" => ["slashed-zero"],
        ##
        # Font Variant Numeric
        # @see https://tailwindcss.com/docs/font-variant-numeric
        ##
        "fvn-figure" => ["lining-nums", "oldstyle-nums"],
        ##
        # Font Variant Numeric
        # @see https://tailwindcss.com/docs/font-variant-numeric
        ##
        "fvn-spacing" => ["proportional-nums", "tabular-nums"],
        ##
        # Font Variant Numeric
        # @see https://tailwindcss.com/docs/font-variant-numeric
        ##
        "fvn-fraction" => ["diagonal-fractions", "stacked-fractions"],
        ##
        # Letter Spacing
        # @see https://tailwindcss.com/docs/letter-spacing
        ##
        "tracking" => [
          {
            "tracking" => [THEME_TRACKING, IS_ARBITRARY_VARIABLE, IS_ARBITRARY_VALUE],
          },
        ],
        #
        # Line Clamp
        # @see https://tailwindcss.com/docs/line-clamp
        #
        "line-clamp" => [{ "line-clamp" => [IS_NUMBER, "none", IS_ARBITRARY_VARIABLE, IS_ARBITRARY_NUMBER] }],
        ##
        # Line Height
        # @see https://tailwindcss.com/docs/line-height
        ##
        "leading" => [
          {
            "leading" => [
              # Deprecated since Tailwind CSS v4.0.0. @see https://github.com/tailwindlabs/tailwindcss.com/issues/2027#issuecomment-2620152757 ##
              THEME_LEADING,
              *SCALE_UNAMBIGUOUS_SPACING.call,
            ],
          },
        ],
        #
        # List Style Image
        # @see https://tailwindcss.com/docs/list-style-image
        #
        "list-image" => [{ "list-image" => ["none", IS_ARBITRARY_VARIABLE, IS_ARBITRARY_VALUE] }],
        # List Style Position
        # @see https://tailwindcss.com/docs/list-style-position
        ##
        "list-style-position" => [{ "list" => ["inside", "outside"] }],
        ##
        # List Style Type
        # @see https://tailwindcss.com/docs/list-style-type
        ##
        "list-style-type" => [{ "list" => ["disc", "decimal", "none", IS_ARBITRARY_VARIABLE, IS_ARBITRARY_VALUE] }],
        ##
        # Text Alignment
        # @see https://tailwindcss.com/docs/text-align
        ##
        "text-alignment" => [{ "text" => ["left", "center", "right", "justify", "start", "end"] }],
        ##
        # Placeholder Color
        # @deprecated since Tailwind CSS v3.0.0
        # @see https://tailwindcss.com/docs/placeholder-color
        ##
        "placeholder-color" => [{ "placeholder" => SCALE_COLOR.call }],
        ##
        # Text Color
        # @see https://tailwindcss.com/docs/text-color
        ##
        "text-color" => [{ "text" => SCALE_COLOR.call }],
        ##
        # Text Decoration
        # @see https://tailwindcss.com/docs/text-decoration
        ##
        "text-decoration" => ["underline", "overline", "line-through", "no-underline"],
        ##
        # Text Decoration Style
        # @see https://tailwindcss.com/docs/text-decoration-style
        ##
        "text-decoration-style" => [{ "decoration" => [*SCALE_LINE_STYLE.call, "wavy"] }],
        ##
        # Text Decoration Thickness
        # @see https://tailwindcss.com/docs/text-decoration-thickness
        ##
        "text-decoration-thickness" => [{ "decoration" => [IS_NUMBER, "from-font", "auto", IS_ARBITRARY_VARIABLE, IS_ARBITRARY_LENGTH] }],
        ##
        # Text Decoration Color
        # @see https://tailwindcss.com/docs/text-decoration-color
        ##
        "text-decoration-color" => [{ "decoration" => SCALE_COLOR.call }],
        ##
        # Text Underline Offset
        # @see https://tailwindcss.com/docs/text-underline-offset
        ##
        "underline-offset" => [{ "underline-offset" => [IS_NUMBER, "auto", IS_ARBITRARY_VARIABLE, IS_ARBITRARY_VALUE] }],
        ##
        # Text Transform
        # @see https://tailwindcss.com/docs/text-transform
        ##
        "text-transform" => ["uppercase", "lowercase", "capitalize", "normal-case"],
        ##
        # Text Overflow
        # @see https://tailwindcss.com/docs/text-overflow
        ##
        "text-overflow" => ["truncate", "text-ellipsis", "text-clip"],
        ##
        # Text Wrap
        # @see https://tailwindcss.com/docs/text-wrap
        ##
        "text-wrap" => [{ "text" => ["wrap", "nowrap", "balance", "pretty"] }],
        ##
        # Text Indent
        # @see https://tailwindcss.com/docs/text-indent
        ##
        "indent" => [{ "indent" => SCALE_UNAMBIGUOUS_SPACING.call }],
        ##
        # Vertical Alignment
        # @see https://tailwindcss.com/docs/vertical-align
        ##
        "vertical-align" => [
          {
            "align" => [
              "baseline",
              "top",
              "middle",
              "bottom",
              "text-top",
              "text-bottom",
              "sub",
              "super",
              IS_ARBITRARY_VARIABLE,
              IS_ARBITRARY_VALUE,
            ],
          },
        ],
        ##
        # Whitespace
        # @see https://tailwindcss.com/docs/whitespace
        ##
        "whitespace" => [{ "whitespace" => ["normal", "nowrap", "pre", "pre-line", "pre-wrap", "break-spaces"] }],
        ##
        # Word Break
        # @see https://tailwindcss.com/docs/word-break
        ##
        "break" => [{ "break" => ["normal", "words", "all", "keep"] }],
        ##
        # Overflow Wrap
        # @see https://tailwindcss.com/docs/overflow-wrap
        ##
        "wrap" => [{ "wrap" => ["break-word", "anywhere", "normal"] }],
        #
        # Hyphens
        # @see https://tailwindcss.com/docs/hyphens
        #
        "hyphens" => [{ "hyphens" => ["none", "manual", "auto"] }],
        ##
        # Content
        # @see https://tailwindcss.com/docs/content
        ##
        "content" => [{ "content" => ["none", IS_ARBITRARY_VARIABLE, IS_ARBITRARY_VALUE] }],

        #############
        # Backgrounds
        #############

        # Background Attachment
        # @see https://tailwindcss.com/docs/background-attachment
        ##
        "bg-attachment" => [{ "bg" => ["fixed", "local", "scroll"] }],
        ##
        # Background Clip
        # @see https://tailwindcss.com/docs/background-clip
        ##
        "bg-clip" => [{ "bg-clip" => ["border", "padding", "content", "text"] }],
        ##
        # Background Origin
        # @see https://tailwindcss.com/docs/background-origin
        ##
        "bg-origin" => [{ "bg-origin" => ["border", "padding", "content"] }],
        ##
        # Background Position
        # @see https://tailwindcss.com/docs/background-position
        ##
        "bg-position" => [{ "bg" => SCALE_BG_POSITION.call }],
        ##
        # Background Repeat
        # @see https://tailwindcss.com/docs/background-repeat
        ##
        "bg-repeat" => [{ "bg" => SCALE_BG_REPEAT.call }],
        ##
        # Background Size
        # @see https://tailwindcss.com/docs/background-size
        ##
        "bg-size" => [{ "bg" => SCALE_BG_SIZE.call }],
        ##
        # Background Image
        # @see https://tailwindcss.com/docs/background-image
        ##
        "bg-image" => [
          {
            "bg" => [
              "none",
              {
                "linear" => [
                  { "to" => ["t", "tr", "r", "br", "b", "bl", "l", "tl"] },
                  IS_INTEGER,
                  IS_ARBITRARY_VARIABLE,
                  IS_ARBITRARY_VALUE,
                ],
                "radial" => ["", IS_ARBITRARY_VARIABLE, IS_ARBITRARY_VALUE],
                "conic" => [IS_INTEGER, IS_ARBITRARY_VARIABLE, IS_ARBITRARY_VALUE],
              },
              IS_ARBITRARY_VARIABLE_IMAGE,
              IS_ARBITRARY_IMAGE,
            ],
          },
        ],
        ##
        # Background Color
        # @see https://tailwindcss.com/docs/background-color
        ##
        "bg-color" => [{ "bg" => SCALE_COLOR.call }],
        #
        # Gradient Color Stops From Position
        # @see https://tailwindcss.com/docs/gradient-color-stops
        #
        "gradient-from-pos" => [{ "from" => SCALE_GRADIENT_STOP_POSITION.call }],
        #
        # Gradient Color Stops Via Position
        # @see https://tailwindcss.com/docs/gradient-color-stops
        #
        "gradient-via-pos" => [{ "via" => SCALE_GRADIENT_STOP_POSITION.call }],
        #
        # Gradient Color Stops To Position
        # @see https://tailwindcss.com/docs/gradient-color-stops
        #
        "gradient-to-pos" => [{ "to" => SCALE_GRADIENT_STOP_POSITION.call }],
        ##
        # Gradient Color Stops From
        # @see https://tailwindcss.com/docs/gradient-color-stops
        ##
        "gradient-from" => [{ "from" => SCALE_COLOR.call }],
        ##
        # Gradient Color Stops Via
        # @see https://tailwindcss.com/docs/gradient-color-stops
        ##
        "gradient-via" => [{ "via" => SCALE_COLOR.call }],
        ##
        # Gradient Color Stops To
        # @see https://tailwindcss.com/docs/gradient-color-stops
        ##
        "gradient-to" => [{ "to" => SCALE_COLOR.call }],

        ###########
        # Borders
        ###########

        # Border Radius
        # @see https://tailwindcss.com/docs/border-radius
        ##
        "rounded" => [{ "rounded" => SCALE_RADIUS.call }],
        #
        # Border Radius Start
        # @see https://tailwindcss.com/docs/border-radius
        #
        "rounded-s" => [{ "rounded-s" => SCALE_RADIUS.call }],
        #
        # Border Radius End
        # @see https://tailwindcss.com/docs/border-radius
        #
        "rounded-e" => [{ "rounded-e" => SCALE_RADIUS.call }],
        ##
        # Border Radius Top
        # @see https://tailwindcss.com/docs/border-radius
        ##
        "rounded-t" => [{ "rounded-t" => SCALE_RADIUS.call }],
        ##
        # Border Radius Right
        # @see https://tailwindcss.com/docs/border-radius
        ##
        "rounded-r" => [{ "rounded-r" => SCALE_RADIUS.call }],
        ##
        # Border Radius Bottom
        # @see https://tailwindcss.com/docs/border-radius
        ##
        "rounded-b" => [{ "rounded-b" => SCALE_RADIUS.call }],
        ##
        # Border Radius Left
        # @see https://tailwindcss.com/docs/border-radius
        ##
        "rounded-l" => [{ "rounded-l" => SCALE_RADIUS.call }],
        #
        # Border Radius Start Start
        # @see https://tailwindcss.com/docs/border-radius
        #
        "rounded-ss" => [{ "rounded-ss" => SCALE_RADIUS.call }],
        #
        # Border Radius Start End
        # @see https://tailwindcss.com/docs/border-radius
        #
        "rounded-se" => [{ "rounded-se" => SCALE_RADIUS.call }],
        #
        # Border Radius End End
        # @see https://tailwindcss.com/docs/border-radius
        #
        "rounded-ee" => [{ "rounded-ee" => SCALE_RADIUS.call }],
        #
        # Border Radius End Start
        # @see https://tailwindcss.com/docs/border-radius
        #
        "rounded-es" => [{ "rounded-es" => SCALE_RADIUS.call }],
        ##
        # Border Radius Top Left
        # @see https://tailwindcss.com/docs/border-radius
        ##
        "rounded-tl" => [{ "rounded-tl" => SCALE_RADIUS.call }],
        ##
        # Border Radius Top Right
        # @see https://tailwindcss.com/docs/border-radius
        ##
        "rounded-tr" => [{ "rounded-tr" => SCALE_RADIUS.call }],
        ##
        # Border Radius Bottom Right
        # @see https://tailwindcss.com/docs/border-radius
        ##
        "rounded-br" => [{ "rounded-br" => SCALE_RADIUS.call }],
        ##
        # Border Radius Bottom Left
        # @see https://tailwindcss.com/docs/border-radius
        ##
        "rounded-bl" => [{ "rounded-bl" => SCALE_RADIUS.call }],
        ##
        # Border Width
        # @see https://tailwindcss.com/docs/border-width
        ##
        "border-w" => [{ "border" => SCALE_BORDER_WIDTH.call }],
        ##
        # Border Width X
        # @see https://tailwindcss.com/docs/border-width
        ##
        "border-w-x" => [{ "border-x" => SCALE_BORDER_WIDTH.call }],
        ##
        # Border Width Y
        # @see https://tailwindcss.com/docs/border-width
        ##
        "border-w-y" => [{ "border-y" => SCALE_BORDER_WIDTH.call }],
        #
        # Border Width Start
        # @see https://tailwindcss.com/docs/border-width
        #
        "border-w-s" => [{ "border-s" => SCALE_BORDER_WIDTH.call }],
        #
        # Border Width End
        # @see https://tailwindcss.com/docs/border-width
        #
        "border-w-e" => [{ "border-e" => SCALE_BORDER_WIDTH.call }],
        #
        # Border Width Block Start
        # @see https://tailwindcss.com/docs/border-width
        #
        "border-w-bs" => [{ "border-bs" => SCALE_BORDER_WIDTH.call }],
        #
        # Border Width Block End
        # @see https://tailwindcss.com/docs/border-width
        #
        "border-w-be" => [{ "border-be" => SCALE_BORDER_WIDTH.call }],
        ##
        # Border Width Top
        # @see https://tailwindcss.com/docs/border-width
        ##
        "border-w-t" => [{ "border-t" => SCALE_BORDER_WIDTH.call }],
        ##
        # Border Width Right
        # @see https://tailwindcss.com/docs/border-width
        ##
        "border-w-r" => [{ "border-r" => SCALE_BORDER_WIDTH.call }],
        ##
        # Border Width Bottom
        # @see https://tailwindcss.com/docs/border-width
        ##
        "border-w-b" => [{ "border-b" => SCALE_BORDER_WIDTH.call }],
        ##
        # Border Width Left
        # @see https://tailwindcss.com/docs/border-width
        ##
        "border-w-l" => [{ "border-l" => SCALE_BORDER_WIDTH.call }],

        ##
        # Divide Width X
        # @see https://tailwindcss.com/docs/border-width#between-children
        ##
        "divide-x" => [{ "divide-x" => SCALE_BORDER_WIDTH.call }],
        ##
        # Divide Width X Reverse
        # @see https://tailwindcss.com/docs/divide-width
        ##
        "divide-x-reverse" => ["divide-x-reverse"],
        ##
        # Divide Width Y
        # @see https://tailwindcss.com/docs/divide-width
        ##
        "divide-y" => [{ "divide-y" => SCALE_BORDER_WIDTH.call }],
        ##
        # Divide Width Y Reverse
        # @see https://tailwindcss.com/docs/divide-width
        ##
        "divide-y-reverse" => ["divide-y-reverse"],
        ##
        # Border Style
        # @see https://tailwindcss.com/docs/border-style
        ##
        "border-style" => [{ "border" => [*SCALE_LINE_STYLE.call, "hidden", "none"] }],
        ##
        # Divide Style
        # @see https://tailwindcss.com/docs/divide-style
        ##
        "divide-style" => [{ "divide" => [*SCALE_LINE_STYLE.call, "hidden", "none"] }],
        ##
        # Border Color
        # @see https://tailwindcss.com/docs/border-color
        ##
        "border-color" => [{ "border" => SCALE_COLOR.call }],
        ##
        # Border Color X
        # @see https://tailwindcss.com/docs/border-color
        ##
        "border-color-x" => [{ "border-x" => SCALE_COLOR.call }],
        ##
        # Border Color Y
        # @see https://tailwindcss.com/docs/border-color
        ##
        "border-color-y" => [{ "border-y" => SCALE_COLOR.call }],
        ##
        # Border Color S
        # @see https://tailwindcss.com/docs/border-color
        ##
        "border-color-s" => [{ "border-s" => SCALE_COLOR.call }],
        ##
        # Border Color E
        # @see https://tailwindcss.com/docs/border-color
        ##
        "border-color-e" => [{ "border-e" => SCALE_COLOR.call }],
        #
        # Border Color Block Start
        # @see https://tailwindcss.com/docs/border-color
        #
        "border-color-bs" => [{ "border-bs" => SCALE_COLOR.call }],
        #
        # Border Color Block End
        # @see https://tailwindcss.com/docs/border-color
        #
        "border-color-be" => [{ "border-be" => SCALE_COLOR.call }],
        ##
        # Border Color Top
        # @see https://tailwindcss.com/docs/border-color
        ##
        "border-color-t" => [{ "border-t" => SCALE_COLOR.call }],
        ##
        # Border Color Right
        # @see https://tailwindcss.com/docs/border-color
        ##
        "border-color-r" => [{ "border-r" => SCALE_COLOR.call }],
        ##
        # Border Color Bottom
        # @see https://tailwindcss.com/docs/border-color
        ##
        "border-color-b" => [{ "border-b" => SCALE_COLOR.call }],
        ##
        # Border Color Left
        # @see https://tailwindcss.com/docs/border-color
        ##
        "border-color-l" => [{ "border-l" => SCALE_COLOR.call }],
        ##
        # Divide Color
        # @see https://tailwindcss.com/docs/divide-color
        ##
        "divide-color" => [{ "divide" => SCALE_COLOR.call }],
        ##
        # Outline Style
        # @see https://tailwindcss.com/docs/outline-style
        ##
        "outline-style" => [{ "outline" => [*SCALE_LINE_STYLE.call, "none", "hidden"] }],
        ##
        # Outline Offset
        # @see https://tailwindcss.com/docs/outline-offset
        ##
        "outline-offset" => [{ "outline-offset" => [IS_NUMBER, IS_ARBITRARY_VARIABLE, IS_ARBITRARY_VALUE] }],
        ##
        # Outline Width
        # @see https://tailwindcss.com/docs/outline-width
        ##
        "outline-w" => [{ "outline" => ["", IS_NUMBER, IS_ARBITRARY_VARIABLE_LENGTH, IS_ARBITRARY_LENGTH] }],
        ##
        # Outline Color
        # @see https://tailwindcss.com/docs/outline-color
        ##
        "outline-color" => [{ "outline" => SCALE_COLOR.call }],

        #########
        # Effects
        #########

        ##
        # Box Shadow
        # @see https://tailwindcss.com/docs/box-shadow
        ##
        "shadow" => [
          {
            "shadow" => [
              # Deprecated since Tailwind CSS v4.0.0
              "",
              "none",
              THEME_SHADOW,
              IS_ARBITRARY_VARIABLE_SHADOW,
              IS_ARBITRARY_SHADOW,
            ],
          },
        ],
        ##
        # Box Shadow Color
        # @see https://tailwindcss.com/docs/box-shadow-color
        ##
        "shadow-color" => [{ "shadow" => SCALE_COLOR.call }],
        ##
        # Inset Box Shadow
        # @see https://tailwindcss.com/docs/box-shadow#adding-an-inset-shadow
        ##
        "inset-shadow" => [
          {
            "inset-shadow" => [
              "none",
              THEME_INSET_SHADOW,
              IS_ARBITRARY_VARIABLE_SHADOW,
              IS_ARBITRARY_SHADOW,
            ],
          },
        ],
        ##
        # Inset Box Shadow Color
        # @see https://tailwindcss.com/docs/box-shadow#setting-the-inset-shadow-color
        ##
        "inset-shadow-color" => [{ "inset-shadow" => SCALE_COLOR.call }],
        ##
        # Ring Width
        # @see https://tailwindcss.com/docs/ring-width
        ##
        "ring-w" => [{ "ring" => SCALE_BORDER_WIDTH.call }],
        ##
        # Ring Width Inset
        # @see https://tailwindcss.com/docs/ring-width
        ##
        "ring-w-inset" => ["ring-inset"],
        ##
        # Ring Color
        # @see https://tailwindcss.com/docs/ring-color
        ##
        "ring-color" => [{ "ring" => SCALE_COLOR.call }],
        ##
        # Ring Offset Width
        # @see https://v3.tailwindcss.com/docs/ring-offset-width
        # @deprecated since Tailwind CSS v4.0.0
        # @see https://github.com/tailwindlabs/tailwindcss/blob/v4.0.0/packages/tailwindcss/src/utilities.ts#L4158
        ##
        "ring-offset-w" => [{ "ring-offset" => [IS_NUMBER, IS_ARBITRARY_LENGTH] }],
        ##
        # Ring Offset Color
        # @see https://v3.tailwindcss.com/docs/ring-offset-color
        # @deprecated since Tailwind CSS v4.0.0
        # @see https://github.com/tailwindlabs/tailwindcss/blob/v4.0.0/packages/tailwindcss/src/utilities.ts#L4158
        ##
        "ring-offset-color" => [{ "ring-offset" => SCALE_COLOR.call }],
        ##
        # Inset Ring Width
        # @see https://tailwindcss.com/docs/box-shadow#adding-an-inset-ring
        ##
        "inset-ring-w" => [{ "inset-ring" => SCALE_BORDER_WIDTH.call }],
        ##
        # Inset Ring Color
        # @see https://tailwindcss.com/docs/box-shadow#setting-the-inset-ring-color
        ##
        "inset-ring-color" => [{ "inset-ring" => SCALE_COLOR.call }],
        ##
        # Text Shadow
        # @see https://tailwindcss.com/docs/text-shadow
        ##
        "text-shadow" => [
          {
            "text-shadow" => [
              "none",
              THEME_TEXT_SHADOW,
              IS_ARBITRARY_VARIABLE_SHADOW,
              IS_ARBITRARY_SHADOW,
            ],
          },
        ],
        ##
        # Text Shadow Color
        # @see https://tailwindcss.com/docs/text-shadow#setting-the-shadow-color
        ##
        "text-shadow-color" => [{ "text-shadow": SCALE_COLOR.call }],
        ##
        # Opacity
        # @see https://tailwindcss.com/docs/opacity
        ##
        "opacity" => [{ "opacity" => [IS_NUMBER, IS_ARBITRARY_VARIABLE, IS_ARBITRARY_VALUE] }],
        ##
        # Mix Blend Mode
        # @see https://tailwindcss.com/docs/mix-blend-mode
        ##
        "mix-blend" => [{ "mix-blend" => [*SCALE_BLEND_MODE.call, "plus-darker", "plus-lighter"] }],
        ##
        # Background Blend Mode
        # @see https://tailwindcss.com/docs/background-blend-mode
        ##
        "bg-blend" => [{ "bg-blend" => SCALE_BLEND_MODE.call }],
        ##
        # Mask Clip
        # @see https://tailwindcss.com/docs/mask-clip
        ##
        "mask-clip" => [
          { "mask-clip" => ["border", "padding", "content", "fill", "stroke", "view"] },
          "mask-no-clip",
        ],
        ##
        # Mask Composite
        # @see https://tailwindcss.com/docs/mask-composite
        ##
        "mask-composite" => [{ "mask" => ["add", "subtract", "intersect", "exclude"] }],
        ##
        # Mask Image
        # @see https://tailwindcss.com/docs/mask-image
        ##
        "mask-image-linear-pos" => [{ "mask-linear" => [Validators::IS_NUMBER] }],
        "mask-image-linear-from-pos" => [{ "mask-linear-from": SCALE_MASK_IMAGE_POSITION.call }],
        "mask-image-linear-to-pos" => [{ "mask-linear-to": SCALE_MASK_IMAGE_POSITION.call }],
        "mask-image-linear-from-color" => [{ "mask-linear-from": SCALE_COLOR.call }],
        "mask-image-linear-to-color" => [{ "mask-linear-to": SCALE_COLOR.call }],
        "mask-image-t-from-pos" => [{ "mask-t-from": SCALE_MASK_IMAGE_POSITION.call }],
        "mask-image-t-to-pos" => [{ "mask-t-to": SCALE_MASK_IMAGE_POSITION.call }],
        "mask-image-t-from-color" => [{ "mask-t-from": SCALE_COLOR.call }],
        "mask-image-t-to-color" => [{ "mask-t-to": SCALE_COLOR.call }],
        "mask-image-r-from-pos" => [{ "mask-r-from": SCALE_MASK_IMAGE_POSITION.call }],
        "mask-image-r-to-pos" => [{ "mask-r-to": SCALE_MASK_IMAGE_POSITION.call }],
        "mask-image-r-from-color" => [{ "mask-r-from": SCALE_COLOR.call }],
        "mask-image-r-to-color" => [{ "mask-r-to": SCALE_COLOR.call }],
        "mask-image-b-from-pos" => [{ "mask-b-from": SCALE_MASK_IMAGE_POSITION.call }],
        "mask-image-b-to-pos" => [{ "mask-b-to": SCALE_MASK_IMAGE_POSITION.call }],
        "mask-image-b-from-color" => [{ "mask-b-from": SCALE_COLOR.call }],
        "mask-image-b-to-color" => [{ "mask-b-to": SCALE_COLOR.call }],
        "mask-image-l-from-pos" => [{ "mask-l-from": SCALE_MASK_IMAGE_POSITION.call }],
        "mask-image-l-to-pos" => [{ "mask-l-to": SCALE_MASK_IMAGE_POSITION.call }],
        "mask-image-l-from-color" => [{ "mask-l-from": SCALE_COLOR.call }],
        "mask-image-l-to-color" => [{ "mask-l-to": SCALE_COLOR.call }],
        "mask-image-x-from-pos" => [{ "mask-x-from": SCALE_MASK_IMAGE_POSITION.call }],
        "mask-image-x-to-pos" => [{ "mask-x-to": SCALE_MASK_IMAGE_POSITION.call }],
        "mask-image-x-from-color" => [{ "mask-x-from": SCALE_COLOR.call }],
        "mask-image-x-to-color" => [{ "mask-x-to": SCALE_COLOR.call }],
        "mask-image-y-from-pos" => [{ "mask-y-from": SCALE_MASK_IMAGE_POSITION.call }],
        "mask-image-y-to-pos" => [{ "mask-y-to": SCALE_MASK_IMAGE_POSITION.call }],
        "mask-image-y-from-color" => [{ "mask-y-from": SCALE_COLOR.call }],
        "mask-image-y-to-color" => [{ "mask-y-to": SCALE_COLOR.call }],
        "mask-image-radial" => [{ "mask-radial" => [IS_ARBITRARY_VARIABLE, IS_ARBITRARY_VALUE] }],
        "mask-image-radial-from-pos" => [{ "mask-radial-from": SCALE_MASK_IMAGE_POSITION.call }],
        "mask-image-radial-to-pos" => [{ "mask-radial-to": SCALE_MASK_IMAGE_POSITION.call }],
        "mask-image-radial-from-color" => [{ "mask-radial-from": SCALE_COLOR.call }],
        "mask-image-radial-to-color" => [{ "mask-radial-to": SCALE_COLOR.call }],
        "mask-image-radial-shape" => [{ "mask-radial" => ["circle", "ellipse"] }],
        "mask-image-radial-size" => [
          { "mask-radial" => [{ "closest" => ["side", "corner"], "farthest" => ["side", "corner"] }] },
        ],
        "mask-image-radial-pos" => [{ "mask-radial-at": SCALE_POSITION.call }],
        "mask-image-conic-pos" => [{ "mask-conic" => [IS_NUMBER] }],
        "mask-image-conic-from-pos" => [{ "mask-conic-from": SCALE_MASK_IMAGE_POSITION.call }],
        "mask-image-conic-to-pos" => [{ "mask-conic-to": SCALE_MASK_IMAGE_POSITION.call }],
        "mask-image-conic-from-color" => [{ "mask-conic-from": SCALE_COLOR.call }],
        "mask-image-conic-to-color" => [{ "mask-conic-to": SCALE_COLOR.call }],
        ##
        # Mask Mode
        # @see https://tailwindcss.com/docs/mask-mode
        ##
        "mask-mode" => [{ "mask" => ["alpha", "luminance", "match"] }],
        ##
        # Mask Origin
        # @see https://tailwindcss.com/docs/mask-origin
        ##
        "mask-origin" => [
          { "mask-origin" => ["border", "padding", "content", "fill", "stroke", "view"] },
        ],
        ##
        # Mask Position
        # @see https://tailwindcss.com/docs/mask-position
        ##
        "mask-position" => [{ "mask" => SCALE_BG_POSITION.call }],
        ##
        # Mask Repeat
        # @see https://tailwindcss.com/docs/mask-repeat
        ##
        "mask-repeat" => [{ "mask" => SCALE_BG_REPEAT.call }],
        ##
        # Mask Size
        # @see https://tailwindcss.com/docs/mask-size
        ##
        "mask-size" => [{ "mask" => SCALE_BG_SIZE.call }],
        ##
        # Mask Type
        # @see https://tailwindcss.com/docs/mask-type
        ##
        "mask-type" => [{ "mask-type" => ["alpha", "luminance"] }],
        ##
        # Mask Image
        # @see https://tailwindcss.com/docs/mask-image
        ##
        "mask-image" => [{ "mask" => ["none", IS_ARBITRARY_VARIABLE, IS_ARBITRARY_VALUE] }],

        #########
        # Filters
        #########

        ##
        # Filter
        # @deprecated since Tailwind CSS v3.0.0
        # @see https://tailwindcss.com/docs/filter
        ##
        "filter" => [
          {
            "filter" =>
            [
              # Deprecated since Tailwind CSS v3.0.0
              "",
              "none",
              IS_ARBITRARY_VARIABLE,
              IS_ARBITRARY_VALUE,
            ],
          },
        ],
        ##
        # Blur
        # @see https://tailwindcss.com/docs/blur
        ##
        "blur" => [{ "blur" => SCALE_BLUR.call }],
        ##
        # Brightness
        # @see https://tailwindcss.com/docs/brightness
        ##
        "brightness" => [{ "brightness" => [IS_NUMBER, IS_ARBITRARY_VARIABLE, IS_ARBITRARY_VALUE] }],
        ##
        # Contrast
        # @see https://tailwindcss.com/docs/contrast
        ##
        "contrast" => [{ "contrast" => [IS_NUMBER, IS_ARBITRARY_VARIABLE, IS_ARBITRARY_VALUE] }],
        ##
        # Drop Shadow
        # @see https://tailwindcss.com/docs/drop-shadow
        ##
        "drop-shadow" => [{
          "drop-shadow" => [
            # Deprecated since Tailwind CSS v4.0.0
            "",
            "none",
            THEME_DROP_SHADOW,
            IS_ARBITRARY_VARIABLE_SHADOW,
            IS_ARBITRARY_SHADOW,
          ],
        }],
        ##
        # Drop Shadow Color
        # @see https://tailwindcss.com/docs/filter-drop-shadow#setting-the-shadow-color
        ##
        "drop-shadow-color" => [{ "drop-shadow": SCALE_COLOR.call }],
        ##
        # Grayscale
        # @see https://tailwindcss.com/docs/grayscale
        ##
        "grayscale" => [{ "grayscale" => ["", IS_NUMBER, IS_ARBITRARY_VARIABLE, IS_ARBITRARY_VALUE] }],
        ##
        # Hue Rotate
        # @see https://tailwindcss.com/docs/hue-rotate
        ##
        "hue-rotate" => [{ "hue-rotate" => [IS_NUMBER, IS_ARBITRARY_VARIABLE, IS_ARBITRARY_VALUE] }],
        ##
        # Invert
        # @see https://tailwindcss.com/docs/invert
        ##
        "invert" => [{ "invert" => ["", IS_NUMBER, IS_ARBITRARY_VARIABLE, IS_ARBITRARY_VALUE] }],
        ##
        # Saturate
        # @see https://tailwindcss.com/docs/saturate
        ##
        "saturate" => [{ "saturate" => [IS_NUMBER, IS_ARBITRARY_VARIABLE, IS_ARBITRARY_VALUE] }],
        ##
        # Sepia
        # @see https://tailwindcss.com/docs/sepia
        ##
        "sepia" => [{ "sepia" => ["", IS_NUMBER, IS_ARBITRARY_VARIABLE, IS_ARBITRARY_VALUE] }],
        ##
        # Backdrop Filter
        # @see https://tailwindcss.com/docs/backdrop-filter
        ##
        "backdrop-filter" => [{
          "backdrop-filter" => [
            # Deprecated since Tailwind CSS v3.0.0
            "",
            "none",
            IS_ARBITRARY_VARIABLE,
            IS_ARBITRARY_VALUE,
          ],
        }],
        ##
        # Backdrop Blur
        # @see https://tailwindcss.com/docs/backdrop-blur
        ##
        "backdrop-blur" => [{ "backdrop-blur" => SCALE_BLUR.call }],
        ##
        # Backdrop Brightness
        # @see https://tailwindcss.com/docs/backdrop-brightness
        ##
        "backdrop-brightness" => [{
          "backdrop-brightness" => [IS_NUMBER, IS_ARBITRARY_VARIABLE, IS_ARBITRARY_VALUE],
        }],
        ##
        # Backdrop Contrast
        # @see https://tailwindcss.com/docs/backdrop-contrast
        ##
        "backdrop-contrast" => [{ "backdrop-contrast" => [IS_NUMBER, IS_ARBITRARY_VARIABLE, IS_ARBITRARY_VALUE] }],
        ##
        # Backdrop Grayscale
        # @see https://tailwindcss.com/docs/backdrop-grayscale
        ##
        "backdrop-grayscale" => [{ "backdrop-grayscale" => ["", IS_NUMBER, IS_ARBITRARY_VARIABLE, IS_ARBITRARY_VALUE] }],
        ##
        # Backdrop Hue Rotate
        # @see https://tailwindcss.com/docs/backdrop-hue-rotate
        ##
        "backdrop-hue-rotate" => [{ "backdrop-hue-rotate" => [IS_NUMBER, IS_ARBITRARY_VARIABLE, IS_ARBITRARY_VALUE] }],
        ##
        # Backdrop Invert
        # @see https://tailwindcss.com/docs/backdrop-invert
        ##
        "backdrop-invert" => [{ "backdrop-invert" => ["", IS_NUMBER, IS_ARBITRARY_VARIABLE, IS_ARBITRARY_VALUE] }],
        ##
        # Backdrop Opacity
        # @see https://tailwindcss.com/docs/backdrop-opacity
        ##
        "backdrop-opacity" => [{ "backdrop-opacity" => [IS_NUMBER, IS_ARBITRARY_VARIABLE, IS_ARBITRARY_VALUE] }],
        ##
        # Backdrop Saturate
        # @see https://tailwindcss.com/docs/backdrop-saturate
        ##
        "backdrop-saturate" => [{ "backdrop-saturate" => [IS_NUMBER, IS_ARBITRARY_VARIABLE, IS_ARBITRARY_VALUE] }],
        ##
        # Backdrop Sepia
        # @see https://tailwindcss.com/docs/backdrop-sepia
        ##
        "backdrop-sepia" => [{ "backdrop-sepia" => ["", IS_NUMBER, IS_ARBITRARY_VARIABLE, IS_ARBITRARY_VALUE] }],

        ########
        # Tables
        ########

        # Border Collapse
        # @see https://tailwindcss.com/docs/border-collapse
        ##
        "border-collapse" => [{ "border" => ["collapse", "separate"] }],
        ##
        # Border Spacing
        # @see https://tailwindcss.com/docs/border-spacing
        ##
        "border-spacing" => [{ "border-spacing" => SCALE_UNAMBIGUOUS_SPACING.call }],
        ##
        # Border Spacing X
        # @see https://tailwindcss.com/docs/border-spacing
        ##
        "border-spacing-x" => [{ "border-spacing-x" => SCALE_UNAMBIGUOUS_SPACING.call }],
        ##
        # Border Spacing Y
        # @see https://tailwindcss.com/docs/border-spacing
        ##
        "border-spacing-y" => [{ "border-spacing-y" => SCALE_UNAMBIGUOUS_SPACING.call }],
        ##
        # Table Layout
        # @see https://tailwindcss.com/docs/table-layout
        ##
        "table-layout" => [{ "table" => ["auto", "fixed"] }],
        #
        # Caption Side
        # @see https://tailwindcss.com/docs/caption-side
        #
        "caption" => [{ "caption" => ["top", "bottom"] }],

        #############################
        # Transitions and Animation
        #############################

        # Tranisition Property
        # @see https://tailwindcss.com/docs/transition-property
        ##
        "transition" => [
          {
            "transition" => [
              "",
              "all",
              "colors",
              "opacity",
              "shadow",
              "transform",
              "none",
              IS_ARBITRARY_VARIABLE,
              IS_ARBITRARY_VALUE,
            ],
          },
        ],
        ##
        # Transition Behavior
        # @see https://tailwindcss.com/docs/transition-behavior
        ##
        "transition-behavior" => [{ "transition" => ["normal", "discrete"] }],
        ##
        # Transition Duration
        # @see https://tailwindcss.com/docs/transition-duration
        ##
        "duration" => [{ "duration" => [IS_NUMBER, "initial", IS_ARBITRARY_VARIABLE, IS_ARBITRARY_VALUE] }],
        ##
        # Transition Timing Function
        # @see https://tailwindcss.com/docs/transition-timing-function
        ##
        "ease" => [{ "ease" => ["linear", "initial", THEME_EASE, IS_ARBITRARY_VARIABLE, IS_ARBITRARY_VALUE] }],
        ##
        # Transition Delay
        # @see https://tailwindcss.com/docs/transition-delay
        ##
        "delay" => [{ "delay" => [IS_NUMBER, IS_ARBITRARY_VARIABLE, IS_ARBITRARY_VALUE] }],
        ##
        # Animation
        # @see https://tailwindcss.com/docs/animation
        ##
        "animate" => [{ "animate" => ["none", THEME_ANIMATE, IS_ARBITRARY_VARIABLE, IS_ARBITRARY_VALUE] }],

        #############
        # Transforms
        #############

        ##
        # Backface Visibility
        # @see https://tailwindcss.com/docs/backface-visibility
        ##
        "backface" => [{ "backface" => ["hidden", "visible"] }],
        ##
        # Perspective
        # @see https://tailwindcss.com/docs/perspective
        ##
        "perspective" => [
          { "perspective" => [THEME_PERSPECTIVE, IS_ARBITRARY_VARIABLE, IS_ARBITRARY_VALUE] },
        ],
        ##
        # Perspective Origin
        # @see https://tailwindcss.com/docs/perspective-origin
        ##
        "perspective-origin" => [{ "perspective-origin" => SCALE_POSITION_WITH_ARBITRARY.call }],
        ##
        # Rotate
        # @see https://tailwindcss.com/docs/rotate
        ##
        "rotate" => [{ "rotate" => SCALE_ROTATE.call }],
        ##
        # Rotate X
        # @see https://tailwindcss.com/docs/rotate
        ##
        "rotate-x" => [{ "rotate-x": SCALE_ROTATE.call }],
        ##
        # Rotate Y
        # @see https://tailwindcss.com/docs/rotate
        ##
        "rotate-y" => [{ "rotate-y": SCALE_ROTATE.call }],
        ##
        # Rotate Z
        # @see https://tailwindcss.com/docs/rotate
        ##
        "rotate-z" => [{ "rotate-z": SCALE_ROTATE.call }],
        ##
        # Scale
        # @see https://tailwindcss.com/docs/scale
        ##
        "scale" => [{ "scale" => SCALE_SCALE.call }],
        ##
        # Scale X
        # @see https://tailwindcss.com/docs/scale
        ##
        "scale-x" => [{ "scale-x" => SCALE_SCALE.call }],
        ##
        # Scale Y
        # @see https://tailwindcss.com/docs/scale
        ##
        "scale-y" => [{ "scale-y" => SCALE_SCALE.call }],
        ##
        # Scale Z
        # @see https://tailwindcss.com/docs/scale
        ##
        "scale-z" => [{ "scale-z" => SCALE_SCALE.call }],
        ##
        # Scale 3D
        # @see https://tailwindcss.com/docs/scale
        ##
        "scale-3d" => ["scale-3d"],
        ##
        # Skew
        # @see https://tailwindcss.com/docs/skew
        ##
        "skew" => [{ "skew" => SCALE_SKEW.call }],
        ##
        # Skew X
        # @see https://tailwindcss.com/docs/skew
        ##
        "skew-x" => [{ "skew-x": SCALE_SKEW.call }],
        ##
        # Skew Y
        # @see https://tailwindcss.com/docs/skew
        ##
        "skew-y" => [{ "skew-y": SCALE_SKEW.call }],
        # Transform
        # @see https://tailwindcss.com/docs/transform
        ##
        "transform" => [{ "transform" => [IS_ARBITRARY_VARIABLE, IS_ARBITRARY_VALUE, "", "none", "gpu", "cpu"] }],
        ##
        # Transform Origin
        # @see https://tailwindcss.com/docs/transform-origin
        ##
        "transform-origin" => [
          {
            "origin" => SCALE_POSITION_WITH_ARBITRARY.call,
          },
        ],
        ##
        # Transform Style
        # @see https://tailwindcss.com/docs/transform-style
        ##
        "transform-style" => [{ "transform" => ["3d", "flat"] }],
        ##
        # Translate
        # @see https://tailwindcss.com/docs/translate
        ##
        "translate" => [{ "translate" => SCALE_TRANSLATE.call }],
        ##
        # Translate X
        # @see https://tailwindcss.com/docs/translate
        ##
        "translate-x" => [{ "translate-x" => SCALE_TRANSLATE.call }],
        ##
        # Translate Y
        # @see https://tailwindcss.com/docs/translate
        ##
        "translate-y" => [{ "translate-y" => SCALE_TRANSLATE.call }],
        ##
        # Translate Z
        # @see https://tailwindcss.com/docs/translate
        ##
        "translate-z" => [{ "translate-z" => SCALE_TRANSLATE.call }],
        ##
        # Translate None
        # @see https://tailwindcss.com/docs/translate
        ##
        "translate-none" => ["translate-none"],

        ###############
        # Interactivity
        ###############

        ##
        # Accent Color
        # @see https://tailwindcss.com/docs/accent-color
        ##
        "accent" => [{ "accent" => SCALE_COLOR.call }],
        ##
        # Appearance
        # @see https://tailwindcss.com/docs/appearance
        ##
        "appearance" => [{ "appearance" => ["none", "auto"] }],
        ##
        # Caret Color
        # @see https://tailwindcss.com/docs/just-in-time-mode#caret-color-utilities
        ##
        "caret-color" => [{ "caret" => SCALE_COLOR.call }],
        ##
        # Color Scheme
        # @see https://tailwindcss.com/docs/color-scheme
        ##
        "color-scheme" => [
          { "scheme" => ["normal", "dark", "light", "light-dark", "only-dark", "only-light"] },
        ],
        ##
        # Cursor
        # @see https://tailwindcss.com/docs/cursor
        ##
        "cursor" => [
          {
            "cursor" => [
              "auto",
              "default",
              "pointer",
              "wait",
              "text",
              "move",
              "help",
              "not-allowed",
              "none",
              "context-menu",
              "progress",
              "cell",
              "crosshair",
              "vertical-text",
              "alias",
              "copy",
              "no-drop",
              "grab",
              "grabbing",
              "all-scroll",
              "col-resize",
              "row-resize",
              "n-resize",
              "e-resize",
              "s-resize",
              "w-resize",
              "ne-resize",
              "nw-resize",
              "se-resize",
              "sw-resize",
              "ew-resize",
              "ns-resize",
              "nesw-resize",
              "nwse-resize",
              "zoom-in",
              "zoom-out",
              IS_ARBITRARY_VARIABLE,
              IS_ARBITRARY_VALUE,
            ],
          },
        ],
        ##
        # Field Sizing
        # @see https://tailwindcss.com/docs/field-sizing
        ##
        "field-sizing" => [{ "field-sizing" => ["fixed", "content"] }],
        ##
        # Pointer Events
        # @see https://tailwindcss.com/docs/pointer-events
        ##
        "pointer-events" => [{ "pointer-events" => ["none", "auto"] }],
        ##
        # Resize
        # @see https://tailwindcss.com/docs/resize
        ##
        "resize" => [{ "resize" => ["none", "", "y", "x"] }],
        ##
        # Scroll Behavior
        # @see https://tailwindcss.com/docs/scroll-behavior
        ##
        "scroll-behavior" => [{ "scroll" => ["auto", "smooth"] }],
        ##
        # Scroll Margin
        # @see https://tailwindcss.com/docs/scroll-margin
        ##
        "scroll-m" => [{ "scroll-m" => SCALE_UNAMBIGUOUS_SPACING.call }],
        ##
        # Scroll Margin X
        # @see https://tailwindcss.com/docs/scroll-margin
        ##
        "scroll-mx" => [{ "scroll-mx" => SCALE_UNAMBIGUOUS_SPACING.call }],
        ##
        # Scroll Margin Y
        # @see https://tailwindcss.com/docs/scroll-margin
        ##
        "scroll-my" => [{ "scroll-my" => SCALE_UNAMBIGUOUS_SPACING.call }],
        #
        # Scroll Margin Start
        # @see https://tailwindcss.com/docs/scroll-margin
        #
        "scroll-ms" => [{ "scroll-ms" => SCALE_UNAMBIGUOUS_SPACING.call }],
        #
        # Scroll Margin End
        # @see https://tailwindcss.com/docs/scroll-margin
        #
        "scroll-me" => [{ "scroll-me" => SCALE_UNAMBIGUOUS_SPACING.call }],
        #
        # Scroll Margin Block Start
        # @see https://tailwindcss.com/docs/scroll-margin
        #
        "scroll-mbs" => [{ "scroll-mbs" => SCALE_UNAMBIGUOUS_SPACING.call }],
        #
        # Scroll Margin Block End
        # @see https://tailwindcss.com/docs/scroll-margin
        #
        "scroll-mbe" => [{ "scroll-mbe" => SCALE_UNAMBIGUOUS_SPACING.call }],
        ##
        # Scroll Margin Top
        # @see https://tailwindcss.com/docs/scroll-margin
        ##
        "scroll-mt" => [{ "scroll-mt" => SCALE_UNAMBIGUOUS_SPACING.call }],
        ##
        # Scroll Margin Right
        # @see https://tailwindcss.com/docs/scroll-margin
        ##
        "scroll-mr" => [{ "scroll-mr" => SCALE_UNAMBIGUOUS_SPACING.call }],
        ##
        # Scroll Margin Bottom
        # @see https://tailwindcss.com/docs/scroll-margin
        ##
        "scroll-mb" => [{ "scroll-mb" => SCALE_UNAMBIGUOUS_SPACING.call }],
        ##
        # Scroll Margin Left
        # @see https://tailwindcss.com/docs/scroll-margin
        ##
        "scroll-ml" => [{ "scroll-ml" => SCALE_UNAMBIGUOUS_SPACING.call }],
        ##
        # Scroll Padding
        # @see https://tailwindcss.com/docs/scroll-padding
        ##
        "scroll-p" => [{ "scroll-p" => SCALE_UNAMBIGUOUS_SPACING.call }],
        ##
        # Scroll Padding X
        # @see https://tailwindcss.com/docs/scroll-padding
        ##
        "scroll-px" => [{ "scroll-px" => SCALE_UNAMBIGUOUS_SPACING.call }],
        ##
        # Scroll Padding Y
        # @see https://tailwindcss.com/docs/scroll-padding
        ##
        "scroll-py" => [{ "scroll-py" => SCALE_UNAMBIGUOUS_SPACING.call }],
        #
        # Scroll Padding Start
        # @see https://tailwindcss.com/docs/scroll-padding
        #
        "scroll-ps" => [{ "scroll-ps" => SCALE_UNAMBIGUOUS_SPACING.call }],
        #
        # Scroll Padding End
        # @see https://tailwindcss.com/docs/scroll-padding
        #
        "scroll-pe" => [{ "scroll-pe" => SCALE_UNAMBIGUOUS_SPACING.call }],
        #
        # Scroll Padding Block Start
        # @see https://tailwindcss.com/docs/scroll-padding
        #
        "scroll-pbs" => [{ "scroll-pbs" => SCALE_UNAMBIGUOUS_SPACING.call }],
        #
        # Scroll Padding Block End
        # @see https://tailwindcss.com/docs/scroll-padding
        #
        "scroll-pbe" => [{ "scroll-pbe" => SCALE_UNAMBIGUOUS_SPACING.call }],
        ##
        # Scroll Padding Top
        # @see https://tailwindcss.com/docs/scroll-padding
        ##
        "scroll-pt" => [{ "scroll-pt" => SCALE_UNAMBIGUOUS_SPACING.call }],
        ##
        # Scroll Padding Right
        # @see https://tailwindcss.com/docs/scroll-padding
        ##
        "scroll-pr" => [{ "scroll-pr" => SCALE_UNAMBIGUOUS_SPACING.call }],
        ##
        # Scroll Padding Bottom
        # @see https://tailwindcss.com/docs/scroll-padding
        ##
        "scroll-pb" => [{ "scroll-pb" => SCALE_UNAMBIGUOUS_SPACING.call }],
        ##
        # Scroll Padding Left
        # @see https://tailwindcss.com/docs/scroll-padding
        ##
        "scroll-pl" => [{ "scroll-pl" => SCALE_UNAMBIGUOUS_SPACING.call }],
        ##
        # Scroll Snap Align
        # @see https://tailwindcss.com/docs/scroll-snap-align
        ##
        "snap-align" => [{ "snap" => ["start", "end", "center", "align-none"] }],
        ##
        # Scroll Snap Stop
        # @see https://tailwindcss.com/docs/scroll-snap-stop
        ##
        "snap-stop" => [{ "snap" =>  ["normal", "always"] }],
        ##
        # Scroll Snap Type
        # @see https://tailwindcss.com/docs/scroll-snap-type
        ##
        "snap-type" => [{ "snap" =>  ["none", "x", "y", "both"] }],
        ##
        # Scroll Snap Type Strictness
        # @see https://tailwindcss.com/docs/scroll-snap-type
        ##
        "snap-strictness" => [{ "snap" => ["mandatory", "proximity"] }],
        ##
        # Touch Action
        # @see https://tailwindcss.com/docs/touch-action
        ##
        "touch" => [
          {
            "touch" => ["auto", "none", "manipulation"],
          },
        ],
        ##
        # Touch Action X
        # @see https://tailwindcss.com/docs/touch-action
        ##
        "touch-x" => [
          {
            "touch-pan" => ["x", "left", "right"],
          },
        ],
        ##
        # Touch Action Y
        # @see https://tailwindcss.com/docs/touch-action
        ##
        "touch-y" => [
          {
            "touch-pan" => ["y", "up", "down"],
          },
        ],
        ##
        # Touch Action Pinch Zoom
        # @see https://tailwindcss.com/docs/touch-action
        ##
        "touch-pz" => ["touch-pinch-zoom"],
        ##
        # User Select
        # @see https://tailwindcss.com/docs/user-select
        ##
        "select" => [{ "select" => ["none", "text", "all", "auto"] }],
        ##
        # Will Change
        # @see https://tailwindcss.com/docs/will-change
        ##
        "will-change" => [
          { "will-change" => ["auto", "scroll", "contents", "transform", IS_ARBITRARY_VARIABLE, IS_ARBITRARY_VALUE] },
        ],

        ######
        # SVG
        ######

        ##
        # Fill
        # @see https://tailwindcss.com/docs/fill
        ##
        "fill" => [{ "fill" => ["none", *SCALE_COLOR.call] }],
        ##
        # Stroke Width
        # @see https://tailwindcss.com/docs/stroke-width
        ##
        "stroke-w" => [{ "stroke" => [IS_NUMBER, IS_ARBITRARY_VARIABLE_LENGTH, IS_ARBITRARY_LENGTH, IS_ARBITRARY_NUMBER] }],
        ##
        # Stroke
        # @see https://tailwindcss.com/docs/stroke
        ##
        "stroke" => [{ "stroke" => ["none", *SCALE_COLOR.call] }],

        ################
        # Accessibility
        ################

        ##
        # Forced Color Adjust
        # @see https://tailwindcss.com/docs/forced-color-adjust
        ##
        "forced-color-adjust" => [{ "forced-color-adjust" => ["auto", "none"] }],
      },
      conflicting_class_groups: {
        "overflow" => ["overflow-x", "overflow-y"],
        "overscroll" => ["overscroll-x", "overscroll-y"],
        "inset" => ["inset-x", "inset-y", "start", "end", "inset-bs", "inset-be", "top", "right", "bottom", "left"],
        "inset-x" => ["right", "left"],
        "inset-y" => ["top", "bottom"],
        "flex" => ["basis", "grow", "shrink"],
        "gap" => ["gap-x", "gap-y"],
        "p" => ["px", "py", "ps", "pe", "pbs", "pbe", "pt", "pr", "pb", "pl"],
        "px" => ["pr", "pl"],
        "py" => ["pt", "pb"],
        "m" => ["mx", "my", "ms", "me", "mbs", "mbe", "mt", "mr", "mb", "ml"],
        "mx" => ["mr", "ml"],
        "my" => ["mt", "mb"],
        "size" => ["w", "h"],
        "font-size" => ["leading"],
        "fvn-normal" => [
          "fvn-ordinal",
          "fvn-slashed-zero",
          "fvn-figure",
          "fvn-spacing",
          "fvn-fraction",
        ],
        "fvn-ordinal" => ["fvn-normal"],
        "fvn-slashed-zero" => ["fvn-normal"],
        "fvn-figure" => ["fvn-normal"],
        "fvn-spacing" => ["fvn-normal"],
        "fvn-fraction" => ["fvn-normal"],
        "line-clamp" => ["display", "overflow"],
        "rounded" => [
          "rounded-s",
          "rounded-e",
          "rounded-t",
          "rounded-r",
          "rounded-b",
          "rounded-l",
          "rounded-ss",
          "rounded-se",
          "rounded-ee",
          "rounded-es",
          "rounded-tl",
          "rounded-tr",
          "rounded-br",
          "rounded-bl",
        ],
        "rounded-s" => ["rounded-ss", "rounded-es"],
        "rounded-e" => ["rounded-se", "rounded-ee"],
        "rounded-t" => ["rounded-tl", "rounded-tr"],
        "rounded-r" => ["rounded-tr", "rounded-br"],
        "rounded-b" => ["rounded-br", "rounded-bl"],
        "rounded-l" => ["rounded-tl", "rounded-bl"],
        "border-spacing" => ["border-spacing-x", "border-spacing-y"],
        "border-w" => [
          "border-w-x",
          "border-w-y",
          "border-w-s",
          "border-w-e",
          "border-w-bs",
          "border-w-be",
          "border-w-t",
          "border-w-r",
          "border-w-b",
          "border-w-l",
        ],
        "border-w-x" => ["border-w-r", "border-w-l"],
        "border-w-y" => ["border-w-t", "border-w-b"],
        "border-color" => [
          "border-color-x",
          "border-color-y",
          "border-color-s",
          "border-color-e",
          "border-color-bs",
          "border-color-be",
          "border-color-t",
          "border-color-r",
          "border-color-b",
          "border-color-l",
        ],
        "border-color-x" => ["border-color-r", "border-color-l"],
        "border-color-y" => ["border-color-t", "border-color-b"],
        "translate" => ["translate-x", "translate-y", "translate-none"],
        "translate-none" => ["translate", "translate-x", "translate-y", "translate-z"],
        "scroll-m" => [
          "scroll-mx",
          "scroll-my",
          "scroll-ms",
          "scroll-me",
          "scroll-mbs",
          "scroll-mbe",
          "scroll-mt",
          "scroll-mr",
          "scroll-mb",
          "scroll-ml",
        ],
        "scroll-mx" => ["scroll-mr", "scroll-ml"],
        "scroll-my" => ["scroll-mt", "scroll-mb"],
        "scroll-p" => [
          "scroll-px",
          "scroll-py",
          "scroll-ps",
          "scroll-pe",
          "scroll-pbs",
          "scroll-pbe",
          "scroll-pt",
          "scroll-pr",
          "scroll-pb",
          "scroll-pl",
        ],
        "scroll-px" => ["scroll-pr", "scroll-pl"],
        "scroll-py" => ["scroll-pt", "scroll-pb"],
        "touch" => ["touch-x", "touch-y", "touch-pz"],
        "touch-x" => ["touch"],
        "touch-y" => ["touch"],
        "touch-pz" => ["touch"],
      },
      conflicting_class_group_modifiers: {
        "font-size" => ["leading"],
      },
      order_sensitive_modifiers: [
        "*",
        "**",
        "after",
        "backdrop",
        "before",
        "details-content",
        "file",
        "first-letter",
        "first-line",
        "marker",
        "placeholder",
        "selection",
      ],
    }.freeze

    def merge_config(incoming_config)
      extended_config = TailwindMerge::Config::DEFAULTS.dup

      incoming_theme = incoming_config.delete(:theme) || {}
      # if the incoming config has a theme, we...
      incoming_theme.each_pair do |key, scales|
        # ...add new scales to the existing ones
        extended_config[:theme][key] << ->(klass) {
          scales.include?(klass)
        }
      end

      extended_config.merge(incoming_config)
    end
  end
end
