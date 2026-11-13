import Testing

@testable import Jinja

// Jinja2 accepts block keywords (`call`, `filter`, `macro`, `generation`) as variable and attribute
// names; the Metis-1.6 chat template uses `for call in message.tool_calls`. // wangqi modified 2026-11-13
@Suite("Keyword Identifier Tests")
struct KeywordIdentifierTests {
    private static let toolCalls: Value = [
        ["function": ["name": "get_weather", "arguments": ["city": "Paris"]]],
        ["name": "plain_call"],
    ]

    @Test("`call` as a for-loop variable with attribute access")
    func callAsLoopVariable() throws {
        let template = try Template("{% for call in xs %}{{ call.function.name }};{% endfor %}")
        let rendered = try template.render([
            "xs": [["function": ["name": "a"]], ["function": ["name": "b"]]]
        ])
        #expect(rendered == "a;b;")
    }

    @Test("`call` in a conditional set expression")
    func callInConditionalSet() throws {
        let template = try Template(
            "{% for call in xs %}{% set f = call.function if call.function is defined else call %}{{ f.name }},{% endfor %}"
        )
        let rendered = try template.render(["xs": Self.toolCalls])
        #expect(rendered == "get_weather,plain_call,")
    }

    @Test("`filter`, `macro` and `generation` as variable and attribute names")
    func otherKeywordsAsNames() throws {
        let template = try Template(
            "{% set filter = 'f' %}{{ filter }}|{{ obj.macro }}|{{ obj.generation }}|{{ obj.call }}"
        )
        let rendered = try template.render([
            "obj": ["macro": "m", "generation": "g", "call": "c"]
        ])
        #expect(rendered == "f|m|g|c")
    }

    @Test("`call` block with caller() still renders")
    func callBlockStillWorks() throws {
        let template = try Template(
            "{% macro wrap(title) %}<{{ title }}>{{ caller() }}</{{ title }}>{% endmacro %}{% call wrap('b') %}inner{% endcall %}"
        )
        #expect(try template.render([:]) == "<b>inner</b>")
    }

    @Test("`filter` block still renders")
    func filterBlockStillWorks() throws {
        let template = try Template("{% filter upper %}hello{% endfilter %}")
        #expect(try template.render([:]) == "HELLO")
    }

    @Test("Metis-1.6 chat template renders tool calls")
    func metisTemplateRenders() throws {
        let template = try Template(Self.metisTemplate)
        let context: [String: Value] = [
            "messages": [
                ["role": "system", "content": "You are helpful."],
                ["role": "user", "content": "Weather in Paris?"],
                [
                    "role": "assistant",
                    "content": "",
                    "tool_calls": [
                        [
                            "type": "function",
                            "function": ["name": "get_weather", "arguments": ["city": "Paris", "days": 2]],
                        ]
                    ],
                ],
                ["role": "tool", "content": "Sunny"],
            ],
            "tools": [
                [
                    "type": "function",
                    "function": [
                        "name": "get_weather",
                        "description": "Get the weather",
                        "parameters": [
                            "type": "object",
                            "properties": ["city": ["type": "string"]],
                        ],
                    ],
                ]
            ],
            "add_generation_prompt": true,
        ]
        let rendered = try template.render(context)
        #expect(rendered.contains("<|tool_call|><function=get_weather>"))
        #expect(rendered.contains("<parameter=city>\nParis\n</parameter>"))
        #expect(rendered.contains("<tools>\n{\"type\": \"function\", \"function\": {"))
    }

    private static let metisTemplate = #"""
{#- metis-chat/v1, the Metis-1.6 chat template.
    Structural ids carry the sealed tokenizer's display names: <|fim_prefix|> opens the
    system turn, <|fim_middle|> a user turn, <|fim_suffix|> ends every turn, and
    <|tool_call|> / <|tool_result|> mark calls and results. Pass enable_thinking=false for
    direct mode; thinking is the default. Reasoning from turns before the last user
    message is dropped, reasoning inside the current tool loop is kept. -#}
{%- set thinking = enable_thinking if enable_thinking is defined else true -%}
{%- set think_open = '<think>\n' -%}
{%- set think_close = '\n</think>\n' -%}
{%- set direct_open = think_open ~ think_close -%}
{%- macro text(content) -%}
{%- if content is string -%}{{- content -}}
{%- elif content is iterable and content is not mapping -%}{%- for part in content -%}{%- if part.type is not defined or part.type == 'text' -%}{{- part.text -}}{%- endif -%}{%- endfor -%}
{%- elif content is not none -%}{{- content | tojson -}}
{%- endif -%}
{%- endmacro -%}
{%- macro json(value) -%}
{#- JSON with keys in sorted order, as the native renderer writes it, built from filters every Jinja engine has -#}
{%- if value is mapping -%}
{{- '{' -}}{%- for key, item in value | dictsort(true) -%}{{- key | tojson -}}{{- ': ' -}}{{- json(item) -}}{%- if not loop.last -%}{{- ', ' -}}{%- endif -%}{%- endfor -%}{{- '}' -}}
{%- elif value is string -%}{{- value | tojson -}}
{%- elif value is iterable -%}
{{- '[' -}}{%- for item in value -%}{{- json(item) -}}{%- if not loop.last -%}{{- ', ' -}}{%- endif -%}{%- endfor -%}{{- ']' -}}
{%- else -%}{{- value | tojson -}}
{%- endif -%}
{%- endmacro -%}
{%- set ns = namespace(system=none, last_user=-1) -%}
{%- for message in messages -%}
{%- if loop.first and message.role in ['system', 'developer'] -%}{%- set ns.system = text(message.content) | trim -%}{%- endif -%}
{%- if message.role == 'user' -%}{%- set ns.last_user = loop.index0 -%}{%- endif -%}
{%- endfor -%}
{%- if ns.system or tools -%}
{{- '<|fim_prefix|>' -}}
{%- if ns.system -%}{{- ns.system -}}{%- if tools -%}{{- '\n\n' -}}{%- endif -%}{%- endif -%}
{%- if tools -%}
{{- '# Tools\n\nYou can call the functions described by these JSON schemas:\n\n<tools>\n' -}}
{%- for tool in tools -%}
{%- set function = tool.function if tool.type is defined and tool.type == 'function' and tool.function is defined else tool -%}
{{- '{"type": "function", "function": ' ~ json(function) ~ '}' -}}
{%- if not loop.last -%}{{- '\n' -}}{%- endif -%}
{%- endfor -%}
{{- '\n</tools>\n\nTo call a function, write a tool call whose body has this form, with one parameter block per argument:\n\n<function=function_name>\n<parameter=parameter_name>\nvalue\n</parameter>\n</function>\n\nYou may make several calls in one turn. Their results come back in the same order.' -}}
{%- endif -%}
{{- '<|fim_suffix|>' -}}
{%- endif -%}
{%- for message in messages -%}
{%- if message.role == 'user' -%}
{{- '<|fim_middle|>' ~ text(message.content) ~ '<|fim_suffix|>' -}}
{%- elif message.role == 'tool' -%}
{{- '<|tool_result|>' ~ text(message.content) ~ '<|fim_suffix|>' -}}
{%- elif message.role == 'assistant' -%}
{%- set active = loop.index0 > ns.last_user -%}
{%- set reasoning = message.reasoning_content if message.reasoning_content is defined and message.reasoning_content is not none else (message.reasoning if message.reasoning is defined and message.reasoning is not none else '') -%}
{%- if active and thinking -%}
{{- think_open ~ (reasoning | trim) ~ think_close -}}
{%- else -%}
{{- direct_open -}}
{%- endif -%}
{{- text(message.content) | trim -}}
{%- if message.tool_calls is defined and message.tool_calls -%}
{%- for call in message.tool_calls -%}
{%- set function = call.function if call.function is defined else call -%}
{{- '<|tool_call|><function=' ~ function.name ~ '>\n' -}}
{%- if function.arguments is mapping -%}
{%- for name, value in function.arguments | dictsort(true) -%}
{{- '<parameter=' ~ name ~ '>\n' ~ (value if value is string else json(value)) ~ '\n</parameter>\n' -}}
{%- endfor -%}
{%- endif -%}
{{- '</function>' -}}
{%- endfor -%}
{%- endif -%}
{{- '<|fim_suffix|>' -}}
{%- endif -%}
{%- endfor -%}
{%- if add_generation_prompt -%}
{{- think_open if thinking else direct_open -}}
{%- endif -%}
"""#
}
