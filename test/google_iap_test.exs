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
    response = %{
      "kind" => "androidpublisher#subscriptionPurchase",
      "startTimeMillis" => 12345,
      "expiryTimeMillis" => 12345,
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

    assert GoogleIAP.get_subscription("p_1", "s_1", "t_1") ==
      {:ok, %HTTPoison.Response{
          status_code: 200,
          body: response
        }
      }

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

    assert GoogleIAP.cancel_subscription("p_1", "s_1", "t_1") ==
      {:ok, %HTTPoison.Response{
          status_code: 200,
          body: ""
        }
      }

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

    response = %{
      "newExpiryTimeMillis" => 54321
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

    assert GoogleIAP.defer_subscription("p_1", "s_1", "t_1", expected_date, desired_date) ==
      {:ok, %HTTPoison.Response{
          status_code: 200,
          body: response
        }
      }

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

    assert GoogleIAP.refund_subscription("p_1", "s_1", "t_1") ==
      {:ok, %HTTPoison.Response{
          status_code: 200,
          body: ""
        }
      }

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

    assert GoogleIAP.revoke_subscription("p_1", "s_1", "t_1") ==
      {:ok, %HTTPoison.Response{
          status_code: 200,
          body: ""
        }
      }

    assert validate :hackney
  end
end
