class InternationalEventBadgeComponent < ApplicationComponent
  erb_template <<-ERB
    <% if @event.international_calendar? %>
      <div class="badge badge-success">
        <b>★ Internacia Evento</b>
      </div>
    <% end %>
  ERB

  def initialize(event:)
    @event = event
  end
end
