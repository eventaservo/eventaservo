ActiveAdmin.register_page "Statistics" do
  menu label: "Statistics"

  content title: "Statistics" do
    div class: "blank_slate_container" do
      span class: "blank_slate" do
        div render(Graphs::FilterByCategoryComponent.new)
      end
    end
  end
end
