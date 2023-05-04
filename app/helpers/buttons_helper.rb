module ButtonsHelper
  def new_button(url, text = "Nova")
    link_to icon("fas", "plus-circle", text), url, class: "button--new"
  end

  def edit_button(url)
    link_to icon("far", "edit", "Redakti"), url, class: "btn btn-sm btn-outline-primary no-border"
  end

  def delete_button(url)
    link_to "Forigi", url, class: "button-outline-red float-left", method: :delete,
      data: {confirm: "Ĉu vi certas? Vi ne kapablos malfari tion."}
  end
end
