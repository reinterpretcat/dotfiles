---
name: tournament-run
description: Run a project-independent, multi-round tournament comparing N variants of a stochastic algorithm against a baseline. Use for benchmarking parameter sweeps, A/B testing algorithm changes, validating optimization strategies, or tasks saying "tournament", "benchmark variants", or "compare configurations". Discovers project commands, datasets, budgets, and objectives; runs sequentially; applies adaptive early-stopping; and ranks results by the declared objective ordering.
---

Run a structured benchmark tournament in the current project, regardless of language, build system, or application domain. Each variant is an isolated code or configuration change. Compare sequential runs against a baseline using the user's declared objectives, including hierarchical objectives when applicable.

## When to invoke

Use when comparing variants of an expensive, noisy stochastic algorithm with measurable per-run outputs (cost, latency, quality score). Examples:
- "Tournament my heuristic changes against baseline"
- "Benchmark these 5 variants on dataset X"
- "Run an A/B test of these parameter values"
- "Validate that my optimization actually improves anything"

Don't invoke for deterministic benchmarks, microbenchmarks, or correctness tests; use the project's timing tools, benchmark harness, or test suite instead.

## Establish the tournament contract

Before expensive runs, inspect project instructions, benchmark documentation, existing scripts, and representative output. Derive this contract from the user's request and local evidence. Ask only about unresolved choices; do not invent commands, datasets, or baseline scores.

| Setting | What to establish |
|---|---|
| Baseline | Project root, revision or source snapshot, configuration, and environment. |
| Variants | Names, exact code/configuration changes, and isolated revisions or configuration files. |
| Preparation | Actual build/install command and artifact, or interpreter and dependencies if no build is needed. |
| Execution | Actual command/entry point, input arguments, logging options, working directory, and exit-code semantics. |
| Datasets | User-provided inputs or existing benchmark fixtures, auxiliary files, and provenance. |
| Objectives | Ordered metric names, units, minimize/maximize direction for each, hard constraints, and aggregation rule. |
| Budget | Supported work unit and termination option, per-run limit, total run/time cap, and resources. |
| Randomness | Independent randomized runs or multiple shared seeds for paired comparisons, if supported. |
| Results | Structured schema or verified log parser, final-result marker, and failed/incomplete-run handling. |
| Artifacts | Output root outside tracked source and disposable worktrees, following project conventions. |

If datasets are unspecified, propose representative existing fixtures: a primary dataset and a second with different characteristics. Confirm choices when several are plausible. If none exist, ask for inputs or an authorized data-generation method. Never assume a domain, filename, CLI flag, package manager, or runtime.

Save the resolved contract in `<OUTPUT_ROOT>/manifest` using the project's preferred structured format. Include exact commands, revisions, input identities/checksums, toolchain versions, resource/thread settings, randomness policy, rejection thresholds, and stopping rules. Validate the command and parser with a cheap smoke run before the full tournament. Historical scores are sanity checks only when revision, inputs, environment, and budget match.

## Protocol

### Phase 0 - Probe baseline

Run baseline once at a generous budget within the agreed total cap to find the convergence knee. Inspect the trajectory and pick a budget just past the knee, using an improvement threshold appropriate to the objective's units and noise. Prefer fixed-work termination for quality comparisons. If trajectories or fixed-work limits are unavailable, document the alternative and its limitations.

Output: `BUDGET`, work unit, `EXPECTED_RUNTIME` per run, and estimated total cost. Revisit the run plan if it exceeds the cap.

### Phase 1 - Baseline variance

Run 5+ baseline runs. For each dataset and objective, record minimum, maximum, mean, standard deviation, and feasibility/failure rate. If noise obscures the target effect, plan more samples within the cap or report inconclusive evidence.

### Phase 2 - Probe variants and adaptively stop

For each variant:
1. Execute one probe run.
2. Reject if clearly worse under the declared direction-aware primary-metric tolerance or hard constraints. Use absolute tolerances for zero/negative metrics where ratios mislead. Do not let secondary improvements excuse primary regressions. Record single-probe rejection as exploratory, not statistically proven inferiority.
3. Otherwise run 2 more for 3 exploratory runs total.
4. Reuse the prepared artifact or isolated runtime instead of rebuilding/reinstalling unnecessarily.

Do not auto-reject on elapsed time alone unless it is a declared objective measured under controlled conditions.

### Phase 3 - Confirm top variants

Top variants get at least 5 total runs each, with sample counts chosen from observed variance and target effect size, within the cap. Keep exploratory and confirmation results identifiable; adaptive selection can favor lucky variants. Validate top variants on a second dataset against a baseline measured there too, when available.

### Phase 4 - Test combinations

If multiple variants improve independently, test their combination as a separate variant. Improvements may interact non-linearly; combinations do not necessarily compound. Validate before stacking changes.

### Phase 5 - Synthesize

Rank using the declared objective ordering. For hierarchical objectives, sort the lexicographic tuple, reversing maximize metrics. Do not invent a weighted combined score. When both metrics are minimized, `(primary=3, secondary=80)` loses to `(primary=2, secondary=100)`.

Separate descriptive ranking from adoption decisions: noisy differences in means are not proof of superiority. Report uncertainty and constraint failures alongside scores.

## Critical rules

### 1. Sequential benchmark runs only

Run one benchmark at a time. Concurrent processes compete for CPU, cache, memory, accelerators, or external services and can change results. Queue variants; do not fan out. Keep internal worker counts and resource limits consistent.

Prepare/build before running; avoid overlapping preparation with measured runs. Refresh or interleave baseline runs sequentially if environmental drift is a concern.

### 2. Isolate and identify every variant

For code changes in Git projects, prefer a branch or worktree per variant (`experiment-vN-<short-name>`). Configuration-only variants can share a revision with distinct recorded configurations. Without Git, use immutable source snapshots and content hashes.

Preserve the user's dirty working tree; do not switch branches in it or discard edits. Follow user authorization and project rules before creating branches or commits. When not authorized, use isolated snapshots/configurations. Record the baseline revision plus intentional patches.

Cache artifacts or prepared environments by source revision/hash, configuration, preparation command, dependencies, and toolchain, not just variant name. Interpreted projects may need no build; preserve source and dependency environments instead. Copied artifacts must include required runtime resources.

### 3. Separate editing and build state

If edits continue during a tournament, use separate worktrees or snapshots with their own build directories, mutable caches, and environments as required by the toolchain. Never mutate sources, configurations, or artifacts used by an active run. Separate editing does not permit concurrent benchmarks.

### 4. Hold non-target factors constant

Keep preprocessing, initialization, data splits, dependencies, resources, and non-target parameters consistent. Do not change initialization unless it is the declared experimental factor. Research on initialization is valid when requested; hold the remaining pipeline fixed.

### 5. Preserve the declared randomness policy

Respect the user's seed policy and actual reproducibility support. With reliable seed control, use multiple shared seeds across baseline and variants for paired comparisons, not a single seed. Otherwise use independent natural randomized runs. Record seeds when available; never mix policies midway through a comparison. Document nondeterminism that seeds do not control.

### 6. Match the budget to the question

For quality at equal work, use supported iteration, evaluation, sample, generation, or equivalent limits. Verify work is comparable: iterations may do different amounts of work after a change. Never assume a specific termination flag exists.

Record elapsed time diagnostically. If latency, throughput, or quality within a time limit is the objective, measure it directly with consistent resources, warmup, and environment controls. Time's role must be declared in the contract.

### 7. Respect hierarchy and feasibility

A genuine primary regression outweighs secondary improvement. Support any number of tiers and both minimize/maximize directions. Apply hard feasibility constraints before ranking feasible outcomes; report infeasible outcomes explicitly.

### 8. Scale evidence to the effect size

Three runs are exploratory; no fixed sample count guarantees statistical significance. Choose confirmation counts from observed variance, minimum meaningful effect, and confidence/power goals. Report dispersion, uncertainty, and selection effects; account for multiple comparisons when making statistical claims. With insufficient evidence, default to "no demonstrated improvement."

### 9. Validate across datasets

Test top candidates on a second dataset with different characteristics before recommending general adoption. If only one is available, label recommendations dataset-specific and disclose the validation gap. Document disagreement rather than hiding it in pooled scores.

## Rust on Linux command guide

Use this adapter when the target project uses Cargo on Linux; other projects retain their native tooling. Keep concrete build, cache, and worktree commands, but derive package names, binary targets, datasets, and solver arguments from the tournament contract.

Inspect the toolchain and available targets from the project root:

```bash
rustc -Vv
cargo -V
cargo metadata --no-deps --format-version 1
git status --short
git rev-parse HEAD
```

Read project instructions, `Cargo.toml`, `.cargo/config.toml`, and any Rust toolchain file. Use identical toolchains, features, profiles, target settings, and compiler flags for baseline and variants. The example below assumes a native release binary and an existing `Cargo.lock`; adapt it for custom targets/profiles or projects without a lockfile.

Replace the values below with contract settings. Use a fresh detached worktree for an existing variant revision, leaving the user's checkout untouched. Each worktree gets a separate `CARGO_TARGET_DIR` to avoid clobbering another variant's build cache.

```bash
set -euo pipefail
PROJECT_ROOT="/absolute/path/to/project"
OUTPUT_ROOT="/absolute/path/to/tournament-output"
VARIANT_REVISION="<existing-commit-or-ref>"
PACKAGE="<cargo-package>"
BINARY="<binary-target>"
ARTIFACT_ID="<source-config-toolchain-identity>"
WORKTREE="${OUTPUT_ROOT}/worktrees/${ARTIFACT_ID}"
ARTIFACT_DIR="${OUTPUT_ROOT}/artifacts/${ARTIFACT_ID}"

mkdir -p -- "${OUTPUT_ROOT}/worktrees" "${ARTIFACT_DIR}"
git -C "${PROJECT_ROOT}" worktree add --detach "${WORKTREE}" "${VARIANT_REVISION}"
cd -- "${WORKTREE}"
export CARGO_TARGET_DIR="${WORKTREE}/target"
cargo build --release --locked -p "${PACKAGE}" --bin "${BINARY}"
cp -- "${CARGO_TARGET_DIR}/release/${BINARY}" "${ARTIFACT_DIR}/${BINARY}"
sha256sum -- "${ARTIFACT_DIR}/${BINARY}"
```

This builds committed sources only. For uncommitted variants, preserve and apply the intentional patch in the isolated worktree or use a source snapshot, and include that patch in the artifact identity. Cache any required runtime resources too. Reuse a cached binary only after verifying its source/configuration/toolchain identity; do not rebuild for every repeat.

Run cached binaries directly rather than through `cargo run`, keeping compilation outside measurements. This example is a smoke run using `--help`, only if supported. For measured runs, replace `RUN_ARGS` with the verified dataset, fixed-work budget, and logging arguments. Use a new run ID for each run and never overwrite prior outputs.

```bash
RUN_ID="smoke-001"
RUN_DIR="${OUTPUT_ROOT}/probe/${ARTIFACT_ID}"
RUN_ARGS=(--help)
mkdir -p -- "${RUN_DIR}"
cd -- "${WORKTREE}"
/usr/bin/time -f 'elapsed_seconds=%e exit_status=%x' \
  -o "${RUN_DIR}/${RUN_ID}.time" \
  "${ARTIFACT_DIR}/${BINARY}" "${RUN_ARGS[@]}" \
  > "${RUN_DIR}/${RUN_ID}.log" 2>&1
```

Verify GNU `/usr/bin/time` is available; otherwise use the project's timing mechanism. Preserve nonzero exit statuses and inspect raw logs before parsing metrics. If the project uses Rayon, set and record `RAYON_NUM_THREADS` consistently; otherwise use its actual worker control. Optional CPU affinity with `taskset` must use the same allowed CPU set for all variants. Run one benchmark at a time, with no concurrent Cargo builds during measurements. Separate worktrees allow independent editing, not parallel benchmark runs.

### Optional profiling tools

Profile to explain a performance difference or locate a bottleneck, not to prove that a variant wins. Profiling runs are diagnostic only: exclude them from scored tournament results and run them sequentially, separately from measured runs and builds. Choose the tool that answers the question; do not run every profiler by default.

| Tool | Use for |
|---|---|
| `cargo flamegraph` / `flamegraph` | CPU hotspots and call stacks; use standalone `flamegraph` with an already-built executable. |
| `perf stat` | CPU counters such as cycles, instructions, and cache misses. |
| `samply` | Sampled CPU profiles for interactive call-stack exploration. |
| `heaptrack` | Allocation hotspots, allocation churn, and tracked heap usage. |

Check selected tools with `command -v` and their installed `--help`; CLI options can vary by version. `flamegraph` and `samply` can be installed with Cargo; `perf` and `heaptrack` typically come from Linux distribution packages. Do not install tools or change kernel security settings without appropriate authorization. Linux sampling tools may be restricted by `perf_event_paranoid`, container permissions, or unavailable hardware counters; report the limitation rather than silently elevating privileges.

Build a separate optimized profiling artifact with debug symbols. From the isolated worktree, reuse the resolved package/binary and all other tournament build settings; the example assumes the same native release target as above:

```bash
PROFILE_DIR="${OUTPUT_ROOT}/profiles/${ARTIFACT_ID}/${RUN_ID}"
mkdir -p -- "${PROFILE_DIR}"
cd -- "${WORKTREE}"
CARGO_PROFILE_RELEASE_DEBUG=1 CARGO_TARGET_DIR="${PROFILE_DIR}/target" \
  cargo build --release --locked -p "${PACKAGE}" --bin "${BINARY}"
PROFILE_BIN="${PROFILE_DIR}/target/release/${BINARY}"
```

Ensure project stripping settings do not remove the symbols needed by the selected profiler. Record any symbol, stripping, or frame-pointer changes and keep them identical across baseline and variant profiling builds. Do not substitute this artifact for the cached tournament artifact. Include runtime resources and use the same inputs, budget, randomness policy, and worker settings; replace the smoke-run `RUN_ARGS` with actual workload arguments before profiling.

The following are alternative commands; execute only the selected profiler, with a fresh profile directory for each diagnostic run:

```bash
flamegraph --output "${PROFILE_DIR}/flamegraph.svg" -- \
  "${PROFILE_BIN}" "${RUN_ARGS[@]}"
perf stat -o "${PROFILE_DIR}/perf-stat.txt" -- \
  "${PROFILE_BIN}" "${RUN_ARGS[@]}"
samply record --save-only -o "${PROFILE_DIR}/samply.json" -- \
  "${PROFILE_BIN}" "${RUN_ARGS[@]}"
heaptrack -o "${PROFILE_DIR}/heaptrack" \
  "${PROFILE_BIN}" "${RUN_ARGS[@]}"
```

Save tool versions, exact commands, artifact identity, raw profiles, and diagnostic logs alongside the manifest. Allocation tracking adds overhead and does not measure total process memory; do not treat tracked heap usage as RSS. Interpret profiles as mechanism evidence and confirm any resulting changes with unprofiled tournament runs.

## Tournament script template

Implement with the project's available scripting tools under `<OUTPUT_ROOT>/round_N/`. This is pseudocode, not an executable command or required language:

```text
load contract and same-dataset baseline statistics
validate inputs, objectives, artifact identities, and remaining budget

run_variant(variant, dataset, run_id):
    prepare or reuse verified artifact/environment
    execute declared command with agreed budget and randomness policy
    capture stdout, stderr, exit status, elapsed time, and completion status
    parse final result with the verified structured-output/log adapter
    validate objective fields, finite values, units, and hard constraints
    persist run record and raw outputs outside the working source tree
    return run record separately from progress messages

for variant in declared sequential order:
    stop and record incomplete status if total cap is exhausted
    probe = run_variant(variant, primary_dataset, new_run_id)
    if execution/parsing failed or run is incomplete:
        record failure separately; do not rank it as a valid score
    else if probe violates hard constraints or declared primary cutoff:
        record exploratory rejection and exact reason
    else:
        execute two additional runs sequentially within remaining cap
        record exploratory results for promotion review
```

Define the primary cutoff from its baseline distribution and tolerance in native units: above an upper cutoff is worse for minimization; below a lower cutoff is worse for maximization. For other tiers, use explicit contract rules. Never compare a secondary score to a primary threshold.

Use unique run IDs and preserve logs when resuming. Fail loudly on missing inputs, build errors, malformed output, or stale artifacts. Persist progress to resume without duplicating runs. Use the environment's supported long-running process mechanism and monitor records; never launch concurrent benchmarks.

## Aggregator template

Reuse existing analysis tools. Prefer structured records; if only logs exist, test the parser on real final, incomplete, and failed outputs.

```text
load manifest and run records; validate identities and schemas
deduplicate by dataset, variant, and run_id
group compatible records by dataset, variant, budget, and randomness policy
report attempted, valid, failed, infeasible, and incomplete counts separately
compute declared aggregates and dispersion for every objective
compute paired comparisons only when the seed policy supports them
rank feasible variants per dataset by ordered objective tuple:
    minimize metric -> aggregate value
    maximize metric -> negative aggregate value
report uncertainty and effect sizes against the same-dataset baseline
assign ADOPT / MAYBE / REJECT using confirmation evidence and constraints
```

Never silently drop failed/infeasible runs to improve a variant's score. Do not pool incompatible budgets, environments, or datasets. Summarize across datasets only with an agreed aggregation rule; otherwise retain per-dataset rankings and tradeoffs.

## Output structure

```text
<OUTPUT_ROOT>/
  manifest                       # contract and provenance
  probe/
    baseline_<dataset>.log       # convergence probe
  artifacts/
    <variant>/<identity>/        # artifact or environment metadata
  round_1/
    <orchestrator>               # project-appropriate script
    summary                     # structured per-run records
    decisions                   # promotion/rejection reasons
    baseline_stats              # per-dataset statistics
    <dataset>/<variant>/
      run_<id>.log
      run_<id>.result            # validated metrics and metadata
  round_2/                      # confirmation runs
  <aggregator>                  # reproducible analysis
  FINAL_REPORT.md
```

Adapt filenames/extensions to the chosen tools. Raw outputs and run records are the source of truth; prepared artifacts avoid unnecessary rebuilds.

## Final report structure

1. **Executive summary** - recommendation, evidence, caveats.
2. **Final decision matrix** - ranked by declared objectives, with ADOPT/MAYBE/REJECT.
3. **Top recommendations** - mechanism, evidence, code/configuration reference, risk.
4. **Negative findings** - distinguish exploratory rejections from confirmed regressions; include combinations.
5. **Cross-dataset validation** - table per dataset and disagreements.
6. **Caveats** - sample sizes, uncertainty, selection effects, failures, generalization limits.
7. **Concrete action items** - what to ship and what to test next.

Save to `<OUTPUT_ROOT>/FINAL_REPORT.md`. Reference the manifest, revisions/configurations, exact commands, budgets, randomness policy, and raw output paths for reproduction. Disclose unmet sample-size or cross-dataset validation requirements.
