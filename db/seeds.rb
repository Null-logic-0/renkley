[
  { key: "chatgpt", name: "ChatGPT" },
  { key: "claude", name: "Claude" },
  { key: "gemini", name: "Gemini" },
  { key: "perplexity", name: "Perplexity" }
].each_with_index do |attrs, index|
  AiPlatform.find_or_create_by!(key: attrs[:key]) do |platform|
    platform.name = attrs[:name]
    platform.position = index
  end
end
