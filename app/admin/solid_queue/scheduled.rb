class SolidQueue::ScheduledExecution
  def self.ransackable_associations(auth_object = nil)
    ["job"]
  end

  def self.ransackable_attributes(auth_object = nil)
    ["created_at", "id", "id_value", "job_id", "priority", "queue_name", "scheduled_at"]
  end
end

ActiveAdmin.register SolidQueue::ScheduledExecution do
  menu parent: "SolidQueue", label: "Scheduled Executions"

  includes :job

  actions :all, except: %i[new destroy edit]
end
