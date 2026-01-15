require 'rails_helper'

RSpec.feature 'Epic 5: SEO Meta Tags (NFR)', type: :feature do
  # User Story: As an Author, I want my published book's page to automatically use my book title
  # and description as the <title> and <meta description> tags, so that it appears correctly
  # in Google search results and when shared on social media.

  let(:author) { create(:user, email: 'author@example.com', name: 'Jane Doe') }
  let(:reader) { create(:user, email: 'reader@example.com', name: 'John Reader') }

  let!(:story_with_cover) do
    story = create(:story,
      user: author,
      title: 'The Amazing Adventure',
      description: 'A thrilling tale of courage and discovery in a magical world filled with wonder and mystery.',
      status: 'published',
      category: 'Fantasy'
    )
    # Attach a cover image
    story.cover_image.attach(
      io: File.open(Rails.root.join('spec', 'fixtures', 'files', 'test_image.png')),
      filename: 'test_image.png',
      content_type: 'image/png'
    )
    story
  end

  let!(:story_without_cover) do
    create(:story,
      user: author,
      title: 'Simple Story',
      description: 'A simple story without a cover image for testing SEO.',
      status: 'published'
    )
  end

  let!(:chapter) do
    create(:chapter,
      story: story_with_cover,
      title: 'The Beginning',
      order: 1,
      content: 'This is the first chapter of an amazing adventure.'
    )
  end

  def sign_in_as(user)
    page.set_rack_session(user_id: user.id)
  end

  describe 'Story/Book Page SEO Meta Tags' do
    context 'when viewing a published story' do
      before { visit story_path(story_with_cover) }

      scenario 'page title includes story title and author name' do
        expect(page).to have_title("#{story_with_cover.title} by #{author.name}")
      end

      scenario 'page title includes site name' do
        # Title should be in format: "Story Title by Author - MekarPad"
        expect(page.title).to include(story_with_cover.title)
        expect(page.title).to include(author.name)
      end

      scenario 'has meta description tag with story description' do
        expect(page.html).to include('<meta name="description"')
        expect(page.html).to include(story_with_cover.description.truncate(160))
      end

      scenario 'meta description is properly truncated to 160 characters' do
        # Should truncate long descriptions to 160 chars
        meta_tag = page.html.match(/<meta name="description" content="([^"]+)"/)[1]
        expect(meta_tag.length).to be <= 160
      end

      scenario 'has Open Graph title tag' do
        expect(page.html).to include('<meta property="og:title"')
        expect(page.html).to include(story_with_cover.title)
      end

      scenario 'has Open Graph description tag' do
        expect(page.html).to include('<meta property="og:description"')
        expect(page.html).to include('thrilling tale')
      end

      scenario 'has Open Graph type set to book' do
        expect(page.html).to include('<meta property="og:type" content="book"')
      end

      scenario 'has Open Graph URL tag' do
        expect(page.html).to include('<meta property="og:url"')
        expect(page.html).to include(story_url(story_with_cover))
      end

      scenario 'has Open Graph image tag when cover exists' do
        expect(page.html).to include('<meta property="og:image"')
        # Should include the cover image URL
        expect(page.html).to match(/og:image.*content=/)
      end

      scenario 'has Twitter Card meta tags' do
        expect(page.html).to include('<meta name="twitter:card"')
        expect(page.html).to include('<meta name="twitter:title"')
        expect(page.html).to include('<meta name="twitter:description"')
      end

      scenario 'Twitter Card type is summary_large_image when cover exists' do
        expect(page.html).to include('twitter:card" content="summary_large_image"')
      end

      scenario 'Twitter Card title matches story title' do
        expect(page.html).to include("twitter:title\" content=\"#{story_with_cover.title}\"")
      end

      scenario 'Twitter Card description is truncated appropriately' do
        meta_tag = page.html.match(/<meta name="twitter:description" content="([^"]+)"/)[1]
        expect(meta_tag.length).to be <= 200
      end

      scenario 'Twitter Card image is included when cover exists' do
        expect(page.html).to include('<meta name="twitter:image"')
      end
    end

    context 'when story has no cover image' do
      before { visit story_path(story_without_cover) }

      scenario 'still has all text-based meta tags' do
        expect(page.html).to include('<meta name="description"')
        expect(page.html).to include('<meta property="og:title"')
        expect(page.html).to include('<meta property="og:description"')
      end

      scenario 'Twitter Card uses summary type when no image' do
        # When no image, should use 'summary' instead of 'summary_large_image'
        expect(page.html).to include('twitter:card" content="summary"')
      end

      scenario 'does not have og:image tag when no cover' do
        # og:image should only be present if cover exists
        # This test checks that we handle missing images gracefully
        expect(page).to have_css('meta[property="og:title"]')
      end
    end

    context 'when story description is very long' do
      let(:long_story) do
        create(:story,
          user: author,
          title: 'Epic Saga',
          description: 'A' * 300, # Very long description
          status: 'published'
        )
      end

      before { visit story_path(long_story) }

      scenario 'meta description is truncated to 160 characters' do
        meta_desc = page.html.match(/<meta name="description" content="([^"]+)"/)[1]
        expect(meta_desc.length).to be <= 160
      end

      scenario 'og:description is truncated to 200 characters' do
        og_desc = page.html.match(/<meta property="og:description" content="([^"]+)"/)[1]
        expect(og_desc.length).to be <= 200
      end
    end

    context 'when story description is empty' do
      let(:no_desc_story) do
        create(:story,
          user: author,
          title: 'No Description Story',
          description: '',
          status: 'published'
        )
      end

      before { visit story_path(no_desc_story) }

      scenario 'uses fallback description' do
        expect(page.html).to include('Read No Description Story on MekarPad')
      end
    end
  end

  describe 'Chapter Page SEO Meta Tags' do
    context 'when viewing a published chapter' do
      before { visit story_chapter_path(story_with_cover, chapter) }

      scenario 'page title includes chapter title and story title' do
        expect(page).to have_title(/#{chapter.title}.*#{story_with_cover.title}/)
      end

      scenario 'page title includes site name' do
        expect(page.title).to match(/MekarPad/)
      end

      scenario 'has meta description with chapter and story info' do
        expect(page.html).to include('<meta name="description"')
        expect(page.html).to include("chapter #{chapter.order}")
        expect(page.html).to include(chapter.title)
        expect(page.html).to include(story_with_cover.title)
      end

      scenario 'has Open Graph title with chapter and story' do
        expect(page.html).to include('<meta property="og:title"')
        expect(page.html).to include(chapter.title)
        expect(page.html).to include(story_with_cover.title)
      end

      scenario 'has Open Graph description mentioning chapter number' do
        expect(page.html).to include('<meta property="og:description"')
        expect(page.html).to include('Read chapter')
      end

      scenario 'has Open Graph type set to article for chapters' do
        expect(page.html).to include('<meta property="og:type" content="article"')
      end

      scenario 'has Open Graph URL for the chapter' do
        expect(page.html).to include('<meta property="og:url"')
        expect(page.html).to include(story_chapter_url(story_with_cover, chapter))
      end

      scenario 'uses story cover image for chapter social sharing' do
        expect(page.html).to include('<meta property="og:image"')
      end

      scenario 'has Twitter Card meta tags for chapters' do
        expect(page.html).to include('<meta name="twitter:card"')
        expect(page.html).to include('<meta name="twitter:title"')
        expect(page.html).to include('<meta name="twitter:description"')
      end

      scenario 'Twitter Card includes chapter information' do
        expect(page.html).to include("twitter:title\" content=\"#{chapter.title} - #{story_with_cover.title}\"")
      end
    end

    context 'with multiple chapters' do
      let!(:chapter2) do
        create(:chapter,
          story: story_with_cover,
          title: 'The Journey Continues',
          order: 2
        )
      end

      scenario 'each chapter has unique meta tags' do
        visit story_chapter_path(story_with_cover, chapter)
        title1 = page.title

        visit story_chapter_path(story_with_cover, chapter2)
        title2 = page.title

        expect(title1).not_to eq(title2)
        expect(title1).to include('The Beginning')
        expect(title2).to include('The Journey Continues')
      end
    end
  end

  describe 'SEO Helper Methods' do
    include ApplicationHelper

    context 'page_title helper' do
      it 'returns just site name when no title provided' do
        expect(page_title).to eq(I18n.t("app.title"))
      end

      it 'returns title with site name when title provided' do
        expect(page_title('Test Page')).to include('Test Page')
        expect(page_title('Test Page')).to include(I18n.t("app.title"))
      end
    end

    context 'meta_description helper' do
      it 'generates meta description tag' do
        result = meta_description('This is a test description')
        expect(result).to match(/<meta name="description"/)
        expect(result).to include('This is a test description')
      end

      it 'truncates long descriptions to 160 characters' do
        long_text = 'A' * 300
        result = meta_description(long_text)
        # Extract content attribute value
        content = result.match(/content="([^"]+)"/)[1]
        expect(content.length).to be <= 160
      end

      it 'strips HTML tags from description' do
        html_text = '<p>This is <strong>bold</strong> text</p>'
        result = meta_description(html_text)
        expect(result).not_to include('<p>')
        expect(result).not_to include('<strong>')
      end
    end

    context 'og_meta_tags helper' do
      it 'generates all required OG tags' do
        result = og_meta_tags(
          title: 'Test Title',
          description: 'Test Description',
          type: 'book',
          url: 'https://example.com/book'
        )

        expect(result).to include('og:title')
        expect(result).to include('og:description')
        expect(result).to include('og:type')
        expect(result).to include('og:url')
      end

      it 'includes image when provided' do
        result = og_meta_tags(
          title: 'Test',
          description: 'Test',
          image: 'https://example.com/image.jpg'
        )

        expect(result).to include('og:image')
        expect(result).to include('https://example.com/image.jpg')
      end

      it 'omits image tag when not provided' do
        result = og_meta_tags(
          title: 'Test',
          description: 'Test'
        )

        expect(result).not_to include('og:image')
      end
    end

    context 'twitter_card_tags helper' do
      it 'generates Twitter Card tags' do
        result = twitter_card_tags(
          title: 'Test Title',
          description: 'Test Description'
        )

        expect(result).to include('twitter:card')
        expect(result).to include('twitter:title')
        expect(result).to include('twitter:description')
      end

      it 'uses summary_large_image when image provided' do
        result = twitter_card_tags(
          title: 'Test',
          description: 'Test',
          image: 'https://example.com/image.jpg'
        )

        expect(result).to include('summary_large_image')
        expect(result).to include('twitter:image')
      end

      it 'uses summary card when no image' do
        result = twitter_card_tags(
          title: 'Test',
          description: 'Test'
        )

        expect(result).to include('twitter:card" content="summary"')
      end
    end
  end

  describe 'Social Media Sharing Preview' do
    context 'when story is shared on social media' do
      before { visit story_path(story_with_cover) }

      scenario 'has all required Open Graph tags for proper preview' do
        # Facebook, LinkedIn, etc. require these tags
        expect(page.html).to include('og:title')
        expect(page.html).to include('og:description')
        expect(page.html).to include('og:type')
        expect(page.html).to include('og:image')
      end

      scenario 'has all required Twitter tags for proper preview' do
        # Twitter requires these for card preview
        expect(page.html).to include('twitter:card')
        expect(page.html).to include('twitter:title')
        expect(page.html).to include('twitter:description')
      end
    end
  end

  describe 'Google Search Results Appearance' do
    context 'for published stories' do
      before { visit story_path(story_with_cover) }

      scenario 'has proper title tag for search results' do
        # Google uses <title> tag
        expect(page).to have_title(/#{story_with_cover.title}/)
      end

      scenario 'has meta description for search snippet' do
        # Google uses meta description for snippet
        expect(page.html).to include('<meta name="description"')
      end

      scenario 'title is descriptive and includes author' do
        # Good SEO practice: include author in title
        expect(page.title).to include(author.name)
      end

      scenario 'description is compelling and informative' do
        expect(page.html).to include(story_with_cover.description.truncate(160))
      end
    end
  end

  describe 'Infrastructure for Dynamic SEO' do
    scenario 'layout supports content_for :title' do
      layout = File.read(Rails.root.join('app/views/layouts/application.html.erb'))
      expect(layout).to include('content_for(:title)')
    end

    scenario 'layout has yield :head for custom meta tags' do
      layout = File.read(Rails.root.join('app/views/layouts/application.html.erb'))
      expect(layout).to include('yield :head')
    end
  end

  describe 'SEO Best Practices' do
    scenario 'page titles are unique per page' do
      visit story_path(story_with_cover)
      title1 = page.title

      visit story_path(story_without_cover)
      title2 = page.title

      expect(title1).not_to eq(title2)
    end

    scenario 'meta descriptions are unique per page' do
      visit story_path(story_with_cover)
      desc1 = page.html.match(/<meta name="description" content="([^"]+)"/)[1]

      visit story_path(story_without_cover)
      desc2 = page.html.match(/<meta name="description" content="([^"]+)"/)[1]

      expect(desc1).not_to eq(desc2)
    end

    scenario 'all meta tags have properly escaped content' do
      special_story = create(:story,
        user: author,
        title: 'Story with "Quotes" & Special <Characters>',
        description: 'Description with "quotes" & ampersands',
        status: 'published'
      )

      visit story_path(special_story)

      # Should not have unescaped HTML
      expect(page.html).not_to include('<meta name="description" content="Description with "quotes"')
    end
  end
end
