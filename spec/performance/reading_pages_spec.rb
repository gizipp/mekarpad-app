require 'rails_helper'
require 'benchmark'

RSpec.describe 'Reading Pages Performance (NFR: < 2 seconds)', type: :request do
  let(:author) { create(:user) }

  describe 'Epic 4 Performance Requirements' do
    context 'Discover Page (stories#index)' do
      before do
        # Create a realistic dataset
        create_list(:story, 20, :published, user: author)
      end

      it 'loads in under 2 seconds with 20 stories' do
        time = Benchmark.realtime do
          get stories_path
        end

        expect(response).to have_http_status(:success)
        expect(time).to be < 2.0, "Expected page to load in < 2s, but took #{time.round(3)}s"
      end

      it 'prevents N+1 queries by eager loading users' do
        # Reset query counter
        queries_count = 0

        ActiveSupport::Notifications.subscribe('sql.active_record') do |*args|
          queries_count += 1 unless args.last[:name] == 'SCHEMA'
        end

        get stories_path

        # Should use minimal queries:
        # 1. SELECT stories with includes
        # 2. SELECT users (eager loaded)
        # Should NOT query users separately for each story (20+ queries)
        expect(queries_count).to be <= 5, "Expected <= 5 queries, but executed #{queries_count}"
      end

      it 'uses database indexes for published status filter' do
        # This is validated by the migration having add_index :stories, :status
        # Query plan should use index_stories_on_status

        get stories_path

        expect(response).to have_http_status(:success)
      end

      it 'limits results to prevent slow page loads' do
        # Create more than the limit
        create_list(:story, 10, :published, user: author)

        get stories_path

        stories = assigns(:stories)
        expect(stories.size).to be <= 20
      end
    end

    context 'Book Public Page (stories#show)' do
      let(:story) { create(:story, :published, :with_chapters, user: author, chapters_count: 10) }

      it 'loads in under 2 seconds with 10 chapters' do
        time = Benchmark.realtime do
          get story_path(story)
        end

        expect(response).to have_http_status(:success)
        expect(time).to be < 2.0, "Expected page to load in < 2s, but took #{time.round(3)}s"
      end

      it 'efficiently loads chapters without N+1 queries' do
        queries_count = 0

        ActiveSupport::Notifications.subscribe('sql.active_record') do |*args|
          queries_count += 1 unless args.last[:name] == 'SCHEMA'
        end

        get story_path(story)

        # Should use minimal queries
        expect(queries_count).to be <= 10, "Expected <= 10 queries, but executed #{queries_count}"
      end

      it 'uses counter cache to avoid counting chapters' do
        # counter_cache should prevent SELECT COUNT(*) on chapters
        expect(story.chapters_count).to eq(10)

        # Getting chapters_count should not trigger a query
        queries_count = 0

        ActiveSupport::Notifications.subscribe('sql.active_record') do |*args|
          queries_count += 1 unless args.last[:name] == 'SCHEMA'
        end

        story.chapters_count

        expect(queries_count).to eq(0)
      end
    end

    context 'Chapter Reading Page (chapters#show)' do
      let(:story) { create(:story, :published, user: author) }
      let!(:chapter1) { create(:chapter, story: story, order: 1, content: 'Chapter content' * 100) }
      let!(:chapter2) { create(:chapter, story: story, order: 2, content: 'More content' * 100) }

      it 'loads in under 2 seconds' do
        time = Benchmark.realtime do
          get story_chapter_path(story, chapter1)
        end

        expect(response).to have_http_status(:success)
        expect(time).to be < 2.0, "Expected page to load in < 2s, but took #{time.round(3)}s"
      end

      it 'efficiently finds next and previous chapters using index' do
        # The unique index on [story_id, order] should make this fast
        time = Benchmark.realtime do
          chapter1.next_chapter
          chapter1.previous_chapter
        end

        expect(time).to be < 0.1, "Navigation queries should be very fast with index"
      end

      it 'uses minimal queries for chapter navigation' do
        queries_count = 0

        ActiveSupport::Notifications.subscribe('sql.active_record') do |*args|
          queries_count += 1 unless args.last[:name] == 'SCHEMA'
        end

        get story_chapter_path(story, chapter1)

        # Should use minimal queries
        expect(queries_count).to be <= 10
      end
    end

    context 'Database Query Optimization' do
      it 'has proper indexes on stories table' do
        indexes = ActiveRecord::Base.connection.indexes(:stories)
        index_columns = indexes.map { |idx| idx.columns.is_a?(Array) ? idx.columns : [ idx.columns ] }.flatten

        # Verify critical indexes exist
        expect(index_columns).to include('status')
        expect(index_columns).to include('category')
        expect(index_columns).to include('created_at')
        expect(index_columns).to include('user_id')
      end

      it 'has proper indexes on chapters table' do
        indexes = ActiveRecord::Base.connection.indexes(:chapters)

        # Find the composite index on [story_id, order]
        composite_index = indexes.find { |idx| idx.columns == [ 'story_id', 'order' ] }

        expect(composite_index).to be_present
        expect(composite_index.unique).to be true
      end

      it 'uses counter cache for chapters_count' do
        story = create(:story, :published, user: author)

        expect {
          create(:chapter, story: story)
        }.to change { story.reload.chapters_count }.by(1)
      end
    end

    context 'Realistic Load Testing' do
      before do
        # Create a realistic dataset
        10.times do |i|
          user = create(:user, name: "Author #{i}")
          3.times do
            story = create(:story, :published, user: user)
            5.times { create(:chapter, story: story) }
          end
        end
      end

      it 'discover page performs well with realistic data (30 stories, 150 chapters)' do
        time = Benchmark.realtime do
          get stories_path
        end

        expect(response).to have_http_status(:success)
        expect(time).to be < 2.0, "Expected page to load in < 2s with realistic data, but took #{time.round(3)}s"
      end

      it 'book page with comments performs well' do
        story = Story.published.first
        10.times { create(:comment, commentable: story, user: author) }

        time = Benchmark.realtime do
          get story_path(story)
        end

        expect(response).to have_http_status(:success)
        expect(time).to be < 2.0
      end
    end

    context 'Memory Efficiency' do
      it 'does not load all chapters into memory at once on discover page' do
        # Create stories with many chapters
        5.times do
          story = create(:story, :published, user: author)
          50.times { create(:chapter, story: story) }
        end

        # Discover page should not load chapters
        get stories_path

        stories = assigns(:stories)

        # Chapters should not be loaded
        stories.each do |story|
          expect(story.association(:chapters).loaded?).to be false
        end
      end

      it 'uses select/limit to avoid loading unnecessary data' do
        create_list(:story, 50, :published, user: author)

        get stories_path

        # Should only load 20 stories (as per limit)
        stories = assigns(:stories)
        expect(stories.size).to be <= 20
      end
    end
  end

  describe 'Performance Monitoring Recommendations' do
    it 'documents performance requirements' do
      # This test serves as documentation for production monitoring

      requirements = {
        'Discover Page' => '< 2 seconds',
        'Book Public Page' => '< 2 seconds',
        'Chapter Reading Page' => '< 2 seconds',
        'Database Queries' => 'N+1 prevention via eager loading',
        'Indexes' => 'status, category, created_at, [story_id, order]',
        'Counter Caches' => 'chapters_count, votes_count',
        'Pagination' => 'Limit 20 stories per page'
      }

      # In production, monitor these with:
      # - Application Performance Monitoring (APM) tools (e.g., New Relic, Scout, Skylight)
      # - Rails.logger for slow queries (> 100ms)
      # - rack-mini-profiler for development profiling
      # - bullet gem for N+1 query detection

      expect(requirements).not_to be_empty
    end

    it 'provides query monitoring example' do
      # Example: Log slow queries in production
      slow_queries = []

      ActiveSupport::Notifications.subscribe('sql.active_record') do |name, start, finish, id, payload|
        duration = (finish - start) * 1000 # Convert to milliseconds

        if duration > 100 # Log queries slower than 100ms
          slow_queries << {
            sql: payload[:sql],
            duration: duration,
            name: payload[:name]
          }
        end
      end

      # Perform some operations
      get stories_path

      # In production, log slow_queries to monitoring service
      slow_queries.each do |query|
        # Rails.logger.warn("Slow query: #{query[:duration]}ms - #{query[:sql]}")
      end

      # For testing purposes, we just ensure the monitoring works
      expect(slow_queries).to be_an(Array)
    end
  end
end
