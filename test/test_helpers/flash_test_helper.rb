module FlashTestHelper
  def assert_notice(text)
    assert_select "div", /#{text}/
  end
end

ActiveSupport.on_load(:action_dispatch_integration_test) do
  include FlashTestHelper
end
