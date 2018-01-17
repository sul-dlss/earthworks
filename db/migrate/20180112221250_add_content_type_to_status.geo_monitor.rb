# This migration comes from geo_monitor (originally 20180112220603)
class AddContentTypeToStatus < ActiveRecord::Migration[5.1]
  def change
    add_column :geo_monitor_statuses, :content_type, :string
  end
end
