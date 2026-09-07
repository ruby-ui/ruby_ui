# Herb lane only (Gemfile.herb). With intercept_erb every .html.erb under
# Rails.root compiles through Herb::Engine with its validators on, and a parser
# or validator error raises instead of rendering an overlay — the policy in
# design/v2/03-plan-fase1.md §4: the 1.6 snapshot is the reference, a Herb
# rejection becomes a row in HERB_FINDINGS.md, never a relaxed validation mode.
if defined?(ReActionView)
  ReActionView.configure do |config|
    config.intercept_erb = true
    config.validation_mode = :raise

    # The browser dev-tools overlay reaches for config.assets.precompile, which
    # propshaft does not have. Off everywhere; :raise is what surfaces errors.
    config.debug_mode = false

    # Templates outside Rails.root (turbo-rails) compile through Herb and fall
    # back to Erubi on error. This is the default; it is spelled out because
    # ReActionView also treats `render inline:` templates as external, so a Herb
    # failure in an inline template would be swallowed by this fallback. Every
    # test template in this app is therefore a file, never `inline:`.
    config.external_template_mode = :fallback
  end
end
