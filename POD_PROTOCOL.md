# Elixir Pods: Pod Protocol

This protocol is adapted from [Babashka Pods](https://github.com/babashka/pods).
This protocol must be implemented by any _Pod Service_.

The _Pod Client_ (`client`) is the _Elixir_ code that connects to the _Pod Service_ (`pod`).

Exchange of messages between pod client and the pod happens in the bencode format. [Bencode](https://en.wikipedia.org/wiki/Bencode) is a bare-bones format that only has four types:

- integers
- lists
- dictionaries (maps)
- byte strings

The recommended library for processing _Bencode_ in _Elixir_ is [https://github.com/folz/bento](https://github.com/folz/bento).

Additionally, payloads like args (arguments) or value (a function return value) are encoded in either _JSON_ or _Transit JSON_ (depends on the pod implementation).

## Environment

The pod client will set the `ELIXIR_POD` environment variable to `true` when starting the pod. This can be used by the service program (`pod`) to determine whether it should behave as a pod or not.

## Operands

Operands must be implemented on each `pod`.
Operands executes without a namespace and arguments.
There are three main operands `describe`, `invoke` and `shutdown`.

### `describe`

This operand will return the description of the `pod`. It's the first
operand that will be called after the start of the service by the pod client.

The following is a `map` with example `describe` for the `demo pod`.
Note that the final response will be encoded in `bencode`.

**call**

```elixir
%{
  op: "describe",
  id: "018f2732-9ce5-726a-a1b4-acb86c3099c6" # uuidv7
}
|> Bento.encode!()
```

**response**

```elixir
%{
  format: "json",
  id: "018f2732-9ce5-726a-a1b4-acb86c3099c6" # same as the called operation
  namespaces: [
    %{
      name: "pod.example.demo",
      vars: [
        %{
          name: "add",
          meta: %{
            shortdoc: "arithmetic addition of 2 arguments",
            spec: "(a :: int(), b :: int()) :: int()"
          }
      }]
    }
  ]
}
|> Bento.encode!()
```

- `format`: which encoding will used by the payloads and values (`json`).
- `namespaces`: provides the identifier for all commands.
- `name`: the name for the namespace.
- `vars`: functions that the namespace support. In this example, for calling the function `add` the client will send `pod.example.demo/add`.
- `meta`: optional information about the functions.

### `invoke`

The `invoke` operand will execute a function defined in `var`, and return it's result (async).

**call**

```elixir
%{
  op: "invoke",
  id: "018f277a-7ccc-7678-8b8b-10bbc7374c05",
  var: "com.example.pod/add",
  args: [1, 2],
  opts: [] # additional options
}
|> Bento.encode!()
```

**response**

The successful response will have `status: :ok` and a `value` with the result of the function.

```elixir
%{
  id: "018f277a-7ccc-7678-8b8b-10bbc7374c05",
  var: "com.example.pod/add",
  value: 3,
  status: :ok
}
|> Bento.encode!()
```

**error response**

If the operation was terminated with error, the response will have `status: :error`, sent to `stdout` and can be similar to:

```elixir
%{
  id: "018f277a-7ccc-7678-8b8b-10bbc7374c05",
  var: "com.example.pod/add",
  error: %{
    code: "com.example.pod/errors/403", # can be any value, maybe http codes would be good
    message: "Illegal input",
    data: %{
      input: ["one"], # the params received
      opts: []
    }
  }
  status: :error
}
|> Bento.encode!()
```

### `shutdown`

The `shutdown` operand can optionally be included in the `pod` service. It is
called by the `pod client` when it requires the pod to stop.

The client will kill the `pod` in two contexts:

1. When the client stops, all pods will be killed.
2. When the client receives the `shutdown` response from the `pod`.

**call**

```elixir
%{
  op: "shutdown",
  id: "018f279a-e1a7-7b7c-a3b5-7e469faa6ee2" # uuidv7
}
|> Bento.encode!()
```

**response**

The `pod` will send the `shutdown` response payload when is ready to be killed by the process manager, upon receiving this respose the pod client process manager will kill the pod process by its `pid`.

```elixir
%{
  id: "018f279a-e1a7-7b7c-a3b5-7e469faa6ee2",
  op: "shutdown",
  status: :ok
}
|> Bento.encode!()
```

## Input and Output

### `stdin`

The `pod` must read from `stdin` (in streams) for input.

### `stdout`

The `pod` must write to `stdout` for output. `stdout` will be used for both
success and errors (normal operation results).

### `stderr`

For exceptions that the `pod` triggers if anything unexpected happends.

## Permissions

The recommended `pod` is a single command that will
be an executable. (`chmod +x`).
