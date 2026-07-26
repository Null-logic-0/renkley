require "test_helper"

class AiPlatformTest < ActiveSupport::TestCase
  test "integrated? reflects whether a real API key is configured" do
    assert ai_platforms(:gemini).integrated?
    assert_not ai_platforms(:chatgpt).integrated?
  end

  test "integrated scope only returns platforms with a real integration" do
    assert_equal [ ai_platforms(:gemini) ], AiPlatform.integrated.to_a
  end
end
