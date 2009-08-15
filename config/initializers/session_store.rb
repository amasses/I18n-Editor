# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_I18nEditor_session',
  :secret      => '3beed3c6a12cd1e514b8ece02be71ff2f933a94f17a7e04c6d0bff475c1d4b1e2515184a902baf9b2f826feb19351b0c960dd89b44d39ce4ef69eff94a1f5285'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
