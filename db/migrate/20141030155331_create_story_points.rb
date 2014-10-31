class CreateStoryPoints < ActiveRecord::Migration
  def change
    create_table :story_points do |t|
      t.integer :value
      t.integer :board_id

      t.timestamps
    end
  end
end
