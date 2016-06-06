class LaunchController < ActionController::Base
  def show
    #@launch_params ||= nil
    render text: "These were the last launch params: #{$launch_params}"
  end

  def receive
    $launch_params = request.body.read
    render text: "Thanks for sending a POST request with cURL! Payload: #{$launch_params}"
  end
end