defmodule ExMtnMomo do
  @moduledoc """
  ExMtnMomo is an Elixir library for interacting with the MTN Mobile Money API.

  This library provides a simple interface to MTN Mobile Money's Sandbox, Collection,
  and Disbursement APIs, making it easy to integrate MTN Mobile Money into your
  Elixir applications.

  ## Features

  * Sandbox API for testing and development
  * Collection API for receiving payments
  * Disbursement API for sending payments
  * Comprehensive error handling
  * Configurable environment settings

  ## Module Overview

  This library is organized into three main modules:

  * `ExMtnMomo.Sandbox` - Functions for setting up and testing in the sandbox environment
  * `ExMtnMomo.Collection` - Functions for receiving payments from customers
  * `ExMtnMomo.Disbursements` - Functions for sending payments to customers

  ## Configuration Options

  The following configuration options can be set in your `config.exs` file:

  ### Global Configuration Options

  * `:base_url` - The base URL for the MTN Mobile Money API
    * Default for sandbox: `"https://sandbox.momodeveloper.mtn.com"`
    * Production: URL provided by MTN for your specific region

  * `:x_target_environment` - The target environment for API requests
    * Options: `"sandbox"` for testing, or a specific production environment like `"mtnzambia"`
    * Default: `"sandbox"`

  * `:sandbox_key` - The API key for sandbox operations
    * This can be either your primary or secondary key provided by MTN
    * Used only for sandbox-specific operations

  ### Disbursement Configuration Options

  Disbursement credentials are configured as a map under the `:disbursement` key:

  ```elixir
  config :ex_mtn_momo,
    disbursement: %{
      secondary_key: "your_secondary_key",  # Subscription key for disbursement API
      primary_key: "your_primary_key",      # Alternative subscription key
      user_id: "your_user_id",              # User ID for authentication
      api_key: "your_api_key"               # API key for authentication
    }
  ```

  ### Collection Configuration Options

  Collection credentials are configured as a map under the `:collection` key:

  ```elixir
  config :ex_mtn_momo,
    collection: %{
      secondary_key: "your_secondary_key",  # Subscription key for collection API
      primary_key: "your_primary_key",      # Alternative subscription key
      user_id: "your_user_id",              # User ID for authentication
      api_key: "your_api_key"               # API key for authentication
    }
  ```

  ## Runtime Options

  Most functions in this library accept an `options` parameter that can be used to override
  configuration values at runtime. The following options are supported:

  * `:base_url` - Override the base URL for the API request
  * `:secondary_key` - Override the secondary key to use for authentication
  * `:primary_key` - Override the primary key to use for authentication
  * `:user_id` - Override the user ID for authentication
  * `:api_key` - Override the API key for authentication
  * `:x_target_environment` - Override the target environment
  * `:sandbox_key` - Override the sandbox key (for sandbox operations only)

  Example:

  ```elixir
  # Override the base URL and target environment for a specific request
  options = [
    base_url: "https://alternative-api.example.com",
    x_target_environment: "production"
  ]

  ExMtnMomo.collect_funds(payment_details, UUID.uuid4(), options)
  ```

  ## Getting Started

  First, configure your MTN MoMo API credentials in your `config.exs` file:

  ```elixir
  config :ex_mtn_momo,
    base_url: "https://sandbox.momodeveloper.mtn.com",
    x_target_environment: "sandbox", # mtnzambia | sandbox
    disbursement: %{
      secondary_key: "your_secondary_key",
      primary_key: "your_primary_key",
      user_id: "your_user_id",
      api_key: "your_api_key"
    },
    collection: %{
      secondary_key: "your_secondary_key",
      primary_key: "your_primary_key",
      user_id: "your_user_id",
      api_key: "your_api_key"
    }
  ```

  Then, you can start using the library in your application.

  See the documentation for `ExMtnMomo.Sandbox`, `ExMtnMomo.Collection`, and
  `ExMtnMomo.Disbursements` for specific usage examples.
  """

  alias ExMtnMomo.{
    Collection,
    Disbursements,
    Sandbox
  }

  @doc """
  Creates a sandbox user with all required credentials.

  This helper function simplifies the process of setting up a sandbox user by
  generating a UUID, creating the user, retrieving the API key, and getting the user details
  in a single function call.

  ## Parameters

  * `callback_url` - URL to receive API callbacks (defaults to "https://webhook.site")
  * `options` - Additional configuration options (optional)

  ## Options

  The `options` parameter can include the following keys:

  * `:base_url` - Override the base URL for the API request
  * `:secondary_key` - Override the secondary key to use for authentication
  * `:x_target_environment` - Override the target environment

  ## Returns

  * `{:ok, user_details}` on success, with user_details containing:
    * `"user_id"` - The UUID of the created user
    * `"api_key"` - The API key for the user
    * `"providerCallbackHost"` - The callback URL
    * `"targetEnvironment"` - The target environment
  * `{:error, reason}` on failure

  ## Examples

      iex> ExMtnMomo.create_sandbox_user()
      {:ok, %{
        "api_key" => "6418abf0507b4829a7ded11ca8f67cd7",
        "providerCallbackHost" => "https://webhook.site",
        "targetEnvironment" => "sandbox",
        "user_id" => "3d6df852-7be6-4870-be57-b784446a885c"
        }}

  """
  def create_sandbox_user(
        callback_url \\ "https://webhook.site",
        options \\ []
      ) do
    with uuid <- Sandbox.get_uuid4(),
         {:ok, _} <- Sandbox.create_api_user(uuid, callback_url, options),
         {:ok, %{"apiKey" => api_key}} <- Sandbox.get_api_key(uuid, options),
         {:ok, attrs} <- Sandbox.get_created_user(uuid, options) do
      {:ok, Map.merge(%{"user_id" => uuid, "api_key" => api_key}, attrs)}
    else
      error ->
        error
    end
  end

  @doc """
  Initiates a payment collection request.

  This function serves as a simplified wrapper around the Collection API, handling
  token creation and payment request in a single function call.

  ## Parameters

  * `attrs` - A map containing payment details
  * `x_reference_id` - A UUID v4 string as the reference ID (optional, generated automatically if not provided)
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

  * `{:ok, result}` on success, with result containing:
    * `"x_reference_id"` - The reference ID for the payment
    * `"status"` - The status of the payment request (initially "pending")
    * `"message"` - A status message
  * `{:error, reason}` on failure

  ## Examples
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
      iex> ExMtnMomo.collect_funds(payment_details)
      {:ok, %{
         "x_reference_id" => "f1bfc995-8dbe-4afb-aa82-a8c75a37edf6",
         "status" => "pending",
         "message" => "Request to pay has been sent"
        }}

  """
  def collect_funds(attrs, x_reference_id \\ UUID.uuid4(), options \\ []) do
    with {:ok, %{"access_token" => access_token}} <- Collection.create_access_token(options),
         {:ok, _} <- Collection.request_to_pay(attrs, access_token, x_reference_id, options) do
      {:ok,
       %{
         "x_reference_id" => x_reference_id,
         "status" => "pending",
         "message" => "Request to pay has been sent"
       }}
    else
      error ->
        error
    end
  end

  @doc """
  Checks the status of a payment collection request.

  This function serves as a simplified wrapper around the Collection API's transaction
  status endpoint, handling token creation and status check in a single function call.

  ## Parameters

  * `reference_id` - The reference ID of the payment request
  * `options` - Additional configuration options (optional)

  ## Options

  The `options` parameter can include the following keys:

  * `:base_url` - Override the base URL for the API request
  * `:secondary_key` - Override the secondary key to use for authentication
  * `:x_target_environment` - Override the target environment

  ## Returns

  * `{:ok, status_details}` on success, with status_details containing:
    * `"amount"` - The payment amount
    * `"currency"` - The currency code
    * `"externalId"` - Your system's transaction ID
    * `"financialTransactionId"` - The MTN transaction ID
    * `"payeeNote"` - Note for the payee's records
    * `"payer"` - Information about the payer
    * `"payerMessage"` - Message shown to the payer
    * `"status"` - The status of the payment (e.g., "SUCCESSFUL", "PENDING", "FAILED")
  * `{:error, reason}` on failure

  ## Examples

      iex> ExMtnMomo.collections_check_transaction_status("f1bfc995-8dbe-4afb-aa82-a8c75a37edf6")
      {:ok, %{
        "amount" => "1000",
        "currency" => "EUR",
        "externalId" => "123456789",
        "financialTransactionId" => "1308275464",
        "payeeNote" => "Payment received",
        "payer" => %{"partyId" => "256771234567", "partyIdType" => "MSISDN"},
        "payerMessage" => "Payment for products",
        "status" => "SUCCESSFUL"
        }}

  """
  def collections_check_transaction_status(reference_id, options \\ []) do
    with {:ok, %{"access_token" => access_token}} <- Collection.create_access_token(options),
         data <- Collection.request_to_pay_transaction_status(reference_id, access_token, options) do
      data
    else
      error ->
        error
    end
  end

  @doc """
  Initiates a funds disbursement (payment to a customer).

  This function serves as a simplified wrapper around the Disbursements API, handling
  token creation and funds transfer in a single function call.

  ## Parameters

  * `attrs` - A map containing disbursement details
  * `reference_id` - A UUID v4 string as the reference ID (optional, generated automatically if not provided)
  * `options` - Additional configuration options (optional)

  ## Disbursement Details

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

      iex> attrs = %{
      ...>   "amount" => "1000",
      ...>   "currency" => "EUR",
      ...>   "externalId" => "1234564789",
      ...>   "payer" => %{
      ...>     "partyIdType" => "MSISDN",
      ...>     "partyId" => "256771234567"
      ...>   },
      ...>   "payerMessage" => "Payment for products",
      ...>   "payeeNote" => "Payment received"
      ...> }
      iex> ExMtnMomo.disburse_funds(attrs)
      {:ok, %{}}

  """
  def disburse_funds(attrs, reference_id \\ UUID.uuid4(), options \\ []) do
    with {:ok, %{"access_token" => access_token}} <- Disbursements.create_access_token(options),
         data <- Disbursements.transfer(attrs, reference_id, access_token, options) do
      data
    else
      error ->
        error
    end
  end

  @doc """
  Checks the status of a disbursement transaction.

  This function serves as a simplified wrapper around the Disbursements API's transaction
  status endpoint, handling token creation and status check in a single function call.

  ## Parameters

  * `reference_id` - The reference ID of the disbursement request
  * `options` - Additional configuration options (optional)

  ## Options

  The `options` parameter can include the following keys:

  * `:base_url` - Override the base URL for the API request
  * `:secondary_key` - Override the secondary key to use for authentication
  * `:x_target_environment` - Override the target environment

  ## Returns

  * `{:ok, status_details}` on success, with status_details typically containing:
    * `"amount"` - The payment amount
    * `"currency"` - The currency code
    * `"externalId"` - Your system's transaction ID
    * `"financialTransactionId"` - The MTN transaction ID
    * `"payeeNote"` - Note for the payee's records
    * `"payee"` - Information about the payee
    * `"status"` - The status of the payment (e.g., "SUCCESSFUL", "PENDING", "FAILED")
  * `{:error, reason}` on failure

  ## Examples

      iex> ExMtnMomo.disbursements_check_transaction_status("f1bfc995-8dbe-4afb-aa82-a8c75a37edf6")
      {:ok, %{
        "amount" => "1000",
        "currency" => "EUR",
        "externalId" => "123456789",
        "financialTransactionId" => "1308275464",
        "payeeNote" => "Payment received",
        "payee" => %{"partyId" => "256771234567", "partyIdType" => "MSISDN"},
        "status" => "SUCCESSFUL"
        }}

  """
  def disbursements_check_transaction_status(reference_id, options \\ []) do
    with {:ok, %{"access_token" => access_token}} <- Disbursements.create_access_token(options),
         data <-
           Disbursements.request_to_pay_transaction_status(reference_id, access_token, options) do
      data
    else
      error ->
        error
    end
  end
end
