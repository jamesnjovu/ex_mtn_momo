defmodule ExMtnMomo.HttpRequest do
  @moduledoc false
  @options [
    timeout: 500_000,
    recv_timeout: 500_000,
    hackney: [:insecure]
  ]

  def header(key),
    do: [
      {"Content-Type", "application/json"},
      {"Origin", "*"},
      {"Authorization", "Bearer #{key}"},
    ]

  def post(url, body, headers \\ []),
    do: HTTPoison.post(url, Jason.encode!(body), headers, @options)

  def put(url, body, headers \\ []),
    do: HTTPoison.put(url, Jason.encode!(body), headers, @options)

  def get(url, attrs \\ %{}, headers \\ []),
    do: (if Enum.empty?(attrs),
          do: HTTPoison.get(url, headers, @options),
          else: HTTPoison.get("#{url}?#{URI.encode_query(attrs)}", headers, @options))

  def handle_response({:ok, %HTTPoison.Response{status_code: 200, body: ""}}), do: {:ok, ""}
  def handle_response({:ok, %HTTPoison.Response{status_code: 200, body: body}}), do: {:ok, Jason.decode!(body)}
  def handle_response({:ok, %HTTPoison.Response{status_code: 201, body: ""}}), do: {:ok, ""}
  def handle_response({:ok, %HTTPoison.Response{status_code: 202, body: ""}}), do: {:ok, ""}
  def handle_response({:ok, %HTTPoison.Response{status_code: 201, body: body}}), do: {:ok, Jason.decode!(body)}
  def handle_response({:ok, %HTTPoison.Response{status_code: 400, body: ""}}), do: {:error, ""}
  def handle_response({:ok, %HTTPoison.Response{status_code: 400, body: body}}), do: {:error, Jason.decode!(body)}
  def handle_response({:ok, %HTTPoison.Response{status_code: 401, body: body}}), do: {:error, Jason.decode!(body)}
  def handle_response({:ok, %HTTPoison.Response{status_code: 405, body: body}}), do: {:error, Jason.decode!(body)}
  def handle_response({:ok, %HTTPoison.Response{status_code: 408, body: body}}), do: {:error, Jason.decode!(body)}
  def handle_response({:ok, %HTTPoison.Response{status_code: 409, body: body}}), do: {:error, Jason.decode!(body)}
  def handle_response({:ok, %HTTPoison.Response{status_code: 422, body: body}}), do: {:error, Jason.decode!(body)}
  def handle_response({:ok, %HTTPoison.Response{status_code: 500, body: body}}), do: {:error, Jason.decode!(body)}
  def handle_response({:ok, %HTTPoison.Response{status_code: 503, body: body}}), do: {:error, Jason.decode!(body)}
  def handle_response({:error, %HTTPoison.Error{reason: message}}), do: {:error, %{"output_error" => message}}

end
