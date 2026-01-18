require "rails_helper"

RSpec.describe ProductPolicy, type: :policy do
  let(:admin) { create(:user, role: :admin) }
  let(:user) { create(:user, role: :user) }
  let(:product) { create(:product) }

  describe "#create?" do
    it "denies access if user is not an admin" do
      policy = ProductPolicy.new(user, product)
      expect(policy.create?).to be false
    end

    it "allows access if user is an admin" do
      policy = ProductPolicy.new(admin, product)
      expect(policy.create?).to be true
    end
  end

  describe "#show?" do
    it "allows access for everyone to view products" do
      policy_user = ProductPolicy.new(user, product)
      policy_admin = ProductPolicy.new(admin, product)
      expect(policy_user.show?).to be true
      expect(policy_admin.show?).to be true
    end
  end
end