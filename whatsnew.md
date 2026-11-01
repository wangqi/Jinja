# swift-jinja upgrade — 2026-11-01

`63cd1f7` (fork main) → upstream `a091d6a` (huggingface/swift-jinja main, 42 commits), merged as
`8968c01` on `main`; upgrade branch `tag-20261101`.

## Why

LFM3 1.7B and LFM3-VL 2B (GGUF) answered garbage in the app. Their chat template contains
`{%- for tool in tools or [] -%}`, which the fork's parser rejected ("Expected '%}' after for loop..
Got or instead"); `LLaMa.LLMTokenize` then sent the bare user text as the whole prompt. Upstream
`0b67ecb` (#59, "Fix for-loop iterable to accept binary expressions") is the fix.

## Highlights (what reaches the app)

- For-loop iterables accept binary expressions (`for x in a or []`) — fixes LFM3 (#59).
- Whitespace control moved into the lexer with Python's `str.isspace()` semantics, including on
  comment tags; a single trailing newline is dropped by default, as Jinja2 does (#93, #76, #90).
- `tojson` serializes like `json.dumps` (`separators`, `sort_keys`, no slash escaping) (#74, #85, #72).
- Python-style printing of lists, dicts, booleans and none (#86, #87); `str.format` / `str.join` (#89).
- Filters and tests bind tighter than binary operators (#96); loop filtering happens before loop
  variables are computed (#92); `loop.previtem` / `loop.nextitem` (#58); integer attribute access and
  integer object keys (#81, #67); `strip(chars)` (#65); `upper`/`lower` coerce to string (#69).
- Errors instead of hangs or traps: unbounded macro recursion, integer overflow, huge integer
  arguments (#91, #94, #83); configurable macro call depth (#102).
- Rendering no longer mutates the environment (#98); linear-time string slicing (#101).
- Jinja2 conformance tests and a weekly fuzz job upstream (#95).

## API changes

- Lexer, parser, AST and interpreter are now `internal` (#97). Our consumers use only `Template` and
  `Value` (`llamacpp_swift/ChatTemplate.swift`, `swift-transformers` Hub/Tokenizers, the Core AI tool
  fallback): no consumer change.
- `Package.swift` unchanged (swift-collections `from: 1.0.0`); no dependency move.

## Conflict resolution and fork patches

| Fork patch | Outcome |
|---|---|
| `Lexer.preprocess` start-of-string `{%-` / `{{-` order fix (2026-08-29) | **Absorbed** by upstream #93, which deleted `preprocess` and does whitespace control in the lexer. Conflict in `Sources/Jinja/Lexer.swift` resolved by taking upstream. |
| `TemplateTests` leading-whitespace regression tests (2026-08-29) | **Kept**, rewritten render-only (upstream #100 changed token positions); `"{\n{%- if true %}X…"` now expects `"{X"`, Python Jinja2's output (the old `"{ X"` was the regex workaround's merge guard). |

`wangqi modified` markers: 1 → 1 (`Tests/JinjaTests/TemplateTests.swift`). `swift test`: 957 tests in
27 suites pass (756 in 13 before the merge).

## Risks

| Risk | Verify |
|---|---|
| Whitespace and `tojson` changes alter every GGUF prompt the app renders (blank lines, indentation, JSON spacing in tool blocks) | GGUF `--tool-call` and generate sweeps with `--compare` against the 2026-11-01 baselines; review fixture `prompt` diffs |
| Swift-transformers (MLX / Core AI tokenizers) renders with the same package | `Flux2PromptEncoderTests` on the macOS test host; MLX sweeps when MLX next moves |
| Trailing newline now dropped | `OCRChatTemplateTests`, `CoreAIToolCallFallbackTests` |

## Opportunities (not built)

- Configurable macro call depth (#102) could cap pathological user-imported templates.
