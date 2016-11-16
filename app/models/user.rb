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

require 'trello'
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

  def trello_client
    if !defined? @trello_client
      @trello_identity = identities.where(provider: 'trello').first
      @trello_client = Trello::Client.new(
        :consumer_key => ENV['TRELLO_KEY'],
        :consumer_secret => ENV['TRELLO_SECRET'],
        :oauth_token => @trello_identity.accesstoken,
        :oauth_token_secret => @trello_identity.secret
      )
    end
    @trello_client
  end

  def trello_member
    if !defined? @trello_member
      @trello_member = trello_client.find(:member, :me)
    end
    @trello_member
  end

  def trello_boards(params = {})
    return Trello::Board.from_response trello_client.get("/members/#{trello_member.username}/boards", params)
  end

  def trello_open_boards
    if !defined? @trello_open_boards
      @trello_open_boards = trello_boards({ filter: 'public'}).select { |item| !item.closed }
    end
    @trello_open_boards
  end

  def trello_lists(board_id, params = {})
    return Trello::List.from_response trello_client.get("/boards/#{board_id}/lists", params)
  end

  def trello_open_lists(board_id)
    return trello_lists(board_id, {filter: 'open'})
  end
end
