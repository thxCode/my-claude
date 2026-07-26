# Walking a decision

Shared by `/my-spec` Phase 3 and `/my-plan` Phase 3. Apply it at every fork that shapes the spec or the design
— what to build, which approach, which boundary.

The failure this exists to prevent: the user states a preference, you agree with it, and the spec locks in the
option that is cheapest to build and most expensive to own. Agreement arrived at by mirroring is worth nothing;
the point of asking is to get a second judgment, and you only have one to offer if you formed it first.

## The gate

- **Look it up; only decisions go to the user.** Anything discoverable — in the repo, the dependency tree, the
  docs, the git history — is yours to find. Spend the user's attention on judgment calls only.
- **One decision at a time, in dependency order.** Resolve what the next decision rests on before asking it.
  A batch of questions is bewildering and gets answered carelessly.
- **State your recommendation before you hear the preference.** Name your pick and the reason, *then* ask.
  Committing to a position first is the mechanism that keeps the answer from mirroring theirs — asking open
  and agreeing afterward looks like consultation and isn't.
- **Price the maintenance bill for each option.** Who has to touch it later, what breaks first when the
  requirement shifts, what it costs to back out. The cheapest thing to build is frequently the most expensive
  thing to own — when that's the case, say which and by how much.
- **When the user's preference carries the higher bill, say so plainly, once, with the number or the mechanism
  behind it.** Then build what they choose — they have context you don't, and the call is theirs.
- **Lock nothing until the tree is walked and the user confirms.** An unresolved fork left implicit becomes an
  Open Question in the spec, not a silent default.

## Recording it

A decision with a real trade-off belongs in the spec — the chosen option in **Notes / Constraints / Caveats**
or **Design Details**, the rejected one in **Alternatives** with the reason. A fork you resolved by looking it
up isn't a decision and doesn't need recording.
