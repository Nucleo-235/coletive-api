Rails.application.config.middleware.use OmniAuth::Builder do
  # provider :facebook,      Rails.application.secrets.facebook_key, Rails.application.secrets.facebook_secret
  provider :trello,   ENV['TRELLO_KEY'], ENV['TRELLO_SECRET'], app_name: "Coletive", scope: 'read,write,account', expiration: 'never'
end