name=$1
if [[ -f /bin/nmcli ]];then
	 (echo "echo $name"; echo "set ipv6.method disabled"; echo "save"; echo "quit") | nmcli 
fi


