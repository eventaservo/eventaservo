class ApplicationService
  def self.call(*, **)
    new(*, **).call
  end

  def success(payload = nil)
    Response.new(true, payload)
  end

  def failure(error)
    Response.new(false, nil, error)
  end

  Response = Struct.new(:success?, :payload, :error) do
    def failure?
      !success?
    end
  end
end
