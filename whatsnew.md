# swift-jinja: What's New (225f0f0 → 3.2.1 / 3104efd)

**Merged:** 2026-11-22 as `30fb903` on branch `tag-20261122` · **Upstream:** huggingface/swift-jinja main
(11 commits, 2026-11-09..17, #104-#112, tag 3.2.1)
**Integration docs:** `helper/docs/llamacpp_swift_toolcall.md`, `helper/docs/thirdparty_package_dependence.md`,
`helper/scripts/model_regression/README.md` ("The chat template probe")
**Consumers:** `thirdparty/llamacpp_swift/Sources/swift/ChatTemplate.swift` (every GGUF prompt),
`thirdparty/swift-transformers` (`Hub/Config.swift` `jinjaValue()`, `Tokenizers/Tokenizer.swift`
`applyChatTemplate` for MLX and Core AI), `testcases/engines/coreai/CoreAIToolCallFallbackTests.swift`
(the only direct `import Jinja` in the app tree).

Eleven upstream commits, all Jinja2-conformance work driven by upstream's conformance oracle and fuzz
job: Python Unicode casing, Python's bool-is-int semantics, a real `namespace` type, chained
comparisons, Jinja2's `striptags` / `indent` / `int` / `float`, and the `str.capitalize()` method.
No public symbol was added, renamed or removed, and `tojson`, `Value(any:)`, key order, `items`,
`length`, `string`, `join`, `replace`, `default` and `trim` are unchanged, so nothing the app pins
in its tests moves. No silent ship-blocker: every change makes a template render closer to what
Hugging Face transformers renders. The merge was conflict-free and the fork's one patch survived.

---

## 1. Changes

| Commit / PR | What changed | Reaches the app? |
|---|---|---|
| `f78d742` #104 | `upper` / `lower` / `title` use per-scalar Unicode mappings with Greek final sigma (Python `str` semantics) instead of Foundation `uppercased` / `capitalized` | Only templates calling these on non-ASCII or apostrophe text (`"don't".title()` is now `Don'T`, as Python) |
| `aefa237` #105 | Numeric / sequence semantics: `is sequence` true for dicts and undefined; `\| list` on a dict returns **keys** (was values); `in` on arrays uses numeric equivalence; `filesizeformat`, `abs`, `sum` treat booleans as 0/1; `int`/`double` equivalence is exact | Possible, see R2 |
| `6604242` #106 | `namespace()` is a distinct type (an `.object` holding an internal marker): attributes no longer collide with dict methods (`ns.items`), `is mapping` is false for a namespace, `tojson` / iteration / `length` / `in` on a namespace throw; prints `<Namespace {...}>`; equality by identity | Every template using `namespace(...)` (Qwen3, Llama 3.x, Gemma, GLM ...). Reads and `set ns.x = ...` behave as before |
| `416b281` #107 | README for 3.0 | No |
| `8569c23` #108 | Fuzz-found fixes: `is number` true for booleans; `is callable` true for undefined; `1 == true`, `0 == 0.0 == false` as Python; `sameas` keeps `true`/`false`/`none` as singletons; `int` filter truncates `"3.5"` | Possible, see R1 |
| `4420cfb` #109 | Chained comparisons `a < b < c` (were parsed as `(a < b) < c` and threw); booleans as dict keys 0 / 1 (`ObjectKey(.boolean)` now `.int`) | Templates that used chains now render instead of failing |
| `cc0ccae` #110 | `striptags` follows MarkupSafe (comments, unclosed tag, HTML entity decoding via new 2239-line `HTMLEntities.swift`); `indent` follows Jinja2 (trailing newline leaves an empty indented line, `blank` / `first` semantics) | Only templates using `indent` / `striptags`; binary grows by the entity table |
| `4970e48` #111 | `int` / `float` filters parse strings as Python `int(value, base)` / `float()`: `"0x10" \| int` is now the default (was 16) unless `base=16` or `0`; `"3.5" \| int` is 3 | Only templates casting strings |
| `fd43896`, `c15cb89` #112, `3104efd` | `str.capitalize()` method (SmolVLM-Instruct's `message['role'].capitalize()` failed with "Cannot call non-function value"); the `capitalize` filter shares it | A template using it now renders; no catalogue row needs it today |

## 2. Public API

| Symbol | Change | Our usage / fix |
|---|---|---|
| `Template`, `Template.render`, `Value`, `Value(any:)`, `Environment`, `Options` | Unchanged | `ChatTemplate.swift`, Tokenizers, `CoreAIToolCallFallbackTests`: no change |
| `ObjectKey.init?(_ value: Value)` | Behaviour: `.boolean` now gives `.int(0/1)` instead of `nil` | Not called by our code |
| `Tests.number`, `Tests.sequence`, `Tests.callable`, `Tests.mapping`, `Tests.sameas`, `Filters.list`, `Filters.int`, `Filters.float`, `Filters.indent`, `Filters.striptags` | Public static functions, same signatures, Jinja2 semantics (section 1) | Not called directly; reached only through templates |
| `Globals.namespace` | Returns the marker object; `JSONEncoder` throws on a namespace | We never encode render-time values |

## 3. Conflicts and fork patches

| File | Resolution |
|---|---|
| (none) | Conflict-free merge (`30fb903`) |

Patch inventory (`wangqi modified`, sources and tests): 4 at `225f0f0` → 4 at `tag-20261122`.
- `Sources/Jinja/Parser.swift` (2 markers, lines 685 / 836): `call` / `filter` / `macro` / `generation`
  accepted as identifiers and attribute names (Metis-1.6 `for call in message.tool_calls`). Survived
  unchanged; still needed, upstream still rejects those keywords as names. #109 rewrote
  `parseComparison` above it without touching the patched blocks.
- `Tests/JinjaTests/KeywordIdentifierTests.swift` (the patch's tests) and
  `Tests/JinjaTests/TemplateTests.swift` (2026-11-01 render-only rewrite): unchanged.

## 4. Dependencies

No dependency move: `Package.swift` unchanged (swift-collections `from: 1.0.0`). swift-transformers
still names the remote swift-jinja in its manifest; the local path package wins by identity.

## 5. Risk assessment — 4 risks (0 high, 2 medium, 2 low)

### R1 — Bool / int equality and `is number` change branch choices on bool arguments (MEDIUM)
**Problem:** `Value(any:)` turns a JSON `true` (NSNumber) into `.int(1)` (pinned in
`CoreAIToolCallFallbackTests.testTheObjectFormsFourKnownDeltasOnQwenTemplates`). Templates comparing
with `== true`, `in [true, ...]` or testing `is number` on booleans now take Python's branch. This is
closer to transformers, but a rendered tool block may change. `llamacpp_swift.toJinjaValue` tests
`as Bool` before `as Int` (its own converter, unchanged by this merge), so GGUF and Core AI paths
differ in how a JSON bool arrives; both are exercised by the checks below.
**Verify:** `cd testcases && ./run_tests.sh CoreAIToolCallFallbackTests`; GGUF
`./run_model_tests.py --templates --scan-local` (helper/scripts/model_regression) against the
2026-11-22 sweep (78 PASS, 5 WARN, 3 FAIL, 3 SKIP). **Status:** templates sweep running in P10.

### R2 — `namespace` is a new internal type (MEDIUM)
**Problem:** Qwen3 / Llama 3.x / GLM templates build `namespace(...)` and assign `ns.x` inside loops.
Attribute reads and assignment keep their old semantics (copy plus `setInChain`), but any template
that iterates, `tojson`s, or calls dict methods on a namespace now throws (Jinja2 raises too).
**Verify:** the `--templates` sweep (every shipped GGUF template, every shape); GGUF `--tool-call`
and generate sweeps with `--compare` against `baseline-toolcall-macos.log` / `baseline-generate-macos.log`
(run-20261122). **Status:** P10.

### R3 — `\| list` on a dict, `indent`, `int` / `float` string parsing (LOW)
**Problem:** behaviour flips toward Jinja2 (`dict | list` keys not values; `indent` trailing newline;
`"0x10" | int` → default). No shipped template known to depend on the old output.
**Verify:** the `--templates` sweep; any WARN whose diff is in a tool or system block names it.
**Status:** P10.

### R4 — MLX / Core AI templates via swift-transformers (LOW)
**Problem:** Tokenizers renders with `lstripBlocks` / `trimBlocks` through the same engine; the
`--templates` probe is GGUF only.
**Verify:** `./run_tests.sh CoreAIToolCallFallbackTests` (renders real Core AI Qwen3 / MiniCPM5
fragments); MLX tool-call sweep on the macOS host when convenient (`--tool-call` MLX rows).
**Status:** unit suite in P10; MLX sweep optional.

## 6. New models

None; a template engine.

## 7. Opportunities (not built)

| Upstream feature | Consumer that would use it | Value |
|---|---|---|
| `str.capitalize()` | `ChatTemplate.swift` / Tokenizers | SmolVLM-family GGUF / MLX rows become addable without a template rewrite |
| Chained comparisons | `ChatTemplate.swift` | Templates with `0 < x < n` no longer fail at render and fall back to bare text |
| Bool-as-int semantics | `llamacpp_swift.toJinjaValue` / Core AI fallback | Could drop the `Value(any:)` bool-as-1 delta workaround notes if `Value(any:)` ever orders `Bool` first upstream |

## 8. Verification

- `swift test` in the fork: 1010 tests in 29 suites pass (P3; 957 / 27 at the 2026-11-01 upgrade).
- App suites to run (P10): `CoreAIToolCallFallbackTests`, `ChatTemplateKeyOrderTests`,
  `OCRChatTemplateTests`. `ToolCallReplayTests` and `ToolCallParserTests` parse recorded output and
  do not render templates.
- GGUF `--templates` sweep (macOS, no model load) and GGUF `--tool-call` / generate sweeps with
  `--compare` against the run-20261122 baselines: results recorded by P10.
- Device: not needed; the engine is pure Swift with no platform code.
