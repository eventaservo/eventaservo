class SolidQueue::ReadyExecution
  def self.ransackable_attributes(auth_object = nil)
    ["created_at", "id", "id_value", "job_id", "priority", "queue_name"]
  end

  def self.ransackable_associations(auth_object = nil)
    ["job"]
  end
end

ActiveAdmin.register SolidQueue::ReadyExecution do
  menu parent: "SolidQueue", label: "Ready Executions"

  actions :all, except: %i[new destroy edit]
end
