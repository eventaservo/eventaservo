# frozen_string_literal: true

require "rails_helper"

RSpec.describe RecurringEvents, type: :model do
  # Create a test class to include the concern
  let(:test_class) do
    Class.new(ApplicationRecord) do
      self.table_name = "events"
      include RecurringEvents
    end
  end

  let(:event) { test_class.new }

  describe "associations" do
    it "includes master_event association" do
      expect(test_class.reflect_on_association(:master_event)).to be_present
      expect(test_class.reflect_on_association(:master_event).class_name).to eq("Event")
    end

    it "includes child_events association" do
      expect(test_class.reflect_on_association(:child_events)).to be_present
      expect(test_class.reflect_on_association(:child_events).class_name).to eq("Event")
    end

    it "includes recurrence association" do
      expect(test_class.reflect_on_association(:recurrence)).to be_present
      expect(test_class.reflect_on_association(:recurrence).class_name).to eq("EventRecurrence")
    end
  end

  describe "scopes" do
    let!(:recurring_parent) { create(:event, is_recurring_master: true) }
    let!(:recurring_child) { create(:event, master_event: recurring_parent) }
    let!(:standalone_event) { create(:event) }

    describe ".recurring_parents" do
      it "returns only recurring parent events" do
        expect(Event.recurring_parents).to include(recurring_parent)
        expect(Event.recurring_parents).not_to include(recurring_child, standalone_event)
      end
    end

    describe ".recurring_children" do
      it "returns only recurring child events" do
        expect(Event.recurring_children).to include(recurring_child)
        expect(Event.recurring_children).not_to include(recurring_parent, standalone_event)
      end
    end

    describe ".standalone_events" do
      it "returns only standalone events" do
        expect(Event.standalone_events).to include(standalone_event)
        expect(Event.standalone_events).not_to include(recurring_parent, recurring_child)
      end
    end

    describe ".upcoming_in_series" do
      let!(:future_child) { create(:event, master_event: recurring_parent, date_start: 1.week.from_now) }
      let!(:past_child) { create(:event, master_event: recurring_parent, date_start: 1.week.ago) }

      it "returns only upcoming events in the series" do
        results = Event.upcoming_in_series(recurring_parent.id)
        expect(results).to include(future_child)
        expect(results).not_to include(past_child)
      end
    end
  end

  describe "instance methods" do
    let(:master_event) { create(:event, :recurring_parent) }
    let(:child_event) { create(:event, master_event: master_event) }
    let(:standalone_event) { create(:event) }

    describe "#recurring_parent?" do
      it "returns true for recurring parent events" do
        expect(master_event.recurring_parent?).to be true
      end

      it "returns false for non-recurring events" do
        expect(child_event.recurring_parent?).to be false
        expect(standalone_event.recurring_parent?).to be false
      end
    end

    describe "#recurring_child?" do
      it "returns true for recurring child events" do
        expect(child_event.recurring_child?).to be true
      end

      it "returns false for non-child events" do
        expect(master_event.recurring_child?).to be false
        expect(standalone_event.recurring_child?).to be false
      end
    end

    describe "#part_of_series?" do
      it "returns true for events that are part of a series" do
        expect(master_event.part_of_series?).to be true
        expect(child_event.part_of_series?).to be true
      end

      it "returns false for standalone events" do
        expect(standalone_event.part_of_series?).to be false
      end
    end

    describe "#root_event" do
      it "returns self for parent events" do
        expect(master_event.root_event).to eq(master_event)
      end

      it "returns parent for child events" do
        expect(child_event.root_event).to eq(master_event)
      end

      it "returns self for standalone events" do
        expect(standalone_event.root_event).to eq(standalone_event)
      end
    end

    describe "#series_events" do
      let!(:child1) { create(:event, master_event: master_event, date_start: 1.week.from_now) }
      let!(:child2) { create(:event, master_event: master_event, date_start: 2.weeks.from_now) }

      it "returns all events in series for parent event" do
        events = master_event.series_events
        expect(events).to include(master_event, child1, child2)
        expect(events.first).to eq(master_event)
      end

      it "returns all events in series for child event" do
        events = child1.series_events
        expect(events).to include(master_event, child1, child2)
      end

      it "returns only self for standalone events" do
        events = standalone_event.series_events
        expect(events).to eq([standalone_event])
      end
    end

    describe "#upcoming_events_in_series" do
      let!(:future_child) { create(:event, master_event: master_event, date_start: 1.week.from_now) }
      let!(:past_child) { create(:event, master_event: master_event, date_start: 1.week.ago) }

      it "returns upcoming events in the series" do
        events = master_event.upcoming_events_in_series
        expect(events).to include(future_child)
        expect(events).not_to include(past_child)
      end

      it "respects the limit parameter" do
        create_list(:event, 10, master_event: master_event, date_start: 1.week.from_now)
        events = master_event.upcoming_events_in_series(limit: 3)
        expect(events.count).to eq(3)
      end
    end

    describe "#past_events_in_series" do
      let!(:future_child) { create(:event, master_event: master_event, date_start: 1.week.from_now) }
      let!(:past_child) { create(:event, master_event: master_event, date_start: 1.week.ago) }

      it "returns past events in the series" do
        events = master_event.past_events_in_series
        expect(events).to include(past_child)
        expect(events).not_to include(future_child)
      end
    end

    describe "#can_edit_series?" do
      let(:user) { create(:user) }
      let(:admin) { create(:user, admin: true) }
      let(:other_user) { create(:user) }

      it "returns true for admin users" do
        expect(master_event.can_edit_series?(admin)).to be true
      end

      it "returns true for event owner" do
        master_event.update!(user: user)
        expect(master_event.can_edit_series?(user)).to be true
      end

      it "returns false for other users" do
        master_event.update!(user: user)
        expect(master_event.can_edit_series?(other_user)).to be false
      end

      it "returns false for nil user" do
        expect(master_event.can_edit_series?(nil)).to be false
      end
    end

    describe "#should_generate_more_events?" do
      it "returns true for parent events with active recurrence" do
        expect(master_event.should_generate_more_events?).to be true
      end

      it "returns false for events without recurrence" do
        expect(child_event.should_generate_more_events?).to be false
        expect(standalone_event.should_generate_more_events?).to be false
      end
    end

    describe "#series_count" do
      let!(:child1) { create(:event, master_event: master_event) }
      let!(:child2) { create(:event, master_event: master_event) }

      it "returns correct count for parent events" do
        expect(master_event.series_count).to eq(3) # parent + 2 children
      end

      it "returns correct count for child events" do
        expect(child1.series_count).to eq(3)
      end

      it "returns 1 for standalone events" do
        expect(standalone_event.series_count).to eq(1)
      end
    end

    describe "#first_in_series?" do
      let!(:child1) { create(:event, master_event: master_event, date_start: 1.week.from_now) }

      it "returns true for parent events" do
        expect(master_event.first_in_series?).to be true
      end

      it "returns false for child events when parent is earlier" do
        expect(child1.first_in_series?).to be false
      end

      it "returns true for standalone events" do
        expect(standalone_event.first_in_series?).to be true
      end
    end

    describe "#position_in_series" do
      let!(:child1) { create(:event, master_event: master_event, date_start: 1.week.from_now) }
      let!(:child2) { create(:event, master_event: master_event, date_start: 2.weeks.from_now) }

      it "returns 1 for parent events" do
        expect(master_event.position_in_series).to eq(1)
      end

      it "returns correct position for child events" do
        expect(child1.position_in_series).to eq(2)
        expect(child2.position_in_series).to eq(3)
      end

      it "returns 1 for standalone events" do
        expect(standalone_event.position_in_series).to eq(1)
      end
    end

    describe "#build_next_occurrence" do
      let(:new_date) { 1.week.from_now }

      it "builds a new child event for parent events" do
        child = master_event.build_next_occurrence(new_date)

        expect(child).to be_a(Event)
        expect(child.master_event_id).to eq(master_event.id)
        expect(child.date_start).to eq(new_date)
        expect(child.is_recurring_master).to be false
        expect(child.title).to eq(master_event.title)
      end

      it "calculates correct end date based on duration" do
        duration = master_event.date_end - master_event.date_start
        child = master_event.build_next_occurrence(new_date)

        expect(child.date_end).to eq(new_date + duration)
      end

      it "returns nil for non-parent events" do
        expect(child_event.build_next_occurrence(new_date)).to be_nil
        expect(standalone_event.build_next_occurrence(new_date)).to be_nil
      end

      it "excludes certain attributes from copying" do
        child = master_event.build_next_occurrence(new_date)

        expect(child.id).to be_nil
        expect(child.code).not_to eq(master_event.code)
        expect(child.short_url).to be_nil
        expect(child.is_recurring_master).to be false
      end
    end
  end

  describe "validations" do
    it "validates master_event cannot be recurring child" do
      parent = create(:event, :recurring_parent)
      child = create(:event, master_event: parent)

      invalid_event = build(:event, master_event: child)
      expect(invalid_event).not_to be_valid
      expect(invalid_event.errors[:master_event]).to include("cannot be a child event from another series")
    end

    it "validates recurring parent cannot have parent" do
      parent = create(:event, :recurring_parent)

      invalid_event = build(:event, is_recurring_master: true, master_event: parent)
      expect(invalid_event).not_to be_valid
      expect(invalid_event.errors[:base]).to include("recurring parent events cannot have a parent event")
    end
  end
end
