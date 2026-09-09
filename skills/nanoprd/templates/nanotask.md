# [NN or NN.M] - [Slug]

*File name is `NN-<behavior-slug>.md` for an unsplit major, or
`NN.M-<increment-slug>.md` for a minor. Two levels only. A major is either one
file or a set of minors, never both, and a split major has no index file.*

## Behavior

> "User can <verb> <object>."
> or
> "System <verb>s <object> when <trigger>."

*One sentence, at the major level. If it needs "and", "then", or a comma-separated
list to stay true, this is more than one behavior. Split it into separate majors -
not into minors.*

## Increment

*Minors only - delete this section on an unsplit major.*

*What this minor makes true, in one line. It must be verifiable on its own against
the running system. If it cannot be checked without its sibling, it is not a
separate minor - merge it.*

**Atomic:** stated as one behavior above.
**Doable:** every decision this needs is made below. An agent can start now
without asking anything. If a question remains open, it belongs in an earlier
nanotask - do not leave it here for the implementing agent to answer in code.

## Depends on

*Nanotask numbers, or `none`. Numbers only, never names.*

*A nanotask may depend only on lower-numbered nanotasks, comparing major first and
minor second. `03.2` may depend on `03.1` and on anything below `03`. It may not
depend on `03.3` or on `04`. A dependency pointing upward means the order is wrong,
or the two are one nanotask.*

## Requirements

*What must be true when this is done. Specific, not general.*

- 

## Data and API

*Entities touched, endpoints called or created, request and response shapes.
Reference `architecture.md` for the model - do not restate it.*

| Endpoint | Method | Request | Response | Errors |
|---|---|---|---|---|
| | | | | |

## UI structure

*Components, states, empty state, error state. UI modes only - delete this section
entirely for `cli-tool`, `data-pipeline`, and `ml-service`.*

## Technical notes

*The non-obvious parts only. The chosen approach, a known trap, or why a simpler
option was rejected. Skip what the implementing agent can work out on its own.*

## Acceptance checks

*Binary. Each carries the exact command that proves it. A check without a command
is an opinion.*

- [ ] 
      Command: 
- [ ] 
      Command: 

## Out of scope for this nanotask

*What a reader might reasonably assume is included but is not, and which nanotask
covers it instead. Prevents the implementing agent from expanding scope on its own.*
