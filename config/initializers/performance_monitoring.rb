# Performance Monitoring for Epic 4: Public Reading & Discovery
# NFR Requirement: Reading pages should load in under 2 seconds

# Configure slow query logging for production monitoring
if Rails.env.production?
  ActiveSupport::Notifications.subscribe("sql.active_record") do |name, start, finish, id, payload|
    duration = (finish - start) * 1000 # Convert to milliseconds

    # Log queries that take longer than 100ms
    if duration > 100
      Rails.logger.warn({
        message: "Slow Query Detected",
        duration_ms: duration.round(2),
        sql: payload[:sql],
        name: payload[:name],
        backtrace: caller.first(5)
      }.to_json)
    end
  end
end

# Log page load times
ActiveSupport::Notifications.subscribe("process_action.action_controller") do |name, start, finish, id, payload|
  duration = (finish - start) * 1000 # Convert to milliseconds

  # Log page loads that take longer than 2 seconds (Epic 4 NFR requirement)
  if duration > 2000
    Rails.logger.warn({
      message: "Slow Page Load - Epic 4 NFR Violation",
      duration_ms: duration.round(2),
      controller: payload[:controller],
      action: payload[:action],
      path: payload[:path],
      status: payload[:status],
      view_runtime: payload[:view_runtime],
      db_runtime: payload[:db_runtime]
    }.to_json)
  end
end

# Development mode: Enable query logging for N+1 detection
if Rails.env.development?
  # Uncomment to enable Bullet gem for N+1 query detection
  # Bullet.enable = true
  # Bullet.alert = true
  # Bullet.bullet_logger = true
  # Bullet.console = true
  # Bullet.rails_logger = true

  Rails.logger.info "Performance monitoring initialized for #{Rails.env}"
  Rails.logger.info "Epic 4 NFR: Pages should load in < 2 seconds"
  Rails.logger.info "Slow query threshold: 100ms"
end
