defmodule ExMtnMomo.Disbursements do
  @moduledoc """
  Provides functions for working with the MTN Mobile Money Disbursements API.

  The Disbursements module allows developers to:

  * Create access tokens for authentication
  * Send money to users (deposits)
  * Process refunds
  * Transfer money between accounts
  * Retrieve account balances
  * Check the status of transactions

  This module is used for sending payments to customers through
  the MTN Mobile Money platform.

  ## Configuration Options

  The Disbursements module uses the following configuration options:

  ### Global Configuration

  * `:base_url` - The base URL for the MTN Mobile Money API
    * Default for sandbox: `"https://sandbox.momodeveloper.mtn.com"`
    * Production: URL provided by MTN for your specific region

  * `:x_target_environment` - The target environment for API requests
    * Options: `"sandbox"` for testing, or a specific production environment like `"mtnzambia"`
    * Default: `"sandbox"`

  ### Disbursement-Specific Configuration

  Disbursement credentials are configured as a map under the `:disbursement` key:

  * `:disbursement.secondary_key` - Subscription key for the Disbursements API
    * Used in the `Ocp-Apim-Subscription-Key` header
    * Required for all Disbursement API operations

  * `:disbursement.primary_key` - Alternative subscription key
    * Can be used as a backup if the secondary key fails

  * `:disbursement.user_id` - User ID for authentication
    * Required for creating access tokens
    * Used in the Basic Auth header

  * `:disbursement.api_key` - API key for authentication
    * Required for creating access tokens
    * Used in the Basic Auth header

  These options should be set in your `config.exs` file:

  ```elixir
  config :ex_mtn_momo,
    base_url: "https://sandbox.momodeveloper.mtn.com",
    x_target_environment: "sandbox",
    disbursement: %{
      secondary_key: "your_secondary_key",
      primary_key: "your_primary_key",
      user_id: "your_user_id",
      api_key: "your_api_key"
    }
  ```

  ## Runtime Options

  Most functions in this module accept an `options` parameter that can be used to override
  configuration values at runtime. The following options are supported:

  * `:base_url` - Override the base URL for the API request
  * `:secondary_key` - Override the secondary key to use for authentication
  * `:primary_key` - Override the primary key to use for authentication
  * `:user_id` - Override the user ID for authentication
  * `:api_key` - Override the API key for authentication
  * `:x_target_environment` - Override the target environment

  Example:

  ```elixir
  # Override the secondary key and target environment for a specific request
  options = [
    secondary_key: "alternative_secondary_key",
    x_target_environment: "production"
  ]

  {:ok, %{"access_token" => token}} = ExMtnMomo.Disbursements.create_access_token(options)
  ```

  ## Examples

  ```elixir
  # Get an access token for disbursements
  {:ok, %{"access_token" => token}} = ExMtnMomo.Disbursements.create_access_token()

  # Initiate a deposit
  deposit_details = %{
    "amount" => "1000",
    "currency" => "EUR",
    "externalId" => "123456789",
    "payee" => %{
      "partyIdType" => "MSISDN",
      "partyId" => "256771234567"
    },
    "payerMessage" => "Salary payment",
    "payeeNote" => "Salary received"
  }

  reference_id = UUID.uuid4()
  {:ok, _} = ExMtnMomo.Disbursements.deposit_v2(deposit_details, reference_id)

  # Check deposit status
  {:ok, status} = ExMtnMomo.Disbursements.get_deposit_status(reference_id, token)
  ```
  """

  alias ExMtnMomo.Util

  @doc """
  Authorizes a BC request.

  ## Parameters

  * `options` - Additional configuration options (optional)

  ## Options

  The `options` parameter can include the following keys:

  * `:base_url` - Override the base URL for the API request
  * `:secondary_key` - Override the secondary key to use for authentication
  * `:x_target_environment` - Override the target environment

  ## Returns

  * `{:ok, authorization_details}` on success
  * `{:error, reason}` on failure

  ## Examples

      iex> ExMtnMomo.Disbursements.bc_authorize()
      {:ok, %{...}}

  """
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

  @doc """
  Creates an access token for disbursement operations.

  ## Parameters

  * `options` - Additional configuration options (optional)

  ## Options

  The `options` parameter can include the following keys:

  * `:base_url` - Override the base URL for the API request
  * `:secondary_key` - Override the secondary key to use for authentication

  ## Returns

  * `{:ok, token_details}` on success, where `token_details` includes the access_token
  * `{:error, reason}` on failure

  ## Examples

      iex> ExMtnMomo.Disbursements.create_access_token()
      {:ok, %{"access_token" => "eyJ0eXAi...", "expires_in" => 3600, "token_type" => "Bearer"}}

  """
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

  @doc """
  Creates an OAuth 2.0 token for disbursement operations.

  ## Parameters

  * `options` - Additional configuration options (optional)

  ## Options

  The `options` parameter can include the following keys:

  * `:base_url` - Override the base URL for the API request
  * `:secondary_key` - Override the secondary key to use for authentication
  * `:x_target_environment` - Override the target environment

  ## Returns

  * `{:ok, token_details}` on success
  * `{:error, reason}` on failure

  ## Examples

      iex> ExMtnMomo.Disbursements.create_oauth_2_token()
      {:ok, %{"access_token" => "eyJ0eXAi...", "expires_in" => 3600, "token_type" => "Bearer"}}

  """
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

  @doc """
  Initiates a deposit using API version 1.0.

  ## Parameters

  * `attrs` - A map containing deposit details
  * `uuid4` - A UUID v4 string as the reference ID
  * `options` - Additional configuration options (optional)

  ## Deposit Details

  The `attrs` map should include the following keys:

  * `"amount"` - The deposit amount
  * `"currency"` - The currency code (e.g., "EUR", "USD")
  * `"externalId"` - Your system's transaction ID
  * `"payee"` - A map containing payee information:
    * `"partyIdType"` - The type of identifier (usually "MSISDN")
    * `"partyId"` - The mobile number of the payee
  * `"payerMessage"` - Message shown to the payer
  * `"payeeNote"` - Note for the payee's records

  ## Options

  The `options` parameter can include the following keys:

  * `:base_url` - Override the base URL for the API request
  * `:secondary_key` - Override the secondary key to use for authentication

  ## Returns

  * `{:ok, response}` on success
  * `{:error, reason}` on failure

  ## Examples

      iex> deposit_details = %{
      ...>   "amount" => "1000",
      ...>   "currency" => "EUR",
      ...>   "externalId" => "123456789",
      ...>   "payee" => %{
      ...>     "partyIdType" => "MSISDN",
      ...>     "partyId" => "256771234567"
      ...>   },
      ...>   "payerMessage" => "Salary payment",
      ...>   "payeeNote" => "Salary received"
      ...> }
      iex> reference_id = UUID.uuid4()
      iex> ExMtnMomo.Disbursements.deposit_v1(deposit_details, reference_id)
      {:ok, %{}}

  """
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

  @doc """
  Initiates a deposit using API version 2.0.

  ## Parameters

  * `attrs` - A map containing deposit details
  * `uuid4` - A UUID v4 string as the reference ID
  * `options` - Additional configuration options (optional)

  ## Deposit Details

  The `attrs` map should include the following keys:

  * `"amount"` - The deposit amount
  * `"currency"` - The currency code (e.g., "EUR", "USD")
  * `"externalId"` - Your system's transaction ID
  * `"payee"` - A map containing payee information:
    * `"partyIdType"` - The type of identifier (usually "MSISDN")
    * `"partyId"` - The mobile number of the payee
  * `"payerMessage"` - Message shown to the payer
  * `"payeeNote"` - Note for the payee's records

  ## Options

  The `options` parameter can include the following keys:

  * `:base_url` - Override the base URL for the API request
  * `:secondary_key` - Override the secondary key to use for authentication

  ## Returns

  * `{:ok, response}` on success
  * `{:error, reason}` on failure

  ## Examples

      iex> deposit_details = %{
      ...>   "amount" => "1000",
      ...>   "currency" => "EUR",
      ...>   "externalId" => "123456789",
      ...>   "payee" => %{
      ...>     "partyIdType" => "MSISDN",
      ...>     "partyId" => "256771234567"
      ...>   },
      ...>   "payerMessage" => "Salary payment",
      ...>   "payeeNote" => "Salary received"
      ...> }
      iex> reference_id = UUID.uuid4()
      iex> ExMtnMomo.Disbursements.deposit_v2(deposit_details, reference_id)
      {:ok, %{}}

  """
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

  @doc """
  Initiates a refund using API version 1.0.

  ## Parameters

  * `attrs` - A map containing refund details
  * `uuid4` - A UUID v4 string as the reference ID
  * `options` - Additional configuration options (optional)

  ## Options

  The `options` parameter can include the following keys:

  * `:base_url` - Override the base URL for the API request
  * `:secondary_key` - Override the secondary key to use for authentication

  ## Returns

  * `{:ok, response}` on success
  * `{:error, reason}` on failure

  ## Examples

      iex> refund_details = %{
      ...>   "amount" => "1000",
      ...>   "currency" => "EUR",
      ...>   "externalId" => "123456789",
      ...>   "payerMessage" => "Refund for order cancellation",
      ...>   "payeeNote" => "Refund processed"
      ...> }
      iex> reference_id = UUID.uuid4()
      iex> ExMtnMomo.Disbursements.refund_v1(refund_details, reference_id)
      {:ok, %{}}

  """
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

  @doc """
  Initiates a refund using API version 2.0.

  ## Parameters

  * `attrs` - A map containing refund details
  * `uuid4` - A UUID v4 string as the reference ID
  * `options` - Additional configuration options (optional)

  ## Options

  The `options` parameter can include the following keys:

  * `:base_url` - Override the base URL for the API request
  * `:secondary_key` - Override the secondary key to use for authentication

  ## Returns

  * `{:ok, response}` on success
  * `{:error, reason}` on failure

  ## Examples

      iex> refund_details = %{
      ...>   "amount" => "1000",
      ...>   "currency" => "EUR",
      ...>   "externalId" => "123456789",
      ...>   "payerMessage" => "Refund for order cancellation",
      ...>   "payeeNote" => "Refund processed"
      ...> }
      iex> reference_id = UUID.uuid4()
      iex> ExMtnMomo.Disbursements.refund_v2(refund_details, reference_id)
      {:ok, %{}}

  """
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

  @doc """
  Initiates a transfer.

  ## Parameters

  * `attrs` - A map containing transfer details
  * `uuid4` - A UUID v4 string as the reference ID
  * `options` - Additional configuration options (optional)

  ## Options

  The `options` parameter can include the following keys:

  * `:base_url` - Override the base URL for the API request
  * `:secondary_key` - Override the secondary key to use for authentication

  ## Returns

  * `{:ok, response}` on success
  * `{:error, reason}` on failure

  ## Examples

      iex> transfer_details = %{
      ...>   "amount" => "1000",
      ...>   "currency" => "EUR",
      ...>   "externalId" => "123456789",
      ...>   "payee" => %{
      ...>     "partyIdType" => "MSISDN",
      ...>     "partyId" => "256771234567"
      ...>   },
      ...>   "payerMessage" => "Transfer payment",
      ...>   "payeeNote" => "Transfer received"
      ...> }
      iex> reference_id = UUID.uuid4()
      iex> ExMtnMomo.Disbursements.transfer(transfer_details, reference_id)
      {:ok, %{}}

  """
  def transfer(attrs, uuid4, access_token, options \\ []) do
    headers = [
      {"Ocp-Apim-Subscription-Key", Util.extract_disbursement_secondary_key(options)},
      {"X-Reference-Id", uuid4},
      {"X-Target-Environment", Util.extract_x_target_environment(options)},
      {"Authorization", "Bearer #{access_token}"},
      {"Content-Type", "application/json"},
    ]

    "#{Util.extract_base_url(options)}/disbursement/v1_0/transfer"
    |> Util.send_post(attrs, headers)
    |> case do
      {:ok, body} -> {:ok, body}
      {:error, message} -> {:error, message}
    end
  end

  @doc """
  Retrieves the account balance for disbursements.

  ## Parameters

  * `access_token` - A valid access token
  * `options` - Additional configuration options (optional)

  ## Options

  The `options` parameter can include the following keys:

  * `:base_url` - Override the base URL for the API request
  * `:secondary_key` - Override the secondary key to use for authentication
  * `:x_target_environment` - Override the target environment

  ## Returns

  * `{:ok, balance_details}` on success
  * `{:error, reason}` on failure

  ## Examples

      iex> token = "eyJ0eXAi..."
      iex> ExMtnMomo.Disbursements.get_account_balance(token)
      {:ok, %{"availableBalance" => "15000", "currency" => "EUR"}}

  """
  def get_account_balance(access_token, options \\ []) do
    headers = [
      {"Ocp-Apim-Subscription-Key", Util.extract_disbursement_secondary_key(options)},
      {"X-Target-Environment", Util.extract_x_target_environment(options)},
      {"Authorization", "Bearer #{access_token}"}
    ]

    "#{Util.extract_base_url(options)}/disbursement/v1_0/account/balance"
    |> Util.send_get(%{}, headers)
    |> case do
      {:ok, body} -> {:ok, body}
      {:error, message} -> {:error, message}
    end
  end

  @doc """
  Retrieves the account balance for a specific currency for disbursements.

  ## Parameters

  * `currency` - Currency code (e.g., "EUR", "USD")
  * `access_token` - A valid access token
  * `options` - Additional configuration options (optional)

  ## Options

  The `options` parameter can include the following keys:

  * `:base_url` - Override the base URL for the API request
  * `:secondary_key` - Override the secondary key to use for authentication
  * `:x_target_environment` - Override the target environment

  ## Returns

  * `{:ok, balance_details}` on success
  * `{:error, reason}` on failure

  ## Examples

      iex> token = "eyJ0eXAi..."
      iex> ExMtnMomo.Disbursements.get_account_balance_in_specific_currency("EUR", token)
      {:ok, %{"availableBalance" => "15000", "currency" => "EUR"}}

  """
  def get_account_balance_in_specific_currency(currency, access_token, options \\ []) do
    headers = [
      {"Ocp-Apim-Subscription-Key", Util.extract_disbursement_secondary_key(options)},
      {"X-Target-Environment", Util.extract_x_target_environment(options)},
      {"Authorization", "Bearer #{access_token}"}
    ]

    "#{Util.extract_base_url(options)}/disbursement/v1_0/account/balance/#{currency}"
    |> Util.send_get(%{}, headers)
    |> case do
      {:ok, body} -> {:ok, body}
      {:error, message} -> {:error, message}
    end
  end

  @doc """
  Retrieves the status of a deposit.

  ## Parameters

  * `reference_id` - The reference ID of the deposit
  * `access_token` - A valid access token
  * `options` - Additional configuration options (optional)

  ## Options

  The `options` parameter can include the following keys:

  * `:base_url` - Override the base URL for the API request
  * `:secondary_key` - Override the secondary key to use for authentication
  * `:x_target_environment` - Override the target environment

  ## Returns

  * `{:ok, status_details}` on success
  * `{:error, reason}` on failure

  ## Examples

      iex> token = "eyJ0eXAi..."
      iex> reference_id = "f1bfc995-8dbe-4afb-aa82-a8c75a37edf6"
      iex> ExMtnMomo.Disbursements.get_deposit_status(reference_id, token)
      {:ok, %{"status" => "SUCCESSFUL", ...}}

  """
  def get_deposit_status(reference_id, access_token, options \\ []) do
    headers = [
      {"Ocp-Apim-Subscription-Key", Util.extract_disbursement_secondary_key(options)},
      {"X-Target-Environment", Util.extract_x_target_environment(options)},
      {"Authorization", "Bearer #{access_token}"}
    ]

    "#{Util.extract_base_url(options)}/disbursement/v1_0/deposit/#{reference_id}"
    |> Util.send_get(%{}, headers)
    |> case do
      {:ok, body} -> {:ok, body}
      {:error, message} -> {:error, message}
    end
  end

  @doc """
  Retrieves the status of a refund.

  ## Parameters

  * `reference_id` - The reference ID of the refund
  * `access_token` - A valid access token
  * `options` - Additional configuration options (optional)

  ## Options

  The `options` parameter can include the following keys:

  * `:base_url` - Override the base URL for the API request
  * `:secondary_key` - Override the secondary key to use for authentication
  * `:x_target_environment` - Override the target environment

  ## Returns

  * `{:ok, status_details}` on success
  * `{:error, reason}` on failure

  ## Examples

      iex> token = "eyJ0eXAi..."
      iex> reference_id = "f1bfc995-8dbe-4afb-aa82-a8c75a37edf6"
      iex> ExMtnMomo.Disbursements.get_refund_status(reference_id, token)
      {:ok, %{"status" => "SUCCESSFUL", ...}}

  """
  def get_refund_status(reference_id, access_token, options \\ []) do
    headers = [
      {"Ocp-Apim-Subscription-Key", Util.extract_disbursement_secondary_key(options)},
      {"X-Target-Environment", Util.extract_x_target_environment(options)},
      {"Authorization", "Bearer #{access_token}"}
    ]

    "#{Util.extract_base_url(options)}/disbursement/v1_0/refund/#{reference_id}"
    |> Util.send_get(%{}, headers)
    |> case do
      {:ok, body} -> {:ok, body}
      {:error, message} -> {:error, message}
    end
  end

  @doc """
  Retrieves the status of a transfer.

  ## Parameters

  * `reference_id` - The reference ID of the transfer
  * `access_token` - A valid access token
  * `options` - Additional configuration options (optional)

  ## Options

  The `options` parameter can include the following keys:

  * `:base_url` - Override the base URL for the API request
  * `:secondary_key` - Override the secondary key to use for authentication
  * `:x_target_environment` - Override the target environment

  ## Returns

  * `{:ok, status_details}` on success
  * `{:error, reason}` on failure

  ## Examples

      iex> token = "eyJ0eXAi..."
      iex> reference_id = "f1bfc995-8dbe-4afb-aa82-a8c75a37edf6"
      iex> ExMtnMomo.Disbursements.get_transfer_status(reference_id, token)
      {:ok, %{"status" => "SUCCESSFUL", ...}}

  """
  def get_transfer_status(reference_id, access_token, options \\ []) do
    headers = [
      {"Ocp-Apim-Subscription-Key", Util.extract_disbursement_secondary_key(options)},
      {"X-Target-Environment", Util.extract_x_target_environment(options)},
      {"Authorization", "Bearer #{access_token}"}
    ]

    "#{Util.extract_base_url(options)}/disbursement/v1_0/transfer/#{reference_id}"
    |> Util.send_get(%{}, headers)
    |> case do
      {:ok, body} -> {:ok, body}
      {:error, message} -> {:error, message}
    end
  end

  @doc """
  Retrieves user information with consent for disbursements.

  ## Parameters

  * `access_token` - A valid access token
  * `options` - Additional configuration options (optional)

  ## Options

  The `options` parameter can include the following keys:

  * `:base_url` - Override the base URL for the API request
  * `:secondary_key` - Override the secondary key to use for authentication
  * `:x_target_environment` - Override the target environment

  ## Returns

  * `{:ok, user_details}` on success
  * `{:error, reason}` on failure

  ## Examples

      iex> token = "eyJ0eXAi..."
      iex> ExMtnMomo.Disbursements.get_user_info_with_consent(token)
      {:ok, %{"name" => "John Doe", "email" => "john.doe@example.com", ...}}

  """
  def get_user_info_with_consent(access_token, options \\ []) do
    headers = [
      {"Ocp-Apim-Subscription-Key", Util.extract_disbursement_secondary_key(options)},
      {"X-Target-Environment", Util.extract_x_target_environment(options)},
      {"Authorization", "Bearer #{access_token}"}
    ]

    "#{Util.extract_base_url(options)}/disbursement/oauth2/v1_0/userinfo"
    |> Util.send_get(%{}, headers)
    |> case do
      {:ok, body} -> {:ok, body}
      {:error, message} -> {:error, message}
    end
  end
end
