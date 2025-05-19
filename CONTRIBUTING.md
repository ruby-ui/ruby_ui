# Contributing to RubyUI

Thank you for your interest in contributing to RubyUI! This document provides guidelines for contributing to the project.

## Development Setup

We recommend using the provided devcontainer to set up your development environment. This ensures a consistent environment for all contributors.

1. Make sure you have Docker
2. Clone the repository
3. Open the project in you editor
4. Select "Reopen in Container" if you are using VSCode or any other method to run the project
5. The devcontainer will set up everything you need to start developing

## Contribution Process

1. Fork the repository
2. Create a new branch for your changes
3. Make your changes
4. Run tests to ensure your changes don't break existing functionality: `bundle exec rake test`
5. Run the linter to ensure consistent code formatting: `bundle exec rake standard`
6. Submit a Pull Request to the main repository

## Focus Areas

We prioritize:
- Improving existing components rather than adding new ones
- Preserving the shadcn look and feel
- Enhancing documentation
- Fixing bugs

## Code Standards

We follow Standard Ruby conventions for code style. The CI pipeline runs `standard` to verify code quality.

## Testing

While we don't have specific test coverage requirements, all contributions should include tests for new functionality and ensure existing tests pass.

## Documentation

If your changes include new components, modify how components should be used, or add new behaviors, it is highly recommended to also open a PR on the [ruby-ui/web](https://github.com/ruby-ui/web) repository. This ensures the documentation website stays up-to-date with the latest component changes.

Thank you for contributing to make RubyUI better! 