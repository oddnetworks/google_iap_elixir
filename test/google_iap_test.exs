defmodule GoogleIAPTest do
  use ExUnit.Case, async: true
  
  import :meck
  alias GoogleIAP

  setup do
    new :hackney
    on_exit fn -> unload() end
    :ok
  end

  test "get_subscription/3" do
    
  end

  test "cancel_subscription/3" do
    
  end

  test "defer_subscription/5" do
    
  end

  test "refund_subscription/3" do
    
  end

  test "revoke_subscription/3" do
    
  end
end
