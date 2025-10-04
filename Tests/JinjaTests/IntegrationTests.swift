import OrderedCollections
import Testing

@testable import Jinja

@Suite("Integration Tests")
struct IntegrationTests {
    let options = Template.Options(lstripBlocks: true, trimBlocks: true)

    // MARK: - Test Data

    private static let messages: [String: Value] = [
        "messages": [
            [
                "role": "user",
                "content": "Hello, how are you?",
            ],
            [
                "role": "assistant",
                "content": "I'm doing great. How can I help you today?",
            ],
            [
                "role": "user",
                "content": "I'd like to show off how chat templating works!",
            ],
        ]
    ]

    private static let systemPromptMessage: [String: Value] = [
        "role": "system",
        "content": "You are a friendly chatbot who always responds in the style of a pirate",
    ]

    private static let messagesWithSystemPrompt: [String: Value] = [
        "messages": [
            [
                "role": "system",
                "content":
                    "You are a friendly chatbot who always responds in the style of a pirate",
            ],
            [
                "role": "user",
                "content": "Hello, how are you?",
            ],
            [
                "role": "assistant",
                "content": "I'm doing great. How can I help you today?",
            ],
            [
                "role": "user",
                "content": "I'd like to show off how chat templating works!",
            ],
        ]
    ]

    // MARK: - Generic Chat Template Tests

    @Test("Generic chat template")
    func genericChatTemplate() throws {
        let string =
            "{% for message in messages %}{{'<|im_start|>' + message['role'] + '\n' + message['content'] + '<|im_end|>' + '\n'}}{% endfor %}{% if add_generation_prompt %}{{ '<|im_start|>assistant\n' }}{% endif %}"
        let template = try Template(string, with: options)

        var context = Self.messages
        context["add_generation_prompt"] = .boolean(false)

        let result = try template.render(context)
        let target = """
            <|im_start|>user
            Hello, how are you?<|im_end|>
            <|im_start|>assistant
            I'm doing great. How can I help you today?<|im_end|>
            <|im_start|>user
            I'd like to show off how chat templating works!<|im_end|>
            """

        #expect(
            result.trimmingCharacters(in: .whitespacesAndNewlines)
                == target.trimmingCharacters(in: .whitespacesAndNewlines)
        )
    }

    @Test("Facebook Blenderbot 400M Distill")
    func facebookBlenderbot400MDistill() throws {
        let string =
            "{% for message in messages %}{% if message['role'] == 'user' %}{{ ' ' }}{% endif %}{{ message['content'] }}{% if not loop.last %}{{ '  ' }}{% endif %}{% endfor %}{{ eos_token }}"
        let template = try Template(string, with: options)

        var context = Self.messages
        context["eos_token"] = .string("</s>")

        let result = try template.render(context)
        let target =
            " Hello, how are you?  I'm doing great. How can I help you today?   I'd like to show off how chat templating works!</s>"

        #expect(
            result.trimmingCharacters(in: .whitespacesAndNewlines)
                == target.trimmingCharacters(in: .whitespacesAndNewlines)
        )
    }

    @Test("Facebook Blenderbot Small 90M")
    func facebookBlenderbotSmall90M() throws {
        let string =
            "{% for message in messages %}{% if message['role'] == 'user' %}{{ ' ' }}{% endif %}{{ message['content'] }}{% if not loop.last %}{{ '  ' }}{% endif %}{% endfor %}{{ eos_token }}"
        let template = try Template(string, with: options)

        var context = Self.messages
        context["eos_token"] = .string("</s>")

        let result = try template.render(context)
        let target =
            " Hello, how are you?  I'm doing great. How can I help you today?   I'd like to show off how chat templating works!</s>"

        #expect(
            result.trimmingCharacters(in: .whitespacesAndNewlines)
                == target.trimmingCharacters(in: .whitespacesAndNewlines)
        )
    }

    @Test("Bigscience Bloom")
    func bigscienceBloom() throws {
        let string =
            "{% for message in messages %}{{ message.content }}{{ eos_token }}{% endfor %}"
        let template = try Template(string, with: options)

        var context = Self.messages
        context["eos_token"] = .string("</s>")

        let result = try template.render(context)
        let target =
            "Hello, how are you?</s>I'm doing great. How can I help you today?</s>I'd like to show off how chat templating works!</s>"

        #expect(
            result.trimmingCharacters(in: .whitespacesAndNewlines)
                == target.trimmingCharacters(in: .whitespacesAndNewlines)
        )
    }

    @Test("EleutherAI GPT-NeoX-20B")
    func eleutherAIGptNeox20b() throws {
        let string =
            "{% for message in messages %}{{ message.content }}{{ eos_token }}{% endfor %}"
        let template = try Template(string, with: options)

        var context = Self.messages
        context["eos_token"] = .string("<|endoftext|>")

        let result = try template.render(context)
        let target =
            "Hello, how are you?<|endoftext|>I'm doing great. How can I help you today?<|endoftext|>I'd like to show off how chat templating works!<|endoftext|>"

        #expect(
            result.trimmingCharacters(in: .whitespacesAndNewlines)
                == target.trimmingCharacters(in: .whitespacesAndNewlines)
        )
    }

    @Test("GPT-2")
    func gpt2() throws {
        let string =
            "{% for message in messages %}{{ message.content }}{{ eos_token }}{% endfor %}"
        let template = try Template(string, with: options)

        var context = Self.messages
        context["eos_token"] = .string("<|endoftext|>")

        let result = try template.render(context)
        let target =
            "Hello, how are you?<|endoftext|>I'm doing great. How can I help you today?<|endoftext|>I'd like to show off how chat templating works!<|endoftext|>"

        #expect(
            result.trimmingCharacters(in: .whitespacesAndNewlines)
                == target.trimmingCharacters(in: .whitespacesAndNewlines)
        )
    }

    @Test("OpenAI Whisper Large V3")
    func openaiWhisperLargeV3() throws {
        let string =
            "{% for message in messages %}{{ message.content }}{{ eos_token }}{% endfor %}"
        let template = try Template(string, with: options)

        var context = Self.messages
        context["eos_token"] = .string("<|endoftext|>")

        let result = try template.render(context)
        let target =
            "Hello, how are you?<|endoftext|>I'm doing great. How can I help you today?<|endoftext|>I'd like to show off how chat templating works!<|endoftext|>"

        #expect(
            result.trimmingCharacters(in: .whitespacesAndNewlines)
                == target.trimmingCharacters(in: .whitespacesAndNewlines)
        )
    }

    // MARK: - Llama Tokenizer Tests

    @Test("HuggingFace Internal Testing Llama Tokenizer 1")
    func hfInternalTestingLlamaTokenizer1() throws {
        let string =
            "{% if messages[0]['role'] == 'system' %}{% set loop_messages = messages[1:] %}{% set system_message = messages[0]['content'] %}{% elif USE_DEFAULT_PROMPT == true and not '<<SYS>>' in messages[0]['content'] %}{% set loop_messages = messages %}{% set system_message = 'DEFAULT_SYSTEM_MESSAGE' %}{% else %}{% set loop_messages = messages %}{% set system_message = false %}{% endif %}{% for message in loop_messages %}{% if (message['role'] == 'user') != (loop.index0 % 2 == 0) %}{{ raise_exception('Conversation roles must alternate user/assistant/user/assistant/...') }}{% endif %}{% if loop.index0 == 0 and system_message != false %}{% set content = '<<SYS>>\\n' + system_message + '\\n<</SYS>>\\n\\n' + message['content'] %}{% else %}{% set content = message['content'] %}{% endif %}{% if message['role'] == 'user' %}{{ bos_token + '[INST] ' + content.strip() + ' [/INST]' }}{% elif message['role'] == 'system' %}{{ '<<SYS>>\\n' + content.strip() + '\\n<</SYS>>\\n\\n' }}{% elif message['role'] == 'assistant' %}{{ ' ' + content.strip() + ' ' + eos_token }}{% endif %}{% endfor %}"
        let template = try Template(string, with: options)

        var context = Self.messagesWithSystemPrompt
        context["bos_token"] = .string("<s>")
        context["eos_token"] = .string("</s>")
        context["USE_DEFAULT_PROMPT"] = .boolean(true)

        let result = try template.render(context)
        let target =
            "<s>[INST] <<SYS>>\nYou are a friendly chatbot who always responds in the style of a pirate\n<</SYS>>\n\nHello, how are you? [/INST] I'm doing great. How can I help you today? </s><s>[INST] I'd like to show off how chat templating works! [/INST]"

        #expect(
            result.trimmingCharacters(in: .whitespacesAndNewlines)
                == target.trimmingCharacters(in: .whitespacesAndNewlines)
        )
    }

    @Test("HuggingFace Internal Testing Llama Tokenizer 2")
    func hfInternalTestingLlamaTokenizer2() throws {
        let string =
            "{% if messages[0]['role'] == 'system' %}{% set loop_messages = messages[1:] %}{% set system_message = messages[0]['content'] %}{% elif USE_DEFAULT_PROMPT == true and not '<<SYS>>' in messages[0]['content'] %}{% set loop_messages = messages %}{% set system_message = 'DEFAULT_SYSTEM_MESSAGE' %}{% else %}{% set loop_messages = messages %}{% set system_message = false %}{% endif %}{% for message in loop_messages %}{% if (message['role'] == 'user') != (loop.index0 % 2 == 0) %}{{ raise_exception('Conversation roles must alternate user/assistant/user/assistant/...') }}{% endif %}{% if loop.index0 == 0 and system_message != false %}{% set content = '<<SYS>>\\n' + system_message + '\\n<</SYS>>\\n\\n' + message['content'] %}{% else %}{% set content = message['content'] %}{% endif %}{% if message['role'] == 'user' %}{{ bos_token + '[INST] ' + content.strip() + ' [/INST]' }}{% elif message['role'] == 'system' %}{{ '<<SYS>>\\n' + content.strip() + '\\n<</SYS>>\\n\\n' }}{% elif message['role'] == 'assistant' %}{{ ' ' + content.strip() + ' ' + eos_token }}{% endif %}{% endfor %}"
        let template = try Template(string, with: options)

        var context = Self.messages
        context["bos_token"] = .string("<s>")
        context["eos_token"] = .string("</s>")
        context["USE_DEFAULT_PROMPT"] = .boolean(true)

        let result = try template.render(context)
        let target =
            "<s>[INST] <<SYS>>\nDEFAULT_SYSTEM_MESSAGE\n<</SYS>>\n\nHello, how are you? [/INST] I'm doing great. How can I help you today? </s><s>[INST] I'd like to show off how chat templating works! [/INST]"

        #expect(
            result.trimmingCharacters(in: .whitespacesAndNewlines)
                == target.trimmingCharacters(in: .whitespacesAndNewlines)
        )
    }

    @Test("HuggingFace Internal Testing Llama Tokenizer 3")
    func hfInternalTestingLlamaTokenizer3() throws {
        let string =
            "{% if messages[0]['role'] == 'system' %}{% set loop_messages = messages[1:] %}{% set system_message = messages[0]['content'] %}{% elif USE_DEFAULT_PROMPT == true and not '<<SYS>>' in messages[0]['content'] %}{% set loop_messages = messages %}{% set system_message = 'DEFAULT_SYSTEM_MESSAGE' %}{% else %}{% set loop_messages = messages %}{% set system_message = false %}{% endif %}{% for message in loop_messages %}{% if (message['role'] == 'user') != (loop.index0 % 2 == 0) %}{{ raise_exception('Conversation roles must alternate user/assistant/user/assistant/...') }}{% endif %}{% if loop.index0 == 0 and system_message != false %}{% set content = '<<SYS>>\\n' + system_message + '\\n<</SYS>>\\n\\n' + message['content'] %}{% else %}{% set content = message['content'] %}{% endif %}{% if message['role'] == 'user' %}{{ bos_token + '[INST] ' + content.strip() + ' [/INST]' }}{% elif message['role'] == 'system' %}{{ '<<SYS>>\\n' + content.strip() + '\\n<</SYS>>\\n\\n' }}{% elif message['role'] == 'assistant' %}{{ ' ' + content.strip() + ' ' + eos_token }}{% endif %}{% endfor %}"
        let template = try Template(string, with: options)

        let messagesWithSysTag: [String: Value] = [
            "messages": .array([
                .object([
                    "role": .string("user"),
                    "content": .string(
                        "<<SYS>>\nYou are a helpful assistant\n<</SYS>> Hello, how are you?"
                    ),
                ]),
                .object([
                    "role": .string("assistant"),
                    "content": .string("I'm doing great. How can I help you today?"),
                ]),
                .object([
                    "role": .string("user"),
                    "content": .string("I'd like to show off how chat templating works!"),
                ]),
            ])
        ]

        var context = messagesWithSysTag
        context["bos_token"] = .string("<s>")
        context["eos_token"] = .string("</s>")
        context["USE_DEFAULT_PROMPT"] = .boolean(true)

        let result = try template.render(context)
        let target =
            "<s>[INST] <<SYS>>\nYou are a helpful assistant\n<</SYS>> Hello, how are you? [/INST] I'm doing great. How can I help you today? </s><s>[INST] I'd like to show off how chat templating works! [/INST]"

        #expect(
            result.trimmingCharacters(in: .whitespacesAndNewlines)
                == target.trimmingCharacters(in: .whitespacesAndNewlines)
        )
    }

    // MARK: - Qwen Tests

    @Test("Qwen Qwen1.5-1.8B-Chat 1")
    func qwenQwen1_5_1_8BChat1() throws {
        let string =
            "{% for message in messages %}{% if loop.first and messages[0]['role'] != 'system' %}{{ '<|im_start|>system\nYou are a helpful assistant<|im_end|>\n' }}{% endif %}{{'<|im_start|>' + message['role'] + '\n' + message['content']}}{% if (loop.last and add_generation_prompt) or not loop.last %}{{ '<|im_end|>' + '\n'}}{% endif %}{% endfor %}{% if add_generation_prompt and messages[-1]['role'] != 'assistant' %}{{ '<|im_start|>assistant\n' }}{% endif %}"
        let template = try Template(string, with: options)

        var context = Self.messages
        context["add_generation_prompt"] = .boolean(true)

        let result = try template.render(context)
        let target =
            "<|im_start|>system\nYou are a helpful assistant<|im_end|>\n<|im_start|>user\nHello, how are you?<|im_end|>\n<|im_start|>assistant\nI'm doing great. How can I help you today?<|im_end|>\n<|im_start|>user\nI'd like to show off how chat templating works!<|im_end|>\n<|im_start|>assistant\n"

        #expect(
            result.trimmingCharacters(in: .whitespacesAndNewlines)
                == target.trimmingCharacters(in: .whitespacesAndNewlines)
        )
    }

    @Test("Qwen Qwen1.5-1.8B-Chat 2")
    func qwenQwen1_5_1_8BChat2() throws {
        let string =
            "{% for message in messages %}{% if loop.first and messages[0]['role'] != 'system' %}{{ '<|im_start|>system\nYou are a helpful assistant<|im_end|>\n' }}{% endif %}{{'<|im_start|>' + message['role'] + '\n' + message['content']}}{% if (loop.last and add_generation_prompt) or not loop.last %}{{ '<|im_end|>' + '\n'}}{% endif %}{% endfor %}{% if add_generation_prompt and messages[-1]['role'] != 'assistant' %}{{ '<|im_start|>assistant\n' }}{% endif %}"
        let template = try Template(string, with: options)

        var context = Self.messagesWithSystemPrompt
        context["add_generation_prompt"] = .boolean(true)

        let result = try template.render(context)
        let target =
            "<|im_start|>system\nYou are a friendly chatbot who always responds in the style of a pirate<|im_end|>\n<|im_start|>user\nHello, how are you?<|im_end|>\n<|im_start|>assistant\nI'm doing great. How can I help you today?<|im_end|>\n<|im_start|>user\nI'd like to show off how chat templating works!<|im_end|>\n<|im_start|>assistant\n"

        #expect(
            result.trimmingCharacters(in: .whitespacesAndNewlines)
                == target.trimmingCharacters(in: .whitespacesAndNewlines)
        )
    }

    @Test("Qwen Qwen1.5-1.8B-Chat 3")
    func qwenQwen1_5_1_8BChat3() throws {
        let string =
            "{% for message in messages %}{% if loop.first and messages[0]['role'] != 'system' %}{{ '<|im_start|>system\nYou are a helpful assistant<|im_end|>\n' }}{% endif %}{{'<|im_start|>' + message['role'] + '\n' + message['content']}}{% if (loop.last and add_generation_prompt) or not loop.last %}{{ '<|im_end|>' + '\n'}}{% endif %}{% endfor %}{% if add_generation_prompt and messages[-1]['role'] != 'assistant' %}{{ '<|im_start|>assistant\n' }}{% endif %}"
        let template = try Template(string, with: options)

        let result = try template.render(Self.messagesWithSystemPrompt)
        let target =
            "<|im_start|>system\nYou are a friendly chatbot who always responds in the style of a pirate<|im_end|>\n<|im_start|>user\nHello, how are you?<|im_end|>\n<|im_start|>assistant\nI'm doing great. How can I help you today?<|im_end|>\n<|im_start|>user\nI'd like to show off how chat templating works!"

        #expect(result == target)
    }

    // MARK: - Additional Model Tests

    @Test("THUDM ChatGLM3-6B")
    func thudmChatglm36b() throws {
        let string =
            "{% for message in messages %}{% if loop.first %}[gMASK]sop<|{{ message['role'] }}|>\n {{ message['content'] }}{% else %}<|{{ message['role'] }}|>\n {{ message['content'] }}{% endif %}{% endfor %}{% if add_generation_prompt %}<|assistant|>{% endif %}"
        let template = try Template(string, with: options)

        let result = try template.render(Self.messagesWithSystemPrompt)
        let target =
            "[gMASK]sop<|system|>\n You are a friendly chatbot who always responds in the style of a pirate<|user|>\n Hello, how are you?<|assistant|>\n I'm doing great. How can I help you today?<|user|>\n I'd like to show off how chat templating works!"

        #expect(result == target)
    }

    @Test("Google Gemma-2B-IT")
    func googleGemma2bIt() throws {
        let string =
            "{{ bos_token }}{% if messages[0]['role'] == 'system' %}{{ raise_exception('System role not supported') }}{% endif %}{% for message in messages %}{% if (message['role'] == 'user') != (loop.index0 % 2 == 0) %}{{ raise_exception('Conversation roles must alternate user/assistant/user/assistant/...') }}{% endif %}{% if (message['role'] == 'assistant') %}{% set role = 'model' %}{% else %}{% set role = message['role'] %}{% endif %}{{ '<start_of_turn>' + role + '\n' + message['content'] | trim + '<end_of_turn>\n' }}{% endfor %}{% if add_generation_prompt %}{{'<start_of_turn>model\n'}}{% endif %}"
        let template = try Template(string, with: options)

        let result = try template.render(Self.messages)
        let target =
            "<start_of_turn>user\nHello, how are you?<end_of_turn>\n<start_of_turn>model\nI'm doing great. How can I help you today?<end_of_turn>\n<start_of_turn>user\nI'd like to show off how chat templating works!<end_of_turn>\n"

        #expect(result == target)
    }

    @Test("Qwen Qwen2.5-0.5B-Instruct")
    func qwenQwen2_5_0_5BInstruct() throws {
        let string =
            "{%- if tools %}\n    {{- '<|im_start|>system\\n' }}\n    {%- if messages[0]['role'] == 'system' %}\n        {{- messages[0]['content'] }}\n    {%- else %}\n        {{- 'You are Qwen, created by Alibaba Cloud. You are a helpful assistant.' }}\n    {%- endif %}\n    {{- \"\\n\\n# Tools\\n\\nYou may call one or more functions to assist with the user query.\\n\\nYou are provided with function signatures within <tools></tools> XML tags:\\n<tools>\" }}\n    {%- for tool in tools %}\n        {{- \"\\n\" }}\n        {{- tool | tojson }}\n    {%- endfor %}\n    {{- \"\\n</tools>\\n\\nFor each function call, return a json object with function name and arguments within <tool_call></tool_call> XML tags:\\n<tool_call>\\n{\\\"name\\\": <function-name>, \\\"arguments\\\": <args-json-object>}\\n</tool_call><|im_end|>\\n\" }}\n{%- else %}\n    {%- if messages[0]['role'] == 'system' %}\n        {{- '<|im_start|>system\\n' + messages[0]['content'] + '<|im_end|>\\n' }}\n    {%- else %}\n        {{- '<|im_start|>system\\nYou are Qwen, created by Alibaba Cloud. You are a helpful assistant.<|im_end|>\\n' }}\n    {%- endif %}\n{%- endif %}\n{%- for message in messages %}\n    {%- if (message.role == \"user\") or (message.role == \"system\" and not loop.first) or (message.role == \"assistant\" and not message.tool_calls) %}\n        {{- '<|im_start|>' + message.role + '\\n' + message.content + '<|im_end|>' + '\\n' }}\n    {%- elif message.role == \"assistant\" %}\n        {{- '<|im_start|>' + message.role }}\n        {%- if message.content %}\n            {{- '\\n' + message.content }}\n        {%- endif %}\n        {%- for tool_call in message.tool_calls %}\n            {%- if tool_call.function is defined %}\n                {%- set tool_call = tool_call.function %}\n            {%- endif %}\n            {{- '\\n<tool_call>\\n{\"name\": \"' }}\n            {{- tool_call.name }}\n            {{- '\", \"arguments\": ' }}\n            {{- tool_call.arguments | tojson }}\n            {{- '}\\n</tool_call>' }}\n        {%- endfor %}\n        {{- '<|im_end|>\\n' }}\n    {%- elif message.role == \"tool\" %}\n        {%- if (loop.index0 == 0) or (messages[loop.index0 - 1].role != \"tool\") %}\n            {{- '<|im_start|>user' }}\n        {%- endif %}\n        {{- '\\n<tool_response>\\n' }}\n        {{- message.content }}\n        {{- '\\n</tool_response>' }}\n        {%- if loop.last or (messages[loop.index0 + 1].role != \"tool\") %}\n            {{- '<|im_end|>\\n' }}\n        {%- endif %}\n    {%- endif %}\n{%- endfor %}\n{%- if add_generation_prompt %}\n    {{- '<|im_start|>assistant\\n' }}\n{%- endif %}"
        let template = try Template(string, with: options)

        let result = try template.render(Self.messages)
        let target =
            "<|im_start|>system\nYou are Qwen, created by Alibaba Cloud. You are a helpful assistant.<|im_end|>\n<|im_start|>user\nHello, how are you?<|im_end|>\n<|im_start|>assistant\nI'm doing great. How can I help you today?<|im_end|>\n<|im_start|>user\nI'd like to show off how chat templating works!<|im_end|>\n"

        #expect(result == target)
    }

    @Test("HuggingFace H4 Zephyr-7B-Beta Add Generation Prompt False")
    func huggingFaceH4Zephyr7bBetaAddGenerationPromptFalse() throws {
        let string =
            "{% for message in messages %}\n{% if message['role'] == 'user' %}\n{{ '<|user|>\n' + message['content'] + eos_token }}\n{% elif message['role'] == 'system' %}\n{{ '<|system|>\n' + message['content'] + eos_token }}\n{% elif message['role'] == 'assistant' %}\n{{ '<|assistant|>\n'  + message['content'] + eos_token }}\n{% endif %}\n{% if loop.last and add_generation_prompt %}\n{{ '<|assistant|>' }}\n{% endif %}\n{% endfor %}"
        let template = try Template(string, with: options)

        var context = Self.messagesWithSystemPrompt
        context["eos_token"] = .string("</s>")
        context["add_generation_prompt"] = .boolean(false)

        let result = try template.render(context)
        let target =
            "<|system|>\nYou are a friendly chatbot who always responds in the style of a pirate</s>\n<|user|>\nHello, how are you?</s>\n<|assistant|>\nI'm doing great. How can I help you today?</s>\n<|user|>\nI'd like to show off how chat templating works!</s>\n"

        #expect(result == target)
    }

    @Test("HuggingFace H4 Zephyr-7B-Beta Add Generation Prompt True")
    func huggingFaceH4Zephyr7bBetaAddGenerationPromptTrue() throws {
        let string =
            "{% for message in messages %}\n{% if message['role'] == 'user' %}\n{{ '<|user|>\n' + message['content'] + eos_token }}\n{% elif message['role'] == 'system' %}\n{{ '<|system|>\n' + message['content'] + eos_token }}\n{% elif message['role'] == 'assistant' %}\n{{ '<|assistant|>\n'  + message['content'] + eos_token }}\n{% endif %}\n{% if loop.last and add_generation_prompt %}\n{{ '<|assistant|>' }}\n{% endif %}\n{% endfor %}"
        let template = try Template(string, with: options)

        let messagesWithSystem: [String: Value] = [
            "messages": .array([
                .object([
                    "role": .string("system"),
                    "content": .string(
                        "You are a friendly chatbot who always responds in the style of a pirate"
                    ),
                ]),
                .object([
                    "role": .string("user"),
                    "content": .string("How many helicopters can a human eat in one sitting?"),
                ]),
            ])
        ]

        var context = messagesWithSystem
        context["eos_token"] = .string("</s>")
        context["add_generation_prompt"] = .boolean(true)

        let result = try template.render(context)
        let target =
            "<|system|>\nYou are a friendly chatbot who always responds in the style of a pirate</s>\n<|user|>\nHow many helicopters can a human eat in one sitting?</s>\n<|assistant|>\n"

        #expect(result == target)
    }

    // MARK: - Mistral and Related Tests

    @Test("HuggingFace H4 Zephyr-7B-Gemma-V0.1")
    func huggingFaceH4Zephyr7bGemmaV0_1() throws {
        let string =
            "{% if messages[0]['role'] == 'user' or messages[0]['role'] == 'system' %}{{ bos_token }}{% endif %}{% for message in messages %}{{ '<|im_start|>' + message['role'] + '\n' + message['content'] + '<|im_end|>' + '\n' }}{% endfor %}{% if add_generation_prompt %}{{ '<|im_start|>assistant\n' }}{% elif messages[-1]['role'] == 'assistant' %}{{ eos_token }}{% endif %}"
        let template = try Template(string, with: options)

        var context = Self.messages
        context["bos_token"] = .string("<bos>")
        context["eos_token"] = .string("<eos>")
        context["add_generation_prompt"] = .boolean(false)

        let result = try template.render(context)
        let target =
            "<bos><|im_start|>user\nHello, how are you?<|im_end|>\n<|im_start|>assistant\nI'm doing great. How can I help you today?<|im_end|>\n<|im_start|>user\nI'd like to show off how chat templating works!<|im_end|>\n"

        #expect(result == target)
    }

    @Test("TheBloke Mistral-7B-Instruct-v0.1-GPTQ")
    func theBlokeMistral7BInstructV0_1GPTQ() throws {
        let string =
            "{{ bos_token }}{% for message in messages %}{% if (message['role'] == 'user') != (loop.index0 % 2 == 0) %}{{ raise_exception('Conversation roles must alternate user/assistant/user/assistant/...') }}{% endif %}{% if message['role'] == 'user' %}{{ '[INST] ' + message['content'] + ' [/INST]' }}{% elif message['role'] == 'assistant' %}{{ message['content'] + eos_token + ' ' }}{% else %}{{ raise_exception('Only user and assistant roles are supported!') }}{% endif %}{% endfor %}"
        let template = try Template(string, with: options)

        var context = Self.messages
        context["bos_token"] = .string("<s>")
        context["eos_token"] = .string("</s>")

        let result = try template.render(context)
        let target =
            "<s>[INST] Hello, how are you? [/INST]I'm doing great. How can I help you today?</s> [INST] I'd like to show off how chat templating works! [/INST]"

        #expect(result == target)
    }

    @Test("MistralAI Mixtral-8x7B-Instruct-v0.1")
    func mistralaiMixtral8x7BInstructV0_1() throws {
        let string =
            "{{ bos_token }}{% for message in messages %}{% if (message['role'] == 'user') != (loop.index0 % 2 == 0) %}{{ raise_exception('Conversation roles must alternate user/assistant/user/assistant/...') }}{% endif %}{% if message['role'] == 'user' %}{{ '[INST] ' + message['content'] + ' [/INST]' }}{% elif message['role'] == 'assistant' %}{{ message['content'] + eos_token}}{% else %}{{ raise_exception('Only user and assistant roles are supported!') }}{% endif %}{% endfor %}"
        let template = try Template(string, with: options)

        var context = Self.messages
        context["bos_token"] = .string("<s>")
        context["eos_token"] = .string("</s>")

        let result = try template.render(context)
        let target =
            "<s>[INST] Hello, how are you? [/INST]I'm doing great. How can I help you today?</s>[INST] I'd like to show off how chat templating works! [/INST]"

        #expect(result == target)
    }

    @Test("CognitiveComputations Dolphin-2.5-Mixtral-8x7b")
    func cognitivecomputationsDolphin2_5Mixtral8x7b() throws {
        let string =
            "{% if not add_generation_prompt is defined %}{% set add_generation_prompt = false %}{% endif %}{% for message in messages %}{{'<|im_start|>' + message['role'] + '\n' + message['content'] + '<|im_end|>' + '\n'}}{% endfor %}{% if add_generation_prompt %}{{ '<|im_start|>assistant\n' }}{% endif %}"
        let template = try Template(string, with: options)

        let result = try template.render(Self.messages)
        let target =
            "<|im_start|>user\nHello, how are you?<|im_end|>\n<|im_start|>assistant\nI'm doing great. How can I help you today?<|im_end|>\n<|im_start|>user\nI'd like to show off how chat templating works!<|im_end|>\n"

        #expect(result == target)
    }

    @Test("OpenChat OpenChat-3.5-0106")
    func openchatOpenchat3_5_0106() throws {
        let string =
            "{{ bos_token }}{% for message in messages %}{{ 'GPT4 Correct ' + message['role'].title() + ': ' + message['content'] + '<|end_of_turn|>'}}{% endfor %}{% if add_generation_prompt %}{{ 'GPT4 Correct Assistant:' }}{% endif %}"
        let template = try Template(string, with: options)

        var context = Self.messages
        context["bos_token"] = .string("<s>")
        context["eos_token"] = .string("</s>")
        context["add_generation_prompt"] = .boolean(false)

        let result = try template.render(context)
        let target =
            "<s>GPT4 Correct User: Hello, how are you?<|end_of_turn|>GPT4 Correct Assistant: I'm doing great. How can I help you today?<|end_of_turn|>GPT4 Correct User: I'd like to show off how chat templating works!<|end_of_turn|>"

        #expect(result == target)
    }

    @Test("Upstage SOLAR-10.7B-Instruct-v1.0")
    func upstageSOLAR10_7BInstructV1_0() throws {
        let string =
            "{% for message in messages %}{% if message['role'] == 'system' %}{% if message['content']%}{{'### System:\n' + message['content']+'\n\n'}}{% endif %}{% elif message['role'] == 'user' %}{{'### User:\n' + message['content']+'\n\n'}}{% elif message['role'] == 'assistant' %}{{'### Assistant:\n'  + message['content']}}{% endif %}{% if loop.last and add_generation_prompt %}{{ '### Assistant:\n' }}{% endif %}{% endfor %}"
        let template = try Template(string, with: options)

        let result = try template.render(Self.messages)
        let target =
            "### User:\nHello, how are you?\n\n### Assistant:\nI'm doing great. How can I help you today?### User:\nI'd like to show off how chat templating works!\n\n"

        #expect(result == target)
    }

    @Test("CodeLlama CodeLlama-70B-Instruct-HF")
    func codellamaCodeLlama70bInstructHf() throws {
        let string =
            "{% if messages[0]['role'] == 'system' %}{% set user_index = 1 %}{% else %}{% set user_index = 0 %}{% endif %}{% for message in messages %}{% if (message['role'] == 'user') != ((loop.index0 + user_index) % 2 == 0) %}{{ raise_exception('Conversation roles must alternate user/assistant/user/assistant/...') }}{% endif %}{% if loop.index0 == 0 %}{{ '<s>' }}{% endif %}{% set content = 'Source: ' + message['role'] + '\n\n ' + message['content'] | trim %}{{ content + ' <step> ' }}{% endfor %}{{'Source: assistant\nDestination: user\n\n '}}"
        let template = try Template(string, with: options)

        let result = try template.render(Self.messages)
        let target =
            "<s>Source: user\n\n Hello, how are you? <step> Source: assistant\n\n I'm doing great. How can I help you today? <step> Source: user\n\n I'd like to show off how chat templating works! <step> Source: assistant\nDestination: user\n\n "

        #expect(result == target)
    }

    @Test("Deci DeciLM-7B-Instruct")
    func deciDeciLM7BInstruct() throws {
        let string =
            "{% for message in messages %}\n{% if message['role'] == 'user' %}\n{{ '### User:\n' + message['content'] }}\n{% elif message['role'] == 'system' %}\n{{ '### System:\n' + message['content'] }}\n{% elif message['role'] == 'assistant' %}\n{{ '### Assistant:\n'  + message['content'] }}\n{% endif %}\n{% if loop.last and add_generation_prompt %}\n{{ '### Assistant:' }}\n{% endif %}\n{% endfor %}"
        let template = try Template(string, with: options)

        let result = try template.render(Self.messages)
        let target =
            "### User:\nHello, how are you?\n### Assistant:\nI'm doing great. How can I help you today?\n### User:\nI'd like to show off how chat templating works!\n"

        #expect(result == target)
    }

    // MARK: - Additional Model Tests

    @Test("Qwen Qwen1.5-72B-Chat")
    func qwenQwen1_5_72BChat() throws {
        let string =
            "{% for message in messages %}{% if loop.first and messages[0]['role'] != 'system' %}{{ '<|im_start|>system\nYou are a helpful assistant.<|im_end|>\n' }}{% endif %}{{'<|im_start|>' + message['role'] + '\n' + message['content'] + '<|im_end|>' + '\n'}}{% endfor %}{% if add_generation_prompt %}{{ '<|im_start|>assistant\n' }}{% endif %}"
        let template = try Template(string, with: options)

        let result = try template.render(Self.messages)
        let target =
            "<|im_start|>system\nYou are a helpful assistant.<|im_end|>\n<|im_start|>user\nHello, how are you?<|im_end|>\n<|im_start|>assistant\nI'm doing great. How can I help you today?<|im_end|>\n<|im_start|>user\nI'd like to show off how chat templating works!<|im_end|>\n"

        #expect(result == target)
    }

    @Test("DeepSeek AI DeepSeek-LLM-7B-Chat")
    func deepseekAiDeepseekLlm7bChat() throws {
        let string =
            "{% if not add_generation_prompt is defined %}{% set add_generation_prompt = false %}{% endif %}{{ bos_token }}{% for message in messages %}{% if message['role'] == 'user' %}{{ 'User: ' + message['content'] + '\n\n' }}{% elif message['role'] == 'assistant' %}{{ 'Assistant: ' + message['content'] + eos_token }}{% elif message['role'] == 'system' %}{{ message['content'] + '\n\n' }}{% endif %}{% endfor %}{% if add_generation_prompt %}{{ 'Assistant:' }}{% endif %}"
        let template = try Template(string, with: options)

        var context = Self.messages
        context["bos_token"] = .string("<｜begin of sentence｜>")
        context["eos_token"] = .string("<｜end of sentence｜>")

        let result = try template.render(context)
        let target =
            "<｜begin of sentence｜>User: Hello, how are you?\n\nAssistant: I'm doing great. How can I help you today?<｜end of sentence｜>User: I'd like to show off how chat templating works!\n\n"

        #expect(result == target)
    }

    @Test("H2O AI H2O-Danube-1.8B-Chat")
    func h2oaiH2oDanube1_8bChat() throws {
        let string =
            "{% for message in messages %}{% if message['role'] == 'user' %}{{ '<|prompt|>' + message['content'] + eos_token }}{% elif message['role'] == 'system' %}{{ '<|system|>' + message['content'] + eos_token }}{% elif message['role'] == 'assistant' %}{{ '<|answer|>'  + message['content'] + eos_token }}{% endif %}{% if loop.last and add_generation_prompt %}{{ '<|answer|>' }}{% endif %}{% endfor %}"
        let template = try Template(string, with: options)

        var context = Self.messages
        context["eos_token"] = .string("</s>")

        let result = try template.render(context)
        let target =
            "<|prompt|>Hello, how are you?</s><|answer|>I'm doing great. How can I help you today?</s><|prompt|>I'd like to show off how chat templating works!</s>"

        #expect(result == target)
    }

    @Test("InternLM InternLM2-Chat-7B")
    func internlmInternlm2Chat7b() throws {
        let string =
            "{% if messages[0]['role'] == 'user' or messages[0]['role'] == 'system' %}{{ bos_token }}{% endif %}{% for message in messages %}{{ '<|im_start|>' + message['role'] + '\n' + message['content'] + '<|im_end|>' + '\n' }}{% endfor %}{% if add_generation_prompt %}{{ '<|im_start|>assistant\n' }}{% elif messages[-1]['role'] == 'assistant' %}{{ eos_token }}{% endif %}"
        let template = try Template(string, with: options)

        var context = Self.messages
        context["bos_token"] = .string("<s>")
        context["eos_token"] = .string("</s>")

        let result = try template.render(context)
        let target =
            "<s><|im_start|>user\nHello, how are you?<|im_end|>\n<|im_start|>assistant\nI'm doing great. How can I help you today?<|im_end|>\n<|im_start|>user\nI'd like to show off how chat templating works!<|im_end|>\n"

        #expect(result == target)
    }

    @Test("TheBloke deepseek-coder-33B-instruct-AWQ")
    func theBlokedeepseekCoder33BInstructAWQ() throws {
        let string =
            "{%- set found_item = false -%}\n{%- for message in messages -%}\n    {%- if message['role'] == 'system' -%}\n        {%- set found_item = true -%}\n    {%- endif -%}\n{%- endfor -%}\n{%- if not found_item -%}\n{{'You are an AI programming assistant, utilizing the Deepseek Coder model, developed by Deepseek Company, and you only answer questions related to computer science. For politically sensitive questions, security and privacy issues, and other non-computer science questions, you will refuse to answer.\\n'}}\n{%- endif %}\n{%- for message in messages %}\n    {%- if message['role'] == 'system' %}\n{{ message['content'] }}\n    {%- else %}\n        {%- if message['role'] == 'user' %}\n{{'### Instruction:\\n' + message['content'] + '\\n'}}\n        {%- else %}\n{{'### Response:\\n' + message['content'] + '\\n<|EOT|>\\n'}}\n        {%- endif %}\n    {%- endif %}\n{%- endfor %}\n{{'### Response:\\n'}}\n"
        let template = try Template(string, with: options)

        let result = try template.render(Self.messages)
        let target = """
            You are an AI programming assistant, utilizing the Deepseek Coder model, developed by Deepseek Company, and you only answer questions related to computer science. For politically sensitive questions, security and privacy issues, and other non-computer science questions, you will refuse to answer.
            ### Instruction:
            Hello, how are you?
            ### Response:
            I'm doing great. How can I help you today?
            <|EOT|>
            ### Instruction:
            I'd like to show off how chat templating works!
            ### Response:
            """

        #expect(
            result.trimmingCharacters(in: .whitespacesAndNewlines)
                == target.trimmingCharacters(in: .whitespacesAndNewlines)
        )
    }

    @Test("Ericzzz Falcon-RW-1B-Chat")
    func ericzzzFalconRw1bChat() throws {
        let string =
            "{% for message in messages %}{% if loop.index > 1 and loop.previtem['role'] != 'assistant' %}{{ ' ' }}{% endif %}{% if message['role'] == 'system' %}{{ '[SYS] ' + message['content'].strip() }}{% elif message['role'] == 'user' %}{{ '[INST] ' + message['content'].strip() }}{% elif message['role'] == 'assistant' %}{{ '[RESP] '  + message['content'] + eos_token }}{% endif %}{% endfor %}{% if add_generation_prompt %}{{ ' [RESP] ' }}{% endif %}"
        let template = try Template(string, with: options)

        var context = Self.messages
        context["eos_token"] = .string("<|endoftext|>")

        let result = try template.render(context)
        let target =
            "[INST] Hello, how are you? [RESP] I'm doing great. How can I help you today?<|endoftext|> [INST] I'd like to show off how chat templating works!"

        #expect(result == target)
    }

    @Test("AbacusAI Smaug-34B-V0.1")
    func abacusaiSmaug34BV0_1() throws {
        let string =
            "{%- for message in messages -%}\n{%- if message['role'] == 'user' -%}\n{%- if loop.index0 > 1 -%}\n{{- bos_token + '[INST] ' + message['content'] + ' [/INST]' -}}\n{%- else -%}\n{{- message['content'] + ' [/INST]' -}}\n{%- endif -%}\n{% elif message['role'] == 'system' %}\n{{- '[INST] <<SYS>>\\n' + message['content'] + '\\n<</SYS>>\\n\\n' -}}\n{%- elif message['role'] == 'assistant' -%}\n{{- ' '  + message['content'] + ' ' + eos_token -}}\n{% endif %}\n{% endfor %}"
        let template = try Template(string, with: options)

        var context = Self.messages
        context["bos_token"] = .string("<s>")
        context["eos_token"] = .string("</s>")

        let result = try template.render(context)
        let target =
            "Hello, how are you? [/INST] I'm doing great. How can I help you today? </s><s>[INST] I'd like to show off how chat templating works! [/INST]"

        #expect(result == target)
    }

    @Test("Maywell Synatra-Mixtral-8x7B")
    func maywellSynatraMixtral8x7B() throws {
        let string =
            "Below is an instruction that describes a task. Write a response that appropriately completes the request.\n\n{% for message in messages %}{% if message['role'] == 'user' %}### Instruction:\n{{ message['content']|trim -}}{% if not loop.last %}{% endif %}\n{% elif message['role'] == 'assistant' %}### Response:\n{{ message['content']|trim -}}{% if not loop.last %}{% endif %}\n{% elif message['role'] == 'system' %}{{ message['content']|trim -}}{% if not loop.last %}{% endif %}\n{% endif %}\n{% endfor %}\n{% if add_generation_prompt and messages[-1]['role'] != 'assistant' %}\n### Response:\n{% endif %}"
        let template = try Template(string, with: options)

        let result = try template.render(Self.messages)
        let target =
            "Below is an instruction that describes a task. Write a response that appropriately completes the request.\n\n### Instruction:\nHello, how are you?### Response:\nI'm doing great. How can I help you today?### Instruction:\nI'd like to show off how chat templating works!"

        #expect(result == target)
    }

    @Test("Maywell Synatra-Mixtral-8x7B with System Prompt")
    func maywellSynatraMixtral8x7B_2() throws {
        let string =
            "Below is an instruction that describes a task. Write a response that appropriately completes the request.\n\n{% for message in messages %}{% if message['role'] == 'user' %}### Instruction:\n{{ message['content']|trim -}}{% if not loop.last %}{% endif %}\n{% elif message['role'] == 'assistant' %}### Response:\n{{ message['content']|trim -}}{% if not loop.last %}{% endif %}\n{% elif message['role'] == 'system' %}{{ message['content']|trim -}}{% if not loop.last %}{% endif %}\n{% endif %}\n{% endfor %}\n{% if add_generation_prompt and messages[-1]['role'] != 'assistant' %}\n### Response:\n{% endif %}"
        let template = try Template(string, with: options)

        let result = try template.render(Self.messagesWithSystemPrompt)
        let target =
            "Below is an instruction that describes a task. Write a response that appropriately completes the request.\n\nYou are a friendly chatbot who always responds in the style of a pirate### Instruction:\nHello, how are you?### Response:\nI'm doing great. How can I help you today?### Instruction:\nI'd like to show off how chat templating works!"

        #expect(result == target)
    }

    // MARK: - Advanced Template Tests

    @Test("Mistral Nemo Instruct 2407")
    func mistralNemoInstruct2407() throws {
        let string =
            "{%- if messages[0][\"role\"] == \"system\" %}\n    {%- set system_message = messages[0][\"content\"] %}\n    {%- set loop_messages = messages[1:] %}\n{%- else %}\n    {%- set loop_messages = messages %}\n{%- endif %}\n{%- if not tools is defined %}\n    {%- set tools = none %}\n{%- endif %}\n{%- set user_messages = loop_messages | selectattr(\"role\", \"equalto\", \"user\") | list %}\n\n{%- for message in loop_messages | rejectattr(\"role\", \"equalto\", \"tool\") | rejectattr(\"role\", \"equalto\", \"tool_results\") | selectattr(\"tool_calls\", \"undefined\") %}\n    {%- if (message[\"role\"] == \"user\") != (loop.index0 % 2 == 0) %}\n        {{- raise_exception(\"After the optional system message, conversation roles must alternate user/assistant/user/assistant/...\") }}\n    {%- endif %}\n{%- endfor %}\n\n{{- bos_token }}\n{%- for message in loop_messages %}\n    {%- if message[\"role\"] == \"user\" %}\n        {%- if tools is not none and (message == user_messages[-1]) %}\n            {{- \"[AVAILABLE_TOOLS][\" }}\n            {%- for tool in tools %}\n        {%- set tool = tool.function %}\n        {{- '{\"type\": \"function\", \"function\": {' }}\n        {%- for key, val in tool.items() if key != \"return\" %}\n            {%- if val is string %}\n            {{- '\"' + key + '\": \"' + val + '\"' }}\n            {%- else %}\n            {{- '\"' + key + '\": ' + val|tojson }}\n            {%- endif %}\n            {%- if not loop.last %}\n            {{- \", \" }}\n            {%- endif %}\n        {%- endfor %}\n        {{- \"}}\" }}\n                {%- if not loop.last %}\n                    {{- \", \" }}\n                {%- else %}\n                    {{- \"]\" }}\n                {%- endif %}\n            {%- endfor %}\n            {{- \"[/AVAILABLE_TOOLS]\" }}\n            {%- endif %}\n        {%- if loop.last and system_message is defined %}\n            {{- \"[INST]\" + system_message + \"\\n\\n\" + message[\"content\"] + \"[/INST]\" }}\n        {%- else %}\n            {{- \"[INST]\" + message[\"content\"] + \"[/INST]\" }}\n        {%- endif %}\n    {%- elif message[\"role\"] == \"tool_calls\" or message.tool_calls is defined %}\n        {%- if message.tool_calls is defined %}\n            {%- set tool_calls = message.tool_calls %}\n        {%- else %}\n            {%- set tool_calls = message.content %}\n        {%- endif %}\n        {{- \"[TOOL_CALLS][\" }}\n        {%- for tool_call in tool_calls %}\n            {%- set out = tool_call.function|tojson %}\n            {{- out[:-1] }}\n            {%- if not tool_call.id is defined or tool_call.id|length != 9 %}\n                {{- raise_exception(\"Tool call IDs should be alphanumeric strings with length 9!\") }}\n            {%- endif %}\n            {{- ', \"id\": \"' + tool_call.id + '\"}' }}\n            {%- if not loop.last %}\n                {{- \", \" }}\n            {%- else %}\n                {{- \"]\" + eos_token }}\n            {%- endif %}\n        {%- endfor %}\n    {%- elif message[\"role\"] == \"assistant\" %}\n        {{- message[\"content\"] + eos_token}}\n    {%- elif message[\"role\"] == \"tool_results\" or message[\"role\"] == \"tool\" %}\n        {%- if message.content is defined and message.content.content is defined %}\n            {%- set content = message.content.content %}\n        {%- else %}\n            {%- set content = message.content %}\n        {%- endif %}\n        {{- '[TOOL_RESULTS]{\"content\": ' + content|string + \", \" }}\n        {%- if not message.tool_call_id is defined or message.tool_call_id|length != 9 %}\n            {{- raise_exception(\"Tool call IDs should be alphanumeric strings with length 9!\") }}\n        {%- endif %}\n        {{- '\"call_id\": \"' + message.tool_call_id + '\"}[/TOOL_RESULTS]' }}\n    {%- else %}\n        {{- raise_exception(\"Only user and assistant roles are supported, with the exception of an initial optional system message!\") }}\n    {%- endif %}\n{%- endfor %}\n"
        let template = try Template(string, with: options)

        var context = Self.messages
        context["bos_token"] = .string("<s>")
        context["eos_token"] = .string("</s>")

        let result = try template.render(context)
        let target =
            "<s>[INST]Hello, how are you?[/INST]I'm doing great. How can I help you today?</s>[INST]I'd like to show off how chat templating works![/INST]"

        #expect(result == target)
    }

    @Test("Qwen2VL Text Only")
    func qwen2VLTextOnly() throws {
        let string =
            "{% for message in messages %}{% if loop.first and message['role'] != 'system' %}<|im_start|>system\nYou are a helpful assistant.<|im_end|>\n{% endif %}<|im_start|>{{ message['role'] }}\n{% if message['content'] is string %}{{ message['content'] }}<|im_end|>\n{% endif %}{% endfor %}{% if add_generation_prompt %}<|im_start|>assistant\n{% endif %}"
        let template = try Template(string, with: options)

        var context = Self.messages
        context["add_generation_prompt"] = .boolean(true)

        let result = try template.render(context)
        let target = """
            <|im_start|>system
            You are a helpful assistant.<|im_end|>
            <|im_start|>user
            Hello, how are you?<|im_end|>
            <|im_start|>assistant
            I'm doing great. How can I help you today?<|im_end|>
            <|im_start|>user
            I'd like to show off how chat templating works!<|im_end|>
            <|im_start|>assistant

            """

        #expect(result == target)
    }

    @Test("Phi-4")
    func phi4() throws {
        let userMessage: [String: Value] = [
            "messages": .array([
                .object([
                    "role": .string("user"),
                    "content": .string("What is the weather in Paris today?"),
                ])
            ])
        ]

        let string =
            "{% for message in messages %}{% if (message['role'] == 'system') %}{{'<|im_start|>system<|im_sep|>' + message['content'] + '<|im_end|>'}}{% elif (message['role'] == 'user') %}{{'<|im_start|>user<|im_sep|>' + message['content'] + '<|im_end|><|im_start|>assistant<|im_sep|>'}}{% elif (message['role'] == 'assistant') %}{{message['content'] + '<|im_end|>'}}{% endif %}{% endfor %}"
        let template = try Template(string, with: options)

        var context = userMessage
        context["bos_token"] = .string("<|begin_of_text|>")
        context["add_generation_prompt"] = .boolean(true)

        let result = try template.render(context)
        let target = """
            <|im_start|>user<|im_sep|>What is the weather in Paris today?<|im_end|><|im_start|>assistant<|im_sep|>
            """

        #expect(result == target)
    }

    // MARK: - Llama 3 Instruct Template

    @Test("Llama 3 Instruct chat template")
    func llama3InstructTemplate() throws {
        let sampleMessages: [String: Value] = [
            "messages": .array([
                .object([
                    "role": .string("system"),
                    "content": .string(
                        "You are a helpful assistant that provides weather information."
                    ),
                ]),
                .object([
                    "role": .string("user"),
                    "content": .string("What's the weather like today?"),
                ]),
                .object([
                    "role": .string("assistant"),
                    "content": .string(
                        "I'd be happy to help you with the weather! However, I need to know your location first."
                    ),
                ]),
            ])
        ]

        let template = try Template(
            """
            {% for message in messages %}
                {% if message['role'] == 'user' %}
                    <|start_header_id|>user<|end_header_id|>

            {{ message['content'] }}<|eot_id|>
                {% elif message['role'] == 'assistant' %}
                    <|start_header_id|>assistant<|end_header_id|>

            {{ message['content'] }}<|eot_id|>
                {% elif message['role'] == 'system' %}
                    <|start_header_id|>system<|end_header_id|>

            {{ message['content'] }}<|eot_id|>
                {% endif %}
            {% endfor %}
            {% if add_generation_prompt %}
            <|start_header_id|>assistant<|end_header_id|>

            {% endif %}
            """,
            with: options
        )

        var context = sampleMessages
        context["add_generation_prompt"] = .boolean(true)

        let result = try template.render(context)

        // Verify structure
        #expect(result.contains("<|start_header_id|>system<|end_header_id|>"))
        #expect(result.contains("You are a helpful assistant"))
        #expect(result.contains("<|start_header_id|>user<|end_header_id|>"))
        #expect(result.contains("What's the weather like today?"))
        #expect(result.contains("<|start_header_id|>assistant<|end_header_id|>"))
        #expect(result.contains("I'd be happy to help"))
        #expect(result.contains("<|eot_id|>"))

        // Verify generation prompt is added
        #expect(result.hasSuffix("<|start_header_id|>assistant<|end_header_id|>\n\n"))
    }

    @Test("Llama 3 template without generation prompt")
    func llama3TemplateWithoutGenerationPrompt() throws {
        let sampleMessages: [String: Value] = [
            "messages": .array([
                .object([
                    "role": .string("system"),
                    "content": .string(
                        "You are a helpful assistant that provides weather information."
                    ),
                ]),
                .object([
                    "role": .string("user"),
                    "content": .string("What's the weather like today?"),
                ]),
                .object([
                    "role": .string("assistant"),
                    "content": .string(
                        "I'd be happy to help you with the weather! However, I need to know your location first."
                    ),
                ]),
            ])
        ]

        let template = try Template(
            """
            {% for message in messages %}
                {% if message['role'] == 'user' %}
                    <|start_header_id|>user<|end_header_id|>

            {{ message['content'] }}<|eot_id|>
                {% elif message['role'] == 'assistant' %}
                    <|start_header_id|>assistant<|end_header_id|>

            {{ message['content'] }}<|eot_id|>
                {% elif message['role'] == 'system' %}
                    <|start_header_id|>system<|end_header_id|>

            {{ message['content'] }}<|eot_id|>
                {% endif %}
            {% endfor %}
            {% if add_generation_prompt %}
            <|start_header_id|>assistant<|end_header_id|>

            {% endif %}
            """,
            with: options
        )

        var context = sampleMessages
        context["add_generation_prompt"] = .boolean(false)

        let result = try template.render(context)

        // Should not end with generation prompt
        #expect(!result.hasSuffix("<|start_header_id|>assistant<|end_header_id|>\n\n"))
        #expect(result.trimmingCharacters(in: .whitespacesAndNewlines).hasSuffix("<|eot_id|>"))
    }

    // MARK: - Multi-turn Conversation Tests

    @Test("Multi-turn conversation with Llama 3")
    func multiTurnConversationLlama3() throws {
        let multiTurnConversation: [String: Value] = [
            "messages": .array([
                .object([
                    "role": .string("system"),
                    "content": .string("You are a coding assistant."),
                ]),
                .object([
                    "role": .string("user"),
                    "content": .string("How do I create a for loop in Python?"),
                ]),
                .object([
                    "role": .string("assistant"),
                    "content": .string(
                        "In Python, you can create a for loop using this syntax:\n\n```python\nfor item in sequence:\n    # code here\n```"
                    ),
                ]),
                .object([
                    "role": .string("user"),
                    "content": .string("Can you show me an example with numbers?"),
                ]),
                .object([
                    "role": .string("assistant"),
                    "content": .string(
                        "Sure! Here's an example:\n\n```python\nfor i in range(5):\n    print(i)\n```\n\nThis will print numbers 0 through 4."
                    ),
                ]),
            ])
        ]

        let template = try Template(
            """
            {% for message in messages %}
                {% if message['role'] == 'system' %}
            <|start_header_id|>system<|end_header_id|>

            {{ message['content'] }}<|eot_id|>
                {% elif message['role'] == 'user' %}
            <|start_header_id|>user<|end_header_id|>

            {{ message['content'] }}<|eot_id|>
                {% elif message['role'] == 'assistant' %}
            <|start_header_id|>assistant<|end_header_id|>

            {{ message['content'] }}<|eot_id|>
                {% endif %}
            {% endfor %}
            """,
            with: options
        )

        let result = try template.render(multiTurnConversation)

        // Count the number of turns
        let systemCount =
            result.components(separatedBy: "<|start_header_id|>system<|end_header_id|>").count - 1
        let userCount =
            result.components(separatedBy: "<|start_header_id|>user<|end_header_id|>").count - 1
        let assistantCount =
            result.components(separatedBy: "<|start_header_id|>assistant<|end_header_id|>").count
            - 1

        #expect(systemCount == 1)
        #expect(userCount == 2)
        #expect(assistantCount == 2)

        // Verify content order
        #expect(result.contains("You are a coding assistant"))
        #expect(result.contains("How do I create a for loop"))
        #expect(result.contains("In Python, you can create"))
        #expect(result.contains("Can you show me an example"))
        #expect(result.contains("Sure! Here's an example"))
    }

    // MARK: - Tool/Function Call Templates

    @Test("Functionary template with tools")
    func functionaryTemplateWithTools() throws {
        let template = try Template(
            """
            {{ bos_token }}<|start_header_id|>system<|end_header_id|>

            You are capable of executing available function(s) if required.
            Available functions:
            {% for tool in tools %}
            - {{ tool.name }}: {{ tool.description }}
            {% endfor %}<|eot_id|>
            {% for message in messages %}
            {% if message['role'] == 'user' %}
            <|start_header_id|>user<|end_header_id|>

            {{ message['content'] }}<|eot_id|>
            {% elif message['role'] == 'assistant' %}
            <|start_header_id|>assistant<|end_header_id|>

            {{ message['content'] }}<|eot_id|>
            {% endif %}
            {% endfor %}
            """,
            with: options
        )

        let context: [String: Value] = [
            "bos_token": .string("<|begin_of_text|>"),
            "tools": .array([
                .object([
                    "name": .string("get_weather"),
                    "description": .string("Get current weather for a location"),
                ]),
                .object([
                    "name": .string("calculate"),
                    "description": .string("Perform mathematical calculations"),
                ]),
            ]),
            "messages": .array([
                .object([
                    "role": .string("user"),
                    "content": .string("What's the weather in Paris and what's 25 * 4?"),
                ])
            ]),
        ]

        let result = try template.render(context)

        #expect(result.contains("<|begin_of_text|>"))
        #expect(result.contains("You are capable of executing available function(s)"))
        #expect(result.contains("- get_weather: Get current weather"))
        #expect(result.contains("- calculate: Perform mathematical"))
        #expect(result.contains("What's the weather in Paris"))
    }

    // MARK: - Advanced Template Features

    @Test("Template with loop variables")
    func templateWithLoopVariables() throws {
        let sampleMessages: [String: Value] = [
            "messages": .array([
                .object([
                    "role": .string("system"),
                    "content": .string(
                        "You are a helpful assistant that provides weather information."
                    ),
                ]),
                .object([
                    "role": .string("user"),
                    "content": .string("What's the weather like today?"),
                ]),
                .object([
                    "role": .string("assistant"),
                    "content": .string(
                        "I'd be happy to help you with the weather! However, I need to know your location first."
                    ),
                ]),
            ])
        ]

        let template = try Template(
            """
            {% for message in messages %}
            Message {{ loop.index }}/{{ loop.length }}: 
            {% if loop.first %}[FIRST] {% endif %}
            {% if message['role'] == 'system' %}SYSTEM{% endif %}
            {% if message['role'] == 'user' %}USER{% endif %}
            {% if message['role'] == 'assistant' %}ASSISTANT{% endif %}
            : {{ message['content'] }}
            {% if loop.last %}[LAST]{% endif %}

            {% endfor %}
            """,
            with: options
        )

        let result = try template.render(sampleMessages)

        #expect(result.contains("Message 1/3"))
        #expect(result.contains("Message 2/3"))
        #expect(result.contains("Message 3/3"))
        #expect(result.contains("[FIRST] SYSTEM"))
        #expect(result.contains("[LAST]"))
        #expect(result.contains("USER: What's the weather"))
        #expect(result.contains("ASSISTANT: I'd be happy"))
    }

    @Test("Template with conditional system message handling")
    func templateWithConditionalSystemMessage() throws {
        let sampleMessages: [String: Value] = [
            "messages": .array([
                .object([
                    "role": .string("system"),
                    "content": .string(
                        "You are a helpful assistant that provides weather information."
                    ),
                ]),
                .object([
                    "role": .string("user"),
                    "content": .string("What's the weather like today?"),
                ]),
                .object([
                    "role": .string("assistant"),
                    "content": .string(
                        "I'd be happy to help you with the weather! However, I need to know your location first."
                    ),
                ]),
            ])
        ]

        let template = try Template(
            """
            {% set system_messages = messages | selectattr('role', 'equalto', 'system') | list %}
            {% for message in messages %}
            {% if message['role'] == 'system' %}
            SYSTEM: {{ message['content'] }}

            {% endif %}
            {% endfor %}

            {% if system_messages | length == 0 %}
            SYSTEM: Default system message

            {% endif %}

            {% for message in messages %}
            {% if message['role'] != 'system' %}
            {{ message['role']|upper }}: {{ message['content'] }}

            {% endif %}
            {% endfor %}
            """,
            with: options
        )

        // Test with system message
        let resultWithSystem = try template.render(sampleMessages)
        #expect(resultWithSystem.contains("SYSTEM: You are a helpful assistant"))
        #expect(!resultWithSystem.contains("Default system message"))

        // Test without system message
        let messagesWithoutSystem: [String: Value] = [
            "messages": .array([
                .object([
                    "role": .string("user"),
                    "content": .string("Hello"),
                ]),
                .object([
                    "role": .string("assistant"),
                    "content": .string("Hi there!"),
                ]),
            ])
        ]

        let resultWithoutSystem = try template.render(messagesWithoutSystem)
        #expect(resultWithoutSystem.contains("SYSTEM: Default system message"))
        #expect(resultWithoutSystem.contains("USER: Hello"))
        #expect(resultWithoutSystem.contains("ASSISTANT: Hi there!"))
    }

    @Test("Complex nested template structure")
    func complexNestedTemplateStructure() throws {
        let sampleMessages: [String: Value] = [
            "messages": .array([
                .object([
                    "role": .string("system"),
                    "content": .string(
                        "You are a helpful assistant that provides weather information."
                    ),
                ]),
                .object([
                    "role": .string("user"),
                    "content": .string("What's the weather like today?"),
                ]),
                .object([
                    "role": .string("assistant"),
                    "content": .string(
                        "I'd be happy to help you with the weather! However, I need to know your location first."
                    ),
                ]),
            ])
        ]

        let template = try Template(
            """
            {% macro render_message(msg, show_role=true) %}
            {% if show_role %}{{ msg.role|upper }}: {% endif %}{{ msg.content }}
            {% endmacro %}

            {% for message in messages %}
            {% if message.role == 'system' %}
            === SYSTEM PROMPT ===
            {{ render_message(message, show_role=false) }}
            === END SYSTEM PROMPT ===

            {% else %}
            {{ render_message(message) }}

            {% endif %}
            {% endfor %}
            """,
            with: options
        )

        let result = try template.render(sampleMessages)

        #expect(result.contains("=== SYSTEM PROMPT ==="))
        #expect(result.contains("You are a helpful assistant"))
        #expect(result.contains("=== END SYSTEM PROMPT ==="))
        #expect(result.contains("USER: What's the weather"))
        #expect(result.contains("ASSISTANT: I'd be happy"))
    }

    // MARK: - Error Cases and Edge Cases

    @Test("Template with missing message fields")
    func templateWithMissingFields() throws {
        let template = try Template(
            """
            {% for message in messages %}
            {% if message.role is defined and message.content is defined %}
            {{ message.role }}: {{ message.content }}
            {% else %}
            [INVALID MESSAGE]
            {% endif %}
            {% endfor %}
            """,
            with: options
        )

        let messagesWithMissing: [String: Value] = [
            "messages": .array([
                .object([
                    "role": .string("user"),
                    "content": .string("Complete message"),
                ]),
                .object([
                    "role": .string("assistant")
                    // missing content
                ]),
                .object([
                    "content": .string("Message without role")
                    // missing role
                ]),
            ])
        ]

        let result = try template.render(messagesWithMissing)

        #expect(result.contains("user: Complete message"))
        #expect(result.contains("[INVALID MESSAGE]"))

        // Count invalid messages
        let invalidCount = result.components(separatedBy: "[INVALID MESSAGE]").count - 1
        #expect(invalidCount == 2)  // Two messages with missing fields
    }

    @Test("Empty messages array")
    func emptyMessagesArray() throws {
        let template = try Template(
            """
            {% if messages %}
            {% for message in messages %}
            {{ message.role }}: {{ message.content }}
            {% endfor %}
            {% else %}
            No messages to display.
            {% endif %}
            """,
            with: options
        )

        let emptyContext: [String: Value] = [
            "messages": .array([])
        ]

        let result = try template.render(emptyContext)
        #expect(result.contains("No messages to display."))
    }

    // MARK: - Performance Tests

    @Test("Large conversation template performance")
    func largeConversationTemplate() throws {
        // Create a large conversation
        var largeMessages: [Value] = []

        for i in 0 ..< 100 {
            largeMessages.append(
                .object([
                    "role": .string(i % 2 == 0 ? "user" : "assistant"),
                    "content": .string("Message number \(i + 1) in this conversation."),
                ])
            )
        }

        let template = try Template(
            """
            {% for message in messages %}
            {{ loop.index }}. {{ message.role|upper }}: {{ message.content }}
            {% endfor %}
            """,
            with: options
        )

        let context: [String: Value] = [
            "messages": .array(largeMessages)
        ]

        let result = try template.render(context)

        // Verify it contains all messages
        #expect(result.contains("1. USER: Message number 1"))
        #expect(result.contains("100. ASSISTANT: Message number 100"))

        // Count lines to ensure all messages are present
        let lines = result.components(separatedBy: "\n").filter { !$0.isEmpty }
        #expect(lines.count == 100)
    }

    // MARK: - Real-world Template Variations

    @Test("Alpaca template variation")
    func alpacaTemplate() throws {
        let template = try Template(
            """
            {% if system_message %}{{ system_message }}

            {% endif %}{% for message in messages %}{% if message['role'] == 'user' %}### Instruction:
            {{ message['content'] }}

            ### Response:
            {% elif message['role'] == 'assistant' %}{{ message['content'] }}{% if not loop.last %}

            {% endif %}{% endif %}{% endfor %}
            """,
            with: options
        )

        let context: [String: Value] = [
            "system_message": .string(
                "Below is an instruction that describes a task. Write a response that appropriately completes the request."
            ),
            "messages": .array([
                .object([
                    "role": .string("user"),
                    "content": .string("Explain quantum computing in simple terms."),
                ]),
                .object([
                    "role": .string("assistant"),
                    "content": .string(
                        "Quantum computing uses quantum mechanical phenomena like superposition and entanglement to perform calculations."
                    ),
                ]),
            ]),
        ]

        let result = try template.render(context)

        #expect(result.contains("Below is an instruction that describes a task"))
        #expect(result.contains("### Instruction:"))
        #expect(result.contains("Explain quantum computing"))
        #expect(result.contains("### Response:"))
        #expect(result.contains("Quantum computing uses quantum mechanical"))
    }

    @Test("Phi template with tools")
    func phiTemplate() throws {
        let template = try Template(
            """
            <｜begin▁of▁sentence｜>{% if not add_generation_prompt is defined %}{% set add_generation_prompt = false %}{% endif %}{% set ns = namespace(is_first=false, is_tool=false, is_output_first=true, system_prompt='', is_first_sp=true, is_last_user=false) %}{%- for message in messages %}{%- if message['role'] == 'system' %}{%- if ns.is_first_sp %}{% set ns.system_prompt = ns.system_prompt + message['content'] %}{% set ns.is_first_sp = false %}{%- else %}{% set ns.system_prompt = ns.system_prompt + '

            ' + message['content'] %}{%- endif %}{%- endif %}{%- endfor %}{{ bos_token }}{{ ns.system_prompt }}{%- for message in messages %}{% set content = message['content'] %}{%- if message['role'] == 'user' %}{%- set ns.is_tool = false -%}{%- set ns.is_first = false -%}{%- set ns.is_last_user = true -%}{{'<｜User｜>' + content + '<｜Assistant｜>'}}{%- endif %}{%- if message['role'] == 'assistant' %}{% if '</think>' in content %}{% set content = content.split('</think>')[-1] %}{% endif %}{% endif %}{%- if message['role'] == 'assistant' and message['tool_calls'] is defined and message['tool_calls'] is not none %}{%- set ns.is_last_user = false -%}{%- if ns.is_tool %}{{'<｜tool▁outputs▁end｜>'}}{%- endif %}{%- set ns.is_first = false %}{%- set ns.is_tool = false -%}{%- set ns.is_output_first = true %}{%- for tool in message['tool_calls'] %}{%- if not ns.is_first %}{%- if content is none %}{{'<｜tool▁calls▁begin｜><｜tool▁call▁begin｜>' + tool['type'] + '<｜tool▁sep｜>' + tool['function']['name'] + '
            ' + '```json' + '
            ' + tool['function']['arguments'] + '
            ' + '```' + '<｜tool▁call▁end｜>'}}{%- else %}{{content + '<｜tool▁calls▁begin｜><｜tool▁call▁begin｜>' + tool['type'] + '<｜tool▁sep｜>' + tool['function']['name'] + '
            ' + '```json' + '
            ' + tool['function']['arguments'] + '
            ' + '```' + '<｜tool▁call▁end｜>'}}{%- endif %}{%- set ns.is_first = true -%}{%- else %}{{'
            ' + '<｜tool▁call▁begin｜>' + tool['type'] + '<｜tool▁sep｜>' + tool['function']['name'] + '
            ' + '```json' + '
            ' + tool['function']['arguments'] + '
            ' + '```' + '<｜tool▁call▁end｜>'}}{%- endif %}{%- endfor %}{{'<｜tool▁calls▁end｜><｜end▁of▁sentence｜>'}}{%- endif %}{%- if message['role'] == 'assistant' and (message['tool_calls'] is not defined or message['tool_calls'] is none)%}{%- set ns.is_last_user = false -%}{%- if ns.is_tool %}{{'<｜tool▁outputs▁end｜>' + content + '<｜end▁of▁sentence｜>'}}{%- set ns.is_tool = false -%}{%- else %}{{content + '<｜end▁of▁sentence｜>'}}{%- endif %}{%- endif %}{%- if message['role'] == 'tool' %}{%- set ns.is_last_user = false -%}{%- set ns.is_tool = true -%}{%- if ns.is_output_first %}{{'<｜tool▁outputs▁begin｜><｜tool▁output▁begin｜>' + content + '<｜tool▁output▁end｜>'}}{%- set ns.is_output_first = false %}{%- else %}{{'
            <｜tool▁output▁begin｜>' + content + '<｜tool▁output▁end｜>'}}{%- endif %}{%- endif %}{%- endfor -%}{% if ns.is_tool %}{{'<｜tool▁outputs▁end｜>'}}{% endif %}{% if add_generation_prompt and not ns.is_last_user and not ns.is_tool %}{{'<｜Assistant｜>'}}{% endif %}            
            """,
            with: options
        )

        let context: [String: Value] = [

            "messages": .array([
                .object([
                    "role": "user",
                    "content": "Explain the Swift programming language.",
                ])
            ])
        ]

        let result = try template.render(context)
        #expect(
            result.trimmingCharacters(in: .whitespacesAndNewlines)
                == "<｜begin▁of▁sentence｜><｜User｜>Explain the Swift programming language.<｜Assistant｜>"
        )
    }

    // MARK: - SmolLM3 Tests

    @Test("HuggingFaceTB SmolLM3-3B")
    func huggingFaceTBSmolLM3_3B() throws {
        let string = """
            {%- if enable_thinking is not defined -%}
            {%- set enable_thinking = true -%}
            {%- endif -%}

            {# ───── reasoning mode ───── #}
            {%- if enable_thinking -%}
            {%- set reasoning_mode = "/think" -%}
            {%- else -%}
            {%- set reasoning_mode = "/no_think" -%}
            {%- endif -%}

            {# ───── header (system message) ───── #}
            {{- "<|im_start|>system\\n" -}}

            {%- if messages[0].role == "system" -%}
            {%- set system_message = messages[0].content -%}
            {%- if "/no_think" in system_message -%}
            {%- set reasoning_mode = "/no_think" -%}
            {%- elif "/think" in system_message -%}
            {%- set reasoning_mode = "/think" -%}
            {%- endif -%}
            {%- set custom_instructions = system_message.replace("/no_think", "").replace("/think", "").rstrip() -%}
            {%- endif -%}

            {%- if "/system_override" in system_message -%}
            {{- custom_instructions.replace("/system_override", "").rstrip() -}}
            {{- "<|im_end|>\\n" -}}
            {%- else -%}
            {{- "## Metadata\\n\\n" -}}
            {{- "Knowledge Cutoff Date: June 2025\\n" -}}
            {%- set today = strftime_now("%d %B %Y") -%}
            {{- "Today Date: " ~ today ~ "\\n" -}}
            {{- "Reasoning Mode: " + reasoning_mode + "\\n\\n" -}}

            {{- "## Custom Instructions\\n\\n" -}}
            {%- if custom_instructions -%}
            {{- custom_instructions + "\\n\\n" -}}
            {%- elif reasoning_mode == "/think" -%}
            {{- "You are a helpful AI assistant named SmolLM, trained by Hugging Face. Your role as an assistant involves thoroughly exploring questions through a systematic thinking process before providing the final precise and accurate solutions. This requires engaging in a comprehensive cycle of analysis, summarizing, exploration, reassessment, reflection, backtracking, and iteration to develop well-considered thinking process. Please structure your response into two main sections: Thought and Solution using the specified format: <think> Thought section </think> Solution section. In the Thought section, detail your reasoning process in steps. Each step should include detailed considerations such as analysing questions, summarizing relevant findings, brainstorming new ideas, verifying the accuracy of the current steps, refining any errors, and revisiting previous steps. In the Solution section, based on various attempts, explorations, and reflections from the Thought section, systematically present the final solution that you deem correct. The Solution section should be logical, accurate, and concise and detail necessary steps needed to reach the conclusion.\\n\\n" -}}
            {%- else -%}
            {{- "You are a helpful AI assistant named SmolLM, trained by Hugging Face.\\n\\n" -}}
            {%- endif -%}

            {%- if xml_tools or python_tools or tools -%}
            {{- "### Tools\\n\\n" -}}
            {%- if xml_tools or tools -%}
            {%- if tools -%}
            {%- set xml_tools = tools -%}
            {%- endif -%}
            {%- set ns = namespace(xml_tool_string="You may call one or more functions to assist with the user query.\\nYou are provided with function signatures within <tools></tools> XML tags:\\n\\n<tools>\\n") -%}
            {%- for tool in xml_tools[:] -%} {# The slicing makes sure that xml_tools is a list #}
            {%- set ns.xml_tool_string = ns.xml_tool_string ~ (tool | string) ~ "\\n" -%}
            {%- endfor -%}
            {%- set xml_tool_string = ns.xml_tool_string + "</tools>\\n\\nFor each function call, return a json object with function name and arguments within <tool_call></tool_call> XML tags:\\n<tool_call>\\n{\\"name\\": <function-name>, \\"arguments\\": <args-json-object>}\\n</tool_call>" -%}
            {{- xml_tool_string -}}
            {%- endif -%}
            {%- if python_tools -%}
            {%- set ns = namespace(python_tool_string="When you send a message containing Python code between '<code>' and '</code>' tags, it will be executed in a stateful Jupyter notebook environment, and you will then be given the output to continued reasoning in an agentic loop.\\n\\nYou can use the following tools in your python code like regular functions:\\n<tools>\\n") -%}
            {%- for tool in python_tools[:] -%} {# The slicing makes sure that python_tools is a list #}
            {%- set ns.python_tool_string = ns.python_tool_string ~ (tool | string) ~ "\\n" -%}
            {%- endfor -%}
            {%- set python_tool_string = ns.python_tool_string + "</tools>\\n\\nThe state persists between code executions: so variables that you define in one step are still available thereafter." -%}
            {{- python_tool_string -}}
            {%- endif -%}
            {{- "\\n\\n" -}}
            {{- "<|im_end|>\\n" -}}
            {%- endif -%}
            {%- endif -%}
            {# ───── main loop ───── #}
            {%- for message in messages -%}
            {%- set content = message.content if message.content is string else "" -%}
            {%- if message.role == "user" -%}
            {{ "<|im_start|>" + message.role + "\\n" + content + "<|im_end|>\\n" }}
            {%- elif message.role == "assistant" -%}
            {% generation %}
            {%- if reasoning_mode == "/think" -%}
            {{ "<|im_start|>assistant\\n" + content.lstrip("\\n") + "<|im_end|>\\n" }}
            {%- else -%}
            {{ "<|im_start|>assistant\\n" + "<think>\\n\\n</think>\\n" + content.lstrip("\\n") + "<|im_end|>\\n" }}
            {%- endif -%}
            {% endgeneration %}
            {%- elif message.role == "tool" -%}
            {{ "<|im_start|>" + "user\\n" + content + "<|im_end|>\\n" }}
            {%- endif -%}
            {%- endfor -%}
            {# ───── generation prompt ───── #}
            {%- if add_generation_prompt -%}
            {%- if reasoning_mode == "/think" -%}
            {{ "<|im_start|>assistant\\n" }}
            {%- else -%}
            {{ "<|im_start|>assistant\\n" + "<think>\\n\\n</think>\\n" }}
            {%- endif -%}
            {%- endif -%}
            """
        let template = try Template(string, with: options)

        var context = Self.messages
        context["add_generation_prompt"] = .boolean(false)

        let result = try template.render(context)
        let target = """
            <|im_start|>system
            ## Metadata

            Knowledge Cutoff Date: June 2025
            Today Date: \(try Globals.strftimeNow([.string("%d %B %Y")], [:], .init()))
            Reasoning Mode: /think

            ## Custom Instructions

            You are a helpful AI assistant named SmolLM, trained by Hugging Face. Your role as an assistant involves thoroughly exploring questions through a systematic thinking process before providing the final precise and accurate solutions. This requires engaging in a comprehensive cycle of analysis, summarizing, exploration, reassessment, reflection, backtracking, and iteration to develop well-considered thinking process. Please structure your response into two main sections: Thought and Solution using the specified format: <think> Thought section </think> Solution section. In the Thought section, detail your reasoning process in steps. Each step should include detailed considerations such as analysing questions, summarizing relevant findings, brainstorming new ideas, verifying the accuracy of the current steps, refining any errors, and revisiting previous steps. In the Solution section, based on various attempts, explorations, and reflections from the Thought section, systematically present the final solution that you deem correct. The Solution section should be logical, accurate, and concise and detail necessary steps needed to reach the conclusion.

            <|im_start|>user
            Hello, how are you?<|im_end|>
            <|im_start|>assistant
            I'm doing great. How can I help you today?<|im_end|>
            <|im_start|>user
            I'd like to show off how chat templating works!<|im_end|>
            """

        #expect(
            result.trimmingCharacters(in: .whitespacesAndNewlines)
                == target.trimmingCharacters(in: .whitespacesAndNewlines)
        )
    }

    @Test("HuggingFaceTB SmolLM3-3B with generation prompt")
    func huggingFaceTBSmolLM3_3BWithGenerationPrompt() throws {
        let string = """
            {%- if enable_thinking is not defined -%}
            {%- set enable_thinking = true -%}
            {%- endif -%}

            {# ───── reasoning mode ───── #}
            {%- if enable_thinking -%}
            {%- set reasoning_mode = "/think" -%}
            {%- else -%}
            {%- set reasoning_mode = "/no_think" -%}
            {%- endif -%}

            {# ───── header (system message) ───── #}
            {{- "<|im_start|>system\\n" -}}

            {%- if messages[0].role == "system" -%}
            {%- set system_message = messages[0].content -%}
            {%- if "/no_think" in system_message -%}
            {%- set reasoning_mode = "/no_think" -%}
            {%- elif "/think" in system_message -%}
            {%- set reasoning_mode = "/think" -%}
            {%- endif -%}
            {%- set custom_instructions = system_message.replace("/no_think", "").replace("/think", "").rstrip() -%}
            {%- endif -%}

            {%- if "/system_override" in system_message -%}
            {{- custom_instructions.replace("/system_override", "").rstrip() -}}
            {{- "<|im_end|>\\n" -}}
            {%- else -%}
            {{- "## Metadata\\n\\n" -}}
            {{- "Knowledge Cutoff Date: June 2025\\n" -}}
            {%- set today = strftime_now("%d %B %Y") -%}
            {{- "Today Date: " ~ today ~ "\\n" -}}
            {{- "Reasoning Mode: " + reasoning_mode + "\\n\\n" -}}

            {{- "## Custom Instructions\\n\\n" -}}
            {%- if custom_instructions -%}
            {{- custom_instructions + "\\n\\n" -}}
            {%- elif reasoning_mode == "/think" -%}
            {{- "You are a helpful AI assistant named SmolLM, trained by Hugging Face. Your role as an assistant involves thoroughly exploring questions through a systematic thinking process before providing the final precise and accurate solutions. This requires engaging in a comprehensive cycle of analysis, summarizing, exploration, reassessment, reflection, backtracking, and iteration to develop well-considered thinking process. Please structure your response into two main sections: Thought and Solution using the specified format: <think> Thought section </think> Solution section. In the Thought section, detail your reasoning process in steps. Each step should include detailed considerations such as analysing questions, summarizing relevant findings, brainstorming new ideas, verifying the accuracy of the current steps, refining any errors, and revisiting previous steps. In the Solution section, based on various attempts, explorations, and reflections from the Thought section, systematically present the final solution that you deem correct. The Solution section should be logical, accurate, and concise and detail necessary steps needed to reach the conclusion.\\n\\n" -}}
            {%- else -%}
            {{- "You are a helpful AI assistant named SmolLM, trained by Hugging Face.\\n\\n" -}}
            {%- endif -%}

            {%- if xml_tools or python_tools or tools -%}
            {{- "### Tools\\n\\n" -}}
            {%- if xml_tools or tools -%}
            {%- if tools -%}
            {%- set xml_tools = tools -%}
            {%- endif -%}
            {%- set ns = namespace(xml_tool_string="You may call one or more functions to assist with the user query.\\nYou are provided with function signatures within <tools></tools> XML tags:\\n\\n<tools>\\n") -%}
            {%- for tool in xml_tools[:] -%} {# The slicing makes sure that xml_tools is a list #}
            {%- set ns.xml_tool_string = ns.xml_tool_string ~ (tool | string) ~ "\\n" -%}
            {%- endfor -%}
            {%- set xml_tool_string = ns.xml_tool_string + "</tools>\\n\\nFor each function call, return a json object with function name and arguments within <tool_call></tool_call> XML tags:\\n<tool_call>\\n{\\"name\\": <function-name>, \\"arguments\\": <args-json-object>}\\n</tool_call>" -%}
            {{- xml_tool_string -}}
            {%- endif -%}
            {%- if python_tools -%}
            {%- set ns = namespace(python_tool_string="When you send a message containing Python code between '<code>' and '</code>' tags, it will be executed in a stateful Jupyter notebook environment, and you will then be given the output to continued reasoning in an agentic loop.\\n\\nYou can use the following tools in your python code like regular functions:\\n<tools>\\n") -%}
            {%- for tool in python_tools[:] -%} {# The slicing makes sure that python_tools is a list #}
            {%- set ns.python_tool_string = ns.python_tool_string ~ (tool | string) ~ "\\n" -%}
            {%- endfor -%}
            {%- set python_tool_string = ns.python_tool_string + "</tools>\\n\\nThe state persists between code executions: so variables that you define in one step are still available thereafter." -%}
            {{- python_tool_string -}}
            {%- endif -%}
            {{- "\\n\\n" -}}
            {{- "<|im_end|>\\n" -}}
            {%- endif -%}
            {%- endif -%}
            {# ───── main loop ───── #}
            {%- for message in messages -%}
            {%- set content = message.content if message.content is string else "" -%}
            {%- if message.role == "user" -%}
            {{ "<|im_start|>" + message.role + "\\n" + content + "<|im_end|>\\n" }}
            {%- elif message.role == "assistant" -%}
            {% generation %}
            {%- if reasoning_mode == "/think" -%}
            {{ "<|im_start|>assistant\\n" + content.lstrip("\\n") + "<|im_end|>\\n" }}
            {%- else -%}
            {{ "<|im_start|>assistant\\n" + "<think>\\n\\n</think>\\n" + content.lstrip("\\n") + "<|im_end|>\\n" }}
            {%- endif -%}
            {% endgeneration %}
            {%- elif message.role == "tool" -%}
            {{ "<|im_start|>" + "user\\n" + content + "<|im_end|>\\n" }}
            {%- endif -%}
            {%- endfor -%}
            {# ───── generation prompt ───── #}
            {%- if add_generation_prompt -%}
            {%- if reasoning_mode == "/think" -%}
            {{ "<|im_start|>assistant\\n" }}
            {%- else -%}
            {{ "<|im_start|>assistant\\n" + "<think>\\n\\n</think>\\n" }}
            {%- endif -%}
            {%- endif -%}
            """
        let template = try Template(string, with: options)

        var context = Self.messages
        context["add_generation_prompt"] = .boolean(true)

        let result = try template.render(context)
        let target = """
            <|im_start|>system
            ## Metadata

            Knowledge Cutoff Date: June 2025
            Today Date: \(try Globals.strftimeNow([.string("%d %B %Y")], [:], .init()))
            Reasoning Mode: /think

            ## Custom Instructions

            You are a helpful AI assistant named SmolLM, trained by Hugging Face. Your role as an assistant involves thoroughly exploring questions through a systematic thinking process before providing the final precise and accurate solutions. This requires engaging in a comprehensive cycle of analysis, summarizing, exploration, reassessment, reflection, backtracking, and iteration to develop well-considered thinking process. Please structure your response into two main sections: Thought and Solution using the specified format: <think> Thought section </think> Solution section. In the Thought section, detail your reasoning process in steps. Each step should include detailed considerations such as analysing questions, summarizing relevant findings, brainstorming new ideas, verifying the accuracy of the current steps, refining any errors, and revisiting previous steps. In the Solution section, based on various attempts, explorations, and reflections from the Thought section, systematically present the final solution that you deem correct. The Solution section should be logical, accurate, and concise and detail necessary steps needed to reach the conclusion.

            <|im_start|>user
            Hello, how are you?<|im_end|>
            <|im_start|>assistant
            I'm doing great. How can I help you today?<|im_end|>
            <|im_start|>user
            I'd like to show off how chat templating works!<|im_end|>
            <|im_start|>assistant
            """

        #expect(
            result.trimmingCharacters(in: .whitespacesAndNewlines)
                == target.trimmingCharacters(in: .whitespacesAndNewlines)
        )
    }
}
