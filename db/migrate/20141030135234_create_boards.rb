class CreateBoards < ActiveRecord::Migration
  def change
    create_table :boards do |t|
      t.integer :velocity

      t.timestamps
    end
  end
end
