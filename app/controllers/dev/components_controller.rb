module Dev
  class ComponentsController < ApplicationController
    allow_unauthenticated_access

    def index
      head :not_found and return unless Rails.env.development?
    end
  end
end
