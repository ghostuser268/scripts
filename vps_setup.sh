#!/bin/bash

if [[ $USER == "root" ]];then echo "user is root! exiting...";fi

error_message(){
	 echo -e "Point of failure:\t $1\nError code:\t\t $2\nReason:\t\t\t $3"
	 exit 
}
file_name="vps.sh"


data_filled=false


g_path=""
g_user=""
auth_key=""
r_pass=""
g_pass=""
#Database
m_admin_name=""
m_admin_pass=""
m_collection_name=""
m_collection_admin_name=""
m_collection_admin_pass=""
m_collection_client_name=""
m_collection_client_pass=""


if [[ ! $data_filled ]];then echo "set info and toggle data_filled";exit; fi

sshd_config=/etc/ssh/sshd_config
sudoers=/etc/sudoers

g_alias="alias ls='ls -ll'\nalias la='ls -lla'\nalias vim='sudo vim'\nalias nvim='sudo vim'\nalias senable='sudo systemctl enable'\nalias sdisable='sudo systemctl disable'\nalias sstart='sudo systemctl start'\nalias sstatus='sudo systemctl status'\nalias srestart='sudo systemctl restart'\nalias sreload='sudo systemctl reload'"
g_vim="set mouse=a\nset number\nset relativenumber\nset noswapfile\nmap <C-c> :w!<CR>"
mongo_repo='[mongodb-org-6.0]\nname=MongoDB Repository\nbaseurl=https://repo.mongodb.org/yum/redhat/$releasever/mongodb-org/6.0/x86_64/\ngpgcheck=1\nenabled=1\ngpgkey=https://www.mongodb.org/static/pgp/server-6.0.asc'
setup_users(){ 
	 #sudo yum -y update || error_message "setup_users" $? "failed to update"
	 sudo yum -y install vim nano || error_message "setup_users" $? "failed to install packages"
	 
	 sudo useradd -mG wheel ghost || error_message "setup_users" $? "failed to add new user"

	 echo "$g_user ALL=(ALL) NOPASSWD: ALL" | sudo tee -a $sudoers
	 ( echo $g_pass; echo $g_pass ) | sudo passwd $g_user
	 ( echo $r_pass; echo $r_pass ) | sudo passwd root

	 sleep 5

	 sudo mv ${HOME}/$file_name $g_path
	 sudo su - $g_user

	 echo "Successfully added user $g_user"
	 #sudo sed -i "121d" $sudoers; 
}

update_user(){
	 mkdir $HOME/.ssh; touch $HOME/.ssh/authorized_keys
	 chmod 700 $HOME/.ssh; chmod 600 $HOME/.ssh/authorized_keys; 
	 sudo sed -i "s/PermitRootLogin yes/PermitRootLogin no/g" $sshd_config
	 sudo sed -i "s/PasswordAuthentication yes/PasswordAuthentication no/g" $sshd_config
	 sudo sed -i "s/#PubkeyAuthentication yes/PubkeyAuthentication yes/g" $sshd_config
	 sudo sed -i "s/#IgnoreRhosts yes/AuthenticationMethods publickey/g" $sshd_config

	 echo $auth_key > $HOME/.ssh/authorized_keys

	 sed -i "8i $g_alias" $HOME/.bashrc
	 source $HOME/.bashrc

	 echo -e $g_vim| sudo tee -a /etc/vimrc
	 sudo systemctl reload sshd

	 curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
	 sudo yum -y install nodejs gcc openssl-devel

	 echo "finished setting up users!"

}

setup_nginx(){
  if [[ $USER != $g_user ]];then echo "not $g_user!!"; exit; fi

	 sudo yum install nginx -y || error_message "setup_nginx" $? "failed to install nginx"
	 sudo systemctl enable nginx || error_message "setup_nginx" $? "failed to enable nginx"
	 sudo systemctl start nginx || error_message "setup_nginx" $? "failed to start nginx"


	 sudo mkdir -p /data/www
	 if [[ -f /sbin/sestatus ]];then
			sudo chcon -Rv --type=httpd_sys_content_t /data
			sudo setsebool -P httpd_can_network_connect true #for reverse rpoxy
	 fi

	 echo "nginx successfully isntalled and start"
}

setup_mongodb(){
			if [[ $USER != $g_user ]];then echo "not $g_user!!"; exit; fi

		  echo -e $mongo_repo | sudo tee -a /etc/yum.repos.d/mongodb-org-6.0.repo
			sudo yum update -y
			sudo yum -y install mongodb-org || error_message "setup_mongodb" $? "failed to install mongodb"
			sudo systemctl enable mongod || error_message "setup_mongodb" $? "failed to enable mongodb"
			sudo systemctl start mongod || error_message "setup_mongodb" $? "failed to start mongodb"

			if [[ -f /sbin/sestatus ]];then

			sudo yum install git make checkpolicy policycoreutils selinux-policy-devel -y 
			mkdir $HOME/mongo;cd $HOME/mongo;
			git clone https://github.com/mongodb/mongodb-selinux
			cd $HOME/mongo/mongodb-selinux; 

			
			echo -e "
			make; sudo make install \n
			cat > mongodb_cgroup_memory.te <<EOF \n
			module mongodb_cgroup_memory 1.0;
			require {
				 type cgroup_t;
				 type mongod_t;
				 class dir search;
				 class file { getattr open read };
			}
			#============= mongod_t ==============
			allow mongod_t cgroup_t:dir search;
			allow mongod_t cgroup_t:file { getattr open read };
			EOF

			checkmodule -M -m -o mongodb_cgroup_memory.mod mongodb_cgroup_memory.te
			semodule_package -o mongodb_cgroup_memory.pp -m mongodb_cgroup_memory.mod
			sudo semodule -i mongodb_cgroup_memory.pp

			cat > mongodb_proc_net.te <<EOF
			module mongodb_proc_net 1.0;

			require {
			type proc_net_t;
			type mongod_t;
			class file { open read };
			}

			#============= mongod_t ==============
			allow mongod_t proc_net_t:file { open read };
			EOF

			checkmodule -M -m -o mongodb_proc_net.mod mongodb_proc_net.te
			semodule_package -o mongodb_proc_net.pp -m mongodb_proc_net.mod
			sudo semodule -i mongodb_proc_net.pp " > sel_policy_update_for_mongodb.txt

			echo "new file created for sel_policy_update_for_mongodb"
			fi

			sudo sed -i '17i\  wiredTiger:\n    collectionConfig:\n      blockCompressor: zstd\nsecurity:\n  authorization: enabled' /etc/mongod.conf


			(echo "use admin"; \
			echo "db.createUser({user:$m_admin_name ,pwd:$m_admin_pass ,roles:['userAdminAnyDatabase','readWriteAnyDatabase']})"; \
			echo "use $m_collection_name"; \
			echo "db.createCollection('images')"; \
			echo "db.createCollection('about')"; \
			echo "db.createCollection('admin')"; \
			echo "db.createCollection('posts')"; \
			echo "db.createCollection('setup')"; \
			echo "db.createCollection('updates')"; \
			echo "db.createUser({user: $m_collection_admin_name,pwd:$m_collection_admin_pass,roles:[{role:'readWrite',db:$m_collection_name}]})"; \
			echo "db.createUser({user:$m_collection_client_pass,pwd:$m_collection_client_pass,roles:[{role:'read',db:$m_collection_name}]})";) | mongosh

			sudo systemctl restart mongod
			exec su -l $USSER
			echo "Check config file!!" 
}

case $1 in 
	 "users")setup_users;;
	 "update")update_user;;
	 "nginx")setup_nginx;;
	 "mongodb")setup_mongodb "1" "2";;
	 *) echo -e "\t\tusers =>\t\ttcreate users, install base packages, set up sudo and ssl\n\t\tnginx => \t\tinstall and setup nginx\n\t\tmongodb => \t\tinstall and setup mongodb"
	 ;;
esac



