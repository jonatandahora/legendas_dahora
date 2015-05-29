require 'test_helper'

class TranslationControllerTest < ActionController::TestCase
  test "should get translate" do
    get :index
    assert_response :success
  end

  test "should get show" do
    get :show
    assert_response :success
  end

end
