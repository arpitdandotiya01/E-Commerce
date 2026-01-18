FactoryBot.define do
  factory :product do
    name { "Test Product" }
    price { 1000 }
    stock_quantity { 10 }
    active { true }
  end
end
