module Settings
  class BrandAliasesController < ApplicationController
    before_action :set_brand_alias, only: :destroy

    def create
      @brand_alias = Current.organization.brand_aliases.new(brand_alias_params)
      flash.now[:alert] = @brand_alias.errors.full_messages.to_sentence unless @brand_alias.save

      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to settings_path }
      end
    end

    def destroy
      @brand_alias.destroy

      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to settings_path }
      end
    end

    private

    def set_brand_alias
      @brand_alias = Current.organization.brand_aliases.find(params[:id])
    end

    def brand_alias_params
      params.require(:brand_alias).permit(:name)
    end
  end
end
