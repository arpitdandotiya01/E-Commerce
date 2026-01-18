require "rails_helper"

RSpec.describe OrderPolicy, type: :policy do
  let(:admin) { create(:user, role: :admin) }
  let(:user) { create(:user, role: :user) }
  let(:order) { create(:order, user: user) }

  describe "#update?" do
    it "allows admin to update any order" do
      policy = OrderPolicy.new(admin, order)
      expect(policy.update?).to be true
    end

    it "denies regular user to update others' orders" do
      policy = OrderPolicy.new(user, order)
      expect(policy.update?).to be false
    end
  end
end