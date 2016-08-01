require 'test_helper'

class ContentItemControllerTest < ActionController::TestCase
  test "should get launch" do
    get :launch
    assert_response :success
  end

  test "should get submit" do
    get :submit
    assert_response :success
  end

  test "should get assignment" do
    get :assignment
    assert_response :success
  end

  test "should get module" do
    get :module
    assert_response :success
  end

  test "should get rce" do
    get :rce
    assert_response :success
  end

end
