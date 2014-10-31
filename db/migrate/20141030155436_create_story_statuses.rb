class CreateStoryStatuses < ActiveRecord::Migration
  def change
    create_table :story_statuses do |t|
      t.string :name
      t.integer :board_id
      t.integer :position
      t.timestamps
    end
  end
end
