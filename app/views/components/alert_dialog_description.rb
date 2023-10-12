# frozen_string_literal: true

class AlertDialogDescription < ApplicationComponent
  def template(&)
    p(class: "text-sm text-muted-foreground", &)
  end
end
