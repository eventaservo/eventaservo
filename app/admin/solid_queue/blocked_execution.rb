class SolidQueue::BlockedExecution
  def self.ransackable_attributes(auth_object = nil)
    ["concurrency_key", "created_at", "expires_at", "id", "id_value", "job_id", "priority", "queue_name"]
  end

  def self.ransackable_associations(auth_object = nil)
    ["job", "semaphore"]
  end
end

ActiveAdmin.register SolidQueue::BlockedExecution do
  menu parent: "SolidQueue", label: "Blocked Executions"

  actions :all, except: %i[new destroy edit]
end
