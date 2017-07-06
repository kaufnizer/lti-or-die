class User < ActiveRecord::Base
  require 'typhoeus'

  def has_api_token?
    self["canvas_api_token"].blank? ? false : true
  end

  def token_valid?(base_url)
    request = Typhoeus::Request.new("#{base_url}/api/v1/users/self",
                                    headers: {:Authorization=>"Bearer #{self.canvas_api_token}"
                                    })
    response = request.run
    puts "Token heath check response: #{response.code}"
    response.code == 200 ? true : false
  end

  def build_refresh_token_request
    puts "Token expired, refreshing"
    domain = self["token_requested_from"]
    @devkey = Devkey.find_by(domain: domain)
    request = Typhoeus::Request.new("#{@devkey.base_url}/login/oauth2/token",
                                    method: :post,
                                    params: {:grant_type=>"refresh_token",
                                             :client_id=> @devkey.client_id,
                                             :client_secret => @devkey.key,
                                             :redirect_uri => @devkey.uri,
                                             :refresh_token => self["canvas_api_refresh_token"]
                                    })
    request
  end

  def build_new_token_request(code)
    puts "Obtaining new token"
    domain = self["token_requested_from"]
    @devkey = Devkey.find_by(domain: domain)
    request = Typhoeus::Request.new("#{@devkey.base_url}/login/oauth2/token",
                                    method: :post,
                                    params: {:grant_type=>"authorization_code",
                                             :client_id=> @devkey.client_id,
                                             :client_secret => @devkey.key,
                                             :redirect_uri => @devkey.uri,
                                             :code => code
                                    })
    request
  end

  def send_oauth2_request(request)
    puts "sending request"
    response = request.run
    response_body = JSON.load response.response_body
    puts response_body

    self.update(canvas_api_token: response_body["access_token"],
                canvas_api_refresh_token: response_body["refresh_token"],
                token_expires_at: Time.now.to_i + response_body["expires_in"])

    puts "Token updated to: #{response_body["access_token"]}"
    puts self.canvas_api_token
  end
end
