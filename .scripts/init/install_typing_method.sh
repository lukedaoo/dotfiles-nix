
#!/bin/bash
run() {
	install_command=$@
	echo "[INFO] Install Typing method system"
	$install_command fcitx5 --noconfirm >> /dev/null;
	$install_command fcitx5-unikey --noconfirm >> /dev/null;
    $install_command fcitx5-gtk --noconfirm >> /dev/null;
}

run $@
