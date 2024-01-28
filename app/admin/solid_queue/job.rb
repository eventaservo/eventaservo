class SolidQueue::Job
  def self.ransackable_attributes(auth_object = nil)
    ["active_job_id", "arguments", "class_name", "concurrency_key", "created_at", "finished_at", "id", "id_value", "priority", "queue_name", "scheduled_at", "updated_at"]
  end

  def self.ransackable_associations(auth_object = nil)
    ["blocked_execution", "claimed_execution", "failed_execution", "ready_execution", "scheduled_execution"]
  end
end

ActiveAdmin.register SolidQueue::Job do
  menu parent: "SolidQueue", label: "Jobs"

  actions :all, except: %i[new destroy edit]
end
