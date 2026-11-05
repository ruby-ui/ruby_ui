# frozen_string_literal: true

require "test_helper"

class RubyUI::NativeSelectTest < ComponentTest
  def test_render_with_all_items
    output = phlex do
      RubyUI.NativeSelect(name: "department") do
        RubyUI.NativeSelectOption(value: "") { "Select a department" }
        RubyUI.NativeSelectGroup(label: "Engineering") do
          RubyUI.NativeSelectOption(value: "frontend") { "Frontend" }
          RubyUI.NativeSelectOption(value: "backend") { "Backend" }
        end
        RubyUI.NativeSelectGroup(label: "Sales") do
          RubyUI.NativeSelectOption(value: "account_executive") { "Account Executive" }
        end
      end
    end

    assert_match(/Frontend/, output)
    assert_match('name="department"', output)
  end

  def test_slots_and_size_on_wrapper_and_select
    output = phlex { RubyUI.NativeSelect { RubyUI.NativeSelectOption(value: "a") { "A" } } }

    assert_match(/<div[^>]*data-slot="native-select-wrapper"[^>]*data-size="default"/, output)
    assert_match(/<select[^>]*data-slot="native-select"[^>]*data-size="default"/, output)
    assert_match(/<option[^>]*data-slot="native-select-option"/, output)
  end

  def test_small_size_uses_data_attribute
    select = tag(phlex { RubyUI.NativeSelect(size: :sm) }, "select")

    assert_match('data-size="sm"', select)
    assert_includes classes(select), "data-[size=sm]:h-8"
    refute_includes classes(select), "h-7"
  end

  def test_vega_select_classes
    select_classes = classes(tag(phlex { RubyUI.NativeSelect }, "select"))

    %w[border-input dark:bg-input/30 dark:hover:bg-input/50 focus-visible:ring-3 aria-invalid:ring-3
      dark:aria-invalid:border-destructive/50 dark:aria-invalid:ring-destructive/40].each do |token|
      assert_includes select_classes, token
    end
    refute_includes select_classes, "border-border"
  end

  def test_disabled_dims_only_the_wrapper
    output = phlex { RubyUI.NativeSelect(disabled: true) }

    assert_includes classes(tag(output, "div")), "has-[select:disabled]:opacity-50"
    refute_includes classes(tag(output, "select")), "disabled:opacity-50"
    assert_match(/\sdisabled(="disabled")?[\s>]/, tag(output, "select"))
  end

  def test_class_goes_to_wrapper_and_attrs_to_select
    output = phlex { RubyUI.NativeSelect(class: "w-full", id: "fruit", name: "fruit") }
    wrapper = tag(output, "div")
    select = tag(output, "select")

    assert_includes classes(wrapper), "w-full"
    refute_includes classes(wrapper), "w-fit"
    refute_includes classes(select), "w-fit"
    assert_match('id="fruit"', select)
    assert_match('name="fruit"', select)
    refute_match("id=", wrapper)
  end

  def test_string_and_symbol_class_keys_both_go_to_wrapper
    output = phlex { RubyUI.NativeSelect(:class => "w-full", "class" => "mt-2") }

    assert_includes classes(tag(output, "div")), "w-full"
    assert_includes classes(tag(output, "div")), "mt-2"
    refute_includes classes(tag(output, "select")), "mt-2"
  end

  def test_wrapper_class_accepts_arrays_and_sets
    [["w-full", ["mt-2"]], Set["w-full", "mt-2"]].each do |value|
      wrapper_classes = classes(tag(phlex { RubyUI.NativeSelect(class: value) }, "div"))

      assert_includes wrapper_classes, "w-full"
      assert_includes wrapper_classes, "mt-2"
      refute_includes wrapper_classes, "w-fit"
    end
  end

  def test_icon_is_the_svg
    output = phlex { RubyUI.NativeSelect }

    assert_match(/<svg[^>]*aria-hidden="true"[^>]*data-slot="native-select-icon"/, output)
    assert_includes classes(tag(output, "svg")), "size-4"
    refute_match("<span", output)
  end

  def test_icon_block_replaces_chevron
    output = phlex { RubyUI.NativeSelectIcon { "v" } }

    assert_match(%r{<span[^>]*data-slot="native-select-icon"[^>]*>v</span>}, output)
    refute_match("<svg", output)
  end

  def test_options_and_groups_use_system_colors
    output = phlex do
      RubyUI.NativeSelect do
        RubyUI.NativeSelectGroup(label: "G") { RubyUI.NativeSelectOption(value: "a") { "A" } }
      end
    end

    assert_match(/<optgroup[^>]*data-slot="native-select-optgroup"[^>]*class="bg-\[Canvas\] text-\[CanvasText\]"/, output)
    assert_match(/<option[^>]*class="bg-\[Canvas\] text-\[CanvasText\]"/, output)
  end

  private

  # Quoted values may contain ">" (data-action="change->...").
  def tag(html, name) = html[/<#{name}\b(?:[^>"]|"[^"]*")*>/]

  def classes(tag) = tag[/class="([^"]*)"/, 1].split
end
