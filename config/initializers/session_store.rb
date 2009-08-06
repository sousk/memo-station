# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_memo-station_session',
  :secret      => '5fa04251fad9146ecb68f34adebe1c88f97b3816fe37f1e4076e061acffe3f8d367cf11ba274923c5f11817403c7c21858eaeaab9a333d6b1af5c9b5d3fd05cb'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
