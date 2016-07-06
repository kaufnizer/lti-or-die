class LaunchController < ActionController::Base

  require 'oauth/request_proxy/action_controller_request'
  require 'typhoeus'

  before_action :set_launch_params, only: [:show, :receive, :request_access]

  def set_launch_params
    @launch_params = request.params
    @user_id = @launch_params["user_id"]
    @domain = @launch_params["custom_canvas_api_domain"]
  end

  #def show
  #  #@launch_params ||= nil
  #  response.headers.delete "X-Frame-Options"
  #  render text: "These were the last launch params: #{@launch_params}"
  #end

  def receive
    response.headers.delete "X-Frame-Options"

    #lti_message = IMS::LTI::Models::Messages::Message.generate(request.request_parameters.merge(request.query_parameters))
    #lti_message.launch_url = request.url
    secret = '1'
    puts request.parameters

    provider_signature = OAuth::Signature.sign(request, :consumer_secret => secret, :consumer_key => '1')

    if provider_signature == @launch_params["oauth_signature"]
    #if lti_message.valid_signature?(secret)
      @user = User.find_by(user_id: @user_id) || User.create(
                                                      full_name: @launch_params["lis_person_name_full"],
                                                      primary_email: @launch_params["lis_person_contact_email_primary"],
                                                      canvas_user_id: @launch_params["custom_canvas_user_id"],
                                                      user_id: @user_id,
                                                      token_requested_from: @domain)

      unless @user.has_api_token? && @user.token_valid?(@domain)
        puts "@User needs token"
        request_access
      else
        puts "User already has token"
        render :show
      end
    else
      render :invalid_signature
    end
  end

    def request_access
      url = "https://#{@domain}/login/oauth2/auth?client_id=37000000000000001&response_type=code&redirect_uri=http://localhost:3000/oauth2response&state=#{@user_id}"
      redirect_to url
    end
#https://jpoulos.instructure.com/login/oauth2/auth?client_id=37000000000000002&response_type=code&redirect_uri=http://google.com&scope=/auth/userinfo
#https://jpoulos.instructure.com/login/oauth2/auth?client_id=37000000000000002&response_type=code&redirect_uri=http://google.com&scope=

  def oauth2response

    code = request.params["code"]
    puts "code = #{code}"
    state = request.params["state"]
    puts "state= #{state}"
    user = User.find_by(user_id: state)
    puts user
    domain = user["token_requested_from"]

    if user["canvas_api_refresh_token"] && Time.now.to_i > user["token_expires_at"]
      puts "Token expired, refreshing"
      request = Typhoeus::Request.new("https://#{domain}/login/oauth2/token",
                                      method: :post,
                                      params: {:grant_type=>"refresh_token",
                                               :client_id=>"37000000000000001",
                                               :client_secret => "SAwDtcgVk9PsONsmVNEnBgRB339KheyfDdqLi9G1oIY1fbgcTFAoYD4NNstYPvHl",
                                               :redirect_uri => "https://localhost:3000/oauth2response",
                                               :refresh_token => user["canvas_api_refresh_token"]
                                      })
    else
      puts "Obtaining new token"
      request = Typhoeus::Request.new("https://#{domain}/login/oauth2/token",
                                      method: :post,
                                      params: {:grant_type=>"authorization_code",
                                               :client_id=>"37000000000000001",
                                               :client_secret => "SAwDtcgVk9PsONsmVNEnBgRB339KheyfDdqLi9G1oIY1fbgcTFAoYD4NNstYPvHl",
                                               :redirect_uri => "https://localhost:3000/oauth2response",
                                               :code => code
                                      })

    end

    response = request.run
    response_body = JSON.load response.response_body
    puts response_body

    user.update(canvas_api_token: response_body["access_token"],
                 canvas_api_refresh_token: response_body["refresh_token"],
                 token_expires_at: Time.now.to_i + response_body["expires_in"])

    puts "Token updated to: #{response_body["access_token"]}"
    puts user.canvas_api_token

    request = Typhoeus::Request.new("https://#{domain}/api/v1/users/self",
                                    headers: {:Authorization=>"Bearer #{user["canvas_api_token"]}"
                                    })
    response = request.run
    response_body = JSON.load response.response_body

    #redirect_to response_body["avatar_url"]
    render :show
  end
end
