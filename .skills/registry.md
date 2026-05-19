# Skill Registry

This registry is a routing aid, not a mandate. Select skills that match the ticket. Write `None` when no skill applies.

## Universal Process Skills

### Planning And Delegation

Applies when:

- Work spans multiple steps, agents, or files.
- A ticket needs decomposition before execution.

Suggested skills:

- `superpowers:brainstorming`
- `superpowers:writing-plans`
- `superpowers:subagent-driven-development`
- `superpowers:dispatching-parallel-agents`

Agent usage:

- Architect: decompose, ticket, and plan.
- Executor: follow the assigned ticket only.
- Reviewer: verify spec compliance before quality.
- Tester: verify fresh evidence before completion.

### Debugging And Verification

Applies when:

- A bug, failure, crash, flaky test, or unexpected behavior is involved.

Suggested skills:

- `superpowers:systematic-debugging`
- `superpowers:test-driven-development`
- `superpowers:verification-before-completion`
- `superpowers:requesting-code-review`
- `superpowers:receiving-code-review`

Agent usage:

- Architect: require reproduction and root-cause evidence in the ticket.
- Executor: create failing test or reproduction before fixing.
- Reviewer: check that the fix addresses root cause rather than symptoms.
- Tester: rerun the original symptom and relevant regressions.

## UI And Product Skills

### General Frontend UI

Applies when:

- A ticket changes UI, UX, layout, visual hierarchy, interaction design, accessibility, or frontend polish.

Suggested skills:

- `frontend-skill`
- `build-web-apps:frontend-app-builder`
- `build-web-apps:frontend-testing-debugging`

Agent usage:

- Architect: mark `Designer Review` as required.
- Designer: produce layout, state, interaction, asset, and accessibility criteria.
- Executor: implement the brief using existing design conventions.
- Reviewer: check visual regression, accessibility risk, and state coverage.
- Tester: verify rendered behavior in the browser or platform-native UI harness.

### React And Next.js

Applies when:

- The project uses React, Next.js, Remix, Vite React, JSX, or TSX.

Suggested skills:

- `build-web-apps:react-best-practices`
- `build-web-apps:frontend-testing-debugging`
- `build-web-apps:shadcn` when shadcn is present.

Agent usage:

- Architect: define component ownership, state ownership, route/data boundaries, and performance risks.
- Designer: map design brief to reusable components and interaction states.
- Executor: avoid unnecessary re-renders, unstable state ownership, and unneeded abstractions.
- Reviewer: check component boundaries, accessibility, render behavior, and data flow.
- Tester: verify with the app's native test tools and browser checks.

### React Native

Applies when:

- The project uses React Native or Expo.

Suggested skills:

- `react-native-best-practices`
- Expo skills when the project uses Expo.

Agent usage:

- Architect: identify navigation, performance, native module, and platform split risks.
- Designer: account for mobile ergonomics and platform conventions.
- Executor: prefer performant lists, stable renders, native driver or platform-appropriate animation patterns.
- Reviewer: check FPS, memory, render churn, and native integration risk.
- Tester: verify on the relevant simulator/device workflow when available.

## Apple And Swift Skills

Axiom and PFW are optional skill families. Select them when they fit the ticket, user request, or project conventions.

### Apple Platform Routing

Applies when:

- The ticket benefits from Apple-specific guidance for Swift, SwiftUI, UIKit, Xcode, macOS, iOS, watchOS, tvOS, visionOS, Apple frameworks, signing, or simulator workflows.

Suggested skills:

- `axiom-build`
- `axiom-swift`
- `axiom-swiftui`
- `axiom-design`
- `axiom-accessibility`
- `axiom-testing`
- `axiom-data`
- `axiom-concurrency`
- `axiom-networking`
- `axiom-security`
- `axiom-performance`

Agent usage:

- Architect: choose the narrow Axiom router skill for the actual symptom or framework.
- Designer: use design, SwiftUI, or accessibility routing only for UI tickets that need it.
- Executor: use implementation-specific routing such as data, concurrency, networking, or SwiftUI.
- Reviewer: check platform conventions and lifecycle or framework risks.
- Tester: choose Swift Testing, XCTest, UI tests, simulator checks, or build verification only when relevant.

### PFW Libraries

Applies when:

- The project uses or should use Point-Free libraries and the user or project conventions support that choice.

Suggested skills:

- `pfw-composable-architecture`
- `pfw-dependencies`
- `pfw-testing`
- `pfw-custom-dump`
- `pfw-snapshot-testing`
- `pfw-sharing`
- `pfw-structured-queries`
- `pfw-sqlite-data`
- `pfw-swift-navigation`
- `pfw-case-paths`
- `pfw-observable-models`
- `pfw-modern-swiftui`

Agent usage:

- Architect: decide whether the ticket should use a PFW library based on existing project conventions.
- Designer: use only when UI guidance intersects with SwiftUI architecture or navigation.
- Executor: follow the selected library's current API and naming conventions.
- Reviewer: check for deterministic dependencies, focused domains, action names that express user intent, and testability.
- Tester: prefer controllable dependencies, strong diffs, and state-focused assertions.

## Data And Persistence

Applies when:

- A ticket touches databases, migrations, persistence, schemas, SQL, sync, or storage.

Suggested skills:

- `axiom-data` for Apple persistence when selected.
- `pfw-structured-queries` or `pfw-sqlite-data` when the project uses those libraries.
- `build-web-apps:supabase-postgres-best-practices` for Supabase/Postgres projects.

Agent usage:

- Architect: identify data-loss, migration, rollback, and compatibility risks.
- Executor: use structured/schema-aware APIs where available.
- Reviewer: check migrations, defaults, indexes, constraints, and backward compatibility.
- Tester: verify migration, persistence, and rollback-sensitive paths.

## OpenAI And External APIs

Applies when:

- A ticket touches OpenAI APIs, Agents SDK, model selection, API migrations, or official OpenAI product behavior.

Suggested skills:

- `openai-docs`
- `openai-developers` plugin if installed and requested.

Agent usage:

- Architect: require current official docs for API-sensitive decisions.
- Executor: implement against official docs and project abstractions.
- Reviewer: check model/API assumptions and error handling.
- Tester: verify mocked or safe integration paths unless live calls are explicitly approved.
