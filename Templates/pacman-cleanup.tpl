#	pacman -Rcns --noconfirm \
#		<package list> \
#		&& \
	pacman -Scc --noconfirm && \
        rm /var/lib/pacman/sync/* && \
	rm -rf /var/cache/*
