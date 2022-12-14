run() {
	platform=$1;
	distro=$2;

	if [[ $platform == "linux" ]]; then
		if [[ $distro == "debian" ]]; then
			echo "sudo apt install ";
			return;
		fi
		if [[ $distro == "arch" ]]; then
			echo "sudo pacman -S ";
			return;
		fi

	elif [[ $platform == "macos" ]]; then 
		echo "brew install ";
		return;
	else 
		echo "unknown"
		return;
	fi
}

run $@
