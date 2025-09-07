# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Events::Recurring::GenerateEvents, type: :service do
  let(:user) { create(:user) }
  let(:country) { create(:country) }
  let(:parent_event) do
    create(:event,
      user: user,
      country: country,
      date_start: Date.current.beginning_of_month + 10.hours,
      date_end: Date.current.beginning_of_month + 12.hours,
      is_recurring_parent: true
    )
  end

  describe '#call' do
    context 'with weekly recurrence' do
      let(:recurrence) do
        create(:event_recurrence,
          parent_event: parent_event,
          frequency: 'weekly',
          interval: 1,
          end_type: 'never'
        )
      end

      subject { described_class.new(recurrence: recurrence) }

      it 'generates weekly events successfully' do
        result = subject.call

        expect(result.success?).to be true
        expect(result.payload).to be_an(Array)
        expect(result.payload.count).to be > 0
        
        # Check that events are created with correct dates
        first_event = result.payload.first
        expect(first_event.parent_event).to eq(parent_event)
        expect(first_event.date_start.to_date).to eq(parent_event.date_start.to_date + 1.week)
      end

      it 'copies attributes from parent event' do
        result = subject.call
        child_event = result.payload.first

        expect(child_event.title).to eq(parent_event.title)
        expect(child_event.description).to eq(parent_event.description)
        expect(child_event.city).to eq(parent_event.city)
        expect(child_event.country_id).to eq(parent_event.country_id)
        expect(child_event.user_id).to eq(parent_event.user_id)
        expect(child_event.is_recurring_parent).to be false
      end

      it 'maintains event duration' do
        result = subject.call
        child_event = result.payload.first
        
        parent_duration = parent_event.date_end - parent_event.date_start
        child_duration = child_event.date_end - child_event.date_start
        
        expect(child_duration).to eq(parent_duration)
      end

      it 'does not create duplicate events' do
        # First generation
        first_result = subject.call
        first_count = first_result.payload.count

        # Second generation should not create duplicates
        second_result = subject.call
        expect(second_result.payload.count).to eq(0)
        
        # Total events should remain the same
        expect(parent_event.child_events.count).to eq(first_count)
      end
    end

    context 'with monthly recurrence' do
      let(:recurrence) do
        create(:event_recurrence,
          parent_event: parent_event,
          frequency: 'monthly',
          interval: 1,
          end_type: 'on_date',
          end_date: 6.months.from_now
        )
      end

      subject { described_class.new(recurrence: recurrence) }

      it 'generates monthly events' do
        result = subject.call

        expect(result.success?).to be true
        expect(result.payload.count).to be > 0
        
        # Check monthly progression
        events = result.payload.sort_by(&:date_start)
        events.each_with_index do |event, index|
          expected_date = parent_event.date_start.to_date >> (index + 1)
          expect(event.date_start.to_date).to eq(expected_date)
        end
      end

      it 'respects end_date limit' do
        result = subject.call
        
        result.payload.each do |event|
          expect(event.date_start.to_date).to be <= recurrence.end_date
        end
      end
    end

    context 'with daily recurrence' do
      let(:recurrence) do
        create(:event_recurrence,
          parent_event: parent_event,
          frequency: 'daily',
          interval: 2,
          end_type: 'never'
        )
      end

      subject { described_class.new(recurrence: recurrence, months_ahead: 1) }

      it 'generates daily events with correct interval' do
        result = subject.call

        expect(result.success?).to be true
        
        # Check that events are created every 2 days
        events = result.payload.sort_by(&:date_start)
        events.each_with_index do |event, index|
          expected_date = parent_event.date_start.to_date + ((index + 1) * 2).days
          expect(event.date_start.to_date).to eq(expected_date)
        end
      end
    end

    context 'with yearly recurrence' do
      let(:recurrence) do
        create(:event_recurrence,
          parent_event: parent_event,
          frequency: 'yearly',
          interval: 1,
          end_type: 'never'
        )
      end

      subject { described_class.new(recurrence: recurrence, months_ahead: 25) }

      it 'generates yearly events' do
        result = subject.call

        expect(result.success?).to be true
        expect(result.payload.count).to be >= 1
        
        first_event = result.payload.first
        expected_date = parent_event.date_start.to_date >> 12
        expect(first_event.date_start.to_date).to eq(expected_date)
      end
    end

    context 'with weekly recurrence on specific days' do
      let(:recurrence) do
        create(:event_recurrence,
          parent_event: parent_event,
          frequency: 'weekly',
          interval: 1,
          days_of_week: [1, 3, 5], # Monday, Wednesday, Friday
          end_type: 'never'
        )
      end

      subject { described_class.new(recurrence: recurrence, months_ahead: 1) }

      it 'generates events on specific days of the week' do
        result = subject.call

        expect(result.success?).to be true
        
        # Check that events are only on Monday, Wednesday, Friday
        result.payload.each do |event|
          day_of_week = event.date_start.wday
          expect([1, 3, 5]).to include(day_of_week)
        end
      end
    end

    context 'with monthly recurrence on specific day' do
      let(:recurrence) do
        create(:event_recurrence,
          parent_event: parent_event,
          frequency: 'monthly',
          interval: 1,
          day_of_month: 15,
          end_type: 'never'
        )
      end

      subject { described_class.new(recurrence: recurrence, months_ahead: 3) }

      it 'generates events on the 15th of each month' do
        result = subject.call

        expect(result.success?).to be true
        
        result.payload.each do |event|
          expect(event.date_start.day).to eq(15)
        end
      end
    end

    context 'when recurrence is inactive' do
      let(:recurrence) do
        create(:event_recurrence,
          parent_event: parent_event,
          frequency: 'weekly',
          interval: 1,
          end_type: 'never',
          active: false
        )
      end

      subject { described_class.new(recurrence: recurrence) }

      it 'returns failure' do
        result = subject.call

        expect(result.failure?).to be true
        expect(result.error).to eq('Recurrence is not active')
      end
    end

    context 'when recurrence has ended' do
      let(:recurrence) do
        create(:event_recurrence,
          parent_event: parent_event,
          frequency: 'weekly',
          interval: 1,
          end_type: 'on_date',
          end_date: Date.yesterday
        )
      end

      subject { described_class.new(recurrence: recurrence) }

      it 'returns failure' do
        result = subject.call

        expect(result.failure?).to be true
        expect(result.error).to eq('Recurrence should not generate more events')
      end
    end

    context 'with existing child events' do
      let(:recurrence) do
        create(:event_recurrence,
          parent_event: parent_event,
          frequency: 'weekly',
          interval: 1,
          end_type: 'never'
        )
      end

      subject { described_class.new(recurrence: recurrence, months_ahead: 1) }

      before do
        # Create some existing child events
        create(:event,
          parent_event: parent_event,
          date_start: parent_event.date_start + 1.week,
          date_end: parent_event.date_end + 1.week
        )
        create(:event,
          parent_event: parent_event,
          date_start: parent_event.date_start + 2.weeks,
          date_end: parent_event.date_end + 2.weeks
        )
      end

      it 'continues from the last generated event' do
        result = subject.call

        expect(result.success?).to be true
        
        # Should start generating from 3 weeks ahead (after existing events)
        first_new_event = result.payload.first
        expect(first_new_event.date_start.to_date).to eq(parent_event.date_start.to_date + 3.weeks)
      end
    end

    context 'with tags and organizations' do
      let(:tag1) { create(:tag) }
      let(:tag2) { create(:tag) }
      let(:organization) { create(:organization) }
      
      let(:recurrence) do
        create(:event_recurrence,
          parent_event: parent_event,
          frequency: 'weekly',
          interval: 1,
          end_type: 'never'
        )
      end

      subject { described_class.new(recurrence: recurrence, months_ahead: 1) }

      before do
        parent_event.tags << [tag1, tag2]
        parent_event.organizations << organization
      end

      it 'copies tags and organizations to child events' do
        result = subject.call
        child_event = result.payload.first

        expect(child_event.tags).to include(tag1, tag2)
        expect(child_event.organizations).to include(organization)
      end
    end
  end

  describe 'RecurrenceDateCalculator' do
    let(:recurrence) do
      create(:event_recurrence,
        parent_event: parent_event,
        frequency: 'weekly',
        interval: 1,
        end_type: 'never'
      )
    end

    let(:calculator) { Events::Recurring::RecurrenceDateCalculator.new(recurrence, 3) }

    describe '#next_dates' do
      it 'calculates correct number of dates' do
        dates = calculator.next_dates
        
        expect(dates).to be_an(Array)
        expect(dates.count).to be > 0
        expect(dates.all? { |date| date.is_a?(Date) }).to be true
      end

      it 'returns dates in chronological order' do
        dates = calculator.next_dates
        
        expect(dates).to eq(dates.sort)
      end
    end
  end
end
