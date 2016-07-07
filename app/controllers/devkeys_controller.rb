class DevkeysController < ApplicationController
  def show
    @devkey = Devkey.find(params[:id])
  end

  def new
    @devkey = Devkey.new
  end

  def create
    @devkey = Devkey.new(devkey_params)
    if @devkey.save
      @devkey.update(:base_url => "https://#{@devkey.domain}")
      redirect_to @devkey
    else
      render 'new'
    end
  end

  private

  def devkey_params
    params.require(:devkey).permit(:domain, :key, :client_id,
                                 :uri)
  end
end
