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

# Model to manage event recurrence rules
#
# This model defines how a parent event should repeat over time,
# including frequency, interval, end conditions and specific settings
# for each type of recurrence.
#
# @example Create weekly recurrence
#   EventRecurrence.create!(
#     master_event: event,
#     frequency: 'weekly',
#     interval: 1,
#     end_type: 'after_count',
#     end_count: 10
#   )
#
# @example Create monthly recurrence on specific days
#   EventRecurrence.create!(
#     master_event: event,
#     frequency: 'monthly',
#     interval: 1,
#     day_of_month: 15,
#     end_type: 'on_date',
#     end_date: 1.year.from_now
#   )
class EventRecurrence < ApplicationRecord
  # Associations
  belongs_to :master_event, class_name: 'Event'
  has_many :generated_events, through: :master_event, source: :child_events

  # Enums
  enum :frequency, {
    daily: 'daily',
    weekly: 'weekly',
    monthly: 'monthly',
  }, prefix: true

  enum :end_type, {
    never: 'never',
    on_date: 'on_date'
  }, prefix: true

  # Serialization
  serialize :days_of_week, coder: JSON

  # Basic validations
  validates :frequency, :end_type, presence: true
  validates :interval, presence: true, numericality: {
    greater_than: 0,
    less_than_or_equal_to: 100,
    message: 'must be between 1 and 100'
  }

  # Conditional validations based on end_type
  validates :end_date, presence: true, if: :end_type_on_date?

  # Custom validations
  validate :end_date_in_future, if: :end_type_on_date?
  validate :days_of_week_valid, if: :frequency_weekly?
  validate :day_of_month_valid, if: :frequency_monthly?
  validate :master_event_not_recurring_child

  # Scopes
  scope :active, -> { where(active: true) }
  scope :inactive, -> { where(active: false) }

  # Public methods

  # Returns a readable description of the recurrence rule
  #
  # @return [String] Recurrence description
  #
  # @example
  #   recurrence.description
  #   # => "Semanalmente, por 10 ocorrências"
  # def description
  #   frequency_text = case frequency
  #   when 'daily'
  #     interval == 1 ? 'Diariamente' : "A cada #{interval} dias"
  #   when 'weekly'
  #     interval == 1 ? 'Semanalmente' : "A cada #{interval} semanas"
  #   when 'monthly'
  #     interval == 1 ? 'Mensalmente' : "A cada #{interval} meses"
  #   end

  #   end_text = case end_type
  #   when 'never'
  #     'sem data de término'
  #   when 'on_date'
  #     "até #{I18n.l(end_date, format: :short)}"
  #   end

  #   "#{frequency_text}, #{end_text}"
  # end

  # Checks if the recurrence should still generate events
  #
  # @return [Boolean] true if should continue generating events
  def should_generate_events?
    return false unless active?

    case end_type
    when 'never'
      true
    when 'on_date'
      Date.current <= end_date
    else
      false
    end
  end

  # Calculates the next occurrence date based on the last generated
  #
  # @param from_date [Date] Base date to calculate next from (default: parent event date)
  # @return [Date, nil] Next occurrence date or nil if none
  def next_occurrence_date(from_date = nil)
    base_date = from_date || master_event.date_start.to_date
    last_generated = generated_events.maximum(:date_start)&.to_date

    if last_generated
      calculate_next_date_from(last_generated)
    else
      calculate_next_date_from(base_date)
    end
  end

  # Deactivates the recurrence
  #
  # @return [Boolean] true if successfully deactivated
  def deactivate!
    update!(active: false)
  end

  # Reactivates the recurrence
  #
  # @return [Boolean] true if successfully reactivated
  def reactivate!
    update!(active: true)
  end

  private

  # Custom validations

  def end_date_in_future
    return unless end_date

    if end_date <= Date.current
      errors.add(:end_date, 'must be in the future')
    end
  end

  def days_of_week_valid
    return if days_of_week.blank?

    valid_days = (0..6).to_a
    invalid_days = days_of_week - valid_days

    if invalid_days.any?
      errors.add(:days_of_week, 'contains invalid days (must be 0-6)')
    end

    if days_of_week.uniq.length != days_of_week.length
      errors.add(:days_of_week, 'contains duplicate days')
    end
  end

  def day_of_month_valid
    return unless day_of_month

    unless day_of_month.between?(1, 31)
      errors.add(:day_of_month, 'must be between 1 and 31')
    end
  end

  def master_event_not_recurring_child
    return unless master_event

    if master_event.master_event_id.present?
      errors.add(:master_event, 'cannot be a child event from another series')
    end
  end

  # Helper methods

  def calculate_next_date_from(base_date)
    case frequency
    when 'daily'
      base_date + interval.days
    when 'weekly'
      base_date + (interval * 7).days
    when 'monthly'
      base_date >> interval # Add months
    end
  rescue ArgumentError
    # In case of invalid date (e.g.: February 29 in non-leap year)
    nil
  end
end
