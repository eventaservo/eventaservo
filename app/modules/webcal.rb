# frozen_string_literal: true

module Webcal
  require 'icalendar/tzinfo'

  def kreas_webcal(eventoj, title: 'Kalendaro')
    eventoj          = Array.wrap(eventoj)
    cal              = Icalendar::Calendar.new
    cal.x_wr_calname = title
    eventoj.each { |evento| kreas_eventon(cal, evento) }
    cal.publish
    render plain: cal.to_ical
  end

  private

    def kreas_eventon(icalendar, evento)
      if evento.multtaga?
        kreas_multtagan_eventon(icalendar, evento)
      else
        icalendar.event do |e|
          e.dtstart = Icalendar::Values::DateOrDateTime.new(
            evento.date_start.in_time_zone(evento.time_zone),
            tzid: evento.time_zone
          ).call
          e.dtend = Icalendar::Values::DateOrDateTime.new(
            evento.date_end.in_time_zone(evento.time_zone),
            tzid: evento.time_zone
          ).call
          e.summary     = evento.title
          e.description = evento.description + '\n\n' + event_url(evento.code)
          e.location    = evento.full_address
        end
      end
    end

    def kreas_multtagan_eventon(icalendar, evento)
      icalendar.event do |e|
        e.dtstart = Icalendar::Values::DateOrDateTime.new(
          evento.date_start.in_time_zone(evento.time_zone).strftime('%Y%m%d'),
          tzid: evento.time_zone
        ).call
        e.dtend = Icalendar::Values::DateOrDateTime.new(
          (evento.date_end.in_time_zone(evento.time_zone) + 1.day).strftime('%Y%m%d'),
          tzid: evento.time_zone
        ).call
        e.summary     = evento.title
        e.description = evento.description + '\n\n' + event_url(evento.code)
        e.location    = evento.full_address
      end

      icalendar.event do |e|
        e.dtstart     = Icalendar::Values::DateOrDateTime.new(
          evento.date_start.in_time_zone(evento.time_zone),
          tzid: evento.time_zone
        ).call
        e.dtend = Icalendar::Values::DateOrDateTime.new(
          evento.date_start.in_time_zone(evento.time_zone) + 1.hour,
          tzid: evento.time_zone
        ).call
        e.summary     = "Komenco: #{evento.title}"
        e.description = evento.description + '\n\n' + event_url(evento.code)
        e.location    = evento.full_address
      end

      icalendar.event do |e|
        e.dtstart     = Icalendar::Values::DateOrDateTime.new(
          evento.date_end.in_time_zone(evento.time_zone),
          tzid: evento.time_zone
        ).call
        e.dtend = Icalendar::Values::DateOrDateTime.new(
          evento.date_end.in_time_zone(evento.time_zone) + 1.hour,
          tzid: evento.time_zone
        ).call
        e.summary     = "Fino: #{evento.title}"
        e.description = evento.description + '\n\n' + event_url(evento.code)
        e.location    = evento.full_address
      end
    end
end
