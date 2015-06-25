require 'test_helper'

class EpicsControllerTest < ActionController::TestCase
  setup do
    @epic = epics(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:epics)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create epic" do
    assert_difference('Epic.count') do
      post :create, epic: { description: @epic.description, name: @epic.name }
    end

    assert_redirected_to project_epic_path(assigns(:epic))
  end

  test "should show epic" do
    get :show, id: @epic
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @epic
    assert_response :success
  end

  test "should update epic" do
    patch :update, id: @epic, epic: { description: @epic.description, name: @epic.name }
    assert_redirected_to project_epic_path(assigns(:epic))
  end

  test "should destroy epic" do
    assert_difference('Epic.count', -1) do
      delete :destroy, id: @epic
    end

    assert_redirected_to project_epics_path
  end
end
