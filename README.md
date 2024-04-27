# Elixir Pods

This is a simple proof of concept.
The idea is emulating [Babashka Pods](https://github.com/babashka/pods/).

_Elixir Pods_ enables using external services that can be writen in any programming language.
It's not required that the program has a _CLI_, since a script is created that interacts with the internal _SDK_.
_Elixir Pods_ are standalone programs that can expose namespaces with vars to _Elixir_.

The example is taken from [LispyClouds SQLite](https://github.com/babashka/pods/tree/master/examples/pod-lispyclouds-sqlite)
a simple `sqlite3` wrapper that can execute commands, programmed in _python_.

Example usage:

You can check the [Example Project](pods_example_project) to see how
can _Pods_ be implemented in an Elixir Project.

```elixir
Pods.Core.start(
  # Available Pods List
  [Pod.LispyClouds.SQLite],
  # Pod Manager
  Pods.ProcessManager,
  # Message Encoder
  PodsExampleProject.Encoder,
  # Message Decoder
  PodsExampleProject.Decoder,
  # stdout and stderr handler
  PodsExampleProject.Handler
)
|> Pod.LispyClouds.SQLite.execute!("create table if not exists foo ( int foo )")
|> Pod.LispyClouds.SQLite.execute!("delete from foo")
|> Pod.LispyClouds.SQLite.execute!("insert into foo values (1), (2)")
|> Pod.LispyClouds.SQLite.execute!("select * from foo")
```

Note how every component is fully customizable, so you can implement
those with your own tools and configurations.

An _Elixir Pod_ must follow some simple rules:

- An infinite function (`while true`).
- Reads from `stdin` (in streaming mode).
- Writes to `stdout` and `stderr`.
- Follows [Babashka Pods](https://github.com/babashka/pods/) format.
- At least implements the `describe` and `invoke` operators.
- Encodes messages with [bencode](https://en.wikipedia.org/wiki/Bencode).
- Encodes payload with _JSON_ (or transit+json).

### Example Codes

- [LispyClouds SQLite Python Pod](pod_lispyclouds_sqlite): A Pod made in Python
- [Pods Core](pods_core): Handles the boilerplate for a Pod Client
- [Pod Process Manager]: Handles `stdio` and starts the Pods services.
- [Pods Example Project]: Implements the encoder, decoder, handler and initial config for the core, process manager and pods.

### Why?

Elixir Pods system lets you interact with external processes using _Elixir_ functions, as opposed to shelling out with `System.cmd`, `Erlang Ports` or making HTTP requests, or something like that. Those external processes are called pods and must implement the pod protocol to tell client programs how to interact with them.

- https://www.youtube.com/watch?v=Q3EFNRwxLLo
- https://www.braveclojure.com/quests/babooka/
- https://book.babashka.org/

#### Is this gRPC?

Good question. Surely other similar protocols can be used
for calling different technologies and expose their awesome features.

This is another alternative that uses standarized and battle tested tools
such as `stdout`, `stderr`, `stdin` and `mix`.

The communication is handled by using

- Bencode (Used by Bitorrent) so messages in `stdio` are more lightweight than raw text.
- JSON.

The main idea is simplying the distribution of ready to use `pods`,
for technologies that:

1. Are not available as _CLI_ or it needs custom business logic that is not practical to be implemented in Elixir (Old SOAP APIs?, custom vendor artifacts, etc).
2. Are not available as _NIF_.
3. Other reasons for fun and profit?.

### Starting Pods

The example process manager uses https://github.com/saleyn/erlexec/
but you can implement the pod services using `System.cmd` or `Erlang Ports`
or any other solution if you want.

The only requirement is that it can allow `stdin` and `stdout` interactions.

#### Implementing a Pod

You can implement the pods with any technology and a simple Elixir wrapper to expose their API.

- `artifacts`: The directory where the external code executables will be stored.
- `pod.ex`: The main public api for the pod.
- `manifest.ex`: Some helper functions to have more information about the pod.

If you want to debug you can use standard tools such as stdin and stdout. In Unix systems you can access by using (1 stdout, 2 stderr).

```bash
  cat /proc/<pid>/fd/1
```

Also some hooks are triggered.

```elixir
defmodule PodsExampleProject.Handler do
  def on_pod_ready(pod, message) do
    IO.inspect([pod, message], label: :on_pod_ready)
  end

  def on_before_call(_registry, pod, message, op) do
    IO.inspect(pod.pid, label: op)
    IO.inspect(message, label: :on_before_call)
  end

  def out(response) do
    IO.inspect(response, label: :out)
  end

  def error(response) do
    IO.inspect(response, label: :error)
  end
end
```

Then you can import the pod using our beloved `mix`.

```elixir
defp deps do
  [
    # bencode
    {:bento, "~> 1.0"},
    # json
    {:jason, "~> 1.4"},
    {:pods_core, path: "../pods_core"},
    {:pods_process_manager, path: "../pods_process_manager"},
    {:pod_lispyclouds_sqlite, path: "../pod_lispyclouds_sqlite"}
  ]
end
```

##### Examples

- [Simple Pod](pod_lispyclouds_sqlite): Just a simple python script
- [Advanced Pod](pod_babashka_sqlite3): A program that requires installation pipeline

## Installation

```bash
cd pods_example_project
```

```bash
mix deps.get
```

## Usage

```bash
iex -S mix
```

## Tecnologies

- https://github.com/saleyn/erlexec/
- https://github.com/folz/bento
- https://github.com/michalmuskala/jason
- https://github.com/martinthenth/uuidv7

## Credits

<p>
  Made with <i class="fa fa-heart">&#9829;</i> by
  <a href="https://ninjas.cl">
    Ninjas.cl
  </a>.
</p>
