module Onboarding
  class PromptsController < ApplicationController
    before_action :set_organization

    def create
      @prompt = @organization.prompts.new(
        prompt_params.merge(source: :manual, position: next_position)
      )
      flash.now[:alert] = @prompt.errors.full_messages.to_sentence unless @prompt.save

      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to onboarding_path }
      end
    end

    def destroy
      @prompt = @organization.prompts.find(params[:id])
      @prompt.destroy

      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to onboarding_path }
      end
    end

    private

    def set_organization
      @organization = Current.organization
    end

    def prompt_params
      params.require(:prompt).permit(:body)
    end

    def next_position
      (@organization.prompts.maximum(:position) || 0) + 1
    end
  end
end
