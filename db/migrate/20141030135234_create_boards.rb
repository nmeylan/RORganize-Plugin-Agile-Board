class CreateBoards < ActiveRecord::Migration
  def change
    create_table :boards do |t|
      t.integer :velocity
      t.integer :project_id

      t.timestamps
    end
  end
end
