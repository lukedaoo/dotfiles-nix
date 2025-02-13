run() {
	install_command=$@
	echo "[INFO] Install X Window system"
	$install_command xorg --noconfirm >> /dev/null;
	$install_command xcompmgr --noconfirm >> /dev/null;
    $install_command xorg-xinit --noconfirm >> /dev/null;
    $install_command xclip --noconfirm >> /dev/null;

    $install_command xcfe4 --noconfirm >> /dev/null;
    $install_command lightdm --noconfirm >> /dev/null;
    $install_command lightdm-gtk-greeter --noconfirm >> /dev/null;
}

run $@

