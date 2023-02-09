class EnableUnaccentExtension < ActiveRecord::Migration[5.2]
  def up
    enable_extension("unaccent") unless extensions.include?("unaccent")
  end

  def down
    disable_extension("unaccent") if extensions.include?("unaccent")
  end
end
