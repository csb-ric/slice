# frozen_string_literal: true

require "test_helper"

SimpleCov.command_name "test:controllers"

# Tests to make sure users can access account settings, and reset password, and
# that admins can edit and update existing users.
class UsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:regular)
    @regular = users(:regular)
    @admin = users(:admin)
  end

  test "should get index as admin" do
    login(@admin)
    get users_url
    assert_response :success
  end

  test "should not get index as regular user" do
    login(@regular)
    get users_url
    assert_redirected_to dashboard_url
  end

  test "should show user as admin" do
    login(@admin)
    get user_url(@user)
    assert_response :success
  end

  test "should get edit as admin" do
    login(@admin)
    get edit_user_url(@user)
    assert_response :success
  end

  test "should not get edit as regular user" do
    login(@regular)
    get edit_user_url(@user)
    assert_redirected_to dashboard_url
  end

  test "should update user as admin" do
    login(@admin)
    patch user_url(@user), params: {
      user: {
        full_name: "FirstName LastName",
        email: "regular_updated_email@example.com",
        admin: "0"
      }
    }
    assert_redirected_to user_url(@user)
  end

  test "should not update user with blank full name" do
    login(@admin)
    patch user_url(@user), params: {
      user: { full_name: "" }
    }
    assert_template "edit"
    assert_response :success
  end

  test "should not update user with invalid id" do
    login(@admin)
    patch user_url(-1), params: {
      user: {
        full_name: "FirstName LastName",
        email: "regular_updated_email@example.com",
        admin: "0"
      }
    }
    assert_redirected_to users_url
  end

  test "should destroy user as admin" do
    login(@admin)
    assert_difference("User.current.count", -1) do
      delete user_url(@user)
    end
    assert_redirected_to users_url
  end
end
