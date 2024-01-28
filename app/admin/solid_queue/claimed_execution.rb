class SolidQueue::ClaimedExecution
  def self.ransackable_attributes(auth_object = nil)
    ["created_at", "id", "id_value", "job_id", "process_id"]
  end

  def self.ransackable_associations(auth_object = nil)
    ["job", "process"]
  end
end

ActiveAdmin.register SolidQueue::ClaimedExecution do
  menu parent: "SolidQueue", label: "Claimed Executions"

  actions :all, except: %i[new destroy edit]
end
