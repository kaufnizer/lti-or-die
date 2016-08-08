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
end
