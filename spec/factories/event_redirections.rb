FactoryBot.define do
  factory :event_redirection do
    old_short_url { "old_short_url" }
    new_short_url { "new_short_url" }
    hits { 0 }
  end
end
