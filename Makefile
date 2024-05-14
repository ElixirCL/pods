.PHONY: install docs lint test iex

install i:
	mix deps.get
lint l:
	mix credo
docs d:
	mix docs

test t:
	mix test

iex e:
	iex -S mix
