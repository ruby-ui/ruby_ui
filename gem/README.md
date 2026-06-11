# RubyUI (former PhlexUI) 🚀

Beautifully designed components that you can copy and paste into your apps. Accessible. Customizable. Open Source.

This is NOT a component library. It's a collection of re-usable components that you can generate or copy and paste into your apps.

Pick the components you need. Copy and paste the code into your project and customize to your needs. The code is yours.

Use this as a reference to build your own component libraries.

### Key Features:

- **Built for Speed** ⚡: RubyUI leverages Phlex, which is up to 12x faster than traditional Rails ERB templates.
- **Stunning UI** 🎨: Design beautiful, streamlined, and customizable UIs that sell your app effortlessly.
- **Stay Organized** 📁: Keep your UI components well-organized and easy to manage.
- **Customer-Centric UX** 🧑‍💼: Create memorable app experiences for your users.
- **Completely Customizable** 🔧: Full control over the design of all components.
- **Minimal Dependencies** 🍃: Uses custom-built Stimulus.js controllers to keep your app lean.
- **Reuse with Ease** ♻️: Build components once and use them seamlessly across your project.

### How to Use:

1. **Find the perfect component** 🔍: Browse live-embedded components on our documentation page.
2. **Copy the snippet** 📋: Easily copy code snippets for quick implementation.
3. **Make it yours** 🎨: Customize components using Tailwind utility classes to fit your specific needs.

## Installation 🚀

> [!NOTE]
> RubyUI 1.0 requires Ruby 3.2 or later

### 1. Install the gem

```bash
bundle add ruby_ui --group development --require false
```

or add it to your Gemfile:

```ruby
gem "ruby_ui", group: :development, require: false
```

### 2. Run the installer:

```bash
bin/rails g ruby_ui:install
```

### 3. Done! 🎉

You can generate your components using `ruby_ui:component` generator.

```bash
bin/rails g ruby_ui:component Accordion
```

You can also generate multiple components at once.

```bash
bin/rails g ruby_ui:component Button Link Input Textarea
```

You also can generate all components using `ruby_ui:component:all` generator

## Documentation 📖

Visit https://rubyui.com/docs/introduction to view the full documentation, including:

- Detailed component guides
- Themes
- Lookbook
- Getting started guide

## Speed Comparison 🏎️

RubyUI, powered by Phlex, outperforms alternative methods:

- Phlex: Baseline 🏁
- ViewComponent: ~1.5x slower 🚙
- ERB Templates: ~5x slower 🐢

See the original [view layers benchmark](https://github.com/KonnorRogers/view-layer-benchmarks) by @KonnorRogers and its [variations](https://github.com/KonnorRogers/view-layer-benchmarks/forks).

## Importmap notes:

If you run into importmap issues this stackoverflow question might help:
https://stackoverflow.com/questions/70548841/how-to-add-custom-js-file-to-new-rails-7-project/72855705

## License 📜

Licensed under the [MIT license](https://github.com/shadcn/ui/blob/main/LICENSE.md).

---

## Sponsors
[![DigitalOcean Referral Badge](https://web-platforms.sfo2.cdn.digitaloceanspaces.com/WWW/Badge%201.svg)](https://www.digitalocean.com/?refcode=0fdaefc76c39&utm_campaign=Referral_Invite&utm_medium=Referral_Program&utm_source=badge)


© 2024 RubyUI. All rights reserved. 🔒
