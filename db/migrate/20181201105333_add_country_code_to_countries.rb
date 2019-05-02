# frozen_string_literal: true

# Krea landaj kodoj por elekti la ĝustan flagon
class AddCountryCodeToCountries < ActiveRecord::Migration[5.2]
  def up
    add_column :countries, :code, :string
  end

  def down
    remove_column :countries, :code
  end
end
