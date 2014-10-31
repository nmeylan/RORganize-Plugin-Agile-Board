class CreateEpics < ActiveRecord::Migration
  def change
    create_table :epics do |t|
      t.string :name
      t.text :description
      t.integer :board_id

      t.timestamps
    end
  end
end
