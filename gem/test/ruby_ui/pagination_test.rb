# frozen_string_literal: true

require "test_helper"

class RubyUI::PaginationTest < ComponentTest
  def test_render_with_all_items
    output = phlex do
      RubyUI.Pagination do
        RubyUI.PaginationContent do
          RubyUI.PaginationPrevious(href: "#")
          RubyUI.PaginationItem(href: "#") { "1" }
          RubyUI.PaginationItem(href: "#", active: true) { "2" }
          RubyUI.PaginationItem(href: "#") { "3" }
          RubyUI.PaginationEllipsis()
          RubyUI.PaginationNext(href: "#")
        end
      end
    end

    assert_match(/<nav role="navigation" aria-label="pagination" data-slot="pagination"/, output)
    assert_match(/<ul data-slot="pagination-content" class="flex items-center gap-1"/, output)
    assert_equal 6, output.scan('<li data-slot="pagination-item">').size
    assert_equal 5, output.scan('data-slot="pagination-link"').size
  end

  def test_item_is_a_square_link_by_default
    output = phlex { RubyUI.PaginationItem(href: "/page/3") { "3" } }

    assert_match(%r{<li data-slot="pagination-item"><a href="/page/3"}, output)
    assert_match(/h-9 w-9/, output)
    refute_match(/px-2\.5/, output)
    refute_match(/role="button"/, output)
    refute_match(/aria-current/, output)
    refute_match(/data-active/, output)
  end

  def test_active_item
    output = phlex { RubyUI.PaginationItem(href: "#", active: true) { "2" } }

    assert_match(/aria-current="page"/, output)
    assert_match(/data-active="true"/, output)
    assert_match(/bg-background/, output)
  end

  def test_item_with_default_size
    output = phlex { RubyUI.PaginationItem(href: "#", size: :default) { "First" } }

    assert_match(/h-9 gap-1\.5 px-2\.5/, output)
    refute_match(/w-9/, output)
  end

  def test_previous_and_next
    previous = phlex { RubyUI.PaginationPrevious(href: "/page/1") }
    following = phlex { RubyUI.PaginationNext(href: "/page/3", text: "Próxima") }

    assert_match(%r{href="/page/1"}, previous)
    assert_match(/aria-label="Go to previous page"/, previous)
    assert_match(/data-icon="inline-start"/, previous)
    assert_match(%r{<span class="hidden sm:block">Previous</span>}, previous)
    assert_match(/pl-2!/, previous)

    assert_match(/aria-label="Go to next page"/, following)
    assert_match(/data-icon="inline-end"/, following)
    assert_match(%r{<span class="hidden sm:block">Próxima</span>}, following)
    assert_match(/pr-2!/, following)
  end

  def test_translated_label_replaces_default_aria_label
    output = phlex { RubyUI.PaginationPrevious(text: "Anterior", aria: {label!: "Página anterior"}) }

    assert_match(/aria-label="Página anterior"/, output)
    refute_match(/Go to previous page/, output)
  end

  def test_ellipsis_is_hidden_from_assistive_tech
    output = phlex { RubyUI.PaginationEllipsis() }

    assert_match(/<span aria-hidden="true" data-slot="pagination-ellipsis"/, output)
    assert_match(/size-9/, output)
    assert_match(/More pages/, output)
  end
end
