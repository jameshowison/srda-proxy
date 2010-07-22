require File.dirname(__FILE__) + '/../test_helper'
require 'notredamesourceforge_controller'

class NotredamesourceforgeController; def rescue_action(e) raise e end; end

class NotredamesourceforgeControllerApiTest < Test::Unit::TestCase
  def setup
    @controller = NotredamesourceforgeController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end
end
