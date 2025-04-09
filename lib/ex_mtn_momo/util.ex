defmodule ExMtnMomo.Util do
  @moduledoc """
  Provides utility functions and configuration handling for the ExMtnMomo library.

  This module handles:

  * Extracting configuration values with fallbacks
  * Creating authentication headers
  * Sending HTTP requests through the HttpRequest module

  Most of these functions are used internally by the library and typically
  don't need to be called directly by library users.
  """

  alias ExMtnMomo.HttpRequest

  @doc """
  Extracts the base URL from options or application configuration.

  ## Parameters

  * `options` - Keyword list of options that may include :base_url (optional)

  ## Returns

  * The base URL for API requests

  ## Examples

      iex> ExMtnMomo.Util.extract_base_url()
      "https://sandbox.momodeveloper.mtn.com"

      iex> ExMtnMomo.Util.extract_base_url(base_url: "https://custom.api.url")
      "https://custom.api.url"
  """
  def extract_base_url(options \\ []), do: Keyword.get(options, :base_url, Application.get_env(:ex_mtn_momo, :base_url))

  @doc """
  Extracts the sandbox key from options or application configuration.

  ## Parameters

  * `options` - Keyword list of options that may include :sandbox_key (optional)

  ## Returns

  * The sandbox key for authentication
  """
  def extract_sand_box_key(options \\ []), do: Keyword.get(options, :sandbox_key, Application.get_env(:ex_mtn_momo, :sandbox_key))

  @doc """
  Extracts the disbursement secondary key from options or application configuration.

  ## Parameters

  * `options` - Keyword list of options that may include :secondary_key (optional)

  ## Returns

  * The disbursement secondary key
  """
  def extract_disbursement_secondary_key(options \\ []), do: Keyword.get(options, :secondary_key, Application.get_env(:ex_mtn_momo, :disbursement).secondary_key)

  @doc """
  Extracts the disbursement primary key from options or application configuration.

  ## Parameters

  * `options` - Keyword list of options that may include :primary_key (optional)

  ## Returns

  * The disbursement primary key
  """
  def extract_disbursement_primary_key(options \\ []), do: Keyword.get(options, :primary_key, Application.get_env(:ex_mtn_momo, :disbursement).primary_key)

  @doc """
  Extracts the disbursement user ID from options or application configuration.

  ## Parameters

  * `options` - Keyword list of options that may include :user_id (optional)

  ## Returns

  * The disbursement user ID
  """
  def extract_disbursement_user_id(options \\ []), do: Keyword.get(options, :user_id, Application.get_env(:ex_mtn_momo, :disbursement).user_id)

  @doc """
  Extracts the disbursement API key from options or application configuration.

  ## Parameters

  * `options` - Keyword list of options that may include :api_key (optional)

  ## Returns

  * The disbursement API key
  """
  def extract_disbursement_api_key(options \\ []), do: Keyword.get(options, :api_key, Application.get_env(:ex_mtn_momo, :disbursement).api_key)

  @doc """
  Extracts the collection secondary key from options or application configuration.

  ## Parameters

  * `options` - Keyword list of options that may include :secondary_key (optional)

  ## Returns

  * The collection secondary key
  """
  def extract_collection_secondary_key(options \\ []), do: Keyword.get(options, :secondary_key, Application.get_env(:ex_mtn_momo, :collection).secondary_key)

  @doc """
  Extracts the collection primary key from options or application configuration.

  ## Parameters

  * `options` - Keyword list of options that may include :primary_key (optional)

  ## Returns

  * The collection primary key
  """
  def extract_collection_primary_key(options \\ []), do: Keyword.get(options, :primary_key, Application.get_env(:ex_mtn_momo, :collection).primary_key)

  @doc """
  Extracts the collection user ID from options or application configuration.

  ## Parameters

  * `options` - Keyword list of options that may include :user_id (optional)

  ## Returns

  * The collection user ID
  """
  def extract_collection_user_id(options \\ []), do: Keyword.get(options, :user_id, Application.get_env(:ex_mtn_momo, :collection).user_id)

  @doc """
  Extracts the collection API key from options or application configuration.

  ## Parameters

  * `options` - Keyword list of options that may include :api_key (optional)

  ## Returns

  * The collection API key
  """
  def extract_collection_api_key(options \\ []), do: Keyword.get(options, :api_key, Application.get_env(:ex_mtn_momo, :collection).api_key)

  @doc """
  Extracts the target environment from options or application configuration.

  ## Parameters

  * `options` - Keyword list of options that may include :x_target_environment (optional)

  ## Returns

  * The target environment (e.g., "sandbox", "mtnzambia")

  ## Examples

      iex> ExMtnMomo.Util.extract_x_target_environment()
      "sandbox"

      iex> ExMtnMomo.Util.extract_x_target_environment(x_target_environment: "mtnzambia")
      "mtnzambia"
  """
  def extract_x_target_environment(options \\ []), do: Keyword.get(options, :x_target_environment, Application.get_env(:ex_mtn_momo, :x_target_environment))

  @doc """
  Creates a Basic Authentication header value for collection API operations.

  ## Parameters

  * `options` - Keyword list of options (optional)

  ## Returns

  * The Basic Auth header value for collection operations

  ## Examples

      iex> ExMtnMomo.Util.collection_auth()
      "Basic dXNlcmlkOmFwaWtleQ=="
  """
  def collection_auth(options \\ []), do: basic_auth(extract_collection_user_id(options), extract_collection_api_key(options))

  @doc """
  Creates a Basic Authentication header value for disbursement API operations.

  ## Parameters

  * `options` - Keyword list of options (optional)

  ## Returns

  * The Basic Auth header value for disbursement operations

  ## Examples

      iex> ExMtnMomo.Util.disbursement_auth()
      "Basic dXNlcmlkOmFwaWtleQ=="
  """
  def disbursement_auth(options \\ []), do: basic_auth(extract_disbursement_user_id(options), extract_disbursement_api_key(options))

  @doc """
  Creates a Basic Authentication header value from a username and password.

  ## Parameters

  * `username` - The username for authentication
  * `password` - The password or API key for authentication

  ## Returns

  * The Basic Auth header value in the format "Basic {base64-encoded string}"

  ## Examples

      iex> ExMtnMomo.Util.basic_auth("user123", "pass456")
      "Basic dXNlcjEyMzpwYXNzNDU2"
  """
  def basic_auth(username, password), do: "Basic #{Base.encode64(username <> ":" <> password)}"

  @doc """
  Sends a GET request to the specified URL.

  ## Parameters

  * `url` - The URL to send the request to
  * `attrs` - Query parameters to append to the URL
  * `header` - HTTP headers to include with the request

  ## Returns

  * `{:ok, response_body}` on success
  * `{:error, error_message}` on failure
  """
  def send_get(url, attrs, header) do
    HttpRequest.get(url, attrs, header)
    |> HttpRequest.handle_response()
  end

  @doc """
  Sends a POST request to the specified URL.

  ## Parameters

  * `url` - The URL to send the request to
  * `attrs` - Request body payload
  * `headers` - HTTP headers to include with the request

  ## Returns

  * `{:ok, response_body}` on success
  * `{:error, error_message}` on failure
  """
  def send_post(url, attrs, headers) do
    HttpRequest.post(url, attrs, headers)
    |> HttpRequest.handle_response()
  end

  @doc """
  Sends a PUT request to the specified URL.

  ## Parameters

  * `url` - The URL to send the request to
  * `attrs` - Request body payload
  * `encrypt_api_key` - API key for authentication

  ## Returns

  * `{:ok, response_body}` on success
  * `{:error, error_message}` on failure
  """
  def send_put(url, attrs, encrypt_api_key) do
    HttpRequest.put(url, attrs, HttpRequest.header(encrypt_api_key))
    |> HttpRequest.handle_response()
  end
end
