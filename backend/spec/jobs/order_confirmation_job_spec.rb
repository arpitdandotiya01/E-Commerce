require "rails_helper"

RSpec.describe OrderConfirmationJob, type: :job do
  let(:order) { create(:order) }

  it "runs without errors" do
    expect {
      described_class.perform_now(order.id)
    }.not_to raise_error
  end
end
