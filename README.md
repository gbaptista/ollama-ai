# Ollama AI

A Ruby gem for interacting with [Ollama](https://ollama.ai)'s API that allows you to run open source AI LLMs (Large Language Models) locally.

![The image presents a llama's head merged with a red ruby gemstone against a light beige background. The red facets form both the ruby and the contours of the llama, creating a clever visual fusion.](https://raw.githubusercontent.com/gbaptista/assets/main/ollama-ai/ollama-ai-canvas.png)

> _This Gem is designed to provide low-level access to Ollama, enabling people to build abstractions on top of it. If you are interested in more high-level abstractions or more user-friendly tools, you may want to consider [Nano Bots](https://github.com/icebaker/ruby-nano-bots) 💎 🤖._

## TL;DR and Quick Start

```ruby
gem 'ollama-ai', '~> 1.3.0'
```

```ruby
require 'ollama-ai'

client = Ollama.new(
  credentials: { address: 'http://localhost:11434' },
  options: { server_sent_events: true }
)

result = client.generate(
  { model: 'llama2',
    prompt: 'Hi!' }
)
```

Result:
```ruby
[{ 'model' => 'llama2',
   'created_at' => '2024-01-07T01:34:02.088810408Z',
   'response' => 'Hello',
   'done' => false },
 { 'model' => 'llama2',
   'created_at' => '2024-01-07T01:34:02.419045606Z',
   'response' => '!',
   'done' => false },
 # ..
 { 'model' => 'llama2',
   'created_at' => '2024-01-07T01:34:07.680049831Z',
   'response' => '?',
   'done' => false },
 { 'model' => 'llama2',
   'created_at' => '2024-01-07T01:34:07.872170352Z',
   'response' => '',
   'done' => true,
   'context' =>
     [518, 25_580,
      # ...
      13_563, 29_973],
   'total_duration' => 11_653_781_127,
   'load_duration' => 1_186_200_439,
   'prompt_eval_count' => 22,
   'prompt_eval_duration' => 5_006_751_000,
   'eval_count' => 25,
   'eval_duration' => 5_453_058_000 }]
```

## Index

- [TL;DR and Quick Start](#tldr-and-quick-start)
- [Index](#index)
- [Setup](#setup)
  - [Installing](#installing)
- [Usage](#usage)
  - [Client](#client)
    - [Bearer Authentication](#bearer-authentication)
  - [Methods](#methods)
    - [generate: Generate a completion](#generate-generate-a-completion)
      - [Without Streaming Events](#without-streaming-events)
      - [Receiving Stream Events](#receiving-stream-events)
    - [chat: Generate a chat completion](#chat-generate-a-chat-completion)
      - [Back-and-Forth Conversations](#back-and-forth-conversations)
    - [embeddings: Generate Embeddings](#embeddings-generate-embeddings)
    - [Models](#models)
      - [create: Create a Model](#create-create-a-model)
      - [tags: List Local Models](#tags-list-local-models)
      - [show: Show Model Information](#show-show-model-information)
      - [copy: Copy a Model](#copy-copy-a-model)
      - [delete: Delete a Model](#delete-delete-a-model)
      - [pull: Pull a Model](#pull-pull-a-model)
      - [push: Push a Model](#push-push-a-model)
  - [Modes](#modes)
    - [Text](#text)
    - [Image](#image)
  - [Streaming and Server-Sent Events (SSE)](#streaming-and-server-sent-events-sse)
    - [Server-Sent Events (SSE) Hang](#server-sent-events-sse-hang)
  - [New Functionalities and APIs](#new-functionalities-and-apis)
  - [Request Options](#request-options)
    - [Adapter](#adapter)
    - [Timeout](#timeout)
  - [Error Handling](#error-handling)
    - [Rescuing](#rescuing)
    - [For Short](#for-short)
    - [Errors](#errors)
- [Development](#development)
  - [Purpose](#purpose)
  - [Publish to RubyGems](#publish-to-rubygems)
  - [Updating the README](#updating-the-readme)
- [Resources and References](#resources-and-references)
- [Disclaimer](#disclaimer)

## Setup

### Installing

```sh
gem install ollama-ai -v 1.3.0
```

```sh
gem 'ollama-ai', '~> 1.3.0'
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

#### Bearer Authentication

```ruby
require 'ollama-ai'

client = Ollama.new(
  credentials: {
    address: 'http://localhost:11434',
    bearer_token: 'eyJhbG...Qssw5c'
  },
  options: { server_sent_events: true }
)
```

Remember that hardcoding your credentials in code is unsafe. It's preferable to use environment variables:

```ruby
require 'ollama-ai'

client = Ollama.new(
  credentials: {
    address: 'http://localhost:11434',
    bearer_token: ENV['OLLAMA_BEARER_TOKEN']
  },
  options: { server_sent_events: true }
)
```

#### Basic Authentication

This accepts a string in the format `username:password`:

```ruby
require 'ollama-ai'

client = Ollama.new(
  credentials: {
    address: 'http://localhost:11434',
    basic_auth: 'usrname:passwd'
  },
  options: { server_sent_events: true }
)
```

We also accept a hash with the keys `username` and `password`:

```ruby
require 'ollama-ai'

client = Ollama.new(
  credentials: {
    address: 'http://localhost:11434',
    basic_auth: { username: 'usrname', password: 'passwd' }
  },
  options: { server_sent_events: true }
)
```

Remember that hardcoding your credentials in code is unsafe. It's preferable to use environment variables:

```ruby
require 'ollama-ai'

client = Ollama.new(
  credentials: {
    address: 'http://localhost:11434',
    basic_auth: 'ENV['OLLAMA_USERNAME']:ENV['OLLAMA_PASSWORD']'
  },
  options: { server_sent_events: true }
)
```

```ruby
require 'ollama-ai'

client = Ollama.new(
  credentials: {
    address: 'http://localhost:11434',
    basic_auth: { username: ENV['OLLAMA_USERNAME'], password: ENV['OLLAMA_PASSWORD'] }
  },
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
  { model: 'llama2',
    prompt: 'Hi!',
    stream: false }
)
```

Result:
```ruby
[{ 'model' => 'llama2',
   'created_at' => '2024-01-07T01:35:41.951371247Z',
   'response' => "Hi there! It's nice to meet you. How are you today?",
   'done' => true,
   'context' =>
     [518, 25_580,
      # ...
      9826, 29_973],
   'total_duration' => 6_981_097_576,
   'load_duration' => 625_053,
   'prompt_eval_count' => 22,
   'prompt_eval_duration' => 4_075_171_000,
   'eval_count' => 16,
   'eval_duration' => 2_900_325_000 }]
```

##### Receiving Stream Events

API Documentation: https://github.com/jmorganca/ollama/blob/main/docs/api.md#generate-a-completion

Ensure that you have enabled [Server-Sent Events](#streaming-and-server-sent-events-sse) before using blocks for streaming. `stream: true` is not necessary, as `true` is the [default](https://github.com/jmorganca/ollama/blob/main/docs/api.md#generate-a-completion):

```ruby
client.generate(
  { model: 'llama2',
    prompt: 'Hi!' }
) do |event, raw|
  puts event
end
```

Event:
```ruby
{ 'model' => 'llama2',
  'created_at' => '2024-01-07T01:36:30.665245712Z',
  'response' => 'Hello',
  'done' => false }
```

You can get all the receive events at once as an array:
```ruby
result = client.generate(
  { model: 'llama2',
    prompt: 'Hi!' }
)
```

Result:
```ruby
[{ 'model' => 'llama2',
   'created_at' => '2024-01-07T01:36:30.665245712Z',
   'response' => 'Hello',
   'done' => false },
 { 'model' => 'llama2',
   'created_at' => '2024-01-07T01:36:30.927337136Z',
   'response' => '!',
   'done' => false },
 # ...
 { 'model' => 'llama2',
   'created_at' => '2024-01-07T01:36:37.249416767Z',
   'response' => '?',
   'done' => false },
 { 'model' => 'llama2',
   'created_at' => '2024-01-07T01:36:37.44041283Z',
   'response' => '',
   'done' => true,
   'context' =>
     [518, 25_580,
      # ...
      13_563, 29_973],
   'total_duration' => 10_551_395_645,
   'load_duration' => 966_631,
   'prompt_eval_count' => 22,
   'prompt_eval_duration' => 4_034_990_000,
   'eval_count' => 25,
   'eval_duration' => 6_512_954_000 }]
```

You can mix both as well:
```ruby
result = client.generate(
  { model: 'llama2',
    prompt: 'Hi!' }
) do |event, raw|
  puts event
end
```

#### chat: Generate a chat completion

API Documentation: https://github.com/jmorganca/ollama/blob/main/docs/api.md#generate-a-chat-completion

```ruby
result = client.chat(
  { model: 'llama2',
    messages: [
      { role: 'user', content: 'Hi! My name is Purple.' }
    ] }
) do |event, raw|
  puts event
end
```

Event:
```ruby
{ 'model' => 'llama2',
  'created_at' => '2024-01-07T01:38:01.729897311Z',
  'message' => { 'role' => 'assistant', 'content' => "\n" },
  'done' => false }
```

Result:
```ruby
[{ 'model' => 'llama2',
   'created_at' => '2024-01-07T01:38:01.729897311Z',
   'message' => { 'role' => 'assistant', 'content' => "\n" },
   'done' => false },
 { 'model' => 'llama2',
   'created_at' => '2024-01-07T01:38:02.081494506Z',
   'message' => { 'role' => 'assistant', 'content' => '*' },
   'done' => false },
 # ...
 { 'model' => 'llama2',
   'created_at' => '2024-01-07T01:38:17.855905499Z',
   'message' => { 'role' => 'assistant', 'content' => '?' },
   'done' => false },
 { 'model' => 'llama2',
   'created_at' => '2024-01-07T01:38:18.07331245Z',
   'message' => { 'role' => 'assistant', 'content' => '' },
   'done' => true,
   'total_duration' => 22_494_544_502,
   'load_duration' => 4_224_600,
   'prompt_eval_count' => 28,
   'prompt_eval_duration' => 6_496_583_000,
   'eval_count' => 61,
   'eval_duration' => 15_991_728_000 }]
```

##### Back-and-Forth Conversations

API Documentation: https://github.com/jmorganca/ollama/blob/main/docs/api.md#generate-a-chat-completion

To maintain a back-and-forth conversation, you need to append the received responses and build a history for your requests:

```ruby
result = client.chat(
  { model: 'llama2',
    messages: [
      { role: 'user', content: 'Hi! My name is Purple.' },
      { role: 'assistant',
        content: 'Hi, Purple!' },
      { role: 'user', content: "What's my name?" }
    ] }
) do |event, raw|
  puts event
end
```

Event:

```ruby
{ 'model' => 'llama2',
  'created_at' => '2024-01-07T01:40:07.352998498Z',
  'message' => { 'role' => 'assistant', 'content' => ' Pur' },
  'done' => false }
```

Result:
```ruby
[{ 'model' => 'llama2',
   'created_at' => '2024-01-07T01:40:06.562939469Z',
   'message' => { 'role' => 'assistant', 'content' => 'Your' },
   'done' => false },
 # ...
 { 'model' => 'llama2',
   'created_at' => '2024-01-07T01:40:07.352998498Z',
   'message' => { 'role' => 'assistant', 'content' => ' Pur' },
   'done' => false },
 { 'model' => 'llama2',
   'created_at' => '2024-01-07T01:40:07.545323584Z',
   'message' => { 'role' => 'assistant', 'content' => 'ple' },
   'done' => false },
 { 'model' => 'llama2',
   'created_at' => '2024-01-07T01:40:07.77769408Z',
   'message' => { 'role' => 'assistant', 'content' => '!' },
   'done' => false },
 { 'model' => 'llama2',
   'created_at' => '2024-01-07T01:40:07.974165849Z',
   'message' => { 'role' => 'assistant', 'content' => '' },
   'done' => true,
   'total_duration' => 11_482_012_681,
   'load_duration' => 4_246_882,
   'prompt_eval_count' => 57,
   'prompt_eval_duration' => 10_387_150_000,
   'eval_count' => 6,
   'eval_duration' => 1_089_249_000 }]
```

#### embeddings: Generate Embeddings

API Documentation: https://github.com/jmorganca/ollama/blob/main/docs/api.md#generate-embeddings

```ruby
result = client.embeddings(
  { model: 'llama2',
    prompt: 'Hi!' }
)
```

Result:
```ruby
[{ 'embedding' =>
   [0.6970467567443848, -2.248202085494995,
    # ...
    -1.5994540452957153, -0.3464218080043793] }]
```

#### Models

##### create: Create a Model

API Documentation: https://github.com/jmorganca/ollama/blob/main/docs/api.md#create-a-model

```ruby
result = client.create(
  { name: 'mario',
    modelfile: "FROM llama2\nSYSTEM You are mario from Super Mario Bros." }
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

> _Woah! *adjusts sunglasses* It's-a me, Mario! *winks* You must be a new friend I've-a met here in the Mushroom Kingdom. *tips top hat* What brings you to this neck of the woods? Maybe you're looking for-a some help on your adventure? *nods* Just let me know, and I'll do my best to-a assist ya! 😃_

##### tags: List Local Models

API Documentation: https://github.com/jmorganca/ollama/blob/main/docs/api.md#list-local-models

```ruby
result = client.tags
```

Result:
```ruby
[{ 'models' =>
   [{ 'name' => 'llama2:latest',
      'modified_at' => '2024-01-06T15:06:23.6349195-03:00',
      'size' => 3_826_793_677,
      'digest' =>
      '78e26419b4469263f75331927a00a0284ef6544c1975b826b15abdaef17bb962',
      'details' =>
      { 'format' => 'gguf',
        'family' => 'llama',
        'families' => ['llama'],
        'parameter_size' => '7B',
        'quantization_level' => 'Q4_0' } },
    { 'name' => 'mario:latest',
      'modified_at' => '2024-01-06T22:41:59.495298101-03:00',
      'size' => 3_826_793_787,
      'digest' =>
      '291f46d2fa687dfaff45de96a8cb6e32707bc16ec1e1dfe8d65e9634c34c660c',
      'details' =>
      { 'format' => 'gguf',
        'family' => 'llama',
        'families' => ['llama'],
        'parameter_size' => '7B',
        'quantization_level' => 'Q4_0' } }] }]
```

##### show: Show Model Information

API Documentation: https://github.com/jmorganca/ollama/blob/main/docs/api.md#show-model-information

```ruby
result = client.show(
  { name: 'llama2' }
)
```

Result:
```ruby
[{ 'license' =>
     "LLAMA 2 COMMUNITY LICENSE AGREEMENT\t\n" \
     # ...
     "* Reporting violations of the Acceptable Use Policy or unlicensed uses of Llama..." \
     "\n",
   'modelfile' =>
     "# Modelfile generated by \"ollama show\"\n" \
     # ...
     'PARAMETER stop "<</SYS>>"',
   'parameters' =>
     "stop                           [INST]\n" \
     "stop                           [/INST]\n" \
     "stop                           <<SYS>>\n" \
     'stop                           <</SYS>>',
     'template' =>
     "[INST] <<SYS>>{{ .System }}<</SYS>>\n\n{{ .Prompt }} [/INST]\n",
   'details' =>
     { 'format' => 'gguf',
       'family' => 'llama',
       'families' => ['llama'],
       'parameter_size' => '7B',
       'quantization_level' => 'Q4_0' } }]
```

##### copy: Copy a Model

API Documentation: https://github.com/jmorganca/ollama/blob/main/docs/api.md#copy-a-model

```ruby
result = client.copy(
  { source: 'llama2',
    destination: 'llama2-backup' }
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
  { name: 'llama2' }
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
    { name: 'llama2' }
  )
rescue Ollama::Errors::OllamaError => error
  puts error.class # Ollama::Errors::RequestError
  puts error.message # 'the server responded with status 404'

  puts error.payload
  # { name: 'llama2',
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
  { name: 'llama2' }
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

### Modes

#### Text

You can use the [generate](#generate-generate-a-completion) or [chat](#chat-generate-a-chat-completion) methods for text.

#### Image

![A black and white image of an old piano. The piano is an upright model, with the keys on the right side of the image. The piano is sitting on a tiled floor. There is a small round object on the top of the piano.](https://raw.githubusercontent.com/gbaptista/assets/main/gemini-ai/piano.jpg)

> _Courtesy of [Unsplash](https://unsplash.com/photos/greyscale-photo-of-grand-piano-czPs0z3-Ggg)_

You need to choose a model that supports images, like [LLaVA](https://ollama.ai/library/llava) or [bakllava](https://ollama.ai/library/bakllava), and encode the image as [Base64](https://en.wikipedia.org/wiki/Base64).

Depending on your hardware, some models that support images can be slow, so you may want to increase the client [timeout](#timeout):

```ruby
client = Ollama.new(
  credentials: { address: 'http://localhost:11434' },
  options: {
    server_sent_events: true,
    connection: { request: { timeout: 120, read_timeout: 120 } } }
)
```

Using the `generate` method:

```ruby
require 'base64'

client.generate(
  { model: 'llava',
    prompt: 'Please describe this image.',
    images: [Base64.strict_encode64(File.read('piano.jpg'))] }
) do |event, raw|
  print event['response']
end
```

Output:
> _The image is a black and white photo of an old piano, which appears to be in need of maintenance. A chair is situated right next to the piano. Apart from that, there are no other objects or people visible in the scene._

Using the `chat` method:
```ruby
require 'base64'

result = client.chat(
  { model: 'llava',
    messages: [
      { role: 'user',
        content: 'Please describe this image.',
        images: [Base64.strict_encode64(File.read('piano.jpg'))] }
    ] }
) do |event, raw|
  puts event
end
```

Output:
> _The image displays an old piano, sitting on a wooden floor with black keys. Next to the piano, there is another keyboard in the scene, possibly used for playing music._
>
> _On top of the piano, there are two mice placed in different locations within its frame. These mice might be meant for controlling the music being played or simply as decorative items. The overall atmosphere seems to be focused on artistic expression through this unique instrument._

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
  { model: 'llama2',
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
  { model: 'llama2',
    prompt: 'Hi!' },
  request_method: 'POST', server_sent_events: true
)
```

### Request Options

#### Adapter

The gem uses [Faraday](https://github.com/lostisland/faraday) with the [Typhoeus](https://github.com/typhoeus/typhoeus) adapter by default.

You can use a different adapter if you want:

```ruby
require 'faraday/net_http'

client = Ollama.new(
  credentials: { address: 'http://localhost:11434' },
  options: { connection: { adapter: :net_http } }
)
```

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
    { model: 'llama2',
      prompt: 'Hi!' }
  )
rescue Ollama::Errors::OllamaError => error
  puts error.class # Ollama::Errors::RequestError
  puts error.message # 'the server responded with status 500'

  puts error.payload
  # { model: 'llama2',
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
    { model: 'llama2',
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

bundle exec ruby spec/tasks/run-client.rb
bundle exec ruby spec/tasks/test-encoding.rb
```

### Purpose

This Gem is designed to provide low-level access to Ollama, enabling people to build abstractions on top of it. If you are interested in more high-level abstractions or more user-friendly tools, you may want to consider [Nano Bots](https://github.com/icebaker/ruby-nano-bots) 💎 🤖.

### Publish to RubyGems

```bash
gem build ollama-ai.gemspec

gem signin

gem push ollama-ai-1.3.0.gem
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
