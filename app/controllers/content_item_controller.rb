class ContentItemController < LaunchController
  def launch
    response.headers.delete "X-Frame-Options"
    secret = '1'
    @content_item_return_url = request.params["content_item_return_url"]
    puts "Content item return url: #{@content_item_return_url}"

    signature_valid?(request, secret) ? (render :launch) : (render :invalid_signature)
  end

  def submit
  end

  def assignment
  end

  def module
  end

  def rce

  end
end
