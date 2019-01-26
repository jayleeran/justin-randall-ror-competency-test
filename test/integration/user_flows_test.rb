require 'test_helper'

class UserFlowsTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  test "sees homepage" do
    get root_path
    assert_select "h1", "Home"
  end

  test "sees nav" do
    get root_path
    assert_select "nav" do
      assert_select "a", "Home"
    end
  end

  test "sees login in nav if not authenticated" do
    get root_path
    assert_select "nav" do
      assert_select "li", "Login"
    end
  end

  test "sees edit profile and logout in nav if authenticated" do
    sign_in users(:one)
    get root_path
    assert_select "nav" do
      assert_select "li", "Edit profile"
      assert_select "li", "Logout"
    end
  end
end
