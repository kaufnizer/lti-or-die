class LaunchController < ActionController::Base
  require 'typhoeus'
  require_relative '../../lib/oauth2.rb'

  before_action :set_launch_params, only: [:show, :receive, :request_access]

  def set_launch_params
    @launch_params = request.params
    @user_id = @launch_params["user_id"]
    @domain = @launch_params["custom_canvas_api_domain"]
  end

  def receive
    response.headers.delete "X-Frame-Options"
    secret = '1'
    puts request

    @devkey = Devkey.find_by(domain: @domain)
    signature = ::OAuth2::Signature.new(request,secret)
    puts "Devkey: #{@devkey}"

    if signature.signature_valid? && @devkey
      @user = User.find_or_create_by(user_id: @user_id) do |user|
        user.full_name = @launch_params["lis_person_name_full"]
        user.primary_email = @launch_params["lis_person_contact_email_primary"]
        user.canvas_user_id = @launch_params["custom_canvas_user_id"]
        user.user_id = @user_id
        user.token_requested_from = @domain
      end

      if @user["canvas_api_refresh_token"] != nil && Time.now.to_i > @user["token_expires_at"]
        @user.send_oauth2_request(@user.build_refresh_token_request)
        render :show
      else
        unless @user.has_api_token? && @user.token_valid?(@devkey.base_url)
          puts "User needs token"
          request_access
        else
          puts "User already has token"
          render :show
        end
      end
    elsif @devkey
      render :invalid_signature
    else
      redirect_to url_for(:controller => :devkeys, :action => :new)
    end
  end

    def request_access
      url = "#{@devkey.base_url}/login/oauth2/auth?client_id=#{@devkey.client_id}&response_type=code&redirect_uri=#{@devkey.uri}&state=#{@user_id}"
      redirect_to url
    end

  def oauth2response
    response.headers.delete "X-Frame-Options"
    code = request.params["code"]
    puts "code = #{code}"
    state = request.params["state"]
    puts "state= #{state}"
    user = User.find_by(user_id: state)
    puts "user in oauth2response #{user}"

    user.send_oauth2_request(user.build_new_token_request(code))

    render :show
  end
end


