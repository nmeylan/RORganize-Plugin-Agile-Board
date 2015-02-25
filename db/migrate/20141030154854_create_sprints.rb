class CreateSprints < ActiveRecord::Migration
  def change
    create_table :sprints do |t|
      t.string :name
      t.date :start_date
      t.date :end_date
      t.integer :version_id
      t.integer :board_id

      t.timestamps null: false
    end
  end
end
