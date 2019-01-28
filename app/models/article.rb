class Article < ApplicationRecord
  belongs_to :user

  scope :for_category, -> (category) { where(:category=>category) }

  validates :title, :content, :category, :user, presence: true

  def self.article_categories
    distinct.pluck(:category)
  end
end
