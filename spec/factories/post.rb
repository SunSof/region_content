FactoryBot.define do
  factory :post do
    title {"Собаки"}
    content {"Мои любимые питомцы"}
    status {'draft'}
    published_at {Time.zone.local(2023, 1, 1, 10, 0, 0)}
    association :region
    user { association :user }
  end
end
