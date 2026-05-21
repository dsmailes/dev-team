# Skill Registry

This registry is intentionally generic. It explains how to route skills without naming machine-specific, plugin-specific, or private skills.

Project installs can add local skill names by importing a registry file into:

```text
.skills/imported.md
```

The architect should use this file together with `.skills/imported.md`, project instructions, and user instructions to fill each ticket's `Skill Context`.

## Universal Process Skills

### Planning And Delegation

Applies when:

- Work spans multiple steps, agents, or files.
- A ticket needs decomposition before execution.
- Multiple roles need a shared plan and handoff gates.

Skill selection:

- Choose local planning, specification, or delegation skills if available.
- If no matching skill exists, write `None` and keep the ticket self-contained.

Agent usage:

- Architect: decompose, ticket, and plan.
- Executor: follow the assigned ticket only.
- Reviewer: verify spec compliance before quality.
- Tester: verify fresh evidence before completion.

### Debugging And Verification

Applies when:

- A bug, failure, crash, flaky test, or unexpected behavior is involved.

Skill selection:

- Choose local debugging, test-first, code-review, or verification skills if available.
- Prefer skills that require root-cause evidence and fresh verification.

Agent usage:

- Architect: require reproduction and root-cause evidence in the ticket.
- Executor: create a failing test or reproduction before fixing.
- Reviewer: check that the fix addresses root cause rather than symptoms.
- Tester: rerun the original symptom and relevant regressions.

## UI And Product Skills

### General UI

Applies when:

- A ticket changes UI, UX, layout, visual hierarchy, interaction design, accessibility, or frontend polish.

Skill selection:

- Choose local frontend, design-system, accessibility, visual QA, or platform UI skills if available.
- Mark `Designer Review` as required when UI criteria need to be shaped before implementation.

Agent usage:

- Architect: mark `Designer Review` as required when appropriate.
- Designer: produce layout, state, interaction, asset, and accessibility criteria.
- Executor: implement the brief using existing design conventions.
- Reviewer: check visual regression, accessibility risk, and state coverage.
- Tester: verify rendered behavior with the project's UI test or inspection tools.

### Optional Design Tooling

Applies when:

- A ticket needs inspection of design artifacts, design-system source material, screenshots, flows, tokens, components, or assets.
- A project has a design MCP, connector, local design workspace, design documents, or screenshot workflow available.

Capability routing:

- `design-inspection`: inspect design artifacts, screens, flows, and component structure.
- `design-token-extraction`: extract or infer color, typography, spacing, radius, shadow, motion, and density decisions.
- `component-reference`: identify existing components, variants, states, and implementation counterparts.
- `layout-comparison`: compare proposed UI criteria or implementation against source designs or screenshots.
- `asset-guidance`: identify images, icons, export needs, aspect ratios, and asset constraints.

Skill selection:

- Do not name or require a specific design product in the core workflow.
- If a project-local design MCP, connector, document set, screenshot workflow, or imported skill satisfies the capability, assign it in `Skill Context`.
- If no design tooling is available, write `None` and proceed from repository files, screenshots, platform conventions, and design-system docs.

Agent usage:

- Architect: decide whether design tooling is required or optional, list capability names, and identify likely design sources if known.
- Designer: use available tools that satisfy the requested capabilities, then record what was inspected and what constraints were discovered.
- Executor: implement the design brief; do not independently reinterpret design artifacts unless assigned.
- Reviewer: check whether design-tool-derived constraints were followed or explicitly waived.
- Tester: verify rendered behavior against the ticket's design brief and any available screenshots or artifacts.

## Framework And Platform Skills

### Web Frontend

Applies when:

- The project uses browser UI frameworks, component systems, routing, client-side state, or web rendering.

Skill selection:

- Choose local web, frontend, component-library, accessibility, browser-testing, or performance skills if available.

Agent usage:

- Architect: define component ownership, state ownership, route/data boundaries, and performance risks.
- Designer: map the design brief to reusable components and interaction states.
- Executor: follow existing component and state patterns.
- Reviewer: check component boundaries, accessibility, render behavior, and data flow.
- Tester: verify with the project's native test tools and browser checks.

### Mobile Or Desktop Apps

Applies when:

- The project uses native, hybrid, or cross-platform app frameworks.

Skill selection:

- Choose local platform, UI, build, simulator/device, accessibility, performance, or native integration skills if available.

Agent usage:

- Architect: identify lifecycle, navigation, performance, native integration, and platform split risks.
- Designer: account for platform conventions and device ergonomics.
- Executor: follow platform and framework conventions already present in the project.
- Reviewer: check lifecycle, performance, memory, and integration risks.
- Tester: verify on the relevant simulator, emulator, device, or desktop workflow when available.

### Backend, CLI, Or Services

Applies when:

- The project changes APIs, services, workers, command-line tools, background jobs, or infrastructure-facing code.

Skill selection:

- Choose local backend, API, CLI, security, observability, deployment, or integration-test skills if available.

Agent usage:

- Architect: identify API contracts, compatibility, auth, data, and deployment risks.
- Executor: follow existing service boundaries and error-handling conventions.
- Reviewer: check compatibility, security, data handling, and operational failure modes.
- Tester: verify contract, integration, and failure-path behavior.

## Data And Persistence

Applies when:

- A ticket touches databases, migrations, persistence, schemas, SQL, sync, caching, or storage.

Skill selection:

- Choose local data, migration, database, query, storage, or persistence skills if available.
- Prefer structured or schema-aware APIs when the stack provides them.

Agent usage:

- Architect: identify data-loss, migration, rollback, and compatibility risks.
- Executor: use structured/schema-aware APIs where available.
- Reviewer: check migrations, defaults, indexes, constraints, and backward compatibility.
- Tester: verify migration, persistence, and rollback-sensitive paths.

## External APIs

Applies when:

- A ticket touches third-party APIs, SDKs, model providers, billing, auth, or service integrations.

Skill selection:

- Choose local provider-specific, official-docs, SDK, or integration skills if available.
- Prefer current official documentation for API-sensitive decisions.

Agent usage:

- Architect: require current source references for API-sensitive decisions.
- Executor: implement against project abstractions and selected source guidance.
- Reviewer: check API assumptions, error handling, auth, retries, and rate limits.
- Tester: verify mocked or safe integration paths unless live calls are explicitly approved.

## Imported Skills

If `.skills/imported.md` exists, it is the project-local source for exact skill names.

Each imported entry should include:

```md
## Skill Or Skill Family Name

Applies when:

- Condition.

Use for:

- Architect:
- Designer:
- Executor:
- Reviewer:
- Tester:
```
