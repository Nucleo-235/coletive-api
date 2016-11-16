class ProjectMemberSerializer < ActiveModel::Serializer
  attributes :id, :trello_member_id
  has_one :project
  has_one :user
end
