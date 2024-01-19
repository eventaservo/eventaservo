class SolidQueue::FailedExecution
  def self.ransackable_attributes(auth_object = nil)
    ["created_at", "error", "id", "id_value", "job_id"]
  end

  def self.ransackable_associations(auth_object = nil)
    ["job"]
  end
end

ActiveAdmin.register SolidQueue::FailedExecution do
  menu parent: "SolidQueue", label: "Failed Executions"

  actions :all, except: %i[new destroy edit]
end
