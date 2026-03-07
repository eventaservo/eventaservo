class InternationalEventBadgeComponent < ApplicationComponent
  erb_template <<-ERB
    <% if @event.international_calendar? %>
      <div class="badge text-bg-success">
        <b>★ Internacia Evento</b>
      </div>
    <% end %>
  ERB

  def initialize(event:)
    @event = event
  end
end
