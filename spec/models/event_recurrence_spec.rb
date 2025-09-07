# frozen_string_literal: true

# == Schema Information
#
# Table name: event_recurrences
#
#  id              :bigint           not null, primary key
#  active          :boolean          default(TRUE), not null, indexed => [frequency], indexed => [master_event_id]
#  day_of_month    :integer
#  days_of_week    :text
#  end_date        :date
#  end_type        :string           not null
#  frequency       :string           not null, indexed => [active]
#  interval        :integer          default(1), not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  master_event_id :bigint           not null, indexed, indexed => [active]
#
# Foreign Keys
#
#  fk_rails_...  (master_event_id => events.id)
#
require 'rails_helper'

RSpec.describe EventRecurrence, type: :model do
  describe 'associations' do
    it { should belong_to(:master_event).class_name('Event') }

    it 'has generated_events through master_event' do
      master_event = create(:event, :recurring_parent)
      recurrence = create(:event_recurrence, master_event: master_event)
      child_event = create(:event, master_event: master_event)

       expect(recurrence.generated_events).to include(child_event)
    end
  end

  describe 'validations' do
    subject { build(:event_recurrence) }

    it { should validate_presence_of(:frequency) }
    it { should validate_presence_of(:interval) }
    it { should validate_presence_of(:end_type) }
    it 'validates interval is between 1 and 100' do
      recurrence = build(:event_recurrence, interval: 0)
      expect(recurrence).not_to be_valid
      expect(recurrence.errors[:interval]).to include('must be between 1 and 100')

      recurrence = build(:event_recurrence, interval: 101)
      expect(recurrence).not_to be_valid
      expect(recurrence.errors[:interval]).to include('must be between 1 and 100')

      recurrence = build(:event_recurrence, interval: 50)
      expect(recurrence).to be_valid
    end


    context 'when end_type is on_date' do
      subject { build(:event_recurrence, end_type: 'on_date') }

      it { should validate_presence_of(:end_date) }

      it 'validates end_date is in the future' do
        recurrence = build(:event_recurrence, end_type: 'on_date', end_date: Date.yesterday)
        expect(recurrence).not_to be_valid
        expect(recurrence.errors[:end_date]).to include('must be in the future')
      end

      it 'allows end_date in the future' do
        recurrence = build(:event_recurrence, end_type: 'on_date', end_date: Date.tomorrow)
        expect(recurrence).to be_valid
      end
    end

    context 'when frequency is weekly' do
      it 'validates days_of_week contains valid days' do
        recurrence = build(:event_recurrence, frequency: 'weekly', days_of_week: [0, 1, 7])
        expect(recurrence).not_to be_valid
        expect(recurrence.errors[:days_of_week]).to include('contains invalid days (must be 0-6)')
      end

      it 'validates days_of_week does not contain duplicates' do
        recurrence = build(:event_recurrence, frequency: 'weekly', days_of_week: [0, 1, 1, 2])
        expect(recurrence).not_to be_valid
        expect(recurrence.errors[:days_of_week]).to include('contains duplicate days')
      end

      it 'allows valid days_of_week' do
        recurrence = build(:event_recurrence, frequency: 'weekly', days_of_week: [0, 1, 2, 6])
        expect(recurrence).to be_valid
      end
    end

    context 'when frequency is monthly' do
      it 'validates day_of_month is between 1 and 31' do
        recurrence = build(:event_recurrence, frequency: 'monthly', day_of_month: 32)
        expect(recurrence).not_to be_valid
        expect(recurrence.errors[:day_of_month]).to include('must be between 1 and 31')
      end

      it 'allows valid day_of_month' do
        recurrence = build(:event_recurrence, frequency: 'monthly', day_of_month: 15)
        expect(recurrence).to be_valid
      end
    end

    it 'validates master_event is not a recurring child' do
      master_event = create(:event, :recurring_parent)
      child_event = create(:event, master_event: master_event)

      recurrence = build(:event_recurrence, master_event: child_event)
      expect(recurrence).not_to be_valid
      expect(recurrence.errors[:master_event]).to include('cannot be a child event from another series')
    end
  end

  describe 'enums' do
    it 'defines frequency enum' do
      expect(EventRecurrence.frequencies).to eq({
        'daily' => 'daily',
        'weekly' => 'weekly',
        'monthly' => 'monthly'
      })
    end

    it 'defines end_type enum' do
      expect(EventRecurrence.end_types).to eq({
        'never' => 'never',
        'on_date' => 'on_date'
      })
    end

    it 'has frequency prefix methods' do
      recurrence = build(:event_recurrence, frequency: 'weekly')
      expect(recurrence.frequency_weekly?).to be true
      expect(recurrence.frequency_daily?).to be false
    end

    it 'has end_type prefix methods' do
      recurrence = build(:event_recurrence, end_type: 'never')
      expect(recurrence.end_type_never?).to be true
      expect(recurrence.end_type_on_date?).to be false
    end
  end

  describe 'scopes' do
    let!(:active_recurrence) { create(:event_recurrence, active: true) }
    let!(:inactive_recurrence) { create(:event_recurrence, active: false) }
    let!(:weekly_recurrence) { create(:event_recurrence, frequency: 'weekly') }
    let!(:monthly_recurrence) { create(:event_recurrence, frequency: 'monthly') }
    let!(:ending_soon) { create(:event_recurrence, end_type: 'on_date', end_date: 2.weeks.from_now) }

    describe '.active' do
      it 'returns only active recurrences' do
        expect(EventRecurrence.active).to include(active_recurrence)
        expect(EventRecurrence.active).not_to include(inactive_recurrence)
      end
    end

    describe '.inactive' do
      it 'returns only inactive recurrences' do
        expect(EventRecurrence.inactive).to include(inactive_recurrence)
        expect(EventRecurrence.inactive).not_to include(active_recurrence)
      end
    end
  end

  describe '#should_generate_events?' do
    context 'when recurrence is inactive' do
      it 'returns false' do
        recurrence = build(:event_recurrence, active: false)
        expect(recurrence.should_generate_events?).to be false
      end
    end

    context 'when end_type is never' do
      it 'returns true' do
        recurrence = build(:event_recurrence, end_type: 'never', active: true)
        expect(recurrence.should_generate_events?).to be true
      end
    end


    context 'when end_type is on_date' do
      it 'returns true when end date not reached' do
        recurrence = build(:event_recurrence, end_type: 'on_date', end_date: 1.month.from_now, active: true)
        expect(recurrence.should_generate_events?).to be true
      end

      it 'returns false when end date passed' do
        recurrence = build(:event_recurrence, end_type: 'on_date', end_date: Date.yesterday, active: true)
        expect(recurrence.should_generate_events?).to be false
      end
    end
  end

  describe '#next_occurrence_date' do
    let(:master_event) { create(:event, date_start: Date.current.beginning_of_month) }

    context 'with daily frequency' do
      it 'calculates next daily occurrence' do
        recurrence = create(:event_recurrence, master_event: master_event, frequency: 'daily', interval: 1)
        expected_date = master_event.date_start.to_date + 1.day
        expect(recurrence.next_occurrence_date).to eq(expected_date)
      end

      it 'calculates next occurrence with interval' do
        recurrence = create(:event_recurrence, master_event: master_event, frequency: 'daily', interval: 3)
        expected_date = master_event.date_start.to_date + 3.days
        expect(recurrence.next_occurrence_date).to eq(expected_date)
      end
    end

    context 'with weekly frequency' do
      it 'calculates next weekly occurrence' do
        recurrence = create(:event_recurrence, master_event: master_event, frequency: 'weekly', interval: 1)
        expected_date = master_event.date_start.to_date + 1.week
        expect(recurrence.next_occurrence_date).to eq(expected_date)
      end
    end

    context 'with monthly frequency' do
      it 'calculates next monthly occurrence' do
        recurrence = create(:event_recurrence, master_event: master_event, frequency: 'monthly', interval: 1)
        expected_date = master_event.date_start.to_date >> 1
        expect(recurrence.next_occurrence_date).to eq(expected_date)
      end
    end


    context 'when there are existing generated events' do
      it 'calculates from the last generated event' do
        recurrence = create(:event_recurrence, master_event: master_event, frequency: 'weekly', interval: 1)

        # Create multiple child events to test the maximum calculation
        create(:event, master_event: master_event, date_start: 1.week.from_now)
        last_event = create(:event, master_event: master_event, date_start: 2.weeks.from_now)

        # Verify the association is working
        expect(recurrence.generated_events.count).to eq(2)
        expect(recurrence.generated_events.maximum(:date_start)).to eq(last_event.date_start)

        # The method should calculate from the last generated event
        expected_date = last_event.date_start.to_date + 1.week
        actual_date = recurrence.next_occurrence_date

        expect(actual_date).to eq(expected_date),
          "Expected #{expected_date} but got #{actual_date}. " \
          "Last generated event: #{last_event.date_start.to_date}, " \
          "Parent event: #{master_event.date_start.to_date}"
      end
    end
  end

  describe '#deactivate!' do
    it 'sets active to false' do
      recurrence = create(:event_recurrence, active: true)
      recurrence.deactivate!
      expect(recurrence.reload.active).to be false
    end
  end

  describe '#reactivate!' do
    it 'sets active to true' do
      recurrence = create(:event_recurrence, active: false)
      recurrence.reactivate!
      expect(recurrence.reload.active).to be true
    end
  end

  describe 'serialization' do
    it 'serializes days_of_week as array' do
      recurrence = create(:event_recurrence, days_of_week: [1, 3, 5])
      expect(recurrence.reload.days_of_week).to eq([1, 3, 5])
    end
  end
end
