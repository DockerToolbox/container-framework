	# Use remove not erase as remove will attempt to remove dependancies
#	tdnf remove -y \
#		<package list> \
#		&& \
	tdnf clean all && \
	rm -rf /var/cache/tdnf
