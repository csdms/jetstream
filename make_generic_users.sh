#! /usr/bin/env bash
#
# Create a sequence of users on a CentOS 7 system, configuring a home
# directory for each. If a user of the same name exists, delete it.
#
user_prefix=csdms
n_users=10
scripts_dir=/opt/csdms/scripts

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
    extra_dirs="new.config Desktop"
    for dir in $extra_dirs; do
	sudo rm -rf /home/$1/$dir;
    done
    if [ -e "$scripts_dir/dot_bash_profile" ]; then
	sudo cp $scripts_dir/dot_bash_profile /home/$1/.bash_profile;
    else
	echo "Failed to copy .bash_profile"
    fi
}

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
