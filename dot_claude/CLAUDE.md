# User-Level CLAUDE.md

Global preferences and architectural standards for all projects.

## Technology Stack

### Backend (Go)
- **Language**: Go 1.22+
- **API Framework**: Protobuf + ConnectRPC (NOT REST/chi/echo)
  - Define all APIs as `.proto` service definitions
  - Use `buf` for code generation and linting
  - Generate Go server stubs via `buf.build/connectrpc/go`
  - Generate TypeScript clients via `buf.build/connectrpc/es`
  - Generate OpenAPI specs via `buf.build/grpc-ecosystem/openapiv2`
  - Use server-streaming RPCs for real-time features (chat, events)
  - Follow the pattern established in `heimdall` and `forseti` projects
- **Database**: PostgreSQL 16+ with pgx driver (raw queries, not ORM)
- **Cache/Sessions**: Redis 7+
- **Job Queue**: asynq (Redis-based) or NATS JetStream
- **Architecture**: Hexagonal / clean architecture
  - Domain layer has zero external dependencies
  - All providers behind interfaces
  - Dependency injection via constructors (no DI frameworks)
- **Migrations**: goose with sequential numbering
- **Testing**: testcontainers-go for integration tests, table-driven tests

### Frontend
- **Framework**: Next.js 14+ (App Router) with React 18+ and TypeScript
- **Styling**: Tailwind CSS with dark mode support
- **State**: TanStack Query v5 (server state), Zustand (client UI state)
- **Forms**: React Hook Form + Zod validation
- **API Client**: Auto-generated ConnectRPC ES client from proto definitions (NOT manual fetch wrappers)
- **Components**: Atomic design (atoms, molecules, organisms, templates)
- **Animation**: Framer Motion

### Infrastructure
- **Cloud**: AWS (preferred), GCP (secondary)
- **IaC**: Terraform
- **CI/CD**: GitHub Actions
- **Containers**: Docker, Kubernetes (ECS/EKS)
- **Monitoring**: Prometheus + Grafana, structured JSON logging (slog)

### Testing
- **Backend**: Go table-driven tests, testcontainers-go, 80%+ coverage
- **Frontend**: Jest + React Testing Library, Playwright for E2E
- **API**: Generated from proto definitions, no manual API test boilerplate
- **Performance**: k6 load testing

## Coding Standards

### Go
- **Style**: Follow `golangci-lint` with standard config
- **Naming**: PascalCase for exports, camelCase for unexported, snake_case for files
- **Errors**: Wrap with `fmt.Errorf("context: %w", err)`, define domain-specific error types
- **No global state**, no `init()` side effects
- **Context propagation**: pass `context.Context` as first parameter

### TypeScript/React
- **Components**: Functional components with hooks, PascalCase names
- **Files**: kebab-case
- **Constants**: UPPER_SNAKE_CASE
- **Git Commits**: Conventional Commits format

## API Design (Protobuf + ConnectRPC)

This is the standard API pattern for all projects:

### Directory Structure
```
api/proto/<project>/
  common/v1/common.proto     # Shared types (pagination, timestamps)
  <domain>/v1/<domain>.proto  # Service + messages per domain
```

### Buf Configuration
- `buf.yaml` — module config with DEFAULT lint and FILE breaking rules
- `buf.gen.yaml` — Go + TypeScript code generation
- `buf.gen.openapi.yaml` — OpenAPI v3 spec generation

### Key Principles
- One `.proto` file per domain/service
- Use `google.protobuf.Timestamp` for all time fields
- Use `google.protobuf.Struct` for flexible JSON-like data
- Server-streaming RPCs for real-time features (NOT custom WebSocket protocols)
- Versioned packages: `<project>.<domain>.v1`
- Generated code goes to `pkg/gen/` (Go) and `src/gen/` (TypeScript)

## Agent Preferences

### Software Architect Agent
- Use Protobuf + ConnectRPC for API design (not REST)
- Prefer hexagonal/clean architecture for Go backends
- Use event-driven architecture where appropriate
- Consider caching strategies early

### Backend Developer Agent
- APIs defined in proto files, NOT hand-written HTTP handlers
- Use ConnectRPC service interfaces for implementation
- Implement proper validation and error handling
- Follow 12-factor app principles

### Frontend Developer Agent
- Use auto-generated ConnectRPC ES clients for API calls
- React functional components with hooks
- Follow atomic design principles
- Use TanStack Query for server state management

### DevOps Engineer Agent
- Use Infrastructure as Code (Terraform)
- Implement blue-green deployments
- Set up comprehensive monitoring and alerting
- Container orchestration (Kubernetes)

## Workflow Preferences

### Feature Development
1. Define API contract in `.proto` files first
2. Generate code with `buf generate`
3. Implement service interface in Go
4. Frontend consumes generated TypeScript client
5. Tests at every layer

### Quality Standards
- No code without tests
- No features without documentation
- No deployment without monitoring
- No API changes without proto definition updates

## Notes for Claude

### Communication Style
- Be concise but thorough
- Explain complex decisions
- Suggest alternatives when appropriate
- Flag potential issues early

### When Uncertain
- Ask for clarification rather than assume
- Provide options with trade-offs
- Reference best practices and documentation
- Consider long-term maintainability
