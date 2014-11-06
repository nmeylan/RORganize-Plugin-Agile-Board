class StoryPoint < ActiveRecord::Base
  include Rorganize::Models::SmartRecords
  belongs_to :board

  def caption
    self.value
  end
end
