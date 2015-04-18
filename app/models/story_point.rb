class StoryPoint < ActiveRecord::Base
  include SmartRecords
  belongs_to :board

  def caption
    self.value
  end
end
