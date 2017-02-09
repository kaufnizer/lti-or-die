class PlagiarismController < ActionController::Base
  require 'json/jwt'

  def configure
    response.headers.delete "X-Frame-Options"

    @lti_assignment_id = "lti_assignment_id: #{params[:ext_lti_assignment_id]}"

    render :configure
  end
end