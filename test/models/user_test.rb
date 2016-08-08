require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test "it detects whether a user has an API token" do
    assert users(:has_valid_token).has_api_token?
    assert_not users(:no_token).has_api_token?
  end

  test "it detects whether a user has a valid API token" do
    assert users(:has_valid_token).token_valid?("https://jpoulos.instructure.com")
    assert_not users(:no_token).token_valid?("https://jpoulos.instructure.com")
  end
end
