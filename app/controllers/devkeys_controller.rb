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

  def update
    @devkey = Devkey.find(params[:id])
    if @devkey.update_attributes(devkey_params)
      @devkey.update(:base_url => "https://#{@devkey.domain}")
      redirect_to @devkey
    else
      render 'edit'
    end
  end

  def edit
    @devkey = Devkey.find(params[:id])
  end

  private

  def devkey_params
    params.require(:devkey).permit(:domain, :key, :client_id,
                                 :uri)
  end
end
