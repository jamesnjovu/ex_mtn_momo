defmodule ExMtnMomo.HttpRequest do
  @moduledoc false
  @moduledoc """
  Provides HTTP request functionality for the ExMtnMomo library.

  This module handles the low-level HTTP operations needed to communicate with
  the MTN Mobile Money API, including:

  * Making POST, PUT, and GET requests
  * Handling responses and errors
  * Parsing JSON responses

  This module is used internally by the ExMtnMomo library and typically
  doesn't need to be used directly by library users.
  """

  @options [
    timeout: 500_000,
    recv_timeout: 500_000,
    hackney: [:insecure]
  ]

  @doc """
  Creates standard headers for HTTP requests with an authentication token.

  ## Parameters

  * `key` - The authentication token or key to include in the Authorization header

  ## Returns

  * A list of HTTP headers with Content-Type, Origin and Authorization

  ## Examples

      iex> ExMtnMomo.HttpRequest.header("eyJ0eXAi...")
      [
        {"Content-Type", "application/json"},
        {"Origin", "*"},
        {"Authorization", "Bearer eyJ0eXAi..."},
      ]
  """
  def header(key),
    do: [
      {"Content-Type", "application/json"},
      {"Origin", "*"},
      {"Authorization", "Bearer #{key}"}
    ]

  @doc """
  Sends a POST request to the specified URL.

  ## Parameters

  * `url` - The URL to send the request to
  * `body` - The request payload, will be encoded as JSON
  * `headers` - Custom headers to include with the request (optional)

  ## Returns

  * The response from the HTTP client (HTTPoison)

  ## Examples

      iex> ExMtnMomo.HttpRequest.post("https://api.example.com/endpoint", %{key: "value"}, [{"X-Custom", "Header"}])
      {:ok, %HTTPoison.Response{...}}
  """
  def post(url, body, headers \\ []),
    do: HTTPoison.post(url, Jason.encode!(body), headers, @options)

  @doc """
  Sends a PUT request to the specified URL.

  ## Parameters

  * `url` - The URL to send the request to
  * `body` - The request payload, will be encoded as JSON
  * `headers` - Custom headers to include with the request (optional)

  ## Returns

  * The response from the HTTP client (HTTPoison)

  ## Examples

      iex> ExMtnMomo.HttpRequest.put("https://api.example.com/endpoint", %{key: "value"}, [{"X-Custom", "Header"}])
      {:ok, %HTTPoison.Response{...}}
  """
  def put(url, body, headers \\ []),
    do: HTTPoison.put(url, Jason.encode!(body), headers, @options)

  @doc """
  Sends a GET request to the specified URL.

  ## Parameters

  * `url` - The URL to send the request to
  * `attrs` - Query parameters to append to the URL (optional)
  * `headers` - Custom headers to include with the request (optional)

  ## Returns

  * The response from the HTTP client (HTTPoison)

  ## Examples

      iex> ExMtnMomo.HttpRequest.get("https://api.example.com/endpoint", %{filter: "value"}, [{"X-Custom", "Header"}])
      {:ok, %HTTPoison.Response{...}}
  """
  def get(url, attrs \\ %{}, headers \\ []),
    do:
      if(Enum.empty?(attrs),
        do: HTTPoison.get(url, headers, @options),
        else: HTTPoison.get("#{url}?#{URI.encode_query(attrs)}", headers, @options)
      )

  @doc """
  Handles HTTP responses and standardizes the return format.

  This function processes the raw response from HTTPoison and converts it
  into a more usable format for the library.

  ## Parameters

  * `response` - The response tuple from an HTTP request

  ## Returns

  * `{:ok, body}` - For successful responses, with body parsed from JSON
  * `{:error, message}` - For error responses, with error message

  ## Response Status Codes

  * 200, 201, 202 - Success responses
  * 400, 401, 405, 408, 409, 422, 500, 503 - Error responses with specific handling
  """
  def handle_response({:ok, %HTTPoison.Response{status_code: 200, body: ""}}),
    do: {:ok, "Accepted"}

  def handle_response({:ok, %HTTPoison.Response{status_code: 200, body: body}}),
    do: {:ok, Jason.decode!(body)}

  def handle_response({:ok, %HTTPoison.Response{status_code: 201, body: ""}}),
    do: {:ok, "Accepted"}

  def handle_response({:ok, %HTTPoison.Response{status_code: 202, body: ""}}),
    do: {:ok, "Accepted"}

  def handle_response({:ok, %HTTPoison.Response{status_code: 201, body: body}}),
    do: {:ok, Jason.decode!(body)}

  def handle_response({:ok, %HTTPoison.Response{status_code: 400, body: ""}}),
    do: {:error, "400 Bad request, e.g. invalid data was sent in the request."}

  def handle_response({:ok, %HTTPoison.Response{status_code: 400, body: body}}),
    do: {:error, Jason.decode!(body)}

  def handle_response({:ok, %HTTPoison.Response{status_code: 401, body: body}}),
    do: {:error, Jason.decode!(body)}

  def handle_response({:ok, %HTTPoison.Response{status_code: 405, body: body}}),
    do: {:error, Jason.decode!(body)}

  def handle_response({:ok, %HTTPoison.Response{status_code: 408, body: body}}),
    do: {:error, Jason.decode!(body)}

  def handle_response({:ok, %HTTPoison.Response{status_code: 409, body: ""}}),
    do: {:error, "Conflict, duplicated reference id"}

  def handle_response({:ok, %HTTPoison.Response{status_code: 409, body: body}}),
    do: {:error, Jason.decode!(body)}

  def handle_response({:ok, %HTTPoison.Response{status_code: 422, body: body}}),
    do: {:error, Jason.decode!(body)}

  def handle_response({:ok, %HTTPoison.Response{status_code: 500, body: body}}),
    do: {:error, Jason.decode!(body)}

  def handle_response({:ok, %HTTPoison.Response{status_code: 503, body: body}}),
    do: {:error, Jason.decode!(body)}

  def handle_response({:error, %HTTPoison.Error{reason: message}}),
    do: {:error, %{"output_error" => message}}
end
