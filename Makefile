build:
	shards build --release

install: build
	mkdir -p ~/.local/bin
	ln -sf "${PWD}/bin/chronic" ~/.local/bin

uninstall:
	rm -f ~/.local/bin/chronic

test:
	crystal spec

clean:
	rm -Rf bin
