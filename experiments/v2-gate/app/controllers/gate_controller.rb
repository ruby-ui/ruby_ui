# One view per golden scenario under app/views/gate/, written exactly as a user
# of 2.0 would write it. The parity suite renders these views with no request
# through `GateController.render(template:)`; the browser and the system tests
# reach them at /gate/<scenario> with the application layout.
class GateController < ApplicationController
  SCENARIO = /\A[a-z0-9_]+\z/

  def show
    return head(:not_found) unless params[:scenario].match?(SCENARIO)

    render template: "gate/#{params[:scenario]}"
  end

  # The 1.6 snapshots were recorded outside Rails, where DataTableForm falls
  # back to this literal token. Pinning it keeps data_table/* comparable
  # (plan §4, Phase 4); harmless for every other scenario.
  def form_authenticity_token(**)
    "csrf-token-placeholder"
  end
end
