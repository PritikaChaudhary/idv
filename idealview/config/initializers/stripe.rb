Rails.configuration.stripe = {
  :publishable_key => ENV['pk_test_HMXVQvXP0VhCtre2zqVRWtvA'],
  :secret_key      => ENV['sk_test_rL51BkW2eNDeonJ6mn5LsW6q']
}

Stripe.api_key = Rails.configuration.stripe[:secret_key]