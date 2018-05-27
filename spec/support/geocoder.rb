geocoder_ca_json = %Q^test({"longt":"-122.381414","remaining_credits":"19505","latt":"47.812141"});^

FakeWeb.register_uri(:any, %r|http://geocoder\.ca|, :body => geocoder_ca_json)