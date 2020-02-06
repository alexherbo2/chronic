build:
	shards build --release

install: build
	mkdir -p ~/.local/bin
	ln -sf "${PWD}/bin/chronic" "${PWD}/scripts/at" "${PWD}/scripts/cg" ~/.local/bin

uninstall:
	rm -f ~/.local/bin/chronic ~/.local/bin/at ~/.local/bin/cg

test:
	crystal spec

clean:
	rm -Rf bin
