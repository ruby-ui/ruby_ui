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

Would you like me to expand on any part of the contributing guide?

[![DigitalOcean Referral Badge](https://web-platforms.sfo2.cdn.digitaloceanspaces.com/WWW/Badge%201.svg)](https://www.digitalocean.com/?refcode=0fdaefc76c39&utm_campaign=Referral_Invite&utm_medium=Referral_Program&utm_source=badge)
