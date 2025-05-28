DOTFILES := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
DEFAULT_SHELL := $(shell dscl . -read ~/ UserShell | sed 's/UserShell: //') # only works on mac
export STOW_DIR = $(DOTFILES)
export XDG_CONFIG_HOME = $(HOME)/.config

all: \
	submodules \
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

submodules:
	git submodule update --init --recursive # ensure that .zprezto is fully pulled

brew:
	which brew || ( \
		/bin/bash -c "$$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" && \
		echo >> /Users/stephen/.zprofile && \
		echo 'eval "$$(/opt/homebrew/bin/brew shellenv)"' >> /Users/stephen/.zprofile && \
		eval "$(/opt/homebrew/bin/brew shellenv)" && \
		brew update \
	)

brew-packages: brew
	brew bundle --file=$(DOTFILES)/Brewfile || true

stow: brew
	which stow || brew install stow

link: link-runcoms link-config link-bin

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

ssh-setup: ~/.ssh/id_ed25519

~/.ssh/id_ed25519:
	# Generate a new ssh key for each new machine, if not already present.
	ssh-keygen -t ed25519

gpg-setup: brew-packages .gpg-key-generated
	echo "pinentry-program $$(which pinentry-mac)" >> ~/.gnupg/gpg-agent.conf # don't manage this with dotfiles

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

zsh-setup: submodules
# This ifneq is just broken for some reason
 # echo "Default Shell: $(DEFAULT_SHELL)"
#ifneq ($(DEFAULT_SHELL),/bin/zsh)
	#chsh -s /bin/zsh
# else
# echo "Shell already defaults to zsh"
# endif
#

go-setup:
	go install golang.org/x/tools/gopls@latest

rust-setup:
	if which rustup; then \
		rustup update; \
	else \
		curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh; \
	fi
	rustup component add rust-analyzer
	rustup component add rustfmt

npm-setup: brew-packages
	which npm || (echo "npm not found, please install Node.js first" && exit 1)
	cat $(DOTFILES)/npm-global-packages.txt | xargs -I {} npm install -g {}

nvim-setup: link-config brew-packages
