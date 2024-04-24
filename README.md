# Elixir Babashka Pods

This is a simple proof of concept.
The idea is using [Babashka Pods](https://github.com/babashka/pods/).

_Babashka Pods_ enables using external services that can be writen in any programming language.
It's not required that the program has a _CLI_, since a script is created that interacts with the internal _SDK_.
_Babashka Pods_ are standalone programs that can expose namespaces with vars to _Elixir_.

The example is taken from [LispyClouds SQLite](https://github.com/babashka/pods/tree/master/examples/pod-lispyclouds-sqlite)
a simple `sqlite3` wrapper that can execute commands, programmed in _python_.

Example usage:

```elixir
Pods.start([Pods.LispyClouds.SQLite.start()])
|> Pods.LispyClouds.SQLite.describe()
|> Pods.LispyClouds.SQLite.execute!("create table if not exists foo ( int foo )")
|> Pods.LispyClouds.SQLite.execute!("delete from foo")
|> Pods.LispyClouds.SQLite.execute!("insert into foo values (1), (2)")
|> Pods.LispyClouds.SQLite.execute!("select * from foo")
```

A _Babashka Pod_ must follow some simple rules:

- An infinite function (`while true`).
- Reads from `stdin` (in streaming mode).
- Writes to `stdout`.
- Follows [Babashka Pods](https://github.com/babashka/pods/) format.
- At least implements the `describe` and `invoke` operators.
- Encodes messages with [bencode](https://en.wikipedia.org/wiki/Bencode).
- Encodes params with _JSON_.

### Why?

Babashka’s pod system lets you interact with external processes using _Elixir_ functions, as opposed to shelling out with `System.cmd` or making HTTP requests, or something like that. Those external processes are called pods and must implement the pod protocol to tell client programs how to interact with them.

- https://www.youtube.com/watch?v=Q3EFNRwxLLo
- https://www.braveclojure.com/quests/babooka/
- https://book.babashka.org/

## Installation

```bash
mix deps.get
```

## Usage

```bash
iex -S mix
```

**Example Output**

```markdown
$ iex -S mix
Erlang/OTP 25 [erts-13.2.2.7] [source] [64-bit] [smp:4:4] [ds:4:4:10] [async-threads:1] [jit:ns]

Compiling 1 file (.ex)

22:08:45.983 [info] describe
%{
message: %{id: "018f0ddc-cfb6-7173-b501-d5dc64be1e8d", op: "describe"},
pid: 41244,
response: :ok
}

22:08:46.031 [info] execute!

22:08:46.031 [debug] create table if not exists foo ( int foo )
%{
message: %{
args: "[\"create table if not exists foo ( int foo )\"]",
id: "018f0ddc-cfcf-718f-a7ac-6a81716b2bfd",
op: "invoke",
var: "pod.lispyclouds.sqlite/execute!"
},
pid: 41244,
response: :ok
}

22:08:46.040 [info] execute!
%{
message: %{
args: "[\"delete from foo\"]",
id: "018f0ddc-cfd9-7675-80f2-0eb70259cad8",
op: "invoke",
var: "pod.lispyclouds.sqlite/execute!"
},
pid: 41244,
response: :ok
}

22:08:46.041 [debug] delete from foo

22:08:46.041 [info] execute!
%{
message: %{
args: "[\"insert into foo values (1), (2)\"]",
id: "018f0ddc-cfd9-79b8-b6e3-1c47f93ee383",
op: "invoke",
var: "pod.lispyclouds.sqlite/execute!"
},
pid: 41244,
response: :ok
}

22:08:46.041 [debug] insert into foo values (1), (2)

22:08:46.041 [info] execute!

22:08:46.042 [debug] select _ from foo
%{
message: %{
args: "[\"select _ from foo\"]",
id: "018f0ddc-cfda-7fef-a162-ced1468741e0",
op: "invoke",
var: "pod.lispyclouds.sqlite/execute!"
},
pid: 41244,
response: :ok
}
Interactive Elixir (1.15.7) - press Ctrl+C to exit (type h() ENTER for help)
iex(1)> %{
"format" => "json",
"namespaces" => [
%{"name" => "pod.lispyclouds.sqlite", "vars" => [%{"name" => "execute!"}]}
]
}
%{
:result => [],
"id" => "018f0ddc-cfcf-718f-a7ac-6a81716b2bfd",
"status" => ["done"],
"value" => "[]"
}
%{
:result => [],
"id" => "018f0ddc-cfd9-7675-80f2-0eb70259cad8",
"status" => ["done"],
"value" => "[]"
}
%{
:result => [],
"id" => "018f0ddc-cfd9-79b8-b6e3-1c47f93ee383",
"status" => ["done"],
"value" => "[]"
}
%{
:result => [[1], [2]],
"id" => "018f0ddc-cfda-7fef-a162-ced1468741e0",
"status" => ["done"],
"value" => "[[1], [2]]"
}
```

## Tecnologies

- https://github.com/saleyn/erlexec/
- https://github.com/folz/bento
- https://github.com/michalmuskala/jason
- https://github.com/martinthenth/uuidv7
