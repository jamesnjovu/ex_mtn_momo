defmodule ExMtnMomo.Sandbox do
  alias ExMtnMomo.Util

  def get_uuid4, do: UUID.uuid4()

  def create_api_user(
        uuid4,
        callback_url \\ "https://webhook.site/2b823c34-90d7-4bf7-bd69-0f0559efcf3a",
        options \\ []
      ) do
    base_url = Util.extract_base_url(options)
    disbursement_secondary_key = Util.extract_collection_secondary_key(options)

    body = %{
      "providerCallbackHost" => callback_url
    }

    headers = [
      {"Content-Type", "application/json"},
      {"Ocp-Apim-Subscription-Key", disbursement_secondary_key},
      {"X-Reference-Id", uuid4}
    ]

    "#{base_url}/v1_0/apiuser"
    |> Util.send_post(body, headers)
    |> case do
      {:ok, _} -> {:ok, "User Created"}
      {:error, message} -> {:error, message}
    end
  end

  def get_created_user(uuid4, options \\ []) do
    base_url = Util.extract_base_url(options)
    disbursement_secondary_key = Util.extract_collection_secondary_key(options)

    headers = [
      {"Content-Type", "application/json"},
      {"Ocp-Apim-Subscription-Key", disbursement_secondary_key}
    ]

    "#{base_url}/v1_0/apiuser/#{uuid4}"
    |> Util.send_get(%{}, headers)
    |> case do
      {:ok, body} -> {:ok, body}
      {:error, message} -> {:error, message}
    end
  end

  def get_api_key(uuid4, options \\ []) do
    base_url = Util.extract_base_url(options)
    disbursement_secondary_key = Util.extract_collection_secondary_key(options)

    headers = [
      {"Content-Type", "application/json"},
      {"Ocp-Apim-Subscription-Key", disbursement_secondary_key}
    ]

    "#{base_url}/v1_0/apiuser/#{uuid4}/apikey"
    |> Util.send_post(%{}, headers)
    |> case do
      {:ok, body} -> {:ok, body}
      {:error, message} -> {:error, message}
    end
  end
end
