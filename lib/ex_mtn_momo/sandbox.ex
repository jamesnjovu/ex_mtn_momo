defmodule ExMtnMomo.Sandbox do
  @moduledoc """
  Provides functions for working with the MTN Mobile Money Sandbox environment.

  The Sandbox module allows developers to:

  * Generate UUIDs for reference IDs
  * Create API users in the sandbox environment
  * Retrieve information about created users
  * Generate API keys for users

  This module is primarily used during development and testing to set up the
  necessary credentials for interacting with other MTN MoMo API endpoints.

  ## Examples

  ```elixir
  # Generate a UUID for user creation
  uuid = ExMtnMomo.Sandbox.get_uuid4()

  # Create a user in the sandbox environment
  {:ok, _} = ExMtnMomo.Sandbox.create_api_user(uuid)

  # Get information about the created user
  {:ok, user_info} = ExMtnMomo.Sandbox.get_created_user(uuid)

  # Generate an API key for the user
  {:ok, %{"apiKey" => api_key}} = ExMtnMomo.Sandbox.get_api_key(uuid)
  ```
  """

  alias ExMtnMomo.Util

  @doc """
  Generates a UUID v4 string.

  This UUID can be used as a reference ID for API user creation and other operations.

  ## Examples

      iex> ExMtnMomo.Sandbox.get_uuid4()
      "f1bfc995-8dbe-4afb-aa82-a8c75a37edf6"

  """
  def get_uuid4, do: UUID.uuid4()

  @doc """
  Creates an API user in the sandbox environment.

  ## Parameters

  * `uuid4` - A UUID v4 string to use as the reference ID for the user
  * `callback_url` - URL to receive API callbacks (optional)
  * `options` - Additional configuration options (optional)

  ## Options

  The `options` parameter can include the following keys:

  * `:base_url` - Override the base URL for the API request
  * `:secondary_key` - Override the secondary key to use for authentication

  ## Returns

  * `{:ok, "User Created"}` on success
  * `{:error, reason}` on failure

  ## Examples

      iex> uuid = ExMtnMomo.Sandbox.get_uuid4()
      iex> ExMtnMomo.Sandbox.create_api_user(uuid)
      {:ok, "User Created"}

  """
  def create_api_user(
        uuid4,
        callback_url \\ "https://webhook.site/2b823c34-90d7-4bf7-bd69-0f0559efcf3a",
        options \\ []
      ) do
    body = %{
      "providerCallbackHost" => callback_url
    }

    headers = [
      {"Content-Type", "application/json"},
      {"Ocp-Apim-Subscription-Key", Util.extract_sand_box_key(options)},
      {"X-Reference-Id", uuid4}
    ]

    "#{Util.extract_base_url(options)}/v1_0/apiuser"
    |> Util.send_post(body, headers)
    |> case do
      {:ok, _} -> {:ok, "User Created"}
      {:error, message} -> {:error, message}
    end
  end

  @doc """
  Retrieves information about a previously created API user.

  ## Parameters

  * `uuid4` - The UUID of the created user
  * `options` - Additional configuration options (optional)

  ## Options

  The `options` parameter can include the following keys:

  * `:base_url` - Override the base URL for the API request
  * `:secondary_key` - Override the secondary key to use for authentication

  ## Returns

  * `{:ok, user_details}` on success
  * `{:error, reason}` on failure

  ## Examples

      iex> uuid = "f1bfc995-8dbe-4afb-aa82-a8c75a37edf6"
      iex> ExMtnMomo.Sandbox.get_created_user(uuid)
      {:ok, %{"providerCallbackHost" => "https://webhook.site/2b823c34-90d7-4bf7-bd69-0f0559efcf3a", ...}}

  """
  def get_created_user(uuid4, options \\ []) do
    headers = [
      {"Content-Type", "application/json"},
      {"Ocp-Apim-Subscription-Key", Util.extract_sand_box_key(options)}
    ]

    "#{Util.extract_base_url(options)}/v1_0/apiuser/#{uuid4}"
    |> Util.send_get(%{}, headers)
    |> case do
      {:ok, body} -> {:ok, body}
      {:error, message} -> {:error, message}
    end
  end

  @doc """
  Generates and retrieves an API key for a user.

  ## Parameters

  * `uuid4` - The UUID of the user
  * `options` - Additional configuration options (optional)

  ## Options

  The `options` parameter can include the following keys:

  * `:base_url` - Override the base URL for the API request
  * `:secondary_key` - Override the secondary key to use for authentication

  ## Returns

  * `{:ok, %{"apiKey" => api_key}}` on success
  * `{:error, reason}` on failure

  ## Examples

      iex> uuid = "f1bfc995-8dbe-4afb-aa82-a8c75a37edf6"
      iex> ExMtnMomo.Sandbox.get_api_key(uuid)
      {:ok, %{"apiKey" => "a94d865a12e047319c6e673a15b48776"}}

  """
  def get_api_key(uuid4, options \\ []) do
    headers = [
      {"Content-Type", "application/json"},
      {"Ocp-Apim-Subscription-Key", Util.extract_sand_box_key(options)}
    ]

    "#{Util.extract_base_url(options)}/v1_0/apiuser/#{uuid4}/apikey"
    |> Util.send_post(%{}, headers)
    |> case do
      {:ok, body} -> {:ok, body}
      {:error, message} -> {:error, message}
    end
  end
end
