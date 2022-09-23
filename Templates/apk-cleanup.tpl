#	apk del <package> && \
	rm -rf /var/cache/apk/* && \
	sed -i -e "s/bin\/ash/bin\/bash/" /etc/passwd
