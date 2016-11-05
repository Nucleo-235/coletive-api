# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  reset_password_token   :string
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :inet
#  last_sign_in_ip        :inet
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  type                   :string
#

require 'file_size_validator'

class User < ActiveRecord::Base
  
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, 
         :omniauthable, omniauth_providers: [:facebook]

  def self.find_for_facebook_oauth(auth, signed_in_resource=nil)
    user = User.where(:provider => auth.provider, :uid => auth.uid).first
    # puts auth

    if user
      user.update(remote_image: auth.info.image)
      user.update(gender: auth.info.gender || auth.extra.raw_info.gender) unless user.gender
      return user
    else
      registered_user = User.where(:email => auth.info.email).first
      if registered_user
        registered_user.update( first_name:(auth.info.first_name || get_first_name(auth.info.name)),
                  last_name: (auth.info.last_name || get_last_name(auth.info.name)),
                  provider:auth.provider,
                  uid:auth.uid,
                  remote_image:auth.info.image,
                  gender:auth.info.gender || auth.extra.raw_info.gender
                )
        return registered_user
      else
        user = User.create( first_name:(auth.info.first_name || get_first_name(auth.info.name)),
                          last_name:(auth.info.last_name || get_last_name(auth.info.name)),
                          provider:auth.provider,
                          uid:auth.uid,
                          email:auth.info.email,
                          remote_image:auth.info.image,
                          gender:auth.info.gender || auth.extra.raw_info.gender,
                          password:Devise.friendly_token[0,20],
                          type: nil
                        )
      end
    end
    return user
  end
end
