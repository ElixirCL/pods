# Pod Babashka SQLite3

This is an example pod that uses an external installation
pipeline for the artifacts.

## Installation

Requires `babashka` (`bb`) executable to install the pod.
It will install the artifacts inside the `pods` directory
on the project.

- Add to `mix.exs`

```elixir
{:pod_babashka_sqlite3, path: "../pod_babashka_sqlite3"}
```

```elixir
mix compile
```

- Install the artifacts

```elixir
mix pod.babashka.sqlite3.check   #   Checks if babashka runtime is on the $PATH

mix pod.babashka.sqlite3.install #   Installs the sqlite3 pod in pods directory
```

## Note on Babashka Pods

Some pods are specially created for clojure language (defines macros and other stuff), so it won't work well with elixir.

_Elixir Pods_ is meant to fill a gap between a CLI and a RPC,
so if you stick to following the bencode + json approach it will work well.

Example Incompatible Pod

- https://github.com/babashka/pod-babashka-filewatcher/blob/master/src/main.rs#L50

Since it requires clojure code to be executed in the client.

## Is this Working?

At least the `describe` command works. Other command does not work
due to parser issues.

Is best to create some pods that can be properly tested with Elixir Pods,
but at least this serves as an example of a more advanced pod configuration and installation procedure.
