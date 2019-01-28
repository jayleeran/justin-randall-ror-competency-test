ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'
require "minitest/rails"

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...
end

# Devise integration test helpers and role-base user login methods
class ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  def login_as_user
    u = users :user
    sign_in(u)
    if block_given?
      yield
      sign_out(u)
    end
  end

  def login_as_editor
    u = users :editor
    sign_in(u)
    if block_given?
      yield
      sign_out(u)
    end
  end

  def login_as_admin
    u = users :admin
    sign_in(u)
    if block_given?
      yield
      sign_out(u)
    end
  end
end