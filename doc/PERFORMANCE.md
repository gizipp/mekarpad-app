# Performance Monitoring Guide

## Epic 4: Public Reading & Discovery - Performance Requirements

### Non-Functional Requirement (NFR)
**Requirement**: Reading pages must load in under 2 seconds

This document outlines the performance optimizations implemented and monitoring recommendations for production.

---

## Performance Optimizations Implemented

### 1. Database Indexes

All critical queries are optimized with proper indexes:

```ruby
# Stories table
add_index :stories, :status          # Fast published story lookup
add_index :stories, :category        # Category filtering
add_index :stories, :created_at      # Recent ordering
add_index :stories, :user_id         # Author lookup

# Chapters table
add_index :chapters, [:story_id, :order], unique: true  # Fast navigation
```

### 2. N+1 Query Prevention

All list views use eager loading to prevent N+1 queries:

```ruby
# Discover page (stories#index)
@stories = Story.published.recent.includes(:user).limit(20)

# Author dashboard
@stories = current_user.stories.includes(:chapters)

# Book page with comments
@comments = @story.comments.includes(:user).order(created_at: :desc)
```

### 3. Counter Caches

Reduce database queries for counts:

```ruby
# Story model
has_many :chapters, counter_cache: true  # chapters_count
# votes_count (for story likes)
```

### 4. Pagination

Limit results to prevent slow page loads:

```ruby
# Discover page: Maximum 20 stories per page
@stories = Story.published.recent.includes(:user).limit(20)
```

---

## Performance Testing

### Running Performance Tests

```bash
# Run all performance tests
bundle exec rspec spec/performance/

# Run specific test
bundle exec rspec spec/performance/reading_pages_spec.rb
```

### Performance Test Coverage

- ✅ Discover page load time (< 2s with 20 stories)
- ✅ Book public page load time (< 2s with 10 chapters)
- ✅ Chapter reading page load time (< 2s)
- ✅ N+1 query detection
- ✅ Index verification
- ✅ Counter cache verification
- ✅ Realistic load testing (30 stories, 150 chapters)

---

## Production Monitoring

### Automated Monitoring (config/initializers/performance_monitoring.rb)

The application automatically logs:

1. **Slow Queries** (> 100ms)
2. **Slow Page Loads** (> 2000ms - NFR violation)

### Recommended APM Tools

For production environments, integrate one of these Application Performance Monitoring tools:

1. **New Relic** - Full-featured APM with real-time monitoring
2. **Scout APM** - Rails-focused performance monitoring
3. **Skylight** - Simple, effective Rails profiling
4. **Datadog** - Comprehensive monitoring and logging

### Setup Example: New Relic

```ruby
# Gemfile
gem 'newrelic_rpm'

# config/newrelic.yml
production:
  monitor_mode: true
  app_name: MekarPad Production
  transaction_tracer:
    transaction_threshold: 2.0  # Alert on transactions > 2s (Epic 4 NFR)
  slow_sql:
    enabled: true
    record_sql: obfuscated
    explain_threshold: 0.1  # Log slow queries > 100ms
```

### Development Profiling

Use `rack-mini-profiler` for development:

```ruby
# Gemfile
group :development do
  gem 'rack-mini-profiler'
end
```

Visit any page with `?pp=help` to see profiling options.

### N+1 Query Detection

Use the `bullet` gem in development:

```ruby
# Gemfile
group :development do
  gem 'bullet'
end

# config/environments/development.rb
config.after_initialize do
  Bullet.enable = true
  Bullet.alert = true
  Bullet.bullet_logger = true
  Bullet.console = true
  Bullet.rails_logger = true
end
```

---

## Performance Metrics Dashboard

### Key Metrics to Monitor

| Metric | Target | Critical Threshold |
|--------|--------|-------------------|
| Discover Page Load Time | < 1s | < 2s (NFR) |
| Book Page Load Time | < 1s | < 2s (NFR) |
| Chapter Page Load Time | < 1s | < 2s (NFR) |
| Database Query Time | < 50ms | < 100ms |
| Average Session Duration | > 3 min | - (Epic 4 Success Metric) |

### Example Monitoring Queries

```sql
-- Find slow pages in the last hour
SELECT
  controller,
  action,
  AVG(duration_ms) as avg_duration,
  COUNT(*) as request_count
FROM page_loads
WHERE created_at > NOW() - INTERVAL '1 hour'
  AND duration_ms > 2000
GROUP BY controller, action
ORDER BY avg_duration DESC;

-- Find slow queries
SELECT
  sql,
  AVG(duration_ms) as avg_duration,
  COUNT(*) as execution_count
FROM query_logs
WHERE created_at > NOW() - INTERVAL '1 hour'
  AND duration_ms > 100
GROUP BY sql
ORDER BY avg_duration DESC;
```

---

## Performance Optimization Checklist

### Before Deploying to Production

- [ ] Run performance test suite: `bundle exec rspec spec/performance/`
- [ ] Verify all indexes exist: Check `db/schema.rb`
- [ ] Check for N+1 queries with Bullet gem
- [ ] Profile pages with rack-mini-profiler
- [ ] Set up APM tool (New Relic, Scout, etc.)
- [ ] Configure slow query logging
- [ ] Set up alerts for pages exceeding 2s load time
- [ ] Test with realistic data volume (100+ stories, 500+ chapters)

### Regular Maintenance

- **Weekly**: Review slow query logs
- **Weekly**: Check average page load times
- **Monthly**: Run full performance test suite
- **Quarterly**: Review and optimize database indexes
- **Quarterly**: Profile and optimize slow endpoints

---

## Troubleshooting Slow Pages

### If Discover Page is Slow

1. **Check Index Usage**:
   ```sql
   EXPLAIN ANALYZE
   SELECT * FROM stories
   WHERE status = 'published'
   ORDER BY created_at DESC
   LIMIT 20;
   ```
   Should use `index_stories_on_status` and `index_stories_on_created_at`

2. **Check N+1 Queries**: Should only have 2 queries (stories + users)

3. **Check Cover Image Processing**: Ensure variants are pre-processed

### If Book Page is Slow

1. **Check Counter Cache**: `chapters_count` should not trigger COUNT query

2. **Check Chapter Loading**: Chapters should load with single query

3. **Check Comments Loading**: Comments should use `.includes(:user)`

### If Chapter Page is Slow

1. **Check Navigation Queries**: `next_chapter` and `previous_chapter` should use composite index

2. **Check Content Size**: Very large chapters may need pagination

---

## Success Metrics (Epic 4)

### Reader Engagement
**Target**: ≥ 50% of sessions exceed 3 minutes of reading

**Monitoring**:
```ruby
# Track session duration with analytics
# Google Analytics: Average Session Duration
# Or custom tracking:
session_start = Time.current
# ... reader navigation ...
session_duration = Time.current - session_start
```

### Performance
**Target**: Reading pages load in under 2 seconds

**Monitoring**:
- Automated via `config/initializers/performance_monitoring.rb`
- APM tools: New Relic, Scout, Skylight
- Custom logging in production

---

## Contact

For performance issues or questions:
- Review logs: `log/production.log`
- Check APM dashboard
- Run performance tests: `bundle exec rspec spec/performance/`

Last Updated: 2025-11-12
