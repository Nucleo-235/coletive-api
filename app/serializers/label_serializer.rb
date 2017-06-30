class LabelSerializer < ActiveModel::Serializer
  attributes :id, :name, :color_rgb, :font_color_rgb, :border_color_rgb
end
