class SubmissionController < LaunchController
  def new
    response.headers.delete "X-Frame-Options"
    secret = '1'
    @lis_result_sourcedid = request.params["lis_result_sourcedid"]
    @lis_outcome_service_url = request.params["lis_outcome_service_url"]

    if signature_valid?(request, secret)
      if request.params["roles"].include? "Learner"
        render :new
      else
        render text: "You must be a student to submit"
      end
    else
      render :invalid_signature
    end
  end

  def submit
    response.headers.delete "X-Frame-Options"
    secret = '1'
    @lis_outcome_service_url = request.params["lis_outcome_service_url"]
    @pox_message = request.params["pox_message"]
    puts "@pox_message: #{@pox_message}"
    puts "@lis_outcome_service_url: #{@lis_outcome_service_url}"

    consumer = OAuth::Consumer.new("1", secret)
    puts "Consumer #{consumer}"
    token = OAuth::AccessToken.new(consumer)
    puts "Token: #{token}"
    @response = token.post(@lis_outcome_service_url, @pox_message, 'Content-Type' => 'application/xml')
    @response_body = @response.body


    puts @response_body
    render :submission
  end
end
