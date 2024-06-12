FactoryBot.define do
  factory :user do
    first_name {'Alex'}
    middle_name {'Alexandrovich'}
    last_name { 'Alexandrov' }
    region {'Moscow'}
    sequence(:email) { "user@example.com" }
    password { 'password' }
    password_confirmation { 'password' }
    role { 'user' }
  end
end
