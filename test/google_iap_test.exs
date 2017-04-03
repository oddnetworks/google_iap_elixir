defmodule GoogleIAPTest do
  use ExUnit.Case
  
  import :meck
  alias GoogleIAP

  setup do
    new :hackney
    on_exit fn -> unload() end
    :ok
  end

  test "get_subscription/3" do
    subscription = %GoogleIAP.Subscription{
      startTime: DateTime.from_unix!(1490964684, :microsecond),
      expiryTime: DateTime.from_unix!(1490964684, :microsecond),
      autoRenewing: true,
      priceCurrencyCode: :USD,
      priceAmount: 1.99,
      countryCode: :US,
      developerPayload: "",
      paymentState: :received,
      cancelReason: :system,
      userCancellationTime: nil
    }

    response = %{
      "kind" => "androidpublisher#subscriptionPurchase",
      "startTimeMillis" => 1490964684,
      "expiryTimeMillis" => 1490964684,
      "autoRenewing" => true,
      "priceCurrencyCode" => "USD",
      "priceAmountMicros" => 1990000,
      "countryCode" => "US",
      "developerPayload" => "",
      "paymentState" => 1,
      "cancelReason" => nil,
      "userCancellationTimeMillis" => nil
    }

    expect(
      :hackney, 
      :request, 
      [
        {
          [:get, "https://www.googleapis.com/androidpublisher/v2/applications/p_1/purchases/subscriptions/s_1/tokens/t_1", [{"accept", "application/json"}], "", []],
          {:ok, 200, [], :client}
        }
      ])
    expect(:hackney, :body, 1, {:ok, Poison.encode!(response)})

    assert {:ok, subscription} == GoogleIAP.get_subscription("p_1", "s_1", "t_1")

    assert validate :hackney
  end

  test "cancel_subscription/3" do
    expect(
      :hackney, 
      :request, 
      [
        {
          [:post, "https://www.googleapis.com/androidpublisher/v2/applications/p_1/purchases/subscriptions/s_1/tokens/t_1:cancel", [{"accept", "application/json"}], "", []],
          {:ok, 200, [], :client}
        }
      ])
    expect(:hackney, :body, 1, {:ok, ""})

    assert :ok == GoogleIAP.cancel_subscription("p_1", "s_1", "t_1")

    assert validate :hackney
  end

  test "defer_subscription/5" do
    expected_date = %DateTime{year: 2000, month: 2, day: 29, zone_abbr: "UTC",
                              hour: 23, minute: 0, second: 7, microsecond: {0, 0},
                              utc_offset: 0, std_offset: 0, time_zone: "Etc/UTC"}
    desired_date = %DateTime{year: 2000, month: 2, day: 29, zone_abbr: "UTC",
                             hour: 23, minute: 0, second: 7, microsecond: {0, 0},
                             utc_offset: 0, std_offset: 0, time_zone: "Etc/UTC"}

    request = %{
      "deferralInfo" => %{
        "expectedExpiryTimeMillis" => DateTime.to_unix(expected_date),
        "desiredExpiryTimeMillis" => DateTime.to_unix(desired_date)
      }
    }

    new_expiry_time = DateTime.from_unix!(1490964684)

    response = %{
      "newExpiryTimeMillis" => 1490964684
    }

    expect(
      :hackney, 
      :request, 
      [
        {
          [:post, "https://www.googleapis.com/androidpublisher/v2/applications/p_1/purchases/subscriptions/s_1/tokens/t_1:defer", [{"accept", "application/json"}, {"content-type", "application/json"}], Poison.encode!(request), []],
          {:ok, 200, [], :client}
        }
      ])
    expect(:hackney, :body, 1, {:ok, Poison.encode!(response)})

    assert {:ok, new_expiry_time} == GoogleIAP.defer_subscription("p_1", "s_1", "t_1", expected_date, desired_date)

    assert validate :hackney
  end

  test "refund_subscription/3" do
    expect(
      :hackney, 
      :request, 
      [
        {
          [:post, "https://www.googleapis.com/androidpublisher/v2/applications/p_1/purchases/subscriptions/s_1/tokens/t_1:refund", [{"accept", "application/json"}], "", []],
          {:ok, 200, [], :client}
        }
      ])
    expect(:hackney, :body, 1, {:ok, ""})

    assert :ok == GoogleIAP.refund_subscription("p_1", "s_1", "t_1")

    assert validate :hackney
  end

  test "revoke_subscription/3" do
    expect(
      :hackney, 
      :request, 
      [
        {
          [:post, "https://www.googleapis.com/androidpublisher/v2/applications/p_1/purchases/subscriptions/s_1/tokens/t_1:revoke", [{"accept", "application/json"}], "", []],
          {:ok, 200, [], :client}
        }
      ])
    expect(:hackney, :body, 1, {:ok, ""})

    assert :ok == GoogleIAP.revoke_subscription("p_1", "s_1", "t_1")

    assert validate :hackney
  end
end
