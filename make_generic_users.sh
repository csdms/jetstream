#! /usr/bin/env bash
#
# Create a sequence of users on a CentOS 7 system, configuring a home
# directory for each. If a user of the same name exists, delete it.
#

remove_user () {
    echo "- removing existing user"
    sudo pkill -u $1
    sudo userdel -r $1
}

add_user () {
    echo "- creating user"
    sudo adduser $1
    echo "csdms*landlab" | sudo passwd $1 --stdin > /dev/null 2>&1
    sudo usermod -aG users $1
}

configure_user () {
    echo "- configuring user"
    sudo rmdir /home/$1/new.config
    if [ -e "/opt/csdms/scripts/dot_bash_profile" ]; then
	sudo cp /opt/csdms/scripts/dot_bash_profile /home/$1/.bash_profile;
    else
	echo "Failed to copy .bash_profile"
    fi
}

user_prefix=csdms
n_users=10
for i in $(seq 1 $n_users); do
    if (($i < 10)); then
	user_name="$user_prefix"0$i;
    else
	user_name=$user_prefix$i;
    fi
    echo "User: $user_name"
    if id -u $user_name > /dev/null 2>&1; then
	remove_user $user_name
    fi
    add_user $user_name
    configure_user $user_name
done

exit 0
