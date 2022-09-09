ActiveAdmin.register Event do
  config.sort_order = 'date_start_asc'

  actions :all, except: :destroy

  scope :venontaj, default: true
  scope :pasintaj

  index do
    column :short_url
    column :title
    column :date_start
    column :date_end
    actions
  end
end
