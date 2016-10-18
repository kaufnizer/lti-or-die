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

    if signature.signature_valid? && @devkey
      @user = User.find_or_create_by(user_id: @user_id) do |user|
        user.full_name = @launch_params["lis_person_name_full"]
        user.primary_email = @launch_params["lis_person_contact_email_primary"]
        user.canvas_user_id = @launch_params["custom_canvas_user_id"]
        user.user_id = @user_id
        user.token_requested_from = @domain
      end

      unless @user.has_api_token? && @user.token_valid?(@devkey.base_url)
        puts "User needs token"
        request_access
      else
        puts "User already has token"
        render :show
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
    puts user
    domain = user["token_requested_from"]
    @devkey = Devkey.find_by(domain: domain)

    if user["canvas_api_refresh_token"] && Time.now.to_i > user["token_expires_at"]
      puts "Token expired, refreshing"
      request = Typhoeus::Request.new("#{@devkey.base_url}/login/oauth2/token",
                                      method: :post,
                                      params: {:grant_type=>"refresh_token",
                                               :client_id=> @devkey.client_id,
                                               :client_secret => @devkey.key,
                                               :redirect_uri => @devkey.uri,
                                               :refresh_token => user["canvas_api_refresh_token"]
                                      })
    else
      puts "Obtaining new token"
      request = Typhoeus::Request.new("#{@devkey.base_url}/login/oauth2/token",
                                      method: :post,
                                      params: {:grant_type=>"authorization_code",
                                               :client_id=> @devkey.client_id,
                                               :client_secret => @devkey.key,
                                               :redirect_uri => @devkey.uri,
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

    render :show
  end
end


