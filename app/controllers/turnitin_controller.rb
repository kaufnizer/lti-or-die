class TurnitinController < LaunchController
  require 'typhoeus'
  require 'json'

  def tools
    response.headers.delete "X-Frame-Options"
    secret = '1'

    signature = ::OAuth2::Signature.new(request,secret)

    if signature.signature_valid?
      if request.params["user_id"] == "da08341968cb37ba1e522fc7c5ef086b7704eff9" || request.params["user_id"] == "489d9cd03435fd77b896526cfc4619209b73a5a1"
        @user_id = request.params["user_id"]
        render :tools
      else
        render text: "You must be a Master of the Universe user to use this tool"
      end
    else
      render :invalid_signature
    end
  end

  def process_urls
    response.headers.delete "X-Frame-Options"
    @urls = request.params["urls"]
    @user_id = request.params["user_id"]

    def string_between_markers(string, marker1, marker2)
      string[/#{Regexp.escape(marker1)}(.*?)#{Regexp.escape(marker2)}/m, 1]
    end

    #https://iu.instructure.com/courses/1598695/gradebook/speed_grader?assignment_id=6823348#%7B%22student_id%22%3A%225714892%22%7D
    @domain = string_between_markers(@urls,"https://","/")
    @course_id = string_between_markers(@urls, "courses/","/")
    @assignment_id = string_between_markers(@urls, "assignment_id=","#")
    @student_id = string_between_markers(@urls, "student_id%22%3A%22","%22%7D")
    @user = User.find_by(user_id: @user_id)
    @token = @user.canvas_api_token

    url = "https://#{@domain}/api/v1/courses/#{@course_id}/assignments/#{@assignment_id}/submissions/#{@student_id}"
    request = Typhoeus::Request.new(url, :headers => {Authorization: "Bearer #{@token}"})
    @response = request.run
    @response_body = JSON.parse(@response.response_body)
    puts @response_body

    @submission_id = @response_body["id"]
    @attachment_id = @response_body["attachments"].first["id"]



    puts "@domain: #{@domain}"
    puts "@course_id: #{@course_id}"
    puts "@assignment_id: #{@assignment_id}"
    puts "@student_id: #{@student_id}"
    puts "@submission_id: #{@submission_id}"
    puts "@attachment_id: #{@attachment_id}"
    render :show_result
  end

  def submit
    @reprocess_url = request.params["reprocess_url"]
    @user_id = request.params["user_id"]
    @assignment_id = request.params["assignment_id"]
    @student_id = request.params["student_id"]
    @domain = request.params["domain"]

    puts @reprocess_url
    @user = User.find_by(user_id: @user_id)
    @token = @user.canvas_api_token

    request = Typhoeus::Request.new(@reprocess_url, :headers => {Authorization: "Bearer #{@token}"})
    @response = request.run
    @response_body = @response.response_body

    sleep(5)

    @crocodoc_url =
    request = Typhoeus::Request.new("https://#{@domain}/api/v1/support_helpers/crocodoc/submission?assignment_id=#{@assignment_id}&user_id=#{@student_id}", :headers => {Authorization: "Bearer #{@token}"})
    @response = request.run
    @response_body = @response.response_body

    render text: "#{@response_body}"

  end


end
