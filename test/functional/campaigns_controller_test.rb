require File.dirname(__FILE__) + '/../test_helper'

class CampaignsControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:campaigns)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_campaign
    assert_difference('Campaign.count') do
      post :create, :campaign => { }
    end

    assert_redirected_to campaign_path(assigns(:campaign))
  end

  def test_should_show_campaign
    get :show, :id => campaigns(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => campaigns(:one).id
    assert_response :success
  end

  def test_should_update_campaign
    put :update, :id => campaigns(:one).id, :campaign => { }
    assert_redirected_to campaign_path(assigns(:campaign))
  end

  def test_should_destroy_campaign
    assert_difference('Campaign.count', -1) do
      delete :destroy, :id => campaigns(:one).id
    end

    assert_redirected_to campaigns_path
  end
end
