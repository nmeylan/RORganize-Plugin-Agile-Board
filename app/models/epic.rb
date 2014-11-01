class Epic < ActiveRecord::Base
  include Rorganize::Models::SmartRecords
  belongs_to :board

  validates :name, presence: true, uniqueness: true

  def caption
    self.name
  end
end
