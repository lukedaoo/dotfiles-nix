
#!/bin/bash
run() {
	install_command=$@
	echo "Install Typing method system"
	$install_command fcitx5;
	$install_command fcitx5-unikey;
    $install_command fcitx5-gtk;
}

run $@
