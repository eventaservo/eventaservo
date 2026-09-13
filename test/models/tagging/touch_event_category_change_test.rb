# frozen_string_literal: true

require "test_helper"

class Tagging::TouchEventCategoryChangeTest < ActiveSupport::TestCase
  test "creating a category tagging touches the taggable event so the webcal feed sees the change" do
    event = events(:esperanto_meetup)
    kursa_tag = tags(:kurso)

    previous_timestamp = event.updated_at
    travel 1.minute do
      event.taggings.create!(tag: kursa_tag)

      assert_operator event.reload.updated_at, :>, previous_timestamp
    end
  end

  test "destroying a category tagging touches the taggable event" do
    event = events(:esperanto_meetup)
    tagging = event.taggings.first!

    previous_timestamp = event.updated_at
    travel 1.minute do
      tagging.destroy!

      assert_operator event.reload.updated_at, :>, previous_timestamp
    end
  end

  test "creating a characteristic tagging does not touch the taggable event" do
    event = events(:esperanto_meetup)
    anonca_tag = tags(:anonco)

    previous_timestamp = event.updated_at
    travel 1.minute do
      event.taggings.create!(tag: anonca_tag)

      assert_equal previous_timestamp, event.reload.updated_at
    end
  end

  test "destroying a characteristic tagging does not touch the taggable event" do
    event = events(:esperanto_meetup)
    tagging = event.taggings.create!(tag: tags(:anonco))

    previous_timestamp = event.updated_at
    travel 1.minute do
      tagging.destroy!

      assert_equal previous_timestamp, event.reload.updated_at
    end
  end
end
