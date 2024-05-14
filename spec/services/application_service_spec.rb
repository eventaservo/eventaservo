require "rails_helper"

describe ApplicationService do
  context "success" do
    let(:some_service) do
      Class.new(ApplicationService) do
        def initialize(arg1:, arg2:)
          @arg1 = arg1
          @arg2 = arg2
        end

        def call
          success({arg1: @arg1, arg2: @arg2})
        end
      end
    end

    describe ".call" do
      subject(:service) { some_service.call(arg1: "a", arg2: "b") }

      it "success? is true" do
        expect(service.success?).to be true
      end

      it "failure? is false" do
        expect(service.failure?).to be false
      end

      it "payload is populated" do
        expect(service.payload).to eql({arg1: "a", arg2: "b"})
      end
    end
  end

  context "failure" do
    let(:some_service) do
      Class.new(ApplicationService) do
        def initialize(arg1, arg2)
          @arg1 = arg1
          @arg2 = arg2
        end

        def call
          failure({error: "#{@arg1}, #{@arg2}"})
        end
      end
    end

    describe ".call" do
      subject(:service) { some_service.call("a", "b") }

      it "success? is false" do
        expect(service.success?).to be false
      end

      it "failure? is true" do
        expect(service.failure?).to be true
      end

      it "error is populated" do
        expect(service.error).to eql({error: "a, b"})
      end
    end
  end
end
