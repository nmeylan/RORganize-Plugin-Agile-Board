class Sprint < ActiveRecord::Base
  include Rorganize::Models::SmartRecords
  has_many :stories, class_name: 'UserStory', dependent: :nullify

  def caption
    self.name
  end
end
