class SolidQueue::Semaphore
  def self.ransackable_attributes(auth_object = nil)
    ["created_at", "expires_at", "id", "id_value", "key", "updated_at", "value"]
  end
end

ActiveAdmin.register SolidQueue::Semaphore do
  menu parent: "SolidQueue", label: "Semaphore"

  actions :all, except: %i[new destroy edit]
end
