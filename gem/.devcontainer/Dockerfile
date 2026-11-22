# Should match .ruby-version. Held at 4.0.9 until ghcr.io/rails/devcontainer/images/ruby
# publishes a 4.0.10 tag; bump it then.
ARG RUBY_VERSION=4.0.9
FROM ghcr.io/rails/devcontainer/images/ruby:$RUBY_VERSION

# Ensure binding is always 0.0.0.0
# Binds the server to all IP addresses of the container, so it can be accessed from outside the container.
ENV BINDING="0.0.0.0"
