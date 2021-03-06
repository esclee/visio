require 'test_helper'

class ApplicationControllerTest < ActionController::TestCase
  include Devise::TestHelpers
  fixtures :all
  def setup
    @user = users(:one)

    sign_in @user
  end

  test 'A not signed in user should hit splash page' do

    sign_out @user

    get :index

    assert_response :found
  end

  test 'Splash page' do
    get :splash

    assert_response :success
    assert_template :splash
    assert_template layout: "layouts/application"
  end

  test 'A signed in user should be redirected to navigation page' do

    get :index

    assert_response :success
    assert_not_nil assigns :mapMD5
    assert_not_nil assigns :strategies
    assert_not_nil assigns :personal_strategies
    assert_template :index
    assert_template layout: "layouts/index"

  end

  test 'operation page' do

    get :operation, { :operation_id => Operation.first.id }

    assert_response :success

    assert_template :operation
    assert_template layout: 'layouts/index'
    assert_not_nil assigns(:operation)
    assert_not_nil assigns(:options)
    assert_not_nil assigns :strategies
    assert_not_nil assigns :personal_strategies
  end

  test 'overview page' do
    get :overview, { :strategy_id => Strategy.first.id }

    assert_response :success

    assert_template :overview
    assert_template layout: 'layouts/index'
    assert_not_nil assigns :strategy
    assert_not_nil assigns :options
    assert_not_nil assigns :strategies
    assert_not_nil assigns :personal_strategies

  end

  test 'global search 0 results on blank input' do

    get :global_search

    assert_response :success
    r = JSON.parse(response.body)

    assert_equal 0, r["operations"].length
    assert_equal 0, r["indicators"].length

    get :global_search, { :query => '' }

    assert_response :success
    r = JSON.parse(response.body)

    assert_equal 0, r["operations"].length
    assert_equal 0, r["indicators"].length
  end



end
