# frozen_string_literal: true

class Pages::LicenseView < ApplicationView
  def template
    render Shared::GridPattern.new
    div(class: 'container max-w-2xl mx-auto px-4 pb-24 space-y-10') do
      div(class: "space-y-4 py-16 md:py-24 md:pb-20 max-w-lg mx-auto") do
        render PhlexUI::Typography::H1.new(class: 'text-center') { "License" }
        render PhlexUI::Typography::Lead.new(class: 'text-center') { "Learn more about the PhlexUI licensing model. Have a question? Get in touch and we'll help you out." }
      end
      personal_license
      team_license
      enforcement
      copyright
      liability
      governing_law
      questions
    end
  end

  private

  # SECTIONS
  def personal_license
    section do
      heading { "Personal License" }
      para { "PhlexUI.com grants you an ongoing, non-exclusive license to use the Components and Templates." }
      para { "The license grants permission to one individual (the Licensee) to access and use the Components and Templates." }
      para do
        plain "You "
        highlight { "can" }
        plain ":"
      end
      list(items: [
        "Use the Components and Templates to create unlimited End Products.",
        "Modify the Components and Templates to create derivative components and templates. Those components and templates are subject to this license.",
        "Use the Components and Templates to create unlimited End Products for unlimited Clients.",
        "Use the Components and Templates to create End Products where the End Product is sold to End Users.",
        "Use the Components and Templates to create End Products that are open source and freely available to End Users."
      ])
      para do
        plain "You "
        highlight { "cannot" }
        plain ":"
      end
      list(items: [
        "Use the Components and Templates to create End Products that are designed to allow an End User to build their own End Products using the Components and Templates or derivatives of the Components and Templates.",
        "Re-distribute the Components and Templates or derivatives of the Components and Templates separately from an End Product, neither in code nor as design assets.",
        "Share your access to the Components and Templates with any other individuals.",
        "Use the Components and Templates to produce anything that may be deemed by PhlexUI.com, in their sole and absolute discretion, to be competitive or in conflict with the business of PhlexUI.com."
      ])
      subheading { "Example usage" }
      para do
        plain "Examples of usage "
        highlight { "allowed" }
        plain " by the license:"
      end
      list(items: [
        "Creating a personal website by yourself.",
        "Creating a website or web application for a client that will be owned by that client.",
        "Creating a commercial SaaS application (like an invoicing app for example) where end users have to pay a fee to use the application.",
        "Creating a commercial self-hosted web application that is sold to end users for a one-time fee.",
        "Creating a web application where the primary purpose is clearly not to simply re-distribute the components (like a conference organization app that uses the components for its UI for example) that is free and open source, where the source code is publicly available."
      ])
      
      para do
        plain "Examples of usage "
        highlight { "not allowed" }
        plain " by the license:"
      end
      list(items: [
        "Creating a repository of your favorite PhlexUI components or templates (or derivatives based on PhlexUI components or templates) and publishing it publicly.",
        "Creating a UI library using PhlexUI components and making it available either for sale or for free.",
        "Converting a PhlexUI template to another framework and making it available either for sale or for free.",
        "Create a Figma or Sketch UI kit based on the PhlexUI component designs.",
        "Creating a \"website builder\" project where end users can build their own websites using components or templates included with or derived from PhlexUI.",
        "Creating a theme, template, or project starter kit using the components or templates and making it available either for sale or for free.",
        "Creating an admin panel tool (like ActiveAdmin) that is made available either for sale or for free."
      ])

      subheading { "Personal License Definitions" }
      list(items: [
        "Licensee: The individual who has purchased a Personal License.",
        "Components and Templates: The source code and design assets made available to the Licensee after purchasing a PhlexUI license.",
        "End Product: Any artifact produced that incorporates the Components or Templates or derivatives of the Components or Templates.",
        "End User: A user of an End Product.",
        "Client: An individual or entity receiving custom professional services directly from the Licensee, produced specifically for that individual or entity. Customers of software-as-a-service products are not considered clients for the purpose of this document."
      ])
    end
  end

  def team_license
    section do
      heading { "Team License" }
      para { "PhlexUI.com grants you an ongoing, non-exclusive license to use the Components and Templates." }
      para { "The license grants permission for up to 25 Employees and Contractors of the Licensee to access and use the Components and Templates." }
      para do
        plain "You "
        highlight { "can" }
        plain ":"
      end
      list(items: [
        "Use the Components and Templates to create unlimited End Products.",
        "Modify the Components and Templates to create derivative components and templates. Those components and templates are subject to this license.",
        "Use the Components and Templates to create unlimited End Products for unlimited Clients.",
        "Use the Components and Templates to create End Products where the End Product is sold to End Users.",
        "Use the Components and Templates to create End Products that are open source and freely available to End Users."
      ])
      para do
        plain "You "
        highlight { "cannot" }
        plain ":"
      end
      list(items: [
        "Use the Components or Templates to create End Products that are designed to allow an End User to build their own End Products using the Components or Templates or derivatives of the Components or Templates.",
        "Re-distribute the Components or Templates or derivatives of the Components or Templates separately from an End Product.",
        "Use the Components or Templates to create End Products that are the property of any individual or entity other than the Licensee or Clients of the Licensee.",
        "Grant access to the Components and Templates to individuals who are not an Employee or Contractor of the Licensee.",
        "Use the Components or Templates to produce anything that may be deemed by PhlexUI.com, in their sole and absolute discretion, to be competitive or in conflict with the business of PhlexUI.com."
      ])
      subheading { "Example usage" }
      para do
        plain "Examples of usage "
        highlight { "allowed" }
        plain " by the license:"
      end
      list(items: [
        "Creating a website for your company.",
        "Creating a website or web application for a client that will be owned by that client.",
        "Creating a commercial SaaS application (like an invoicing app for example) where end users have to pay a fee to use the application.",
        "Creating a commercial self-hosted web application that is sold to end users for a one-time fee.",
        "Creating a web application where the primary purpose is clearly not to simply re-distribute the components or templates (like a conference organization app that uses the components or a template for its UI for example) that is free and open source, where the source code is publicly available."
      ])
      
      para do
        plain "Examples of usage "
        highlight { "not allowed" }
        plain " by the license:"
      end
      list(items: [
        "Creating a repository of your favorite PhlexUI components or template (or derivatives based on PhlexUI components or templates) and publishing it publicly.",
        "Creating a UI library using PhlexUI components and making it available either for sale or for free.",
        "Converting a PhlexUI template to another framework and making it available either for sale or for free.",
        "Creating a \"website builder\" project where end users can build their own websites using components or templates included with or derived from PhlexUI.",
        "Creating a theme or template using the components or templates and making it available either for sale or for free.",
        "Creating an admin panel tool (like ActiveAdmin) that is made available either for sale or for free.",
        "Creating any End Product that is not the sole property of either your company or a client of your company. For example, your employees/contractors can't use your company PhlexUI license to build their own websites or side projects.",
        "Giving someone access to PhlexUI when they purchase a product from you. For example, you can't use a Team License as a way to give someone access to PhlexUI when they purchase an online course from you.",
        "Selling access to your team account to people who don't work for your company."
      ])

      subheading { "Team License Definitions" }
      list(items: [
        "Licensee: The business entity that has purchased a Team License.",
        "Components and Templates: The source code and design assets made available to the Licensee after purchasing a PhlexUI license.",
        "End Product: Any artifact produced that incorporates the Components or Templates or derivatives of the Components or Templates.",
        "End User: A user of an End Product.",
        "Employee: A full-time or part-time employee of the Licensee.",
        "Contractor: An individual or business entity contracted to perform services for the Licensee.",
        "Client: An individual or entity receiving custom professional services directly from the Licensee, produced specifically for that individual or entity. Customers of software-as-a-service products are not considered clients for the purpose of this document."
      ])
    end
  end

  def enforcement
    section do
      heading { "Enforcement" }
      para { "If you are found to be in violation of the license, access to your PhlexUI account will be terminated, and a refund may be issued at our discretion. When license violation is blatant and malicious (such as intentionally redistributing the Components or Templates through private warez channels), no refund will be issued." }
    end
  end

  def copyright
    section do
      heading { "Copyright" }
      para { "The copyright of the Components and Templates is owned by PhlexUI.com. "}
      para { "You are granted only the permissions described in this license; all other rights are reserved. PhlexUI.com reserves the right to pursue legal remedies for any unauthorized use of the Components or Templates outside the scope of this license." }
    end
  end

  def liability
    section do
      heading { "Liability" }
      para { "PhlexUI.com’s liability to you for costs, damages, or other losses arising from your use of the Components or Templates — including third-party claims against you — is limited to a refund of your license fee. PhlexUI.com may not be held liable for any consequential damages related to your use of the Components or Templates." }
    end
  end

  def governing_law
    section do
      heading { "Governing Law" }
      para { "This Agreement is governed by the laws applicable to the jurisdiction of PhlexUI.com. Legal proceedings related to this Agreement may only be brought in the courts of this jurisdiction. You agree to service of process at the e-mail address on your original order." }
    end
  end

  def questions
    section do
      heading { "Questions?" }
      para do
        plain "Unsure which license you need, or unsure if your use case is covered by our licenses? Email us at "
        render PhlexUI::Link.new(href: "mailto:#{ENV['SUPPORT_EMAIL']}", class: '!px-1') { ENV['SUPPORT_EMAIL'] }
        plain " with your questions."
      end
    end
  end

  # COMPONENTS
  def section(&)
    div(class: 'space-y-4', &)
  end

  def heading(&block)
    render PhlexUI::Typography::H2.new(class: 'text-xl') { block.call }
  end

  def subheading(&block)
    render PhlexUI::Typography::H4.new(class!: 'font-semibold') { block.call }
  end

  def para(&block)
    render PhlexUI::Typography::P.new(class: 'text-muted-foreground text-sm') { block.call }
  end

  def highlight(&block)
    span(class: "text-foreground font-semibold") { block.call }
  end

  def list(items: [])
    render PhlexUI::Typography::List.new(class: 'text-muted-foreground indent-0 text-sm', items: items)
  end
end

# License

# License
# Learn more about the PhlexUI licensing model. Have a question? Get in touch at support@phlexui.com, and we’ll help you out.

# Personal License

# PhlexUI.com grants you an ongoing, non-exclusive license to use the Components and Templates.

# The license grants permission to one individual (the Licensee) to access and use the Components and Templates.

# You can:

# Use the Components and Templates to create unlimited End Products.
# Modify the Components and Templates to create derivative components and templates. Those components and templates are subject to this license.
# Use the Components and Templates to create unlimited End Products for unlimited Clients.
# Use the Components and Templates to create End Products where the End Product is sold to End Users.
# Use the Components and Templates to create End Products that are open source and freely available to End Users.
# You cannot:

# Use the Components and Templates to create End Products that are designed to allow an End User to build their own End Products using the Components and Templates or derivatives of the Components and Templates.
# Re-distribute the Components and Templates or derivatives of the Components and Templates separately from an End Product, neither in code nor as design assets.
# Share your access to the Components and Templates with any other individuals.
# Use the Components and Templates to produce anything that may be deemed by PhlexUI.com, in their sole and absolute discretion, to be competitive or in conflict with the business of PhlexUI.com.
# Example usage:
# Examples of usage allowed by the license:

# Creating a personal website by yourself.
# Creating a website or web application for a client that will be owned by that client.
# Creating a commercial SaaS application (like an invoicing app for example) where end users have to pay a fee to use the application.
# Creating a commercial self-hosted web application that is sold to end users for a one-time fee.
# Creating a web application where the primary purpose is clearly not to simply re-distribute the components (like a conference organization app that uses the components for its UI for example) that is free and open source, where the source code is publicly available.
# Examples of usage not allowed by the license:

# Creating a repository of your favorite PhlexUI components or templates (or derivatives based on PhlexUI components or templates) and publishing it publicly.
# Creating a UI library using PhlexUI components and making it available either for sale or for free.
# Converting a PhlexUI template to another framework and making it available either for sale or for free.
# Create a Figma or Sketch UI kit based on the PhlexUI component designs.
# Creating a "website builder" project where end users can build their own websites using components or templates included with or derived from PhlexUI.
# Creating a theme, template, or project starter kit using the components or templates and making it available either for sale or for free.
# Creating an admin panel tool (like Laravel Nova or ActiveAdmin) that is made available either for sale or for free.
# Personal License Definitions

# Licensee: The individual who has purchased a Personal License.
# Components and Templates: The source code and design assets made available to the Licensee after purchasing a PhlexUI license.
# End Product: Any artifact produced that incorporates the Components or Templates or derivatives of the Components or Templates.
# End User: A user of an End Product.
# Client: An individual or entity receiving custom professional services directly from the Licensee, produced specifically for that individual or entity. Customers of software-as-a-service products are not considered clients for the purpose of this document.
# Team License

# PhlexUI.com grants you an ongoing, non-exclusive license to use the Components and Templates.

# The license grants permission for up to 25 Employees and Contractors of the Licensee to access and use the Components and Templates.

# You can:

# Use the Components and Templates to create unlimited End Products.
# Modify the Components and Templates to create derivative components and templates. Those components and templates are subject to this license.
# Use the Components and Templates to create unlimited End Products for unlimited Clients.
# Use the Components and Templates to create End Products where the End Product is sold to End Users.
# Use the Components and Templates to create End Products that are open source and freely available to End Users.
# You cannot:

# Use the Components or Templates to create End Products that are designed to allow an End User to build their own End Products using the Components or Templates or derivatives of the Components or Templates.
# Re-distribute the Components or Templates or derivatives of the Components or Templates separately from an End Product.
# Use the Components or Templates to create End Products that are the property of any individual or entity other than the Licensee or Clients of the Licensee.
# Grant access to the Components and Templates to individuals who are not an Employee or Contractor of the Licensee.
# Use the Components or Templates to produce anything that may be deemed by PhlexUI.com, in their sole and absolute discretion, to be competitive or in conflict with the business of PhlexUI.com.
# Example usage:
# Examples of usage allowed by the license:

# Creating a website for your company.
# Creating a website or web application for a client that will be owned by that client.
# Creating a commercial SaaS application (like an invoicing app for example) where end users have to pay a fee to use the application.
# Creating a commercial self-hosted web application that is sold to end users for a one-time fee.
# Creating a web application where the primary purpose is clearly not to simply re-distribute the components or templates (like a conference organization app that uses the components or a template for its UI for example) that is free and open source, where the source code is publicly available.
# Examples of use not allowed by the license:

# Creating a repository of your favorite PhlexUI components or template (or derivatives based on PhlexUI components or templates) and publishing it publicly.
# Creating a UI library using PhlexUI components and making it available either for sale or for free.
# Converting a PhlexUI template to another framework and making it available either for sale or for free.
# Creating a "website builder" project where end users can build their own websites using components or templates included with or derived from PhlexUI.
# Creating a theme or template using the components or templates and making it available either for sale or for free.
# Creating an admin panel tool (like Laravel Nova or ActiveAdmin) that is made available either for sale or for free.
# Creating any End Product that is not the sole property of either your company or a client of your company. For example, your employees/contractors can't use your company PhlexUI license to build their own websites or side projects.
# Giving someone access to PhlexUI when they purchase a product from you. For example, you can't use a Team License as a way to give someone access to PhlexUI when they purchase an online course from you.
# Selling access to your team account to people who don't work for your company.
# Team License Definitions

# Licensee: The business entity that has purchased a Team License.
# Components and Templates: The source code and design assets made available to the Licensee after purchasing a PhlexUI license.
# End Product: Any artifact produced that incorporates the Components or Templates or derivatives of the Components or Templates.
# End User: A user of an End Product.
# Employee: A full-time or part-time employee of the Licensee.
# Contractor: An individual or business entity contracted to perform services for the Licensee.
# Client: An individual or entity receiving custom professional services directly from the Licensee, produced specifically for that individual or entity. Customers of software-as-a-service products are not considered clients for the purpose of this document.

# Enforcement
# If you are found to be in violation of the license, access to your PhlexUI account will be terminated, and a refund may be issued at our discretion. When license violation is blatant and malicious (such as intentionally redistributing the Components or Templates through private warez channels), no refund will be issued.

# Copyright
# The copyright of the Components and Templates is owned by PhlexUI.com. You are granted only the permissions described in this license; all other rights are reserved. PhlexUI.com reserves the right to pursue legal remedies for any unauthorized use of the Components or Templates outside the scope of this license.

# Liability
# PhlexUI.com’s liability to you for costs, damages, or other losses arising from your use of the Components or Templates — including third-party claims against you — is limited to a refund of your license fee. PhlexUI.com may not be held liable for any consequential damages related to your use of the Components or Templates.

# Governing Law
# This Agreement is governed by the laws applicable to the jurisdiction of PhlexUI.com. Legal proceedings related to this Agreement may only be brought in the courts of this jurisdiction. You agree to service of process at the e-mail address on your original order.

# Questions?
# Unsure which license you need, or unsure if your use case is covered by our licenses? Email us at support@phlexui.com with your questions.
