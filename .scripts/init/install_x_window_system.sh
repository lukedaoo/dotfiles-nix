run() {
	install_command=$@
	echo "Install X Window system"
	$install_command xorg;
	$install_command xcompmgr;
    $install_command xorg-xinit;
    $install_command xclip;

    $install_command xcfe4;
    $install_command lightdm;
    $install_command lightdm-gtk-greeter;
}

run $@

