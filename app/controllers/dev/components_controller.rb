module Dev
  class ComponentsController < ApplicationController
    def index
      head :not_found and return unless Rails.env.development?
    end
  end
end
