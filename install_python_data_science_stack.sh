﻿# figure out why people put this shit here
#!/usr/bin/env bash <--- why?

# Installation Instructions
#
# 1. download scripts
# wget www.github.com/byronhousten/scripts/install_python_data_science_stack.sh
# wget www.github.com/byronhousten/scripts/passwd.py
#
# 2. make it executable
# chmod a+x install_python_analytics_stack.sh
#
# 3. Run it
# ./install_python_analytics_stack.sh

# sets LC_ALL environment variable - Ubuntu server often does not specify this
export LC_ALL="en_US.UTF-8"

# updates apt repository index
sudo apt -y update

# install linux functionality
sudo apt install -y git-all curl

# installs pip3
sudo apt install -y python3-pip

# installs virtualenv
pip3 install virtualenv
pip3 install virtualenvwrapper

echo "
export VIRTUALENVWRAPPER_PYTHON=/usr/bin/python3.5
" | sudo tee -a ~/.bashrc
export VIRTUALENVWRAPPER_PYTHON=/usr/bin/python3.5

echo "
export WORKON_HOME=$HOME/.virtualenvs
export PROJECT_HOME=$HOME/Projects
source $HOME/.local/bin/virtualenvwrapper.sh
" | sudo tee -a ~/.profile

export WORKON_HOME=$HOME/.virtualenvs
export PROJECT_HOME=$HOME/Projects	
source $HOME/.local/bin/virtualenvwrapper.sh

# create & activate virtual environment
mkvirtualenv data-science

# start installing base stack
# edit this line for installing additional packages
pip install jupyter matplotlib numpy pandas scipy seaborn sklearn statsmodels

# project management
pip install cookiecutter

# text processing stack
pip install nltk gensim

# installing XGBoost
cd $HOME
git clone --recursive https://github.com/dmlc/xgboost
cd xgboost
make -j4
cd python-package
python setup.py install
echo "
export PYTHONPATH=~/xgboost/python-package
" | sudo tee -a ~/.bashrc
export PYTHONPATH=~/xgboost/python-package

# setting up Jupyter notebook
cd $HOME
echo "Create Jupyter password"
echo "---"
read -p "Input password for Jupyter notebook: " passwd
read -p "Please confirm password: " passwd_confirm
while [ "$passwd" != "$passwd_confirm" ]
	do
		echo "***"
		read -s -p "Passwords do not match. Please input password: " passwd
		read -s -p "Please confirm password: " passwd_confirm
done

ipython passwd.py $passwd
passwd_file="$HOME/passwd_hash.txt"
passwd_hash=$(cat $passwd_file)
rm $passwd_file

mkdir $HOME/.certs
cd $HOME/.certs
path_to_pem="$HOME/.certs/jupyter.pem"
sudo openssl req -x509 -nodes -days 365 -newkey rsa:1024 -keyout $path_to_pem -out $path_to_pem

jupyter notebook --generate-config
jupyter_config=~/.jupyter/jupyter_notebook_config.py

echo "
c = get_config()
c.IPKernelApp.pylab = 'inline'
c.NotebookApp.certfile = u'/home/ubuntu/.certs/jupyter.pem'
c.NotebookApp.ip = '*'
c.NotebookApp.open_browser = False

c.NotebookApp.password = u'$passwd_hash'
c.NotebookApp.port = 8888
" | sudo tee -a $jupyter_config

### setting up git
read -p "Input GitHub username: " $github_username
git config --global user.name "$github_username"
read -p "Input Github email address: " $github_email
git config --global user.email "$github_email"
git config --global core.editor vi