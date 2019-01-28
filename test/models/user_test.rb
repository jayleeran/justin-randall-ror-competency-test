require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test "to_s returns email" do
    user = users(:user)
    assert_equal user.to_s, "user@test.com"
  end
end
