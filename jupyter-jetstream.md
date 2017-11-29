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

1. On login, the `ezj` script is automatically run. The user copies
   the resulting URL to their local browser, which starts a Jupyter
   Notebook session.

I've set up an *m1.tiny* instance to prototype.


## Set up and run Jupyter Notebook

Install Anaconda2 (in this case, v4.3.1) in **/opt/anaconda2**.

The XSEDE Jetstream `ezj` setup script,
**cyverse20-ezj-setup.sh**,
is found in **/etc/profile.d**,
where it's run on login for each user.

Call `ezj` with

    ezj -q -p /opt

where `-q` is the "quick" flag,
which bypasses updating the Anaconda distro,
and `-p` gives the location of the Anaconda install directory.

Call `ezj` in this way from the user's **.bash_profile**
to start Jupyter Notebook when a user logs in.


## Generic users

Make users *csdms01*, *csdms02*, etc.

Because the **/home** directory is wiped whenever
an instance is created from an image,
use the script [make_generic_users.sh](./make_generic_users.sh)
to generate these users.

I'd like to run this script automatically at startup.
In CentOS 7, I can either

1. Create a service and place it in **/usr/lib/systemd/system**, or
1. Use the old way of referencing the script from **/etc/rc.local**.

Jetstream also has the notion of a
[deployment script](https://portal.xsede.org/jetstream#vmcust:request-bootscripts),
but I'm not sure this is what's needed here.

From the Jetstream docs,
allow these users to `ssh` into the instance.
This only needs to be done once.
Edit **/etc/ssh/sshd_config**, adding the line:

    PasswordAuthentication yes

(Note: this is already set as the default)
then restart sshd:

    sudo systemctl restart sshd


## CSDMS and Landlab Jupyter Notebooks

Install CSDMS and Landlab Jupyter Notebooks
in **/opt/csdms/jupyter/notebooks**.

Make the directory **~/notebooks** for each user.
On login,
populate this directory with CSDMS/Landlab Jupyter Notebooks
using a login script (add to or call from **~/.bash_profile**).
Create a README in `$HOME`
that directs users to the notebooks in **~/notebooks**.

Add these statements to the user's **.bash_profile**.

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
in this repo.
