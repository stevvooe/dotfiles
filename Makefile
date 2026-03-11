DOTFILES := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
DEFAULT_SHELL := $(shell dscl . -read ~/ UserShell | sed 's/UserShell: //') # only works on mac
export STOW_DIR = $(DOTFILES)
export XDG_CONFIG_HOME = $(HOME)/.config

all: \
	brew \
	link \
	ssh-setup \
	gpg-setup \
	git-setup \
	zsh-setup \
	go-setup \
	rust-setup \
	npm-setup \
	nvim-setup
brew:
	which brew || ( \
		/bin/bash -c "$$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" && \
		touch $$HOME/.zprofile && \
		echo >> $$HOME/.zprofile && \
		echo 'eval "$$(/opt/homebrew/bin/brew shellenv)"' >> $$HOME/.zprofile && \
		eval "$(/opt/homebrew/bin/brew shellenv)" && \
		brew update \
	)

brew-packages: brew
	brew bundle --file=$(DOTFILES)/Brewfile || true

stow: brew
	which stow || brew install stow

link: link-runcoms link-config link-bin link-gnupg

tmux-tpm-update:
	set -e; \
	TPM_DIR="$$HOME/.local/share/tmux/plugins/tpm"; \
	mkdir -p "$${TPM_DIR%/tpm}"; \
	if [ -d "$$TPM_DIR/.git" ]; then \
		git -C "$$TPM_DIR" pull --ff-only; \
	else \
		rm -rf "$$TPM_DIR"; \
		git clone https://github.com/tmux-plugins/tpm "$$TPM_DIR"; \
	fi

$(HOME)/bin:
	mkdir -p "$@"

link-bin: stow bin/* $(HOME)/bin
	stow -t $(HOME)/bin bin

link-runcoms: stow runcoms/.*
	for FILE in $$(\ls -A runcoms); do if [ -f $(HOME)/$$FILE -a ! -h $(HOME)/$$FILE ]; then \
		mv -v $(HOME)/$$FILE{,.bak}; fi; \
	done
	stow -t $(HOME) runcoms

link-config: stow config/*
	mkdir -p $(XDG_CONFIG_HOME)
	stow -t $(XDG_CONFIG_HOME) config

unlink-runcoms: stow
	stow --delete -t $(HOME) runcoms
	for FILE in $$(\ls -A runcoms); do if [ -f $(HOME)/$$FILE.bak ]; then \
		mv -v $(HOME)/$$FILE.bak $(HOME)/$${FILE%%.bak}; fi; done

link-gnupg: stow gnupg/.gnupg/gpg-agent.conf
	mkdir -p $(HOME)/.gnupg
	chmod 700 $(HOME)/.gnupg
	if [ -f $(HOME)/.gnupg/gpg-agent.conf -a ! -h $(HOME)/.gnupg/gpg-agent.conf ]; then \
		mv -v $(HOME)/.gnupg/gpg-agent.conf $(HOME)/.gnupg/gpg-agent.conf.bak; \
	fi
	stow -t $(HOME) gnupg
	chmod 600 $(HOME)/.gnupg/gpg-agent.conf
	gpgconf --kill gpg-agent || true

unlink-gnupg: stow
	stow --delete -t $(HOME) gnupg
	if [ -f $(HOME)/.gnupg/gpg-agent.conf.bak ]; then \
		mv -v $(HOME)/.gnupg/gpg-agent.conf.bak $(HOME)/.gnupg/gpg-agent.conf; \
	fi

ssh-setup: ~/.ssh/id_ed25519

~/.ssh/id_ed25519:
	# Generate a new ssh key for each new machine, if not already present.
	ssh-keygen -t ed25519

gpg-setup: brew-packages link-gnupg .gpg-key-generated

.gpg-key-generated:
	gpg --full-generate-key
	touch .gpg-key-generated # do this once per machine

git-setup: brew-packages config/git/signingkey.inc config/git/email.inc

config/git/signingkey.inc: .gpg-key-generated
	git config --file $(DOTFILES)/config/git/signingkey.inc user.signingkey \
		$$(gpg --list-secret-keys --keyid-format LONG --with-colons | awk -F: '/^sec:/ { print $$5 }' | head -n1)

config/git/email.inc:
ifndef EMAIL
	$(error EMAIL is undefined)
endif
	git config --file $(DOTFILES)/config/git/email.inc user.email "$$EMAIL"

zsh-setup:
# This ifneq is just broken for some reason
 # echo "Default Shell: $(DEFAULT_SHELL)"
#ifneq ($(DEFAULT_SHELL),/bin/zsh)
	#chsh -s /bin/zsh
# else
# echo "Shell already defaults to zsh"
# endif
#

go-setup: brew-packages

rust-setup: brew-packages
	rustup component add rust-analyzer
	rustup component add rustfmt

npm-setup: brew-packages
	which npm || (echo "npm not found, please install Node.js first" && exit 1)
	cat $(DOTFILES)/npm-global-packages.txt | xargs -I {} npm install -g {}

nvim-setup: link-config brew-packages
