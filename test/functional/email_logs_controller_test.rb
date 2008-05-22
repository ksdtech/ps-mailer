require File.dirname(__FILE__) + '/../test_helper'

class EmailLogsControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:email_logs)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_email_log
    assert_difference('EmailLog.count') do
      post :create, :email_log => { }
    end

    assert_redirected_to email_log_path(assigns(:email_log))
  end

  def test_should_show_email_log
    get :show, :id => email_logs(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => email_logs(:one).id
    assert_response :success
  end

  def test_should_update_email_log
    put :update, :id => email_logs(:one).id, :email_log => { }
    assert_redirected_to email_log_path(assigns(:email_log))
  end

  def test_should_destroy_email_log
    assert_difference('EmailLog.count', -1) do
      delete :destroy, :id => email_logs(:one).id
    end

    assert_redirected_to email_logs_path
  end
end
