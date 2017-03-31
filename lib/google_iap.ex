defmodule GoogleIAP do
  @moduledoc """
  Documentation for GoogleIAP.
  """

  alias GoogleIAP.Client

  defmodule Subscription do
    defstruct(startTime: nil,
            expiryTime: nil,
            autoRenewing: false,
            priceCurrencyCode: nil,
            priceAmount: nil,
            countryCode: nil,
            developerPayload: nil,
            paymentState: :received,
            cancelReason: :system,
            userCancellationTime: nil)
  end

  @doc """
  Get a subscription from Google

  Args:
    * `package_name`- Your app's package name in Google
    * `subscription_id` - The Google customer of your app
    * `token` - The receipt ID of the purchase
  """
  @spec get_subscription(String.t, String.t, String.t) :: {:ok, Subscription | :error, String.t}
  def get_subscription(package_name, subscription_id, token) do
    case subscription_url("get", package_name, subscription_id, token) |> Client.get do
      {:ok, response} -> {:ok, %Subscription{
                                startTime: DateTime.from_unix!(response.body["startTimeMillis"], :microsecond),
                                expiryTime: DateTime.from_unix!(response.body["expiryTimeMillis"], :microsecond),
                                autoRenewing: response.body["autoRenewing"],
                                priceAmount: response.body["priceAmountMicros"] / 1000000,
                                priceCurrencyCode: String.to_atom(response.body["priceCurrencyCode"]),
                                countryCode: String.to_atom(response.body["countryCode"]),
                                developerPayload: response.body["developerPayload"],
                                paymentState: (if (response.body["paymentState"] == 0), do: :pending, else: :received),
                                cancelReason: (if (response.body["cancelReason"] == 0), do: :user, else: :system),
                                userCancellationTime: (if (response.body["cancelReason"] == 0), do: DateTime.from_unix!(response.body["userCancellationTimeMillis"], :microsecond), else: nil)
                              }}
      {:error, error} -> error.reason
    end
  end

  @doc """
  Cancels a receipt with Google

  Args:
    * `package_name`- Your app's package name in Google
    * `subscription_id` - The Google customer of your app
    * `token` - The receipt ID of the purchase
  """
  @spec cancel_subscription(String.t, String.t, String.t) :: {:ok | :error, String.t}
  def cancel_subscription(package_name, subscription_id, token) do
    case subscription_url("cancel", package_name, subscription_id, token) |> Client.post("") do
      {:ok, _} -> :ok
      {:error, error} -> error.reason
    end
  end

  @doc """
  Defer a subscription with Google until a future date

  Args:
    * `package_name`- Your app's package name in Google
    * `subscription_id` - The Google customer of your app
    * `token` - The receipt ID of the purchase
    * `expected_date`
    * `desired_date`
  """
  @spec defer_subscription(String.t, String.t, String.t, DateTime.t, DateTime.t) :: {:ok, DateTime.t | :error, String.t}
  def defer_subscription(package_name, subscription_id, token, expected_date, desired_date) do
    body = %{
      deferralInfo: %{
        expectedExpiryTimeMillis: DateTime.to_unix(expected_date),
        desiredExpiryTimeMillis: DateTime.to_unix(desired_date)
      }
    }

    case subscription_url("defer", package_name, subscription_id, token) |> Client.post(body, [{"content-type", "application/json"}]) do
      {:ok, response} -> {:ok, DateTime.from_unix!(response.body["newExpiryTimeMillis"])}
      {:error, error} -> error.reason
    end
  end

  @doc """
  Refund a subscription with Google and let it expire on its own

  Args:
    * `package_name`- Your app's package name in Google
    * `subscription_id` - The Google customer of your app
    * `token` - The receipt ID of the purchase
  """
  @spec refund_subscription(String.t, String.t, String.t) :: {:ok | :error, String.t}
  def refund_subscription(package_name, subscription_id, token) do
    case subscription_url("refund", package_name, subscription_id, token) |> Client.post("") do
      {:ok, _} -> :ok
      {:error, error} -> error.reason
    end
  end

  @doc """
  Revoke a subscription with Google and immediately expire it

  Args:
    * `package_name`- Your app's package name in Google
    * `subscription_id` - The Google customer of your app
    * `token` - The receipt ID of the purchase
  """
  @spec revoke_subscription(String.t, String.t, String.t) :: {:ok | :error, String.t}
  def revoke_subscription(package_name, subscription_id, token) do
    case subscription_url("revoke", package_name, subscription_id, token) |> Client.post("") do
      {:ok, _} -> :ok
      {:error, error} -> error.reason
    end
  end

  defp subscription_url(action, package_name, subscription_id, token) do
    url = "/#{package_name}/purchases/subscriptions/#{subscription_id}/tokens/#{token}"
    case action do
      "get" -> url
      _default -> url <> ":" <> action
    end
  end
end