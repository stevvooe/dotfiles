DOTFILES := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
export STOW_DIR = $(DOTFILES)
export XDG_CONFIG_HOME = $(HOME)/.config

all:
	echo "in progress"
	echo ${DOTFILES_DIR}

brew:
	which brew || ( \
		/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" && \
		brew update \
	)

brew-packages: brew
	brew bundle --file=$(DOTFILES)/Brewfile || true

stow: brew
	which stow || brew install stow

link: link-runcom link-config

link-runcom: stow runcom/*
	for FILE in $$(\ls -A runcom); do if [ -f $(HOME)/$$FILE -a ! -h $(HOME)/$$FILE ]; then \
		mv -v $(HOME)/$$FILE{,.bak}; fi; done
	stow -t $(HOME) runcom

link-config: stow config/*
	mkdir -p $(XDG_CONFIG_HOME)
	stow -t $(XDG_CONFIG_HOME) config

unlink-runcom: stow
	stow --delete -t $(HOME) runcom
	for FILE in $$(\ls -A runcom); do if [ -f $(HOME)/$$FILE.bak ]; then \
		mv -v $(HOME)/$$FILE.bak $(HOME)/$${FILE%%.bak}; fi; done

gpg-generatekey:
	gpg --full-generate-key

config/git/signingkey.inc:
	git config --file $(DOTFILES)/config/git/signingkey.inc user.signingkey \
		$$(gpg --list-secret-keys --keyid-format LONG --with-colons | awk -F: '/^sec:/ { print $$5 }' | head -n1)
