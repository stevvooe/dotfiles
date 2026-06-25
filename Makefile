DOTFILES := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
DEFAULT_SHELL := $(shell dscl . -read ~/ UserShell | sed 's/UserShell: //') # only works on mac
export STOW_DIR = $(DOTFILES)
export XDG_CONFIG_HOME = $(HOME)/.config

all: \
	brew \
	brew-packages \
	link \
	ssh-setup \
	gpg-setup \
	git-setup \
	go-setup \
	rust-setup \
	bun-setup \
	npm-setup
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

link: link-runcoms link-config link-bin link-gnupg link-zshrc-local

# $HOME/.zshrc escape hatch.
#
# ZDOTDIR is set to ~/.config/zsh, so zsh never sources $HOME/.zshrc. But dumb
# tools hardcode $HOME/.zshrc and inject machine-specific lines there. We point
# $HOME/.zshrc at a gitignored local file so those writes (a) take effect via
# our config, which sources config/zsh/.zshrc.local, and (b) never land in the
# committed tree. The .local file is created empty if absent.
link-zshrc-local:
	touch $(DOTFILES)/config/zsh/.zshrc.local
	if [ -e $(HOME)/.zshrc -a ! -h $(HOME)/.zshrc ]; then \
		mv -v $(HOME)/.zshrc $(HOME)/.zshrc.bak; \
	fi
	ln -sfn $(DOTFILES)/config/zsh/.zshrc.local $(HOME)/.zshrc

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

# swarm: TS agent-orchestration tool compiled to a standalone binary via bun.
# Built from src/swarm; output is gitignored and stowed like other bin/ tools.
bin/swarm: src/swarm/swarm.ts $(wildcard src/swarm/*.ts)
	which bun || (echo "bun not found, please install Bun first" && exit 1)
	cd $(DOTFILES)/src/swarm && bun install
	cd $(DOTFILES) && bun build --compile --outfile bin/swarm src/swarm/swarm.ts

swarm: bin/swarm

link-bin: stow bin/swarm bin/* $(HOME)/bin
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

go-setup: brew-packages

rust-setup: brew-packages
	rustup component add rust-analyzer
	rustup component add rustfmt

bun-setup: brew-packages
	which bun || (echo "bun not found, please install Bun first" && exit 1)
	cat $(DOTFILES)/bun-global-packages.txt | xargs -I {} bun add -g {}

npm-setup: brew-packages
	which npm || (echo "npm not found, please install Node.js first" && exit 1)
	cat $(DOTFILES)/npm-global-packages.txt | xargs -I {} npm install -g {}

