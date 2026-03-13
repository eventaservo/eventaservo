class InternationalEventBadgeComponent < ApplicationComponent
  erb_template <<-ERB
    <% if @event.international_calendar? %>
      <div class="badge text-bg-success fw-normal">
        ★ Internacia Evento
      </div>
    <% end %>
  ERB

  def initialize(event:)
    @event = event
  end
end
