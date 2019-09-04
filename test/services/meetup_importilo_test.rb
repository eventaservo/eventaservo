require 'helpers/vcr_helper'
require 'importilo'

class EventTest < ActiveSupport::TestCase

  test 'sukcesa Meetup evento' do

    lando = create(:lando, :kanado)
    tempozono = "America/Toronto"

    VCR.use_cassette("meetup_success") do
        expected = {
            "title"=>"Esperanto-Toronto: Socia kunveno", 
            "city"=>"Toronto", 
            "site"=>"https://www.meetup.com/Esperanto-Toronto/events/nbplfqyzmbfb/",
            "country_id"=>lando.id,
            "latitude"=>43.66590881347656,
            "longitude"=>-79.38521575927734,
            "address"=>"Aroma Espresso Bar,  618 Yonge Street",
            "time_zone"=>tempozono,
            "date_start"=>Time.find_zone("UTC").parse("2019-09-03 22:00:00").in_time_zone(tempozono).strftime("%Y-%m-%d %H:%M:%S"),
            "date_end"=>Time.find_zone("UTC").parse("2019-09-03 23:30:00").in_time_zone(tempozono).strftime("%Y-%m-%d %H:%M:%S"),
            "content"=>"<p>English below</p> <p>Ni kunvenas unufoje monate por trinki kafon kaj ĝui konversacion en Esperanto pri io ajn. Je 19:30 kelkaj el ni iras al unu el la apudaj restoracioj por manĝi kaj daŭrigi la konversaciojn.</p> <p>Se vi vizitos nin el eksterurbe kaj vi ne povas trafi unu el ĉi tiuj kunvenoj, bonvolu sendi retmesaĝon al esperanto.toronto(ĉe)gmail.com, por ke ni eventuale povu ŝanĝi la daton de unu kunveno, aŭ aldoni kroman.</p> <p>We meet once a month to drink coffee and enjoy conversation in Esperanto about anything. At 7:30 some of us go to one of the nearby reastaurants to eat and continue the conversations.</p> <p>If you are visiting us from out of town and can’t make one of these meetings, please send an email to esperanto.toronto(at)gmail.com so that we can change the date of one meeting or add another one in order to accommodate you.</p> Ĉe la okcidenta flanko de Yonge Street, unu strato norde de Wellesley Street (metroo Wellesley) / On the west side of Yonge Street, one block north of Wellesley Street (Wellesley subway)",
            "description"=>"Socia kunveno"
        }

        url = 'https://www.meetup.com/Esperanto-Toronto/events/nbplfqyzmbfb/'
        datumoj = Importilo.new(url).datumoj
        
        assert_not_nil datumoj

        assert_equal expected, datumoj
    end
  end

  test 'nesukcesa Meetup evento' do
    VCR.use_cassette("meetup_no_success") do
        url = 'https://www.meetup.com/Esperanto-Toronto/events/nbplfqyzmbfbs/'
        datumoj = Importilo.new(url).datumoj

        assert_nil datumoj
    end
  end

  test 'malbona Meetup url' do
    url = 'https://www.meetup.com/Esperanto-Toronto/eventa/nbplfqyzmbfbs/'
    datumoj = Importilo.new(url).datumoj

    assert_nil datumoj
  end

  test 'Meetup evento sen eventejo' do
    lando = create(:lando, :novzelando)
    tempozono = "Pacific/Auckland"

    VCR.use_cassette("meetup_no_venue") do
        expected = {
            "title"=>"Esperanto-NZ: Wellington Esperanto Club Meetup",
            "city"=>"Wellington",
            "site"=>"https://www.meetup.com/Esperanto-NZ/events/fdmpqyzmbpb/",
            "country_id"=>lando.id,
            "latitude"=>-41.279998779296875,
            "longitude"=>174.77999877929688,
            "address"=>"Wellington, New Zealand",
            "time_zone"=>tempozono,
            "date_start"=>Time.find_zone("UTC").parse("2019-09-11 07:00:00").in_time_zone(tempozono).strftime("%Y-%m-%d %H:%M:%S"),
            "date_end"=>Time.find_zone("UTC").parse("2019-09-11 10:00:00").in_time_zone(tempozono).strftime("%Y-%m-%d %H:%M:%S"),
            "content"=>"<p>The Wellington Esperanto Club meets the second Wednesday every month between February and December. </p> <p> </p> <p>La Rondo de Wellington kunvenas inter februaro kaj decembro, la duan merkredon de ĉiu monato. </p> <p> </p> ",
            "description"=>"Wellington Esperanto Club Meetup"
        }

        url = 'https://www.meetup.com/Esperanto-NZ/events/fdmpqyzmbpb/'
        datumoj = Importilo.new(url).datumoj

        assert_not_nil datumoj

        assert_equal expected, datumoj
    end
  end

end