require 'helpers/vcr_helper'
require 'importilo'

class EventTest < ActiveSupport::TestCase

  test 'sukcesa Duolingo evento' do

    lando = create(:lando, :usono)
    tempozono = "America/New_York"

    VCR.use_cassette("duolingo_success") do
        expected = {
            "title"=>"Washington DC EsperantoEsperanto Meetup in Washington DC!",
            "city"=>"Washington DC",
            "site"=>"https://events.duolingo.com/events/details/duolingo-washington-dc-esperanto-presents-esperanto-meetup-in-washington-dc/",
            "country_id"=>"US",
            "latitude"=>38.892081,
            "longitude"=>-77.014021,
            "address"=>"Cascade Cafe at the National Gallery of Art, 4th Street and Constitution Ave. NW, Washington DC, 20001",
            "time_zone"=>tempozono,
            "date_start"=>Time.find_zone("UTC").parse("2018-04-22T17:00:00").in_time_zone(tempozono).strftime("%Y-%m-%d %H:%M:%S"),
            "date_end"=>Time.find_zone("UTC").parse("2018-04-22T19:00:00").in_time_zone(tempozono).strftime("%Y-%m-%d %H:%M:%S"),
            "content"=>"<p>Drinks, meals and snacks are available for purchase at the cafe, but no purchase is required. We will chat together and play games. Spot it and Scrabble in Esperanto will be available, and beginners are welcome!&nbsp; Look for the green flag! We will be at a table in the large underground cafe; enter from the East or West Wing of the National Gallery. We will be near to the Walkway to the East Wing.&nbsp; Trinkaĵoj, manĝoj kaj manĝetoj estos aĉeteblaj, &nbsp;sed se vi ne volas manĝi/trinki tie, oni ne devigas mendon. Ni&nbsp;babilos&nbsp;kaj ludos kune. Komencantoj estas bonvenaj!&nbsp;Serĉu la verdan flagon! Ni sidos ĉe tablo in la granda subtera kafeo, apud la trotuaro al al&nbsp;Orienta&nbsp;konstruaĵo. Eniru de la Orienta au Okcidenta parto de la Nacia Galerio.</p><p>Afterward at 3:30 pm there will be an optional free concert by the Inscape Chamber Orchestra in the West Building of the National Gallery, in the West Garden Court. Poste laŭ via elekto je la 3:30a okazos senpaga koncerto de la muzika grupo \"Inscape Chamber Orchestra\" en la okcidenta konstruaĵo de la Nacia Galerio, en la \"Okcidenta Ĝardena Korto\".<br></p>",
            "description"=>"Drinks, meals and snacks are available for purchase at the cafe, but no purchase is required. We will chat together and play games. Scrabble in Esperanto will be available, and beginners are welcome! Trinkaĵoj, manĝoj kaj manĝetoj estos aĉeteblaj, sed se vi ne volas manĝi/trinki tie, oni ne devigas mendon. Ni simple babilos kune. Komencantoj estas bonvenaj!"
        }

        url = 'https://events.duolingo.com/events/details/duolingo-washington-dc-esperanto-presents-esperanto-meetup-in-washington-dc/'
        datumoj = Importilo.new(url).datumoj

        assert_not_nil datumoj

        assert_equal expected, datumoj
    end
  end

  test 'nesukcesa Duolingo evento' do
    VCR.use_cassette("duolingo_no_success") do
        url = 'https://events.duolingo.com/events/details/duolingo-washington-dc-esperanto-presents-esperanto-meetup-in-washington-dcs/'
        datumoj = Importilo.new(url).datumoj

        assert_nil datumoj
    end
  end

  test 'malbona Duolingo url' do
    url = 'https://events.duolingo.com/eventa/details/duolingo-washington-dc-esperanto-presents-esperanto-meetup-in-washington-dc/'
    datumoj = Importilo.new(url).datumoj

    assert_nil datumoj
  end

end