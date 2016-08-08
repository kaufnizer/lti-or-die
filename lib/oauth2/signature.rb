module OAuth2
  class Signature
    def initialize(request, secret)
      @request = request
      @secret = secret
      @params = @request.params
      @signature = OAuth::Signature.sign(request, :consumer_secret => secret, :method => 'HMAC-SHA1')
    end

    def request
      @request
    end

    def params
      @params
    end

    def secret
      @secret
    end

    def signature
      @signature
    end

    def signature_valid?
      puts "Provider signature:#{@signature}"
      puts "Canvas signature: #{@params["oauth_signature"]}"

      @signature == @params["oauth_signature"] ? true : false
    end
  end
end