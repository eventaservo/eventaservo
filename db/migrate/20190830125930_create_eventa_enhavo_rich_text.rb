class CreateEventaEnhavoRichText < ActiveRecord::Migration[6.0]
  def up
    PaperTrail.enabled = false
    i = Event.all.count
    Event.all.each do |e|
      e.enhavo = e.content
      e.save
      printf "#{i}     \r"
      i -= 1
    end
    PaperTrail.enabled = true
  end

  def down
    PaperTrail.enabled = false
    Event.all.each do |e|
      e.enhavo = nil
      e.save
    end
    PaperTrail.enabled = true
  end
end
