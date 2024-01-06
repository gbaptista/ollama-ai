# Ollama

A Ruby gem for interacting with [Ollama](https://github.com/jmorganca/ollama)'s API that allows you to run open source AI LLMs (Large Language Models) locally.

![The image presents a llama's head merged with a red ruby gemstone against a light beige background. The red facets form both the ruby and the contours of the llama, creating a clever visual fusion.](https://raw.githubusercontent.com/gbaptista/assets/main/ollama-ai/ollama-ai-canvas.png)

> _This Gem is designed to provide low-level access to Ollama, enabling people to build abstractions on top of it. If you are interested in more high-level abstractions or more user-friendly tools, you may want to consider [Nano Bots](https://github.com/icebaker/ruby-nano-bots) 💎 🤖._

## TL;DR and Quick Start

```ruby
gem 'ollama-ai', '~> 1.0.0'
```

```ruby
require 'ollama-ai'

client = Ollama.new(
  credentials: { address: 'http://localhost:11434' },
  options: { server_sent_events: true }
)

result = client.generate(
  { model: 'dolphin-phi',
    prompt: 'Hi!' }
)
```

Result:
```ruby
[{ 'model' => 'dolphin-phi',
   'created_at' => '2024-01-06T16:53:21.357816652Z',
   'response' => 'Hello',
   'done' => false },
 { 'model' => 'dolphin-phi',
   'created_at' => '2024-01-06T16:53:21.490053654Z',
   'response' => '!',
   'done' => false },
 # ...
 { 'model' => 'dolphin-phi',
   'created_at' => '2024-01-06T16:53:24.82505599Z',
   'response' => '.',
   'done' => false },
 { 'model' => 'dolphin-phi',
   'created_at' => '2024-01-06T16:53:24.956774721Z',
   'response' => '',
   'done' => true,
   'context' =>
     [50_296, 10_057,
      # ...
      1037, 13],
   'total_duration' => 5_702_027_026,
   'load_duration' => 649_711,
   'prompt_eval_count' => 25,
   'prompt_eval_duration' => 2_227_159_000,
   'eval_count' => 39,
   'eval_duration' => 3_466_593_000 }]
```

## Index

{index}

## Setup

### Installing

```sh
gem install ollama-ai -v 1.0.0
```

```sh
gem 'ollama-ai', '~> 1.0.0'
```

## Usage

### Client

Create a new client:
```ruby
require 'ollama-ai'

client = Ollama.new(
  credentials: { address: 'http://localhost:11434' },
  options: { server_sent_events: true }
)
```

### Methods

```ruby
client.generate
client.chat
client.embeddings

client.create
client.tags
client.show
client.copy
client.delete
client.pull
client.push
```

#### generate: Generate a completion

API Documentation: https://github.com/jmorganca/ollama/blob/main/docs/api.md#generate-a-completion

##### Without Streaming Events

API Documentation: https://github.com/jmorganca/ollama/blob/main/docs/api.md#generate-a-completion

```ruby
result = client.generate(
  { model: 'dolphin-phi',
    prompt: 'Hi!',
    stream: false }
)
```

Result:
```ruby
[{ 'model' => 'dolphin-phi',
   'created_at' => '2024-01-06T17:47:26.443128626Z',
   'response' =>
     "Hello! How can I assist you today? Do you have any questions or problems that you'd like help with?",
   'done' => true,
   'context' =>
     [50_296, 10_057,
      # ...
      351, 30],
   'total_duration' => 6_495_278_960,
   'load_duration' => 1_434_052_851,
   'prompt_eval_count' => 25,
   'prompt_eval_duration' => 1_938_861_000,
   'eval_count' => 23,
   'eval_duration' => 3_119_030_000 }]
```

##### Receiving Stream Events

API Documentation: https://github.com/jmorganca/ollama/blob/main/docs/api.md#generate-a-completion

Ensure that you have enabled [Server-Sent Events](#streaming-and-server-sent-events-sse) before using blocks for streaming. `stream: true` is not necessary, as `true` is the [default](https://github.com/jmorganca/ollama/blob/main/docs/api.md#generate-a-completion):

```ruby
client.generate(
  { model: 'dolphin-phi',
    prompt: 'Hi!' }
) do |event, raw|
  puts event
end
```

Event:
```ruby
{ 'model' => 'dolphin-phi',
  'created_at' => '2024-01-06T17:27:29.366879586Z',
  'response' => 'Hello',
  'done' => false }
```

You can get all the receive events at once as an array:
```ruby
result = client.generate(
  { model: 'dolphin-phi',
    prompt: 'Hi!' }
)
```

Result:
```ruby
[{ 'model' => 'dolphin-phi',
   'created_at' => '2024-01-06T16:53:21.357816652Z',
   'response' => 'Hello',
   'done' => false },
 { 'model' => 'dolphin-phi',
   'created_at' => '2024-01-06T16:53:21.490053654Z',
   'response' => '!',
   'done' => false },
 # ...
 { 'model' => 'dolphin-phi',
   'created_at' => '2024-01-06T16:53:24.82505599Z',
   'response' => '.',
   'done' => false },
 { 'model' => 'dolphin-phi',
   'created_at' => '2024-01-06T16:53:24.956774721Z',
   'response' => '',
   'done' => true,
   'context' =>
     [50_296, 10_057,
      # ...
      1037, 13],
   'total_duration' => 5_702_027_026,
   'load_duration' => 649_711,
   'prompt_eval_count' => 25,
   'prompt_eval_duration' => 2_227_159_000,
   'eval_count' => 39,
   'eval_duration' => 3_466_593_000 }]
```

You can mix both as well:
```ruby
result = client.generate(
  { model: 'dolphin-phi',
    prompt: 'Hi!' }
) do |event, raw|
  puts event
end
```

#### chat: Generate a chat completion

API Documentation: https://github.com/jmorganca/ollama/blob/main/docs/api.md#generate-a-chat-completion

```ruby
result = client.chat(
  { model: 'dolphin-phi',
    messages: [
      { role: 'user', content: 'Hi! My name is Purple.' }
    ] }
) do |event, raw|
  puts event
end
```

Event:
```ruby
{ 'model' => 'dolphin-phi',
  'created_at' => '2024-01-06T18:17:22.468231988Z',
  'message' => { 'role' => 'assistant', 'content' => 'Hello' },
  'done' => false }
```

Result:
```ruby
[{ 'model' => 'dolphin-phi',
   'created_at' => '2024-01-06T18:17:22.468231988Z',
   'message' => { 'role' => 'assistant', 'content' => 'Hello' },
   'done' => false },
 { 'model' => 'dolphin-phi',
   'created_at' => '2024-01-06T18:17:22.594414415Z',
   'message' => { 'role' => 'assistant', 'content' => ' Purple' },
   'done' => false },
 # ...
 { 'model' => 'dolphin-phi',
   'created_at' => '2024-01-06T18:17:25.491597233Z',
   'message' => { 'role' => 'assistant', 'content' => '?' },
   'done' => false },
 { 'model' => 'dolphin-phi',
   'created_at' => '2024-01-06T18:17:25.578463723Z',
   'message' => { 'role' => 'assistant', 'content' => '' },
   'done' => true,
   'total_duration' => 5_274_177_696,
   'load_duration' => 1_565_325,
   'prompt_eval_count' => 30,
   'prompt_eval_duration' => 2_284_638_000,
   'eval_count' => 29,
   'eval_duration' => 2_983_962_000 }]
```

##### Back-and-Forth Conversations

API Documentation: https://github.com/jmorganca/ollama/blob/main/docs/api.md#generate-a-chat-completion

To maintain a back-and-forth conversation, you need to append the received responses and build a history for your requests:

```ruby
result = client.chat(
  { model: 'dolphin-phi',
    messages: [
      { role: 'user', content: 'Hi! My name is Purple.' },
      { role: 'assistant',
        content: "Hi, Purple! It's nice to meet you. I am Dolphin. How can I help you today?" },
      { role: 'user', content: "What's my name?" }
    ] }
) do |event, raw|
  puts event
end
```

Event:

```ruby
{ 'model' => 'dolphin-phi',
  'created_at' => '2024-01-06T19:07:51.05465997Z',
  'message' => { 'role' => 'assistant', 'content' => 'Your' },
  'done' => false }
```

Result:
```ruby
[{ 'model' => 'dolphin-phi',
   'created_at' => '2024-01-06T19:07:51.05465997Z',
   'message' => { 'role' => 'assistant', 'content' => 'Your' },
   'done' => false },
 { 'model' => 'dolphin-phi',
   'created_at' => '2024-01-06T19:07:51.184476541Z',
   'message' => { 'role' => 'assistant', 'content' => ' name' },
   'done' => false },
 # ...
 { 'model' => 'dolphin-phi',
   'created_at' => '2024-01-06T19:07:56.526297223Z',
   'message' => { 'role' => 'assistant', 'content' => '.' },
   'done' => false },
 { 'model' => 'dolphin-phi',
   'created_at' => '2024-01-06T19:07:56.667809424Z',
   'message' => { 'role' => 'assistant', 'content' => '' },
   'done' => true,
   'total_duration' => 12_169_557_266,
   'load_duration' => 4_486_689,
   'prompt_eval_count' => 95,
   'prompt_eval_duration' => 6_678_566_000,
   'eval_count' => 40,
   'eval_duration' => 5_483_133_000 }]
```

#### embeddings: Generate Embeddings

API Documentation: https://github.com/jmorganca/ollama/blob/main/docs/api.md#generate-embeddings

```ruby
result = client.embeddings(
  { model: 'dolphin-phi',
    prompt: 'Hi!' }
)
```

Result:
```ruby
[{ 'embedding' =>
   [1.0372048616409302,
    1.0635842084884644,
    # ...
    -0.5416496396064758,
    0.051569778472185135] }]
```

#### Models

##### create: Create a Model

API Documentation: https://github.com/jmorganca/ollama/blob/main/docs/api.md#create-a-model

```ruby
result = client.create(
  { name: 'mario',
    modelfile: "FROM dolphin-phi\nSYSTEM You are mario from Super Mario Bros." }
) do |event, raw|
  puts event
end
```

Event:
```ruby
{ 'status' => 'reading model metadata' }
```

Result:
```ruby
[{ 'status' => 'reading model metadata' },
 { 'status' => 'creating system layer' },
 { 'status' =>
   'using already created layer sha256:4eca7304a07a42c48887f159ef5ad82ed5a5bd30fe52db4aadae1dd938e26f70' },
 { 'status' =>
   'using already created layer sha256:876a8d805b60882d53fed3ded3123aede6a996bdde4a253de422cacd236e33d3' },
 { 'status' =>
   'using already created layer sha256:a47b02e00552cd7022ea700b1abf8c572bb26c9bc8c1a37e01b566f2344df5dc' },
 { 'status' =>
   'using already created layer sha256:f02dd72bb2423204352eabc5637b44d79d17f109fdb510a7c51455892aa2d216' },
 { 'status' =>
   'writing layer sha256:1741cf59ce26ff01ac614d31efc700e21e44dd96aed60a7c91ab3f47e440ef94' },
 { 'status' =>
   'writing layer sha256:e8bcbb2eebad88c2fa64bc32939162c064be96e70ff36aff566718fc9186b427' },
 { 'status' => 'writing manifest' },
 { 'status' => 'success' }]
```

After creation, you can use it:
```ruby
client.generate(
  { model: 'mario',
    prompt: 'Hi! Who are you?' }
) do |event, raw|
  print event['response']
end
```

> _Hello! I'm Mario, a character from the popular video game series Super Mario Bros. My goal is to rescue Princess Peach from the evil Bowser and his minions, so we can live happily ever after in the Mushroom Kingdom! 🍄🐥_
> 
> _What brings you here? How can I help you on your journey?_

##### tags: List Local Models

API Documentation: https://github.com/jmorganca/ollama/blob/main/docs/api.md#list-local-models

```ruby
result = client.tags
```

Result:
```ruby
[{ 'models' =>
   [{ 'name' => 'dolphin-phi:latest',
      'modified_at' => '2024-01-06T12:20:42.778120982-03:00',
      'size' => 1_602_473_850,
      'digest' =>
       'c5761fc772409945787240af89a5cce01dd39dc52f1b7b80d080a1163e8dbe10',
      'details' =>
        { 'format' => 'gguf',
          'family' => 'phi2',
          'families' => ['phi2'],
          'parameter_size' => '3B',
          'quantization_level' => 'Q4_0' } },
    { 'name' => 'mario:latest',
      'modified_at' => '2024-01-06T16:19:11.340234644-03:00',
      'size' => 1_602_473_846,
      'digest' =>
        '582e668feaba3fcb6add3cee26046a1d6a0c940b86a692ea30d5100aec90135f',
      'details' =>
        { 'format' => 'gguf',
          'family' => 'phi2',
          'families' => ['phi2'],
          'parameter_size' => '3B',
          'quantization_level' => 'Q4_0' } }] }]
```

##### show: Show Model Information

API Documentation: https://github.com/jmorganca/ollama/blob/main/docs/api.md#show-model-information

```ruby
result = client.show(
  { name: 'dolphin-phi' }
)
```

Result:
```ruby
[{ 'license' =>
     "MICROSOFT RESEARCH LICENSE TERMS\n" \
     # ...
     'It also applies even if Microsoft knew or should have known about the possibility...',
   'modelfile' =>
     "# Modelfile generated by \"ollama show\"\n" \
     # ...
     'PARAMETER stop "<|im_end|>"',
   'parameters' =>
     "stop                           <|im_start|>\n" \
     'stop                           <|im_end|>',
   'template' =>
     "<|im_start|>system\n" \
     "{{ .System }}<|im_end|>\n" \
     "<|im_start|>user\n" \
     "{{ .Prompt }}<|im_end|>\n" \
     "<|im_start|>assistant\n",
   'system' => 'You are Dolphin, a helpful AI assistant.',
   'details' =>
     { 'format' => 'gguf',
       'family' => 'phi2',
       'families' => ['phi2'],
       'parameter_size' => '3B',
       'quantization_level' => 'Q4_0' } }]
```

##### copy: Copy a Model

API Documentation: https://github.com/jmorganca/ollama/blob/main/docs/api.md#copy-a-model

```ruby
result = client.copy(
  { source: 'dolphin-phi',
    destination: 'dolphin-phi-backup' }
)
```

Result:
```ruby
true
```

If the source model does not exist:
```ruby
begin
  result = client.copy(
    { source: 'purple',
      destination: 'purple-backup' }
  )
rescue Ollama::Errors::OllamaError => error
  puts error.class # Ollama::Errors::RequestError
  puts error.message # 'the server responded with status 404'

  puts error.payload
  # { source: 'purple',
  #   destination: 'purple-backup',
  #   ...
  # }

  puts error.request.inspect
  # #<Faraday::ResourceNotFound response={:status=>404, :headers...
end
```

##### delete: Delete a Model

API Documentation: https://github.com/jmorganca/ollama/blob/main/docs/api.md#delete-a-model

```ruby
result = client.delete(
  { name: 'dolphin-phi' }
)
```

Result:
```ruby
true
```

If the model does not exist:
```ruby
begin
  result = client.delete(
    { name: 'dolphin-phi' }
  )
rescue Ollama::Errors::OllamaError => error
  puts error.class # Ollama::Errors::RequestError
  puts error.message # 'the server responded with status 404'

  puts error.payload
  # { name: 'dolphin-phi',
  #   ...
  # }

  puts error.request.inspect
  # #<Faraday::ResourceNotFound response={:status=>404, :headers...
end
```

##### pull: Pull a Model

API Documentation: https://github.com/jmorganca/ollama/blob/main/docs/api.md#pull-a-model

```ruby
result = client.pull(
  { name: 'dolphin-phi' }
) do |event, raw|
  puts event
end
```

Event:
```ruby
{ 'status' => 'pulling manifest' }
```

Result:
```ruby
[{ 'status' => 'pulling manifest' },
 { 'status' => 'pulling 4eca7304a07a',
   'digest' =>
   'sha256:4eca7304a07a42c48887f159ef5ad82ed5a5bd30fe52db4aadae1dd938e26f70',
   'total' => 1_602_463_008,
   'completed' => 1_602_463_008 },
 # ...
 { 'status' => 'verifying sha256 digest' },
 { 'status' => 'writing manifest' },
 { 'status' => 'removing any unused layers' },
 { 'status' => 'success' }]
```

##### push: Push a Model

Documentation: [API](https://github.com/jmorganca/ollama/blob/main/docs/api.md#push-a-model) and [_Publishing Your Model_](https://github.com/jmorganca/ollama/blob/main/docs/import.md#publishing-your-model-optional--early-alpha).


You need to create an account at https://ollama.ai and add your Public Key at https://ollama.ai/settings/keys.

Your keys are located in `/usr/share/ollama/.ollama/`. You may need to copy them to your user directory:

```sh
sudo cp /usr/share/ollama/.ollama/id_ed25519 ~/.ollama/
sudo cp /usr/share/ollama/.ollama/id_ed25519.pub ~/.ollama/
```

Copy your model to your user namespace:

```ruby
client.copy(
  { source: 'mario',
    destination: 'your-user/mario' }
)
```

And push it:

```ruby
result = client.push(
  { name: 'your-user/mario' }
) do |event, raw|
  puts event
end
```

Event:
```ruby
{ 'status' => 'retrieving manifest' }
```

Result:
```ruby
[{ 'status' => 'retrieving manifest' },
 { 'status' => 'pushing 4eca7304a07a',
   'digest' =>
   'sha256:4eca7304a07a42c48887f159ef5ad82ed5a5bd30fe52db4aadae1dd938e26f70',
   'total' => 1_602_463_008,
   'completed' => 1_602_463_008 },
 # ...
 { 'status' => 'pushing e8bcbb2eebad',
   'digest' =>
   'sha256:e8bcbb2eebad88c2fa64bc32939162c064be96e70ff36aff566718fc9186b427',
   'total' => 555,
   'completed' => 555 },
 { 'status' => 'pushing manifest' },
 { 'status' => 'success' }]
```

### Streaming and Server-Sent Events (SSE)

[Server-Sent Events (SSE)](https://en.wikipedia.org/wiki/Server-sent_events) is a technology that allows certain endpoints to offer streaming capabilities, such as creating the impression that "the model is typing along with you," rather than delivering the entire answer all at once.

You can set up the client to use Server-Sent Events (SSE) for all supported endpoints:
```ruby
client = Ollama.new(
  credentials: { address: 'http://localhost:11434' },
  options: { server_sent_events: true }
)
```

Or, you can decide on a request basis:
```ruby
result = client.generate(
  { model: 'dolphin-phi',
    prompt: 'Hi!' },
  server_sent_events: true
) do |event, raw|
  puts event
end
```

With Server-Sent Events (SSE) enabled, you can use a block to receive partial results via events. This feature is particularly useful for methods that offer streaming capabilities, such as `generate`: [Receiving Stream Events](#receiving-stream-events)

#### Server-Sent Events (SSE) Hang

Method calls will _hang_ until the server-sent events finish, so even without providing a block, you can obtain the final results of the received events: [Receiving Stream Events](#receiving-stream-events)

### New Functionalities and APIs

Ollama may launch a new endpoint that we haven't covered in the Gem yet. If that's the case, you may still be able to use it through the `request` method. For example, `generate` is just a wrapper for `api/generate`, which you can call directly like this:

```ruby
result = client.request(
  'api/generate',
  { model: 'dolphin-phi',
    prompt: 'Hi!' },
  request_method: 'POST', server_sent_events: true
)
```

### Request Options

#### Timeout

You can set the maximum number of seconds to wait for the request to complete with the `timeout` option:

```ruby
client = Ollama.new(
  credentials: { address: 'http://localhost:11434' },
  options: { connection: { request: { timeout: 5 } } }
)
```

You can also have more fine-grained control over [Faraday's Request Options](https://lostisland.github.io/faraday/#/customization/request-options?id=request-options) if you prefer:

```ruby
client = Ollama.new(
  credentials: { address: 'http://localhost:11434' },
  options: {
    connection: {
      request: {
        timeout: 5,
        open_timeout: 5,
        read_timeout: 5,
        write_timeout: 5
      }
    }
  }
)
```

### Error Handling

#### Rescuing

```ruby
require 'ollama-ai'

begin
  client.chat_completions(
    { model: 'dolphin-phi',
      prompt: 'Hi!' }
  )
rescue Ollama::Errors::OllamaError => error
  puts error.class # Ollama::Errors::RequestError
  puts error.message # 'the server responded with status 500'

  puts error.payload
  # { model: 'dolphin-phi',
  #   prompt: 'Hi!',
  #   ...
  # }

  puts error.request.inspect
  # #<Faraday::ServerError response={:status=>500, :headers...
end
```

#### For Short

```ruby
require 'ollama-ai/errors'

begin
  client.chat_completions(
    { model: 'dolphin-phi',
      prompt: 'Hi!' }
  )
rescue OllamaError => error
  puts error.class # Ollama::Errors::RequestError
end
```

#### Errors

```ruby
OllamaError

BlockWithoutServerSentEventsError

RequestError
```

## Development

```bash
bundle
rubocop -A
```

### Purpose

This Gem is designed to provide low-level access to Ollama, enabling people to build abstractions on top of it. If you are interested in more high-level abstractions or more user-friendly tools, you may want to consider [Nano Bots](https://github.com/icebaker/ruby-nano-bots) 💎 🤖.

### Publish to RubyGems

```bash
gem build ollama-ai.gemspec

gem signin

gem push ollama-ai-1.0.0.gem
```

### Updating the README

Install [Babashka](https://babashka.org):

```sh
curl -s https://raw.githubusercontent.com/babashka/babashka/master/install | sudo bash
```

Update the `template.md` file and then:

```sh
bb tasks/generate-readme.clj
```

Trick for automatically updating the `README.md` when `template.md` changes:

```sh
sudo pacman -S inotify-tools # Arch / Manjaro
sudo apt-get install inotify-tools # Debian / Ubuntu / Raspberry Pi OS
sudo dnf install inotify-tools # Fedora / CentOS / RHEL

while inotifywait -e modify template.md; do bb tasks/generate-readme.clj; done
```

Trick for Markdown Live Preview:
```sh
pip install -U markdown_live_preview

mlp README.md -p 8076
```

## Resources and References

These resources and references may be useful throughout your learning process:

- [Ollama Official Website](https://ollama.ai)
- [Ollama GitHub](https://github.com/jmorganca/ollama)
- [Ollama API Documentation](https://github.com/jmorganca/ollama/blob/main/docs/api.md)

## Disclaimer

This is not an official Ollama project, nor is it affiliated with Ollama in any way.

This software is distributed under the [MIT License](https://github.com/gbaptista/ollama-ai/blob/main/LICENSE). This license includes a disclaimer of warranty. Moreover, the authors assume no responsibility for any damage or costs that may result from using this project. Use the Ollama AI Ruby Gem at your own risk.
