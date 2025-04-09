defmodule ExMtnMomo.Disbursements do
  alias ExMtnMomo.Util

  def bc_authorize(options \\ []) do
    headers = [
      {"Content-Type", "application/json"},
      {"X-Target-Environment", Util.extract_x_target_environment(options)},
      {"Authorization", Util.disbursement_auth(options)},
      {"Ocp-Apim-Subscription-Key", Util.extract_disbursement_secondary_key(options)}
    ]

    "#{Util.extract_base_url(options)}/disbursement/v1_0/bc-authorize"
    |> Util.send_post(%{}, headers)
    |> case do
      {:ok, body} -> {:ok, body}
      {:error, message} -> {:error, message}
    end
  end

  def create_access_token(options \\ []) do
    headers = [
      {"Content-Type", "application/json"},
      {"Authorization", Util.disbursement_auth(options)},
      {"Ocp-Apim-Subscription-Key", Util.extract_disbursement_secondary_key(options)}
    ]

    "#{Util.extract_base_url(options)}/disbursement/token/"
    |> Util.send_post(%{}, headers)
    |> case do
      {:ok, body} -> {:ok, body}
      {:error, message} -> {:error, message}
    end
  end

  def create_oauth_2_token(options \\ []) do
    headers = [
      {"Content-Type", "application/x-www-form-urlencoded"},
      {"X-Target-Environment", Util.extract_x_target_environment(options)},
      {"Authorization", Util.disbursement_auth(options)},
      {"Ocp-Apim-Subscription-Key", Util.extract_disbursement_secondary_key(options)}
    ]

    "#{Util.extract_base_url(options)}/disbursement/oauth2/token/"
    |> Util.send_post(%{}, headers)
    |> case do
      {:ok, body} -> {:ok, body}
      {:error, message} -> {:error, message}
    end
  end

  def deposit_v1(attrs, uuid4, options \\ []) do
    headers = [
      {"Content-Type", "application/json"},
      {"X-Reference-Id", uuid4},
      {"Authorization", Util.disbursement_auth(options)},
      {"Ocp-Apim-Subscription-Key", Util.extract_disbursement_secondary_key(options)}
    ]

    "#{Util.extract_base_url(options)}/disbursement/v1_0/deposit"
    |> Util.send_post(attrs, headers)
    |> case do
      {:ok, body} -> {:ok, body}
      {:error, message} -> {:error, message}
    end
  end

  def deposit_v2(attrs, uuid4, options \\ []) do
    headers = [
      {"Content-Type", "application/json"},
      {"X-Reference-Id", uuid4},
      {"Authorization", Util.disbursement_auth(options)},
      {"Ocp-Apim-Subscription-Key", Util.extract_disbursement_secondary_key(options)}
    ]

    "#{Util.extract_base_url(options)}/disbursement/v2_0/deposit"
    |> Util.send_post(attrs, headers)
    |> case do
      {:ok, body} -> {:ok, body}
      {:error, message} -> {:error, message}
    end
  end

  def refund_v1(attrs, uuid4, options \\ []) do
    headers = [
      {"Content-Type", "application/json"},
      {"X-Reference-Id", uuid4},
      {"Authorization", Util.disbursement_auth(options)},
      {"Ocp-Apim-Subscription-Key", Util.extract_disbursement_secondary_key(options)}
    ]

    "#{Util.extract_base_url(options)}/disbursement/v1_0/refund"
    |> Util.send_post(attrs, headers)
    |> case do
      {:ok, body} -> {:ok, body}
      {:error, message} -> {:error, message}
    end
  end

  def refund_v2(attrs, uuid4, options \\ []) do
    headers = [
      {"Content-Type", "application/json"},
      {"X-Reference-Id", uuid4},
      {"Authorization", Util.disbursement_auth(options)},
      {"Ocp-Apim-Subscription-Key", Util.extract_disbursement_secondary_key(options)}
    ]

    "#{Util.extract_base_url(options)}/disbursement/v2_0/refund"
    |> Util.send_post(attrs, headers)
    |> case do
      {:ok, body} -> {:ok, body}
      {:error, message} -> {:error, message}
    end
  end

  def transfer(attrs, uuid4, options \\ []) do
    headers = [
      {"Content-Type", "application/json"},
      {"X-Reference-Id", uuid4},
      {"Authorization", Util.disbursement_auth(options)},
      {"Ocp-Apim-Subscription-Key", Util.extract_disbursement_secondary_key(options)}
    ]

    "#{Util.extract_base_url(options)}/disbursement/v1_0/transfer"
    |> Util.send_post(attrs, headers)
    |> case do
      {:ok, body} -> {:ok, body}
      {:error, message} -> {:error, message}
    end
  end

  def get_account_balance(access_token,  options \\ []) do
    headers = [
      {"Ocp-Apim-Subscription-Key", Util.extract_disbursement_secondary_key(options)},
      {"X-Target-Environment", Util.extract_x_target_environment(options)},
      {"Authorization", "Bearer #{access_token}"},
    ]

    "#{Util.extract_base_url(options)}/disbursement/v1_0/account/balance"
    |> Util.send_get(%{}, headers)
    |> case do
      {:ok, body} -> {:ok, body}
      {:error, message} -> {:error, message}
    end
  end

  def get_account_balance_in_specific_currency(currency, access_token,  options \\ []) do
    headers = [
      {"Ocp-Apim-Subscription-Key", Util.extract_disbursement_secondary_key(options)},
      {"X-Target-Environment", Util.extract_x_target_environment(options)},
      {"Authorization", "Bearer #{access_token}"},
    ]

    "#{Util.extract_base_url(options)}/disbursement/v1_0/account/balance/#{currency}"
    |> Util.send_get(%{}, headers)
    |> case do
      {:ok, body} -> {:ok, body}
      {:error, message} -> {:error, message}
    end
  end

  def get_deposit_status(reference_id, access_token,  options \\ []) do
    headers = [
      {"Ocp-Apim-Subscription-Key", Util.extract_disbursement_secondary_key(options)},
      {"X-Target-Environment", Util.extract_x_target_environment(options)},
      {"Authorization", "Bearer #{access_token}"},
    ]

    "#{Util.extract_base_url(options)}/disbursement/v1_0/deposit/#{reference_id}"
    |> Util.send_get(%{}, headers)
    |> case do
      {:ok, body} -> {:ok, body}
      {:error, message} -> {:error, message}
    end
  end

  def get_refund_status(reference_id, access_token,  options \\ []) do
    headers = [
      {"Ocp-Apim-Subscription-Key", Util.extract_disbursement_secondary_key(options)},
      {"X-Target-Environment", Util.extract_x_target_environment(options)},
      {"Authorization", "Bearer #{access_token}"},
    ]

    "#{Util.extract_base_url(options)}/disbursement/v1_0/refund/#{reference_id}"
    |> Util.send_get(%{}, headers)
    |> case do
      {:ok, body} -> {:ok, body}
      {:error, message} -> {:error, message}
    end
  end

  def get_transfer_status(reference_id, access_token,  options \\ []) do
    headers = [
      {"Ocp-Apim-Subscription-Key", Util.extract_disbursement_secondary_key(options)},
      {"X-Target-Environment", Util.extract_x_target_environment(options)},
      {"Authorization", "Bearer #{access_token}"},
    ]

    "#{Util.extract_base_url(options)}/disbursement/v1_0/transfer/#{reference_id}"
    |> Util.send_get(%{}, headers)
    |> case do
      {:ok, body} -> {:ok, body}
      {:error, message} -> {:error, message}
    end
  end

  def get_user_info_with_consent(access_token,  options \\ []) do
    headers = [
      {"Ocp-Apim-Subscription-Key", Util.extract_disbursement_secondary_key(options)},
      {"X-Target-Environment", Util.extract_x_target_environment(options)},
      {"Authorization", "Bearer #{access_token}"},
    ]

    "#{Util.extract_base_url(options)}/disbursement/oauth2/v1_0/userinfo"
    |> Util.send_get(%{}, headers)
    |> case do
      {:ok, body} -> {:ok, body}
      {:error, message} -> {:error, message}
    end
  end
end
