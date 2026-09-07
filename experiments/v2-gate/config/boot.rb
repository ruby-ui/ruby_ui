# Lanes are selected with BUNDLE_GEMFILE=Gemfile.<lane>. Without it, the gate
# lane (Herb through ReActionView) is the default.
ENV["BUNDLE_GEMFILE"] ||= File.expand_path("../Gemfile.herb", __dir__)

require "bundler/setup" # Set up gems listed in the Gemfile.
