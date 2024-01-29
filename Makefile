DOTFILES := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
DEFAULT_SHELL := $(shell dscl . -read ~/ UserShell | sed 's/UserShell: //') # only works on mac
export STOW_DIR = $(DOTFILES)
export XDG_CONFIG_HOME = $(HOME)/.config


all: brew link gpg-setup git-setup
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

link-runcom: stow runcom/.*
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

gpg-setup: brew-packages .gpg-key-generated
	echo "pinentry-program $(which pinentry-mac)" >> ~/.gnupg/gpg-agent.conf # don't manage this with dotfiles

.gpg-key-generated:
	gpg --full-generate-key
	touch .gpg-key-generated # do this once per machine

git-setup: brew-packages config/git/signingkey.inc

config/git/signingkey.inc: .gpg-key-generated
	git config --file $(DOTFILES)/config/git/signingkey.inc user.signingkey \
		$$(gpg --list-secret-keys --keyid-format LONG --with-colons | awk -F: '/^sec:/ { print $$5 }' | head -n1)

zsh-setup:
	git submodule update --init --recursive # ensure that .zprezto is fully pulled
# This ifneq is just broken for some reason
 # echo "Default Shell: $(DEFAULT_SHELL)"
#ifneq ($(DEFAULT_SHELL),/bin/zsh)
	#chsh -s /bin/zsh
# else
# echo "Shell already defaults to zsh"
# endif
