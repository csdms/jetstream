# Jupyter Notebook server on XSEDE Jetstream

XSEDE's `ezj` script allows a user to run a Jupyter Notebook instance.
It provides an URL with a token
that the user copies to their local browser.
Anyone can access this Jupyter Notebook
as long as they have a login
and the Jetstream VM instance is running.

We can set up a series of generic users
(e.g., *csdmsXX*)
to serve Notebooks for CSDMS (including Landlab) demos or for a class.

For a user, the process is:

1. From a terminal, login to the Jetstream instance with a *csdmsXX*
   username and password; e.g.,

        $ ssh csdms01@149.165.169.186

   or, if it would look nicer,

        $ ssh csdms01@js-169-186.jetstream-cloud.org

1. On login, the `ezj` script is automatically run. The user copies
   the resulting URL to their local browser, which starts a Jupyter
   Notebook session.

I've set up an *m1.tiny* instance in the "mdpiper" project to prototype,
and an *m1.small* instance in the "csdms" project to run.


## Install Anaconda Python

Install Anaconda2 (in this case, v4.3.1) in **/opt/anaconda2**.

    curl https://repo.continuum.io/archive/Anaconda2-4.3.1-Linux-x86_64.sh -o anaconda.sh
    sudo bash anaconda.sh -b -p /opt/anaconda2
    #PATH=/opt/anaconda2/bin:$PATH  # for me only

Install PyMT and Landlab into the root environment.

    sudo $(which conda) install -c csdms-stack -c conda-forge babelizer pymt
    sudo $(which conda) install -c landlab -c conda-forge landlab

Test the Landlab install.

    python -c 'import landlab; landlab.test()'

Install components that can be used in PyMT.

    sudo $(which conda) install -c csdms-stack csdms-pydeltarcm csdms-permamodel-frostnumber csdms-permamodel-ku
    sudo $(which conda) install -c csdms-stack csdms-hydrotrend
    sudo $(which conda) install -c csdms-stack csdms-child
    sudo $(which conda) install -c csdms-stack csdms-sedflux-3d

Test that each can be instantiated.


## Generic users

Make users *csdms01*, *csdms02*, etc.

Because the **/home** directory is wiped whenever
an instance is created from an image,
use the script [make_generic_users.sh](./make_generic_users.sh)
to generate these users.
Place this script in **/opt/csdms/scripts**.

I'd like to run this script automatically when the instance is booted.
In CentOS 7, I can either

1. create a service and place it in **/usr/lib/systemd/system**, or
1. use the deprecated way of referencing the script from
**/etc/rc.d/rc.local** (symlinked to **/etc/rc.local**).

I chose the old way since it's easier.
The [rc.local](./rc.local) file I used is stored in this repo.
This file must have `+x` permissions.

Note that Jetstream also has the notion of a
[deployment script](https://portal.xsede.org/jetstream#vmcust:request-bootscripts),
but I'm not sure it's what's needed here.

From the Jetstream docs,
allow these users to `ssh` into the instance.
This only needs to be done once.
Edit **/etc/ssh/sshd_config**, adding the line:

    PasswordAuthentication yes

(Note: this is already set as the default)
then restart sshd:

    sudo systemctl restart sshd


### Installing notebooks for users

Each user will have a directory **~/notebooks**,
that's populated with the CSDMS/Landlab Jupyter Notebooks
on login using code in **~/.bash_profile**.
Also create a README in `$HOME`
that directs users to the notebooks in **~/notebooks**.

Add these statements to the user's **.bash_profile**:

```bash
notebook_dir=$HOME/notebooks
if [ -d $notebook_dir ]; then
    rm -rf $notebook_dir;
fi
cp -R /opt/csdms/jupyter/* $HOME
```

where

```
$ tree /opt/csdms/jupyter
/opt/csdms/jupyter/
├── notebooks
│   └── simple.ipynb
└── README.ipynb

1 directory, 2 files
```

This is done in the sample [dot_bash_profile](./dot_bash_profile)
in this repo
and added to the **make_generic_users.sh** script.


## CSDMS and Landlab Jupyter Notebooks

Install CSDMS and Landlab Jupyter Notebooks
in **/opt/csdms/jupyter/notebooks**.

    mkdir -p /opt/csdms/jupyter
    cd ~/projects/jetstream
    sudo cp -R README.ipynb notebooks /opt/csdms/jupyter

Clone Landlab tutorials.

    cd ~/projects
    git clone https://github.com/landlab/tutorials landlab-tutorials

Remove extraneous files and copy all tutorials
to **/opt/csdms/jupyter/notebooks**.

    cd landlab-tutorials
    rm *.md *.sh *.py *.ipynb
    cp -R * /opt/csdms/jupyter/notebooks

Clone the PyMT demo.

    cd ~/projects
    git clone https://github.com/mcflugen/pymt-demo.git

and copy it to **/opt/csdms/jupyter/notebooks**.


## Run Jupyter Notebook server

The XSEDE Jetstream `ezj` setup script,
**cyverse20-ezj-setup.sh**,
is found in **/etc/profile.d**,
where it's run on login for each user.

Call `ezj` with

    ezj -q -p /opt

where `-q` is the "quick" flag,
which bypasses updating the Anaconda distro,
and `-p` gives the directory where Anaconda is installed.

Call `ezj` in this way from the user's **.bash_profile**
to start Jupyter Notebook when a user logs in.
