unset MEDALLION_DBT_ROOT
unset AWS_PROFILE
unset MEDALLION_DBT_PROFILE
unset MED_DBT_USER_SCHEMA

# Rosetta 2
if [[ $OSTYPE == 'darwin'* && $(pgrep -q oahd && echo 1 || echo 0) = 0 ]] ; then
    sudo softwareupdate --install-rosetta
fi


which -s brew
if [[ $? != 0 ]] ; then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    (echo; echo 'eval "$(/opt/homebrew/bin/brew shellenv)"') >> /Users/$USER/.zshrc
    eval "$(/opt/homebrew/bin/brew shellenv)"
else
    echo "Updating Homebrew..."
    brew update
fi

which -s aws-sso-util
if [[ $? != 0 ]] ; then
    brew install pipx
    pipx ensurepath
    brew install aws-sso-util
fi

which -s pyenv
if [[ $? != 0 ]] ; then
    brew update
    brew install pyenv
    brew install pyenv-virtualenv
fi

if ! grep -q "pyenv" ~/.zshrc; then
    echo "Adding pyenv to zshrc..."
    echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.zshrc
    echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.zshrc
    echo 'eval "$(pyenv init --path)"' >> ~/.zshrc
    echo 'eval "$(pyenv init -)"' >> ~/.zshrc
    source ~/.zshrc
fi

echo "Installing and activating virtualenvs..."

if which pyenv-virtualenv-init > /dev/null; then
    eval "$(pyenv virtualenv-init -)";
fi

if ! pyenv versions | grep -q "3.11"; then
   pyenv install 3.11.4
fi

pyenv virtualenv 3.11.4 medallion
pyenv local medallion

yes | pip3 install -r core/requirements.txt
dbt deps

which -s aws
if [[ $? != 0 ]] ; then
    curl "https://awscli.amazonaws.com/AWSCLIV2.pkg" -o "/tmp/AWSCLIV2.pkg"
    sudo installer -pkg /tmp/AWSCLIV2.pkg -target /
fi

echo "Configure AWS Profile.."
awsume-configure --alias-file ~/.zshrc --shell zsh
source ~/.zshrc

aws-sso-util configure profile DataAnalyticsAdminAccess \
  -u https://shipveho.awsapps.com/start# --sso-region us-east-1 \
  -a 680267403278 -r DataAnalyticsAdminAccess --region us-east-1 \
  --existing-config-action discard

aws-sso-util login --profile DataAnalyticsAdminAccess && awsume -a DataAnalyticsAdminAccess

var=$(echo "$PWD")

echo "Exporting Your DBT and AWS Credential Profiles..."

export MEDALLION_DBT_ROOT=$(echo "$PWD")
export AWS_PROFILE=DataAnalyticsAdminAccess
export MEDALLION_DBT_PROFILE=medallion-athena-poc
export MEDALLION_DBT_USER_SCHEMA=$(aws sts get-caller-identity --query UserId --output text | awk -F ':' '{print $2}' | awk -F '@' '{print $1}' | tr -d .)

echo "DONE! Please SQL Responsibly!!"