defmodule ExMtnMomo.Collection do
  @moduledoc """
  Provides functions for working with the MTN Mobile Money Collection API.

  The Collection module allows developers to:

  * Create access tokens for authentication
  * Request payments from customers
  * Check the status of payment requests
  * Retrieve account balances
  * Get user information

  This module is used for receiving payments from customers through
  the MTN Mobile Money platform.

  ## Configuration Options

  The Collection module uses the following configuration options:

  ### Global Configuration

  * `:base_url` - The base URL for the MTN Mobile Money API
    * Default for sandbox: `"https://sandbox.momodeveloper.mtn.com"`
    * Production: URL provided by MTN for your specific region

  * `:x_target_environment` - The target environment for API requests
    * Options: `"sandbox"` for testing, or a specific production environment like `"mtnzambia"`
    * Default: `"sandbox"`

  ### Collection-Specific Configuration

  Collection credentials are configured as a map under the `:collection` key:

  * `:collection.secondary_key` - Subscription key for the Collection API
    * Used in the `Ocp-Apim-Subscription-Key` header
    * Required for all Collection API operations

  * `:collection.primary_key` - Alternative subscription key
    * Can be used as a backup if the secondary key fails

  * `:collection.user_id` - User ID for authentication
    * Required for creating access tokens
    * Used in the Basic Auth header

  * `:collection.api_key` - API key for authentication
    * Required for creating access tokens
    * Used in the Basic Auth header

  These options should be set in your `config.exs` file:

  ```elixir
  config :ex_mtn_momo,
    base_url: "https://sandbox.momodeveloper.mtn.com",
    x_target_environment: "sandbox",
    collection: %{
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

  {:ok, %{"access_token" => token}} = ExMtnMomo.Collection.create_access_token(options)
  ```

  ## Examples

  ```elixir
  # Get an access token for collections
  {:ok, %{"access_token" => token}} = ExMtnMomo.Collection.create_access_token()

  # Initiate a payment request
  payment_details = %{
    "amount" => "1000",
    "currency" => "EUR",
    "externalId" => "123456789",
    "payer" => %{
      "partyIdType" => "MSISDN",
      "partyId" => "256771234567"
    },
    "payerMessage" => "Payment for products",
    "payeeNote" => "Payment received"
  }

  reference_id = UUID.uuid4()
  {:ok, _} = ExMtnMomo.Collection.request_to_pay(payment_details, token, reference_id)

  # Check payment status
  {:ok, status} = ExMtnMomo.Collection.request_to_pay_transaction_status(reference_id, token)
  ```
  """

  alias ExMtnMomo.Util

  @doc """
  Creates an access token for collection operations.

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

      iex> ExMtnMomo.Collection.create_access_token()
      {:ok, %{"access_token" => "eyJ0eXAi...", "expires_in" => 3600, "token_type" => "Bearer"}}

  """
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

  @doc """
  Creates an OAuth 2.0 token for collection operations.

  ## Parameters

  * `options` - Additional configuration options (optional)

  ## Options

  The `options` parameter can include the following keys:

  * `:base_url` - Override the base URL for the API request
  * `:secondary_key` - Override the secondary key to use for authentication

  ## Returns

  * `{:ok, token_details}` on success
  * `{:error, reason}` on failure

  ## Examples

      iex> ExMtnMomo.Collection.create_oauth_2_token()
      {:ok, %{"access_token" => "eyJ0eXAi...", "expires_in" => 3600, "token_type" => "Bearer"}}

  """
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

  @doc """
  Initiates a payment request to a customer.

  ## Parameters

  * `attrs` - A map containing payment details
  * `access_token` - A valid access token
  * `uuid4` - A UUID v4 string as the reference ID (optional)
  * `options` - Additional configuration options (optional)

  ## Payment Details

  The `attrs` map should include the following keys:

  * `"amount"` - The payment amount
  * `"currency"` - The currency code (e.g., "EUR", "USD")
  * `"externalId"` - Your system's transaction ID
  * `"payer"` - A map containing payer information:
    * `"partyIdType"` - The type of identifier (usually "MSISDN")
    * `"partyId"` - The mobile number of the payer
  * `"payerMessage"` - Message shown to the payer
  * `"payeeNote"` - Note for the payee's records

  ## Options

  The `options` parameter can include the following keys:

  * `:base_url` - Override the base URL for the API request
  * `:secondary_key` - Override the secondary key to use for authentication
  * `:x_target_environment` - Override the target environment

  ## Returns

  * `{:ok, response}` on success
  * `{:error, reason}` on failure

  ## Examples

      iex> token = "eyJ0eXAi..."
      iex> payment_details = %{
      ...>   "amount" => "1000",
      ...>   "currency" => "EUR",
      ...>   "externalId" => "123456789",
      ...>   "payer" => %{
      ...>     "partyIdType" => "MSISDN",
      ...>     "partyId" => "256771234567"
      ...>   },
      ...>   "payerMessage" => "Payment for products",
      ...>   "payeeNote" => "Payment received"
      ...> }
      iex> reference_id = UUID.uuid4()
      iex> ExMtnMomo.Collection.request_to_pay(payment_details, token, reference_id)
      {:ok, %{}}

  """
  def request_to_pay(attrs, access_token, uuid4 \\ UUID.uuid4(), options \\ []) do
    headers = [
      {"Ocp-Apim-Subscription-Key", Util.extract_collection_secondary_key(options)},
      {"X-Reference-Id", uuid4},
      {"X-Target-Environment", Util.extract_x_target_environment(options)},
      {"Authorization", "Bearer #{access_token}"},
      {"Content-Type", "application/json"}
    ]

    "#{Util.extract_base_url(options)}/collection/v1_0/requesttopay"
    |> Util.send_post(attrs, headers)
    |> case do
      {:ok, body} -> {:ok, body}
      {:error, message} -> {:error, message}
    end
  end

  @doc """
  Checks the status of a payment request.

  ## Parameters

  * `reference_id` - The reference ID of the payment request
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
      iex> ExMtnMomo.Collection.request_to_pay_transaction_status(reference_id, token)
      {:ok, %{
        "amount" => "1000",
        "currency" => "EUR",
        "financialTransactionId" => "23503452",
        "externalId" => "123456789",
        "payer" => %{
          "partyIdType" => "MSISDN",
          "partyId" => "256771234567"
        },
        "status" => "SUCCESSFUL"
      }}

  """

  @doc """
  Checks the status of a payment request.

  ## Parameters

  * `reference_id` - The reference ID of the payment request
  @spec get_account_balance_in_specific_currency(any(), any()) :: {:error, any()} | {:ok, any()}
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
      iex> ExMtnMomo.Disbursements.request_to_pay_transaction_status(reference_id, token)
      {:ok, %{"status" => "SUCCESSFUL", ...}}

  """

  def request_to_pay_transaction_status(reference_id, access_token, options \\ []) do
    headers = [
      {"Ocp-Apim-Subscription-Key", Util.extract_collection_secondary_key(options)},
      {"X-Target-Environment", Util.extract_x_target_environment(options)},
      {"Authorization", "Bearer #{access_token}"}
    ]

    "#{Util.extract_base_url(options)}/collection/v1_0/requesttopay/#{reference_id}"
    |> Util.send_get(%{}, headers)
    |> case do
      {:ok, body} -> {:ok, body}
      {:error, message} -> {:error, message}
    end
  end

  @doc """
  Retrieves the account balance for a specific currency.

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
      iex> ExMtnMomo.Collection.get_account_balance_in_specific_currency("EUR", token)
      {:ok, %{"availableBalance" => "15000", "currency" => "EUR"}}

  """
  def get_account_balance_in_specific_currency(currency, access_token, options \\ []) do
    headers = [
      {"Ocp-Apim-Subscription-Key", Util.extract_collection_secondary_key(options)},
      {"X-Target-Environment", Util.extract_x_target_environment(options)},
      {"Authorization", "Bearer #{access_token}"}
    ]

    "#{Util.extract_base_url(options)}/collection/v1_0/account/balance/#{currency}"
    |> Util.send_get(%{}, headers)
    |> case do
      {:ok, body} -> {:ok, body}
      {:error, message} -> {:error, message}
    end
  end

  @doc """
  Retrieves the account balance.

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
      iex> ExMtnMomo.Collection.get_account_balance(token)
      {:ok, %{"availableBalance" => "15000", "currency" => "EUR"}}

  """
  def get_account_balance(access_token, options \\ []) do
    headers = [
      {"Ocp-Apim-Subscription-Key", Util.extract_collection_secondary_key(options)},
      {"X-Target-Environment", Util.extract_x_target_environment(options)},
      {"Authorization", "Bearer #{access_token}"}
    ]

    "#{Util.extract_base_url(options)}/collection/v1_0/account/balance"
    |> Util.send_get(%{}, headers)
    |> case do
      {:ok, body} -> {:ok, body}
      {:error, message} -> {:error, message}
    end
  end

  @doc """
  Retrieves the status of an invoice.

  ## Parameters

  * `x_reference_id` - The reference ID of the invoice
  * `access_token` - A valid access token
  * `options` - Additional configuration options (optional)

  ## Options

  The `options` parameter can include the following keys:

  * `:base_url` - Override the base URL for the API request
  * `:secondary_key` - Override the secondary key to use for authentication
  * `:x_target_environment` - Override the target environment

  ## Returns

  * `{:ok, invoice_details}` on success
  * `{:error, reason}` on failure

  ## Examples

      iex> token = "eyJ0eXAi..."
      iex> reference_id = "f1bfc995-8dbe-4afb-aa82-a8c75a37edf6"
      iex> ExMtnMomo.Collection.get_invoice_status(reference_id, token)
      {:ok, %{"status" => "PAID", ...}}

  """
  def get_invoice_status(x_reference_id, access_token, options \\ []) do
    headers = [
      {"Ocp-Apim-Subscription-Key", Util.extract_collection_secondary_key(options)},
      {"X-Target-Environment", Util.extract_x_target_environment(options)},
      {"Authorization", "Bearer #{access_token}"}
    ]

    "#{Util.extract_base_url(options)}/collection/v2_0/invoice/#{x_reference_id}"
    |> Util.send_get(%{}, headers)
    |> case do
      {:ok, body} -> {:ok, body}
      {:error, message} -> {:error, message}
    end
  end

  @doc """
  Checks the status of a withdrawal request.

  ## Parameters

  * `reference_id` - The reference ID of the withdrawal request
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
      iex> ExMtnMomo.Collection.request_to_withdraw_transaction_status(reference_id, token)
      {:ok, %{"status" => "SUCCESSFUL", ...}}

  """
  def request_to_withdraw_transaction_status(reference_id, access_token, options \\ []) do
    headers = [
      {"Ocp-Apim-Subscription-Key", Util.extract_collection_secondary_key(options)},
      {"X-Target-Environment", Util.extract_x_target_environment(options)},
      {"Authorization", "Bearer #{access_token}"}
    ]

    "#{Util.extract_base_url(options)}/collection/v1_0/requesttowithdraw/#{reference_id}"
    |> Util.send_get(%{}, headers)
    |> case do
      {:ok, body} -> {:ok, body}
      {:error, message} -> {:error, message}
    end
  end

  @doc """
  Retrieves basic information about a user.

  ## Parameters

  * `msisdn` - The mobile number of the user
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
      iex> msisdn = "256771234567"
      iex> ExMtnMomo.Collection.basic_user_info(msisdn, token)
      {:ok, %{"name" => "John Doe", ...}}

  """
  def basic_user_info(msisdn, access_token, options \\ []) do
    headers = [
      {"Ocp-Apim-Subscription-Key", Util.extract_collection_secondary_key(options)},
      {"X-Target-Environment", Util.extract_x_target_environment(options)},
      {"Authorization", "Bearer #{access_token}"}
    ]

    "#{Util.extract_base_url(options)}/collection/v1_0/accountholder/msisdn/#{msisdn}/basicuserinfo"
    |> Util.send_get(%{}, headers)
    |> case do
      {:ok, body} -> {:ok, body}
      {:error, message} -> {:error, message}
    end
  end

  @doc """
  Retrieves the status of a payment.

  ## Parameters

  * `x_reference_id` - The reference ID of the payment
  * `access_token` - A valid access token
  * `options` - Additional configuration options (optional)

  ## Options

  The `options` parameter can include the following keys:

  * `:base_url` - Override the base URL for the API request
  * `:secondary_key` - Override the secondary key to use for authentication
  * `:x_target_environment` - Override the target environment

  ## Returns

  * `{:ok, payment_details}` on success
  * `{:error, reason}` on failure

  ## Examples

      iex> token = "eyJ0eXAi..."
      iex> reference_id = "f1bfc995-8dbe-4afb-aa82-a8c75a37edf6"
      iex> ExMtnMomo.Collection.get_payment_status(reference_id, token)
      {:ok, %{"status" => "SUCCESSFUL", ...}}

  """
  def get_payment_status(x_reference_id, access_token, options \\ []) do
    headers = [
      {"Ocp-Apim-Subscription-Key", Util.extract_collection_secondary_key(options)},
      {"X-Target-Environment", Util.extract_x_target_environment(options)},
      {"Authorization", "Bearer #{access_token}"}
    ]

    "#{Util.extract_base_url(options)}/collection/v2_0/payment/#{x_reference_id}"
    |> Util.send_get(%{}, headers)
    |> case do
      {:ok, body} -> {:ok, body}
      {:error, message} -> {:error, message}
    end
  end

  @doc """
  Retrieves the status of a pre-approval.

  ## Parameters

  * `reference_id` - The reference ID of the pre-approval
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
      iex> ExMtnMomo.Collection.get_pre_approval_status(reference_id, token)
      {:ok, %{"status" => "APPROVED", ...}}

  """
  def get_pre_approval_status(reference_id, access_token, options \\ []) do
    headers = [
      {"Ocp-Apim-Subscription-Key", Util.extract_collection_secondary_key(options)},
      {"X-Target-Environment", Util.extract_x_target_environment(options)},
      {"Authorization", "Bearer #{access_token}"}
    ]

    "#{Util.extract_base_url(options)}/collection/v2_0/preapproval/#{reference_id}"
    |> Util.send_get(%{}, headers)
    |> case do
      {:ok, body} -> {:ok, body}
      {:error, message} -> {:error, message}
    end
  end

  @doc """
  Retrieves user information with consent.

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
      iex> ExMtnMomo.Collection.get_user_info_with_consent(token)
      {:ok, %{"name" => "John Doe", "email" => "john.doe@example.com", ...}}

  """
  def get_user_info_with_consent(access_token, options \\ []) do
    headers = [
      {"Ocp-Apim-Subscription-Key", Util.extract_collection_secondary_key(options)},
      {"X-Target-Environment", Util.extract_x_target_environment(options)},
      {"Authorization", "Bearer #{access_token}"}
    ]

    "#{Util.extract_base_url(options)}/collection/oauth2/v1_0/userinfo"
    |> Util.send_get(%{}, headers)
    |> case do
      {:ok, body} -> {:ok, body}
      {:error, message} -> {:error, message}
    end
  end
end
