source 'https://rubygems.org'

gemspec

group :development do
  gem "minitar", "0.9"
  gem "minitest", "~> 5.15" # open range for ruby 2.3 support
  gem "minitest-hooks", "1.5.2"
  gem "rake", "13.2.1"
  if RUBY_VERSION >= "3.4"
    gem "webrick", git: "https://github.com/ruby/webrick" # shouldn't be necessary to pin once webrick 1.8.2 or 1.9.0 is released
  else
    gem "webrick"
  end

  gem "net-ftp" if Gem::Requirement.new("> 3.1.0.dev").satisfied_by?(Gem::Version.new(RUBY_VERSION))
  gem "logger", "1.6.5" if Gem::Requirement.new("> 3.5.0.dev").satisfied_by?(Gem::Version.new(RUBY_VERSION))
end
