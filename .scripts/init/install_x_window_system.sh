run() {
	install_command=$@
	echo "Install X Window system"
	$install_command xorg;
	$install_command xcompmgr;
}

run $@

