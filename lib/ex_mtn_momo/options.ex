defmodule ExMtnMomo.Options do
  alias ExMtnMomo.HttpRequest

  def extract_base_url(options \\ []), do: Keyword.get(options, :base_url, Application.get_env(:ex_mtn_momo, :base_url))

  def extract_disbursement_secondary_key(options \\ []), do: Keyword.get(options, :disbursement_secondary_key, Application.get_env(:ex_mtn_momo, :disbursement_secondary_key))

  @doc false
  def send_get(url, attrs, header) do
    HttpRequest.get(url, attrs, header)
    |> HttpRequest.handle_response()
  end

  @doc false
  def send_post(url, attrs, headers) do
    HttpRequest.post(url, attrs, headers)
    |> IO.inspect
    |> HttpRequest.handle_response()
  end

  @doc false
  def send_put(url, attrs, encrypt_api_key) do
    HttpRequest.put(url, attrs, HttpRequest.header(encrypt_api_key))
    |> HttpRequest.handle_response()
  end
end
