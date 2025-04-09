defmodule ExMtnMomo.Util do
  alias ExMtnMomo.HttpRequest

  def extract_base_url(options \\ []), do: Keyword.get(options, :base_url, Application.get_env(:ex_mtn_momo, :base_url))

  def extract_disbursement_secondary_key(options \\ []), do: Keyword.get(options, :secondary_key, Application.get_env(:ex_mtn_momo, :disbursement).secondary_key)
  def extract_disbursement_primary_key(options \\ []), do: Keyword.get(options, :primary_key, Application.get_env(:ex_mtn_momo, :disbursement).primary_key)
  def extract_disbursement_user_id(options \\ []), do: Keyword.get(options, :user_id, Application.get_env(:ex_mtn_momo, :disbursement).user_id)
  def extract_disbursement_api_key(options \\ []), do: Keyword.get(options, :api_key, Application.get_env(:ex_mtn_momo, :disbursement).api_key)
  def extract_collection_secondary_key(options \\ []), do: Keyword.get(options, :secondary_key, Application.get_env(:ex_mtn_momo, :collection).secondary_key)
  def extract_collection_primary_key(options \\ []), do: Keyword.get(options, :primary_key, Application.get_env(:ex_mtn_momo, :collection).primary_key)
  def extract_collection_user_id(options \\ []), do: Keyword.get(options, :user_id, Application.get_env(:ex_mtn_momo, :collection).user_id)
  def extract_collection_api_key(options \\ []), do: Keyword.get(options, :api_key, Application.get_env(:ex_mtn_momo, :collection).api_key)
  def extract_x_target_environment(options \\ []), do: Keyword.get(options, :x_target_environment, Application.get_env(:ex_mtn_momo, :x_target_environment))

  def collection_auth(options \\ []), do: basic_auth(extract_disbursement_user_id(options), extract_disbursement_api_key(options))

  def disbursement_auth(options \\ []), do: basic_auth(extract_disbursement_user_id(options), extract_disbursement_api_key(options))

  def basic_auth(username, password), do: "Basic #{Base.encode64(username<>":"<>password)}"

  @doc false
  def send_get(url, attrs, header) do
    HttpRequest.get(url, attrs, header)
    |> HttpRequest.handle_response()
  end

  @doc false
  def send_post(url, attrs, headers) do
    HttpRequest.post(url, attrs, headers)
    |> HttpRequest.handle_response()
  end

  @doc false
  def send_put(url, attrs, encrypt_api_key) do
    HttpRequest.put(url, attrs, HttpRequest.header(encrypt_api_key))
    |> HttpRequest.handle_response()
  end
end
