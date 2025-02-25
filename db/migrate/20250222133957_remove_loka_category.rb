class RemoveLokaCategory < ActiveRecord::Migration[7.2]
  def up
    Event.find_each do |event|
      next unless event.specolisto&.downcase&.include?("loka")

      categories = event.specolisto.split(",").map(&:strip)

      if categories.any? { |c| c.downcase == "kunveno/evento" }
        # If Kunveno/Evento exists, just remove Loka
        categories.reject! { |c| c.downcase == "loka" }
      else
        # Replace Loka with Kunveno/Evento
        categories.map! { |c| (c.downcase == "loka") ? "Kunveno/Evento" : c }
      end

      event.update_column(:specolisto, categories.join(", "))
    end
  end

  def down
    # no-op
  end
end
