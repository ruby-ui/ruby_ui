# frozen_string_literal: true

# Lists candidate spots where the golden suite's canonical form is blind to
# whitespace: two adjacent inline-level elements under a parent that lays out
# inline. An inventory to read, not a number to rely on.
#
#   cd gem && bundle exec ruby test/golden/tools/inline_adjacency.rb
#
# Known limits, all deliberate: inline-level is judged from the tag name plus
# `inline`, `inline-block` and `inline-flex` in the class list; a parent is
# skipped if its class list has `flex`, `grid`, `inline-flex` or `inline-grid`.
# That is enough to find candidates and not enough to prove absence — it does
# not see `absolute`, `hidden`, `sr-only`, `block` on an inline tag,
# responsive or state variants, or whitespace at a text–element boundary.
# Task 2 of the Phase 1 plan closes the empty-versus-whitespace-only case for
# every component; Phase 2's strict lane covers text-bearing components raw.

require "nokogiri"

SNAPSHOT_ROOT = File.expand_path("../snapshots", __dir__)

INLINE_TAGS = %w[
  a abbr b bdi bdo br cite code data dfn em i kbd mark q rp rt ruby s samp
  small span strong sub sup time u var wbr img svg
].freeze

INLINE_CLASSES = /(?:\A|\s)(?:inline|inline-block|inline-flex)(?:\s|\z)/
FLOW_CLASSES = /(?:\A|\s)(?:flex|grid|inline-flex|inline-grid)(?:\s|\z)/

def inline?(node)
  return false unless node.element?
  return true if INLINE_TAGS.include?(node.name)

  node["class"].to_s.match?(INLINE_CLASSES)
end

def inline_formatting_context?(node)
  return true if node.fragment?

  !node["class"].to_s.match?(FLOW_CLASSES)
end

findings = Hash.new { |hash, key| hash[key] = [] }

Dir.glob(File.join(SNAPSHOT_ROOT, "**", "*.html")).sort.each do |path|
  slug = path.delete_prefix("#{SNAPSHOT_ROOT}/").delete_suffix(".html")
  component = slug.split("/").first

  Nokogiri::HTML5.fragment(File.read(path)).traverse do |node|
    next unless node.element? || node.fragment?
    next unless inline_formatting_context?(node)

    children = node.children.reject { |child| child.text? && child.text.strip.empty? }

    children.each_cons(2) do |left, right|
      next unless inline?(left) && inline?(right)

      findings[component] << "#{slug}: <#{left.name}> + <#{right.name}>"
    end
  end
end

puts "components with candidates: #{findings.keys.size}"
puts "candidate pairs: #{findings.values.sum(&:size)}"
puts

findings.keys.sort.each do |component|
  puts "#{component} (#{findings[component].size})"
  findings[component].first(3).each { |line| puts "  #{line}" }
  puts "  …" if findings[component].size > 3
end
