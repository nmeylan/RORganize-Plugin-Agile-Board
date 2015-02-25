class CreateEpics < ActiveRecord::Migration
  def change
    create_table :epics do |t|
      t.string :name
      t.text :description
      t.integer :board_id
      t.string :color

      t.timestamps null: false
    end
  end
end
