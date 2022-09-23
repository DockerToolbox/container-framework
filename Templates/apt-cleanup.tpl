#        apt-get -y remove --purge \
#                <package list> \
#                && \
        apt-get -y autoremove && \
        rm -rf /var/lib/apt/lists/*
