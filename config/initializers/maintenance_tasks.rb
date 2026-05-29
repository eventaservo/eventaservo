# frozen_string_literal: true

MaintenanceTasks.report_errors_as_handled = false
MaintenanceTasks.parent_controller = "ApplicationController"
MaintenanceTasks.metadata = -> do
  {user_email: current_user.email, user_id: current_user.id}
end
