module Probes
  # Control for ReActionView issue #57 (plan §4, Phase 0 probe iv): a component
  # template calls a helper with a block, the helper does `render "partial",
  # &block`, and the partial does `<%= yield %>`. The layer never takes this
  # path; the probe records what a user's template would get.
  class Issue57 < RubyUI::Base
  end
end
