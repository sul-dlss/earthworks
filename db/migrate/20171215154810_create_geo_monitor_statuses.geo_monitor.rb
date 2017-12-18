class CreateGeoMonitorStatuses < ActiveRecord::Migration[5.1]
  def change
    create_table :geo_monitor_statuses do |t|
      t.string :res_code
      t.string :res_headers
      t.decimal :res_time
      t.text :submitted_query
      t.references :layer, index: true
      t.timestamps
    end
  end
end
