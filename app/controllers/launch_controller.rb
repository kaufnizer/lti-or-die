class LaunchController < ActionController::Base

  require 'oauth/request_proxy/action_controller_request'
  require 'typhoeus'

  def show
    #@launch_params ||= nil
    response.headers.delete "X-Frame-Options"
    render text: "These were the last launch params: #{launch_params}"
  end

  def receive

    response.headers.delete "X-Frame-Options"
    launch_params = request.params
    @user_id = launch_params["user_id"]
    @domain = launch_params["custom_canvas_api_domain"]
    @user = set_user(launch_params)

    #lti_message = IMS::LTI::Models::Messages::Message.generate(request.request_parameters.merge(request.query_parameters))
    #lti_message.launch_url = request.url
    secret = '1'

    provider_signature = OAuth::Signature.sign(request, :consumer_secret => secret)

    if provider_signature == launch_params["oauth_signature"]
    #if lti_message.valid_signature?(secret)

      unless @user.has_api_token? && @user.token_valid?(@domain)
        puts "@User needs token"
        request_access
      else
        puts "User already has token"
        render text: "Signature is valid, here are your launch params\n\n Payload:\n\n #{launch_params}"
      end
    else
      render text: "Invalid signature!\n\n Payload:\n\n #{launch_params}"
    end
  end

  def user_exists?
    if User.find_by(user_id: @user_id)
      puts "User exists"
      true
    else
      puts "User does not yet exist"
    end
  end

  def set_user(launch_params)
    if user_exists?

      puts "Setting existing user with ID #{@user_id}"
      User.find_by(user_id: @user_id)
    else
      puts "creating new user"
      User.create(full_name: launch_params["lis_person_name_full"],
                          primary_email: launch_params["lis_person_contact_email_primary"],
                          canvas_user_id: launch_params["custom_canvas_user_id"], user_id: @user_id)
    end
  end


    def request_access
      url = "https://#{@domain}/login/oauth2/auth?client_id=10000000000002&response_type=code&redirect_uri=http://localhost:3001/oauth2response&state=temp"
      redirect_to url
    end


  def oauth2response

    code = request.params["code"]
    puts "code = #{code}"
    state = request.params["state"]
    puts "state= #{state}"

    if @user.canvas_api_refresh_token != nil && Time.now.to_i > @user.token_expires_at
      puts "Token expired, refreshing"
      request = Typhoeus::Request.new("https://#{@domain}/login/oauth2/token",
                                      method: :post,
                                      params: {:grant_type=>"refresh_token",
                                               :client_id=>"10000000000002",
                                               :client_secret => "hR0UihLlmehye6y1xaQyBROapqfonAWzlk69RiKsbR4oqI8CDCHnCQx6Ft7GfNFv",
                                               :redirect_uri => "https://localhost:3001/oauth2response",
                                               :code => code,
                                               :refresh_token => @user.canvas_api_refresh_token
                                      })
    else
      puts "Obtaining new token"
      request = Typhoeus::Request.new("https://#{@domain}/login/oauth2/token",
                                      method: :post,
                                      params: {:grant_type=>"authorization_code",
                                               :client_id=>"10000000000002",
                                               :client_secret => "hR0UihLlmehye6y1xaQyBROapqfonAWzlk69RiKsbR4oqI8CDCHnCQx6Ft7GfNFv",
                                               :redirect_uri => "https://localhost:3001/oauth2response",
                                               :code => code
                                      })

    end

    response = request.run
    response_body = JSON.load response.response_body
    puts response_body
    @user.update(canvas_api_token: response_body["access_token"])
    @user.update(canvas_api_refresh_token: response_body["refresh_token"])
    @user.update(token_expires_at: (Time.now.to_i + response_body["expires_in"]))
    puts "Token updated to: #{response_body["access_token"]}"
    puts @user.canvas_api_token
    render text: "Signature is valid, here are your launch params\n\n Payload:\n\n #{launch_params}"
  end
end
