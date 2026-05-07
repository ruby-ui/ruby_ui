Rails need a plug n play system for creating streamlined ui components.

Phlex looks fun and fast, so I thought I'd start creating ui components with it.

## Contributing - Local Development Setup

### Install the Gem Locally

To contribute to this project, it's recommended to install the gem locally and point to it in your Gemfile:

```ruby
gem "ruby_ui", path: "../ruby_ui"
```

## Working with Components

### Component Development Workflow

1. Eject the component you want to modify using the generator:
   ```bash
   rails generate ruby_ui:component combobox
   ```
2. Make your desired changes to the ejected component
3. Once you're satisfied with the modifications, integrate the component back into the gem in the appropriate location

This workflow allows you to iterate quickly on components while maintaining the gem's structure.

## Site Files

The docs app serves `/llms.txt`, `/llms-full.txt`, and `/sitemap.xml` from `public/`.
Those files are generated from `app/lib/site_files.rb`, which is the source of truth for the LLM link map and sitemap URL list.

After changing public routes, controllers, or views, update `SiteFiles` if the change adds, removes, or renames a public URL. Then refresh the generated files:

```bash
bin/rails site_files:generate
```

Review the resulting diff in:

- `public/llms.txt`
- `public/llms-full.txt`
- `public/sitemap.xml`

Set `SITE_FILES_OUTPUT_DIR=tmp/site_files` to generate into a temporary directory instead of overwriting `public/`.
