# CSS Bundling for Rails

Use [Tailwind CSS](https://tailwindcss.com), [Bootstrap](https://getbootstrap.com/), [Bulma](https://bulma.io/), [PostCSS](https://postcss.org), or [Dart Sass](https://sass-lang.com/) to bundle and process your CSS, then deliver it via the asset pipeline in Rails. This gem provides installers to get you going with the bundler of your choice in a new Rails application, and a convention to use `app/assets/builds` to hold your bundled output as artifacts that are not checked into source control (the installer adds this directory to `.gitignore` by default).

You develop using this approach by running the bundler in watch mode in a terminal with `yarn build:css --watch` (and your Rails server in another, if you're not using something like [puma-dev](https://github.com/puma/puma-dev)). You can also use `./bin/dev`, which will start both the Rails server and the CSS build watcher (along with a JS build watcher, if you're also using `jsbundling-rails`).

Whenever the bundler detects changes to any of the stylesheet files in your project, it'll bundle `app/assets/stylesheets/application.[bundler].css` into `app/assets/builds/application.css`. This build output takes over from the regular asset pipeline default file. So you continue to refer to the build output in your layout using the standard asset pipeline approach with `<%= stylesheet_link_tag "application" %>`.

When you deploy your application to production, the `css:build` task attaches to the `assets:precompile` task to ensure that all your package dependencies from `package.json` have been installed via yarn, and then runs `yarn build:css` to process your stylesheet entrypoint, as it would in development. This output is then picked up by the asset pipeline, digested, and copied into public/assets, as any other asset pipeline file.

This also happens in testing where the bundler attaches to the `test:prepare` task to ensure the stylesheets have been bundled before testing commences. If your test framework does not call the `test:prepare` Rake task, ensure that your test framework runs `css:build` to bundle stylesheets before testing commences. If your setup uses [jsbundling-rails](https://github.com/rails/jsbundling-rails) (ie, esbuild + tailwind), you will also need to run `javascript:build`.

That's it!

You can configure your bundler options in the `build:css` script in `package.json` or `postcss.config.js` for PostCSS.

## Installation

You must already have node and yarn installed on your system. You will also need npx version 7.1.0 or later. Then:

1. Run `./bin/bundle add cssbundling-rails`
2. Run `./bin/rails css:install:[tailwind|bootstrap|bulma|postcss|sass]`

Or, in Rails 7+, you can preconfigure your new application to use `cssbundling-rails` for `bootstrap`, `bulma` or `postcss` with `rails new myapp --css [bootstrap|bulma|postcss]`.

## FAQ

### How does this compare to tailwindcss-rails and dartsass-rails?

If you're already relying on Node to process your JavaScript, this gem is the way to go. But if you're using [the default import map setup in Rails 7+](https://github.com/rails/importmap-rails/), you can avoid having to deal with Node at all by using the standalone versions of Tailwind CSS and Dart Sass that are available through [tailwindcss-rails](https://github.com/rails/tailwindcss-rails/) and [dartsass-rails](https://github.com/rails/dartsass-rails/). It's simpler, fewer moving parts, and still has all the functionality.

In Rails 7+, you can preconfigure your new application to use `tailwindcss-rails` and `dartsass-rails` with `rails new myapp --css [tailwind|sass]`.

### How do I import relative CSS files with Tailwind?

Tailwind CSS 4 is configured using native CSS. Instead of bundling all your CSS into a single file, consider referencing individual CSS files directly. This approach simplifies setup and improves caching performance. To reference multiple CSS files in Rails, update the stylesheet_link_tag in application.html.erb like this:

```erb
<%= stylesheet_link_tag "application", "other", "styles", "data-turbo-track": "reload" %>
```

This ensures your files are properly linked and ready to use.

### How do I avoid SassC::SyntaxError exceptions on existing projects?

Some CSS packages use new CSS features that are not supported by the default SassC rails integration that previous versions of Rails used. If you hit such an incompatibility, it'll likely be in the form of a `SassC::SyntaxError` when running `assets:precompile`. The fix is to `bundle remove sass-rails` (or `sassc-rails`, if you were using that).

### Why do I get `application.css not in asset pipeline` in production?

A common issue is that your repository does not contain the output directory used by the build commands. You must have `app/assets/builds` available. Add the directory with a `.keep` file, and you'll ensure it's available in production.

### How do I avoid `ActionView::Template::Error: Error: Function rgb is missing argument $green`?

This might happen if your Gemfile.lock contains the legacy `sassc-rails`, which might be need while progressively migrating your project, or which might be a transitive dependency of a gem your project depends on and over which you have no control. In this case, prevent Sprockets from bundling the CSS on top of the bundling already performed by this gem. Make sure do this for all environments, not only production, otherwise your test suite may fail.

```
# config/initializers/assets.rb
Rails.application.config.assets.css_compressor = nil
```

### Why isn't Rails using my updated css files?

Watch out - if you precompile your files locally, those will be served over the dynamically created ones you expect. The solution:

```shell
rails assets:clobber
```

### How do I include 3rd party stylesheets from `node_modules` in my bundle?

Use an `@import` statement and path to a specific stylesheet, omitting the `node_modules/` segment and the file's extension. For example:

```scss
/* Desired file is at at node_modules/select2/dist/css/select2.css */
@import "select2/dist/css/select2";
```

## License

CSS Bundling for Rails is released under the [MIT License](https://opensource.org/licenses/MIT).
