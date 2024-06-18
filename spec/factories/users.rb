FactoryBot.define do
  factory :user do
    first_name {'Alex'}
    middle_name {'Alexandrovich'}
    last_name { 'Alexandrov' }
    association :region
    sequence(:email) { |n| "user#{n}@example.com" }
    password { 'password' }
    password_confirmation { 'password' }
    role { 'user' }
  end
end
