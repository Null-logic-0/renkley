class PromptsController < ApplicationController
  before_action :set_prompt, only: %i[update destroy]

  def create
    @prompt = Current.organization.prompts.new(prompt_params)
    flash.now[:alert] = @prompt.errors.full_messages.to_sentence unless @prompt.save

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to overview_path }
    end
  end

  def update
    flash.now[:alert] = @prompt.errors.full_messages.to_sentence unless @prompt.update(prompt_params)

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to overview_path }
    end
  end

  def destroy
    @prompt.destroy
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to overview_path }
    end
  end

  private

  def set_prompt
    @prompt = Current.organization.prompts.find(params[:id])
  end

  def prompt_params
    params.require(:prompt).permit(:body, :search_volume)
  end
end
