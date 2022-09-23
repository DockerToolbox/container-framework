#	yum remove -y \
#		<package list> \
#		--remove-leaves \
#		&& \
	yum clean all && \
	rm -rf /var/cache/yum
