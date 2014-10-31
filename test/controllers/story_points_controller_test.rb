require 'test_helper'

class StoryPointsControllerTest < ActionController::TestCase
  setup do
    @story_point = story_points(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:story_points)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create story_point" do
    assert_difference('StoryPoint.count') do
      post :create, story_point: { board_id: @story_point.board_id, value: @story_point.value }
    end

    assert_redirected_to story_point_path(assigns(:story_point))
  end

  test "should show story_point" do
    get :show, id: @story_point
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @story_point
    assert_response :success
  end

  test "should update story_point" do
    patch :update, id: @story_point, story_point: { board_id: @story_point.board_id, value: @story_point.value }
    assert_redirected_to story_point_path(assigns(:story_point))
  end

  test "should destroy story_point" do
    assert_difference('StoryPoint.count', -1) do
      delete :destroy, id: @story_point
    end

    assert_redirected_to story_points_path
  end
end
