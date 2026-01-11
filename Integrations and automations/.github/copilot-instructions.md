# Copilot Instructions for Integrations and Automations

## Project Overview
This is a Swift Package Manager (SPM) project that serves as **Phase 1 of AutoGPT** - a library providing integrations and automation workflow capabilities for autonomous agents. This package enables agents to connect with external services, orchestrate multi-step workflows, and execute automated tasks across various platforms and APIs.

This is a **foundational integration layer** for the AutoGPT ecosystem, designed to be consumed by agent implementations to handle service communication, workflow orchestration, and task automation.

**Key Files:**
- [Package.swift](../Package.swift) - Package manifest defining the library target and test suite
- [Sources/Integrations and automations/Integrations_and_automations.swift](../Sources/Integrations%20and%20automations/Integrations_and_automations.swift) - Main module implementation
- [Tests/Integrations and automationsTests/Integrations_and_automationsTests.swift](../Tests/Integrations%20and%20automationsTests/Integrations_and_automationsTests.swift) - Test suite using Swift Testing framework

## Build and Test Workflows

### Building the Package
```bash
# Build the library
swift build

# Build in release mode
swift build -c release

# Build and show build log
swift build -v
```

### Running Tests
```bash
# Run all tests
swift test

# Run tests with output
swift test -v

# Run specific test
swift test --filter "<test_name>"
```

### Swift Version
- **Minimum:** Swift 6.2+ (from `swift-tools-version` in Package.swift)
- Target iOS/macOS/Linux compatibility for SPM libraries

## Project Conventions

### Module Structure
- Single-target library design (one public module: `Integrations and automations`)
- Design for **agent consumption** - public APIs should be clean interfaces for autonomous agents to call

### AutoGPT Integration Patterns
- **Service Adapters** - Create protocol-based adapters for each external service (API, webhook, database, queue)
- **Workflow Definitions** - Define structures for multi-step workflows that agents can compose and execute
- **Result Types** - Use Swift Result types and proper error handling for agent error recovery
- **Async-first design** - All service calls should be `async`/`await` compatible for concurrent agent operations
- **Agent Context** - Design APIs to accept agent context/identity for audit trails and isolation

### Testing Patterns
- Uses Swift **Testing framework** (modern Swift 5.9+ successor to XCTest)
- Test syntax: `@Test func testName() async throws { ... }`
- Mark tests as `async` when they involve concurrency or await operations
- Include mock service tests to simulate agent workflows

### Code Style for integrations:
1. Add to `Package.swift` targets' `dependencies` array
2. Prefer lightweight, focused libraries (e.g., minimal HTTP client over full frameworks)
3. Document the dependency rationale in commit message
4. Update this guide with critical dependency usage patterns
5. Ensure compatibility with long-running agent processes (avoid memory leaks, handle connection pooling)

**Common Integration Types to Support:**
- REST APIs (HTTP client)
- Message queues (RabbitMQ, AWS SQS, Azure Service Bus)
- Databases (SQL, NoSQL)
- Webhooks and event streams
- Cloud service SDKs) for data models
- Use `async/await` for asynchronous operations (not callbacks or completion handlers)
- Design error types as enums for exhaustive error handling in agentselines/)
- Prefer value types (structs) over reference types (classes) for data models
- Use `async/await` for asynchronous operations (not callbacks or completion handlers)

## External Depend**Phase 1 of AutoGPT** - integration layer for autonomous agents
- Follow conventional commits for consistency with parent project
- Changes should maintain agent-consumability (clear errors, proper async handling)

## Architecture Principles for AI Agents
1. **Isolation** - Each agent should be able to use integrations independently
2. **Error Recovery** - Design for agent retry logic and fallback handling
3. **Observability** - Support logging and tracing for agent debugging
4. **Extensibility** - Plugin/adapter pattern so agents can add custom integrations
5. **Configuration** - Support runtime configuration injection for different agent deployments

## Next Steps for AI Agents
1. **Define Integration Interfaces** - Create protocols for common integration patterns (ServiceAdapter, WorkflowExecutor, etc.)
2. **Implement Core Services** - REST API client, message queue integration, database adapter
3. **Build Workflow Engine** - Multi-step workflow composition and execution for agents
4. **Add Error Recovery** - Retry logic, circuit breakers, fallback strategies
5. **Comprehensive Testing** - Mock all external service interactions for agent testing
6. **Document public types** - Add doc comments (///) to all public API with agent usage examples
### SPM Build Artifacts
- Build outputs in `.build/` directory (in `.gitignore`)
- Xcode cache in `DerivedData/` and `xcuserdata/` (both ignored)
- Use `swift package resolve` to fetch dependencies
- Use `swift build --clean` if encountering stale build state

### Testing with @testable
Tests use `@testable import Integrations_and_automations` to access internal symbols - this is intentional for unit testing implementation details.

## Git Context
- Repository: `Significant-Gravitas/AutoGPT` (master branch)
- This package is part of a larger AutoGPT integration project
- Follow conventional commits for consistency with parent project

## Next Steps for AI Agents
1. **Expand the main module** - Implement core integration/automation types
2. **Add dependencies** - Consider Foundation, URLSession, or async frameworks as needed
3. **Grow test coverage** - Each public API should have corresponding tests
4. **Document public types** - Add doc comments (///) to all public API
