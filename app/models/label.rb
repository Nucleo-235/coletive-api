# == Schema Information
#
# Table name: labels
#
#  id               :integer          not null, primary key
#  name             :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  color_rgb        :string
#  border_color_rgb :string
#

class Label < ActiveRecord::Base
end
