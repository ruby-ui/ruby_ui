# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = "1.0"

# Add additional assets to the asset load path.
# Rails.application.config.assets.paths << Emoji.images_path

# Inter Variable webfont (@fontsource-variable/inter). Tailwind inlines its
# @font-face rules into builds/application.css with relative `./files/*.woff2`
# URLs; this load path lets Propshaft resolve and digest those files.
Rails.application.config.assets.paths << Rails.root.join("node_modules/@fontsource-variable/inter")
