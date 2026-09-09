# Architecture: [Project Name]

> Written by nanoPRD Phase 2. Source of truth for stack, data model, and structure.
> Nanotasks reference this file rather than restating it.

## 1. Tech stack

*Every technology with a pinned major version. New dependencies carry a
justification - one added without a stated reason cannot be removed later, because
nobody knows what it was for.*

| Layer | Technology | Version | Inherited or new | Why |
|---|---|---|---|---|
| | | | | |

## 2. Data model

*Every entity and relationship, defined now. A data model discovered halfway
through implementation forces a rewrite of every nanotask that touched the old
shape.*

| Entity | Key fields | Relationships | Storage |
|---|---|---|---|
| | | | |

## 3. Components

*Ordered so dependencies come first. Component 0 is always setup.*

| # | Component | Responsibility | Depends on |
|---|---|---|---|
| 0 | Setup | Scaffolding, dependencies, configuration | none |

## 4. Dependency graph

```mermaid
graph TD
    C0[0. Setup]
```

*If this graph has a cycle, the decomposition is wrong. Break it here, not in
Phase 3.*

## 5. Risk chains

*Only failures that cross a component boundary. Single-component failures are not
risk chains - they are caught by the nanotask that owns them.*

| Trigger | Immediate failure | Downstream effect | Mitigation |
|---|---|---|---|
| | | | |

## 6. External integrations

*Third-party APIs, webhooks, auth providers. For each: what happens when it is
down, and whether that is acceptable.*

| Service | Used for | Failure mode | Degradation strategy |
|---|---|---|---|
| | | | |
