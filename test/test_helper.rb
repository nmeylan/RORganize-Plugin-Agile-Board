ENV['RAILS_ENV'] = 'test'
require File.expand_path('../../../../../config/environment', __FILE__)

require 'rails/test_help'

if ActiveSupport::TestCase.respond_to?(:fixture_path=)
  ActiveSupport::TestCase.fixture_path = File.expand_path("../fixtures", __FILE__)
end

class ActiveSupport::TestCase
  fixtures :all

  setup do
    User.current = users(:users_001)
  end
  # Add more helper methods to be used by all tests here...
end
