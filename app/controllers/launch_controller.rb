class LaunchController < ActionController::Base

  require 'oauth/request_proxy/action_controller_request'

  def show
    #@launch_params ||= nil
    response.headers.delete "X-Frame-Options"
    render text: "These were the last launch params: #{$launch_params}"
  end

  def receive

    response.headers.delete "X-Frame-Options"
    $launch_params = request.params

    #lti_message = IMS::LTI::Models::Messages::Message.generate(request.request_parameters.merge(request.query_parameters))
    #lti_message.launch_url = request.url
    secret = '1'

    provider_signature = OAuth::Signature.sign(request, :consumer_secret => secret)

    if provider_signature == request.params["oauth_signature"]
    #if lti_message.valid_signature?(secret)
      render text: "Signature is valid, here are your launch params\n\n Payload:\n\n #{$launch_params}"
    else
      render text: "Invalid signature!\n\n Payload:\n\n #{$launch_params}"
    end


  end
end