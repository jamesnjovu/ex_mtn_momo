defmodule ExMtnMomo.Collection do
  alias ExMtnMomo.Util

  def create_access_token(options \\ []) do
    headers = [
      {"Content-Type", "application/json"},
      {"Authorization", Util.collection_auth(options)},
      {"Ocp-Apim-Subscription-Key", Util.extract_collection_secondary_key(options)}
    ]

    "#{Util.extract_base_url(options)}/collection/token/"
    |> Util.send_post(%{}, headers)
    |> case do
      {:ok, body} -> {:ok, body}
      {:error, message} -> {:error, message}
    end
  end

  def create_oauth_2_token(options \\ []) do
    headers = [
      {"Content-Type", "application/json"},
      {"Authorization", Util.collection_auth(options)},
      {"Ocp-Apim-Subscription-Key", Util.extract_collection_secondary_key(options)}
    ]

    "#{Util.extract_base_url(options)}/collection/oauth2/token/"
    |> Util.send_post(%{}, headers)
    |> case do
      {:ok, body} -> {:ok, body}
      {:error, message} -> {:error, message}
    end
  end

  def request_to_pay(attrs, access_token, uuid4 \\ UUID.uuid4(),  options \\ []) do
    headers = [
      {"Ocp-Apim-Subscription-Key", Util.extract_collection_secondary_key(options)},
      {"X-Reference-Id", uuid4},
      {"X-Target-Environment", Util.extract_x_target_environment(options)},
      {"Authorization", "Bearer #{access_token}"},
      {"Content-Type", "application/json"},
    ]

    "#{Util.extract_base_url(options)}/collection/v1_0/requesttopay"
    |> Util.send_post(attrs, headers)
    |> case do
      {:ok, body} -> {:ok, body}
      {:error, message} -> {:error, message}
    end
  end

  def request_to_pay_transaction_status(reference_id, access_token,  options \\ []) do
    headers = [
      {"Ocp-Apim-Subscription-Key", Util.extract_collection_secondary_key(options)},
      {"X-Target-Environment", Util.extract_x_target_environment(options)},
      {"Authorization", "Bearer #{access_token}"},
    ]

    "#{Util.extract_base_url(options)}/collection/v1_0/requesttopay/#{reference_id}"
    |> Util.send_get(%{}, headers)
    |> case do
      {:ok, body} -> {:ok, body}
      {:error, message} -> {:error, message}
    end
  end

  def get_account_balance_in_specific_currency(currency, access_token,  options \\ []) do
    headers = [
      {"Ocp-Apim-Subscription-Key", Util.extract_collection_secondary_key(options)},
      {"X-Target-Environment", Util.extract_x_target_environment(options)},
      {"Authorization", "Bearer #{access_token}"},
    ]

    "#{Util.extract_base_url(options)}/collection/v1_0/account/balance/#{currency}"
    |> Util.send_get(%{}, headers)
    |> case do
      {:ok, body} -> {:ok, body}
      {:error, message} -> {:error, message}
    end
  end

  def get_account_balance(access_token,  options \\ []) do
    headers = [
      {"Ocp-Apim-Subscription-Key", Util.extract_collection_secondary_key(options)},
      {"X-Target-Environment", Util.extract_x_target_environment(options)},
      {"Authorization", "Bearer #{access_token}"},
    ]

    "#{Util.extract_base_url(options)}/collection/v1_0/account/balance"
    |> Util.send_get(%{}, headers)
    |> case do
      {:ok, body} -> {:ok, body}
      {:error, message} -> {:error, message}
    end
  end

  def get_invoice_status(x_reference_id, access_token,  options \\ []) do
    headers = [
      {"Ocp-Apim-Subscription-Key", Util.extract_collection_secondary_key(options)},
      {"X-Target-Environment", Util.extract_x_target_environment(options)},
      {"Authorization", "Bearer #{access_token}"},
    ]

    "#{Util.extract_base_url(options)}/collection/v2_0/invoice/#{x_reference_id}"
    |> Util.send_get(%{}, headers)
    |> case do
      {:ok, body} -> {:ok, body}
      {:error, message} -> {:error, message}
    end
  end

  def request_to_withdraw_transaction_status(reference_id, access_token,  options \\ []) do
    headers = [
      {"Ocp-Apim-Subscription-Key", Util.extract_collection_secondary_key(options)},
      {"X-Target-Environment", Util.extract_x_target_environment(options)},
      {"Authorization", "Bearer #{access_token}"},
    ]

    "#{Util.extract_base_url(options)}/collection/v1_0/requesttowithdraw/#{reference_id}"
    |> Util.send_get(%{}, headers)
    |> case do
      {:ok, body} -> {:ok, body}
      {:error, message} -> {:error, message}
    end
  end

  def basic_user_info(msisdn, access_token,  options \\ []) do
    headers = [
      {"Ocp-Apim-Subscription-Key", Util.extract_collection_secondary_key(options)},
      {"X-Target-Environment", Util.extract_x_target_environment(options)},
      {"Authorization", "Bearer #{access_token}"},
    ]

    "#{Util.extract_base_url(options)}/collection/v1_0/accountholder/msisdn/#{msisdn}/basicuserinfo"
    |> Util.send_get(%{}, headers)
    |> case do
      {:ok, body} -> {:ok, body}
      {:error, message} -> {:error, message}
    end
  end

  def get_payment_status(x_reference_id, access_token,  options \\ []) do
    headers = [
      {"Ocp-Apim-Subscription-Key", Util.extract_collection_secondary_key(options)},
      {"X-Target-Environment", Util.extract_x_target_environment(options)},
      {"Authorization", "Bearer #{access_token}"},
    ]

    "#{Util.extract_base_url(options)}/collection/v2_0/payment/#{x_reference_id}"
    |> Util.send_get(%{}, headers)
    |> case do
      {:ok, body} -> {:ok, body}
      {:error, message} -> {:error, message}
    end
  end

  def get_pre_approval_status(reference_id, access_token,  options \\ []) do
    headers = [
      {"Ocp-Apim-Subscription-Key", Util.extract_collection_secondary_key(options)},
      {"X-Target-Environment", Util.extract_x_target_environment(options)},
      {"Authorization", "Bearer #{access_token}"},
    ]

    "#{Util.extract_base_url(options)}/collection/v2_0/preapproval/#{reference_id}"
    |> Util.send_get(%{}, headers)
    |> case do
      {:ok, body} -> {:ok, body}
      {:error, message} -> {:error, message}
    end
  end

  def get_user_info_with_consent(access_token,  options \\ []) do
    headers = [
      {"Ocp-Apim-Subscription-Key", Util.extract_collection_secondary_key(options)},
      {"X-Target-Environment", Util.extract_x_target_environment(options)},
      {"Authorization", "Bearer #{access_token}"},
    ]

    "#{Util.extract_base_url(options)}/collection/oauth2/v1_0/userinfo"
    |> Util.send_get(%{}, headers)
    |> case do
      {:ok, body} -> {:ok, body}
      {:error, message} -> {:error, message}
    end
  end

end
