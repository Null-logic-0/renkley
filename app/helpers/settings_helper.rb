module SettingsHelper
  # Only platforms with a real, working integration (currently just Gemini)
  # — same dynamic source as the overview dashboard's platform breakdown,
  # so this dropdown never offers a platform we don't actually query.
  def default_ai_platform_options
    [ [ "All platforms", "all" ] ] + AiPlatform.integrated.ordered.map { |platform| [ platform.name, platform.key ] }
  end

  def scan_frequency_options(organization)
    [ "hourly", "daily", "weekly" ].map do |value|
      { label: value.capitalize, value: value, selected: organization.scan_frequency == value }
    end
  end
end
