#	yum remove -y \
#		<packages> \
#		&& \
	microdnf clean all && \
	rm -rf /var/cache/dnf && \
	yum autoremove -y && \
	yum clean all && \
	rm -rf /var/cache/yum
