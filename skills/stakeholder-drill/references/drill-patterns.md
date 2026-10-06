# Patterns for a useful stakeholder drill

Choose patterns that test the user's decision. Do not run every pattern by default.

## Roles with different decisions

| Perspective | What the stakeholder wants to decide | Productive pressure |
|---|---|---|
| Daily user | Can I complete and correct my work? | Actual input/output, ambiguity, exceptions and feedback |
| Operations owner | Will this fit real operating conditions? | Dependencies, interruptions, commitments and recovery |
| Buyer or technical adopter | Is integration worth the cost? | Comparable alternatives, migration, ownership, measured quality and total cost |
| Extension author | Can I add a requirement without hidden framework work? | Language/API boundaries, semantics, implementation hooks and output fidelity |
| Reviewer or auditor | What exactly does the evidence establish? | Coverage, provenance, repeatability and unsupported conclusions |

A specialist role is useful when it introduces a distinct decision. A longer cast is not automatically a deeper review. Fictional preferences are scenario assumptions, not evidence of customer demand.

## Follow one case as it changes

Begin with one simple action, then change one consequential condition. Later combine changes where interaction is the concern. Carry the same identities and commitments forward instead of inventing an unrelated feature in every exchange.

For a meeting-room service, for example:

1. Reserve a room for a team and receive a confirmation.
2. Move the meeting after attendees have accepted it.
3. An accessibility requirement removes the selected room from eligibility.
4. Two editors revise the reservation concurrently.

The drill asks what is preserved, what can change, how conflicts are reported and what the user sees. It does not assume every service must implement concurrent editing.

## Useful distinctions to probe

- **Meaning versus convenient encoding.** “Keep my booking” might mean the time, room, attendees or merely the existence of a reservation. Show two cases that separate plausible interpretations.
- **Past occurrence versus current state.** A room was free at 10:00; that does not establish its availability throughout 10:00–11:00. Ask for the interval and evidence.
- **One checked result versus a complete workflow.** A validator may check a completed reservation without choosing replacements after an edit.
- **A policy versus a new mechanism.** A different cancellation threshold may reuse existing accounting; partial refunds across several payment providers may add decisions or transaction semantics.
- **One component versus end-to-end performance.** A fast lookup does not include import, preparation, repair, checking, export or external calls. Compare useful outcomes under matching scope.
- **A simplified assumption versus a physical or business law.** A session-duration limit does not by itself model battery consumption; a successful API response does not prove a multi-system transaction completed.
- **A proposed architecture versus its current exposure.** An extension contract can exist while its parser or runtime path remains incomplete. Conversely, a missing example is not proof that the contract is absent.

## Strengthen a vague answer

If an evaluator says “it supports custom policies,” ask for one policy the examples did not anticipate and trace how an ordinary author supplies it. If it says “the checker explains failures,” ask whether that means one observed violation, a tested repair conflict or proof that no acceptable alternative exists. If it says “it scales,” ask for workload, quality, elapsed time, memory and preparation boundaries.

For each suspected gap, form a small discriminator: two interpretations, one boundary case, a changed input or a minimal conflicting example with independently stated expectations. Label hand-derived expectations honestly. Do not turn a thought experiment into a claimed execution.

## Reviewing someone else's role-play

Read it once for stakeholder questions and once for evaluator assertions. Inventory only material claims. Check the strongest claims yourself before adopting another review's verdict, and preserve the difference between stale evidence, incorrect interpretation and a real implementation limitation.

A constructive reply should say which questions to keep, which answers to correct, and which unresolved case would clarify the design. Do not turn the exercise into a debate about which LLM is right.
