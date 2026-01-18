FactoryBot.define do
  factory :order do
    user
    status { :pending }
  end
end
