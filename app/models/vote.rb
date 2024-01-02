class Vote < ApplicationRecord
  belongs_to :user

  validates :user_id, presence: true, uniqueness: { scope: :component_slug }
end
