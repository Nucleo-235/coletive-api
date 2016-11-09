# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  provider               :string           default("email"), not null
#  uid                    :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  reset_password_token   :string
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string
#  last_sign_in_ip        :string
#  confirmation_token     :string
#  confirmed_at           :datetime
#  confirmation_sent_at   :datetime
#  unconfirmed_email      :string
#  name                   :string
#  email                  :string
#  nickname               :string
#  social_image           :string
#  image                  :string
#  phone                  :string
#  type                   :string
#  tokens                 :json
#  created_at             :datetime
#  updated_at             :datetime
#

require 'file_size_validator'

class User < ActiveRecord::Base
  include DeviseTokenAuth::Concerns::User
  # Include default devise modules.
  devise :database_authenticatable, :registerable,
          :recoverable, :rememberable, :trackable,
          :confirmable, :omniauthable
  
  has_many :identities, dependent: :destroy

  def masked_email
    if email && email.length > 5
      email[0..4] + ("*" * (email.length - 5))
    else
      nil
    end
  end

  def first_name
    if name && name.length > 1 # pelo menos 2 letras
      names_separator_index = name.index(' ')
      if names_separator_index > -1
        if names_separator_index > 1 # pelo menos 2 letras
          name[0..(names_separator_index-1)]
        else
          nil
        end
      else
        name
      end
    else
      nil
    end
  end

  def public_name
    nickname || first_name || masked_email
  end
end
