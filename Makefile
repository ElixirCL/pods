.PHONY: install docs lint

install i:
	mix deps.get
lint l:
	mix credo
docs d:
	mix docs
