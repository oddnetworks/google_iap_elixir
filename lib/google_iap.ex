defmodule GoogleIAP do
  @moduledoc """
  Documentation for GoogleIAP.
  """

  alias GoogleIAP.Client

  @doc """
  Get a subscription from Google

  Args:
    * `package_name`- Your app's package name in Google
    * `subscription_id` - The Google customer of your app
    * `token` - The receipt ID of the purchase
  """
  @spec get_subscription(String.t, String.t, String.t) :: HTTPoison.Response
  def get_subscription(package_name, subscription_id, token) do
    subscription_url("get", package_name, subscription_id, token)
    |> Client.get
  end

  @doc """
  Cancels a receipt with Google

  Args:
    * `package_name`- Your app's package name in Google
    * `subscription_id` - The Google customer of your app
    * `token` - The receipt ID of the purchase
  """
  @spec cancel_subscription(String.t, String.t, String.t) :: HTTPoison.Response
  def cancel_subscription(package_name, subscription_id, token) do
    subscription_url("cancel", package_name, subscription_id, token)
    |> Client.post("")
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
  @spec defer_subscription(String.t, String.t, String.t, DateTime.t, DateTime.t) :: HTTPoison.Response
  def defer_subscription(package_name, subscription_id, token, expected_date, desired_date) do
    body = %{
      deferralInfo: %{
        expectedExpiryTimeMillis: DateTime.to_unix(expected_date),
        desiredExpiryTimeMillis: DateTime.to_unix(desired_date)
      }
    }
    subscription_url("defer", package_name, subscription_id, token)
    |> Client.post(body, [{"content-type", "application/json"}])
  end

  @doc """
  Refund a subscription with Google and let it expire on its own

  Args:
    * `package_name`- Your app's package name in Google
    * `subscription_id` - The Google customer of your app
    * `token` - The receipt ID of the purchase
  """
  @spec refund_subscription(String.t, String.t, String.t) :: HTTPoison.Response
  def refund_subscription(package_name, subscription_id, token) do
     subscription_url("refund", package_name, subscription_id, token)
    |> Client.post("")
  end

  @doc """
  Revoke a subscription with Google and immediately expire it

  Args:
    * `package_name`- Your app's package name in Google
    * `subscription_id` - The Google customer of your app
    * `token` - The receipt ID of the purchase
  """
  @spec revoke_subscription(String.t, String.t, String.t) :: HTTPoison.Response
  def revoke_subscription(package_name, subscription_id, token) do
     subscription_url("revoke", package_name, subscription_id, token)
    |> Client.post("")
  end

  defp subscription_url(action, package_name, subscription_id, token) do
    url = "/#{package_name}/purchases/subscriptions/#{subscription_id}/tokens/#{token}"
    case action do
      "get" -> url
      _default -> url <> action
    end
  end
end
