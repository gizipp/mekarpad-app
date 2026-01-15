module ApplicationHelper
  # SEO Helper Methods for Epic 5

  # Set page title with optional prefix
  def page_title(title = nil)
    base_title = t("app.title")
    title.present? ? "#{title} - #{base_title}" : base_title
  end

  # Generate meta description tag
  def meta_description(description)
    tag.meta(name: "description", content: truncate(strip_tags(description), length: 160))
  end

  # Generate Open Graph meta tags for social media sharing
  def og_meta_tags(title:, description:, image: nil, type: "website", url: nil)
    tags = []
    tags << tag.meta(property: "og:title", content: title)
    tags << tag.meta(property: "og:description", content: truncate(strip_tags(description), length: 200))
    tags << tag.meta(property: "og:type", content: type)
    tags << tag.meta(property: "og:url", content: url) if url.present?
    tags << tag.meta(property: "og:image", content: image) if image.present?
    safe_join(tags, "\n")
  end

  # Generate Twitter Card meta tags
  def twitter_card_tags(title:, description:, image: nil)
    tags = []
    tags << tag.meta(name: "twitter:card", content: image.present? ? "summary_large_image" : "summary")
    tags << tag.meta(name: "twitter:title", content: title)
    tags << tag.meta(name: "twitter:description", content: truncate(strip_tags(description), length: 200))
    tags << tag.meta(name: "twitter:image", content: image) if image.present?
    safe_join(tags, "\n")
  end

  # Complete SEO meta tags for a story/book
  def story_seo_tags(story)
    title = "#{story.title} by #{story.user.name}"
    description = story.description.presence || "Read #{story.title} on MekarPad"
    image_url = story.cover_image.attached? ? url_for(story.cover_image) : nil
    story_url = story_url(story)

    content_for :title, page_title(title)
    content_for :head do
      safe_join([
        meta_description(description),
        og_meta_tags(title: story.title, description: description, image: image_url, type: "book", url: story_url),
        twitter_card_tags(title: story.title, description: description, image: image_url)
      ], "\n")
    end
  end

  # Complete SEO meta tags for a chapter
  def chapter_seo_tags(chapter, story)
    title = "#{chapter.title} - #{story.title}"
    description = "Read chapter #{chapter.order}: #{chapter.title} from #{story.title} by #{story.user.name}"
    image_url = story.cover_image.attached? ? url_for(story.cover_image) : nil
    chapter_url = story_chapter_url(story, chapter)

    content_for :title, page_title(title)
    content_for :head do
      safe_join([
        meta_description(description),
        og_meta_tags(title: title, description: description, image: image_url, type: "article", url: chapter_url),
        twitter_card_tags(title: title, description: description, image: image_url)
      ], "\n")
    end
  end
end
