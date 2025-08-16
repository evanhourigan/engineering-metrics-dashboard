# Engineering Metrics Dashboard Architecture

## System Overview

The Engineering Metrics Dashboard is a lightweight data platform that ingests GitHub and Jira activity, computes DORA + flow metrics, and uses an LLM to surface Sprint Health insights and bottlenecks.

## Architecture Diagram

```mermaid
flowchart LR
  subgraph Sources
    G[GitHub API] ---|
    J[Jira API]
  end

  subgraph Ingestion
    I1[Ingest: GitHub PRs/Commits]
    I2[Ingest: Jira Issues/Sprints]
    S1[Scheduler/Cron]
  end

  subgraph Warehouse
    DB[(Postgres/DuckDB)]
    MV1[(Views: DORA/Flow)]
  end

  subgraph Services
    API[FastAPI]
    LLM[Insight Service (LLM)]
    Slack[Slack Bot]
  end

  subgraph UI
    Web[React Dashboard]
  end

  S1 --> I1 --> DB
  S1 --> I2 --> DB
  DB --> MV1 --> API
  API --> Web
  MV1 --> LLM --> API
  API --> Slack
```

## Component Details

### Data Sources

- **GitHub API**: Pull requests, commits, reviews, merges
- **Jira API**: Issues, sprints, status transitions

### ETL Layer

- **Scheduler**: APScheduler with cron-like scheduling
- **GitHub Ingester**: Fetches PRs, commits, reviews with rate limiting
- **Jira Ingester**: Fetches issues, sprints with JQL queries
- **Incremental Updates**: Uses `updated_at` timestamps for efficiency

### Data Warehouse

- **PostgreSQL**: Primary database with materialized views
- **Materialized Views**: Pre-computed aggregations for performance
- **Indexes**: Optimized for common query patterns

### API Layer

- **FastAPI**: RESTful API with automatic documentation
- **Metrics Endpoints**: `/metrics/tiles`, `/metrics/series/*`
- **Insights Endpoints**: `/insights/sprint-health`
- **Slack Integration**: `/slack/summaries`

### AI/ML Layer

- **OpenAI Integration**: GPT-4 for sprint health insights
- **Prompt Engineering**: Structured prompts for consistent outputs
- **Fallback Mode**: Mock insights when LLM unavailable

### Frontend

- **React + TypeScript**: Modern, type-safe UI
- **Recharts**: Professional data visualization
- **Responsive Design**: Mobile-friendly interface
- **Real-time Updates**: Live data refresh

### DevOps

- **Docker Compose**: Local development environment
- **Health Checks**: Container health monitoring
- **Environment Variables**: Secure configuration management

## Data Flow

1. **Scheduled Ingestion**: ETL jobs run hourly (GitHub) and every 2 hours (Jira)
2. **Data Processing**: Raw data stored with upsert logic for idempotency
3. **Metrics Computation**: Daily aggregations computed and cached
4. **Materialized View Refresh**: Views refreshed daily at 2 AM
5. **API Serving**: FastAPI serves metrics and insights on demand
6. **Dashboard Updates**: React frontend fetches and displays data
7. **Slack Integration**: Sprint health summaries posted automatically

## Security & Privacy

- **Least Privilege**: Minimal API tokens for data sources
- **Environment Variables**: Secrets managed via environment
- **PII Minimization**: Aggregated data where possible
- **Rate Limiting**: Respects API limits with backoff

## Performance Considerations

- **Materialized Views**: Expensive aggregations pre-computed
- **Database Indexes**: Optimized for common query patterns
- **Caching**: Daily metrics cached to reduce computation
- **Async Processing**: Non-blocking API calls and ETL jobs

## Monitoring & Observability

- **Structured Logging**: JSON logs with correlation IDs
- **Health Checks**: Container and service health monitoring
- **Error Tracking**: Comprehensive error handling and logging
- **Performance Metrics**: Response times and throughput tracking
