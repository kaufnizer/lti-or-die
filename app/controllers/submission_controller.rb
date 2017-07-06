class SubmissionController < LaunchController
  def new
    response.headers.delete "X-Frame-Options"
    secret = '1'
    @lis_result_sourcedid = request.params["lis_result_sourcedid"]
    @lis_outcome_service_url = request.params["lis_outcome_service_url"]
    @user = request.params["user_id"]

    signature = ::OAuth2::Signature.new(request,secret)

    if signature.signature_valid?
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
    @user = request.params["user"]

    consumer = OAuth::Consumer.new("1", secret)
    token = OAuth::AccessToken.new(consumer)
    @response = token.post(@lis_outcome_service_url, @pox_message, 'Content-Type' => 'application/xml')
    @response_body = @response.body
    Submission.create(user: @user)

    render :submission_response
  end

  def create
    @submission = Submission.new(user: @user)
    if @submission.save
      render :submission_response
    else
      render 'new'
    end
  end

  def show
    response.headers.delete "X-Frame-Options"
    secret = '1'

    signature = ::OAuth2::Signature.new(request,secret)
    @submission_id = request.query_parameters["submission_id"]

    if signature.signature_valid?
        render :show
    else
      render :invalid_signature
    end

  end
end
