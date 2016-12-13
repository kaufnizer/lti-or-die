class TemperatureController < LaunchController
  def new
    @request = request
    render :show
  end
  def show
    render :show
  end
end