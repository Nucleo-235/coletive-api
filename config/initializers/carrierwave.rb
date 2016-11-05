CarrierWave.configure do |config|
  if Rails.env.production?
    config.storage = :aws
    config.aws_bucket =  "projetos.livres.live"
  elsif (Rails.env.development? && Rails.application.secrets.aws_access_key_id.present?)
    config.storage = :aws
    config.aws_bucket =  "projetos.livres.dev"
  else
    config.storage = :file
    config.aws_bucket =  "projetos.livres"
  end
  config.aws_acl    =  :public_read

  config.aws_credentials = {
    access_key_id:      Rails.application.secrets.aws_access_key_id,    # required
    secret_access_key:  Rails.application.secrets.aws_secret_access_key,    # required
    region: "sa-east-1"
  }
end
