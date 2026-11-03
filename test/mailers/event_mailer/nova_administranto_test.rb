# frozen_string_literal: true

require "test_helper"

class EventMailer::NovaAdministrantoTest < ActionMailer::TestCase
  setup do
    @event = events(:valid_event)
  end

  test "delivers new admin notification in default locale (Esperanto)" do
    email = EventMailer.nova_administranto(@event)

    assert_emails 1 do
      email.deliver_now
    end

    body = (email.html_part || email).body.decoded
    assert_equal "Vi estas nova eventa administranto", email.subject
    assert_includes body, "Vi nun estas la administranto de la evento"
    assert_includes body, "VIDI LA EVENTAN PAĜON"
  end

  test "delivers new admin notification in English when specified" do
    email = EventMailer.nova_administranto(@event, locale: :en)
    body = (email.html_part || email).body.decoded

    assert_equal "You are a new event administrator", email.subject
    assert_includes body, "You are now the administrator of the event"
    assert_includes body, "VIEW EVENT PAGE"
  end

  test "delivers new admin notification in Portuguese when admin user prefers pt_BR" do
    @event.user.mailings = {"locale" => "pt_BR"}
    email = EventMailer.nova_administranto(@event)
    body = (email.html_part || email).body.decoded

    assert_equal "Você é o novo administrador do evento", email.subject
    assert_includes body, "Você agora é o administrador do evento"
    assert_includes body, "VER A PÁGINA DO EVENTO"
  end
end
