class User < ActiveRecord::Base
  require 'typhoeus'

  def has_api_token?
    self["canvas_api_token"].blank? ? false : true
  end

  def token_valid?(domain)
    request = Typhoeus::Request.new("https://#{domain}/api/v1/users/self",
                                    headers: {:Authorization=>"Bearer #{self.canvas_api_token}"
                                    })
    response = request.run
    puts "Token heath check response: #{response.code}"
    return true if response.code == 200 else return false
  end
end
