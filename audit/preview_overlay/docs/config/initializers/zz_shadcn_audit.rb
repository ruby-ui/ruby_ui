# frozen_string_literal: true

# Added by the shadcn audit (audit/preview_overlay) to an archived checkout;
# never part of the real docs app. Named zz_ so it runs after phlex.rb, which
# makes app/views autoload as Views::.

# Fixture views define ShadcnAuditFixtures::<Name>, not Views::..., so Zeitwerk
# must not manage them; the controller loads them by path.
Rails.autoloaders.main.ignore(Rails.root.join("app/views/shadcn_audit_fixtures"))

if Rails.env.development?
  Rails.application.routes.prepend do
    get "__audit/:component", to: "shadcn_audit_fixtures#show"
  end
end
