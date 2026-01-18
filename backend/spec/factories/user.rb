FactoryBot.define do
  factory :user do
    email { "user@example.com" }
    password { "password123" }
    role { :user }

    trait :admin do
      role { :admin }
    end
  end
end
