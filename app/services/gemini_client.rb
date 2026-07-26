class GeminiClient
  Error = Class.new(StandardError)

  ENDPOINT = "https://generativelanguage.googleapis.com/v1beta/models/%<model>s:generateContent"

  def initialize(api_key: Rails.application.credentials.dig(:gemini, :api_key),
                 model: Rails.application.credentials.dig(:gemini, :model))
    raise Error, "Gemini API key is not configured" if api_key.blank?

    @api_key = api_key
    @model = model.presence || "gemini-flash-latest"
  end


  def generate_json(prompt)
    text = generate_text(prompt)
    json_text = text[/\{.*\}/m]
    raise Error, "Gemini response did not contain JSON: #{text.truncate(200)}" unless json_text

    JSON.parse(json_text)
  rescue JSON::ParserError => e
    raise Error, "Gemini returned invalid JSON: #{e.message}"
  end

  def generate_text(prompt)
    candidate(prompt).dig("content", "parts", 0, "text") || raise(Error, "Gemini returned no candidates")
  end


  def generate_grounded(prompt)
    result = candidate(prompt, tools: [ { google_search: {} } ])
    text = result.dig("content", "parts", 0, "text").to_s
    chunks = result.dig("groundingMetadata", "groundingChunks") || []
    sources = chunks.filter_map { |chunk| chunk.dig("web", "uri") }
    { text: text, sources: sources }
  end

  private

  def candidate(prompt, tools: nil)
    uri = URI(format(ENDPOINT, model: @model))
    uri.query = URI.encode_www_form(key: @api_key)

    body = { contents: [ { parts: [ { text: prompt } ] } ] }
    body[:tools] = tools if tools

    request = Net::HTTP::Post.new(uri, "Content-Type" => "application/json")
    request.body = body.to_json

    response = Net::HTTP.start(uri.host, uri.port, use_ssl: true, open_timeout: 10, read_timeout: 20) do |http|
      http.request(request)
    end
    raise Error, "Gemini request failed: #{response.code} #{response.body.to_s.truncate(200)}" unless response.is_a?(Net::HTTPSuccess)

    JSON.parse(response.body).dig("candidates", 0) || raise(Error, "Gemini returned no candidates")
  rescue Timeout::Error, SocketError, Net::OpenTimeout, Net::ReadTimeout => e
    raise Error, "Gemini request errored: #{e.message}"
  end
end
