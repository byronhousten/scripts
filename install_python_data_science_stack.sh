# figure out why people put this shit here
#!/usr/bin/env bash <--- why?

# Installation Instructions
#
# 1. download script
# wget www.byronhousten.com/install_python_analytics_stack.sh
#
# 2. make it executable
# chmod a+x install_python_analytics_stack.sh
#
# 3. Run it (in screen)
# screen ./install_python_analytics_stack.sh

# sets LC_ALL environment variable - Ubuntu server often does not specify this
export LC_ALL="en_US.UTF-8"

# updates apt repository index
sudo apt -y update

# install linux functionality
sudo apt install -y git curl

# installs pip3
sudo apt install python3-pip

# installs virtualenv
pip3 install virtualenv
pip3 install virtualenvwrapper

export VIRTUALENVWRAPPER_PYTHON=/usr/bin/python3.5

echo "
export WORKON_HOME=$HOME/.virtualenvs
export PROJECT_HOME=$HOME/Projects
source $HOME/.local/bin/virtualenvwrapper.sh
" | sudo tee -a ~/.profile
source ~/.profile

# create & activate virtual environment
mkvirtualenv data-science

# start installing base stack
# edit this line for installing additional packages
pip install jupyter matplotlib numpy pandas scipy seaborn sklearn statsmodels

# project management
pip install cookiecutter

# text processing stack
pip install nltk gensim

cd $HOME
echo "Create Jupyter password"
echo "---"
read -s -p "Input password for Jupyter notebook: " passwd
read -s -p "Please confirm password: " passwd_confirm
while [ "$passwd" != "$passwd_confirm" ]
	do
		echo "***"
		read -s -p "Passwords do not match. Please input password: " passwd
		read -s -p "Please confirm password: " passwd_confirm
done

# setting up Jupyter
ipython passwd.py $passwd
passwd_file = "$HOME/passwd_hash.txt"
passwd_hash = 'cat $passwd_file'
rm $passwd_file

mkdir $HOME/.certs
cd $HOME/.certs
path_to_pem = "$HOME/.certs/jupyter.pem"
sudo openssl req -x509 -nodes -days 365 -newkey rsa:1024 -keyout $path_to_pem -out $path_to_pem

jupyter notebook --generate-config
cd ~/.jupyter/
jupyter_config = ~/.jupyter/jupyter_notebook_config.py
echo "
c = get_config()
c.IPKernelApp.pylab = 'inline'
c.NotebookApp.certfile = u'/home/ubuntu/.certs/jupyter.pem'
c.NotebookApp.ip = '*'
c.NotebookApp.open_browser = False

c.NotebookApp.password = u''
c.NotebookApp.port = 8888
" | sudo tee -a $jupyter_config