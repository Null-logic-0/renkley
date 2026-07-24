class CompetitorDiscoveryJob < ApplicationJob
  queue_as :default

  def perform(organization)
    results = CompetitorDiscoveryService.new(organization.website_url).call

    results.each_with_index do |result, index|
      organization.companies.find_or_create_by!(domain: result[:domain]) do |c|
        c.name = result[:name]
        c.kind = :competitor
        c.source = :discovered
        c.position = index
      end
    end

    organization.companies.find_or_create_by!(domain: organization.website_url) do |c|
      c.name = organization.name
      c.kind = :owned
      c.source = :discovered
      c.position = -1
    end
  end
end
