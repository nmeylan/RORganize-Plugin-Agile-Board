class UserStory < ActiveRecord::Base
  include Rorganize::Models::SmartRecords
  belongs_to :points, class_name: 'StoryPoint', foreign_key: :point_id
  belongs_to :tracker
  belongs_to :status, class_name: 'StoryStatus'

  def caption
    self.title
  end
end
