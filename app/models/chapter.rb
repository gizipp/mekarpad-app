class Chapter < ApplicationRecord
  belongs_to :story, counter_cache: true
  has_rich_text :content

  validates :title, presence: true, length: { minimum: 1, maximum: 200 }
  validates :order, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :order, uniqueness: { scope: :story_id }
  validates :status, presence: true, inclusion: { in: %w[draft published], message: "%{value} is not a valid status" }

  default_scope { order(order: :asc) }

  scope :drafts, -> { where(status: "draft") }
  scope :published, -> { where(status: "published") }

  def draft?
    status == "draft"
  end

  def published?
    status == "published"
  end

  def publish!
    update!(status: "published")
  end

  def unpublish!
    update!(status: "draft")
  end

  def next_chapter
    story.chapters.where('"chapters"."order" > ?', order).first
  end

  def previous_chapter
    story.chapters.where('"chapters"."order" < ?', order).last
  end

  # Placeholder methods for features not yet implemented (Epic 3)
  def coin_cost
    0
  end
end
