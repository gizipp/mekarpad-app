class Story < ApplicationRecord
  belongs_to :user
  has_many :chapters, dependent: :destroy
  has_many :reading_lists, dependent: :destroy
  has_one_attached :cover_image

  LANGUAGES = {
    "en" => "English",
    "id" => "Bahasa Indonesia",
    "ms" => "Bahasa Melayu"
  }.freeze

  validates :title, presence: true, length: { minimum: 1, maximum: 200 }
  validates :status, inclusion: { in: %w[draft published] }
  validates :category, presence: true
  validates :language, presence: true, inclusion: { in: LANGUAGES.keys }

  scope :published, -> { where(status: "published") }
  scope :drafts, -> { where(status: "draft") }
  scope :by_category, ->(category) { where(category: category) }
  scope :by_language, ->(language) { where(language: language) }
  scope :recent, -> { order(created_at: :desc) }
  scope :popular, -> { order(view_count: :desc) }

  def increment_views!
    increment!(:view_count)
  end

  def language_name
    LANGUAGES[language] || language
  end

  # Placeholder methods for features not yet implemented (Epic 3)
  def votes_count
    0
  end

  def voted_by?(user)
    false
  end

  def in_reading_list_of?(user)
    false
  end
end
