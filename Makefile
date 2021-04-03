build:
	shards build --release

install: build
	install -d ~/.local/bin
	install bin/chronic ~/.local/bin

uninstall:
	rm -f ~/.local/bin/chronic

test:
	crystal spec

clean:
	rm -Rf bin
