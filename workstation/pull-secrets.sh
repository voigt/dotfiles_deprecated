#!/bin/bash

set -eu

echo "Authenticating with 1Password"
export OP_SESSION_my=$(op signin https://my.1password.com voigt.christoph@gmail.com --output=raw)

echo "Pulling secrets"
  # private keys
op get document 'github_rsa' > github_rsa
op get document 'cv_cetus_uberspace' > cv_uberspace
op get document 'jmb_horologium_uberspace' > jmb_uberspace
op get document 'currywurst' > currywurst
#op get document 'zsh_private' > zsh_private
#op get document 'zsh_history' > zsh_history

# rm ~/.ssh/github_rsa
# rm ~/.zsh_private
# rm ~/.zsh_history

ln -snf $(pwd)/github_rsa ~/.ssh/github_rsa
chmod 0600 ~/.ssh/github_rsa
ln -snf $(pwd)/cv_uberspace ~/.ssh/cv_uberspace
chmod 0600 ~/.ssh/cv_uberspace
ln -snf $(pwd)/jmb_uberspace ~/.ssh/jmb_uberspace
chmod 0600 ~/.ssh/jmb_uberspace
ln -snf $(pwd)/currywurst ~/.ssh/currywurst
chmod 0600 ~/.ssh/currywurst
# ln -s $(pwd)/zsh_private ~/.zsh_private
# ln -s $(pwd)/zsh_history ~/.zsh_history

echo "Done!"
