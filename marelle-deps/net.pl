% This came from Greg V's dotfiles:
%      https://github.com/myfreeweb/dotfiles
% Feel free to steal it, but attribution is nice

managed_pkg(ca_root_nss).
managed_pkg(libressl).

managed_pkg(w3m).
depends(w3m, freebsd, [libressl, ca_root_nss]).

managed_pkg(curl).
depends(curl, freebsd, [libressl, ca_root_nss]).

managed_pkg(wget).
depends(wget, freebsd, [libressl, ca_root_nss]).

pkg(openssh).
depends(openssh, freebsd, [libressl]).
installs_with_ports(openssh, 'security/openssh-portable', 'WITH="AES_THREADED BSM" WITHOUT="NONECIPHER"').
depends(openssh, osx, ['dupes-tap']).
installs_with_brew(openssh, 'openssh', '--with-ldns').

managed_pkg(openntpd).
idempotent_pkg(openntpd_enabled).
depends(openntpd_enabled, _, [openntpd]).
execute(openntpd_enabled, freebsd) :-
	sysrc('ntpd_enable', 'NO'),
	sysrc('openntpd_enable').

idempotent_pkg(unbound_enabled).
execute(unbound_enabled, freebsd) :-
	sudo_sh('cp -f ./marelle-tpls/unbound.conf /var/unbound'),
	lo_alias('53', '127.0.0.53'),
	sysrc('local_unbound_enable'),
	sudo_sh('echo "nameserver 127.0.0.53" > /etc/resolv.conf'),
	sudo_sh('echo "supersede domain-name-servers 127.0.0.53;" > /etc/dhclient.conf').

managed_pkg(i2p).
managed_pkg(javaservicewrapper).
pkg(i2p_installed).
depends(i2p_installed, _, [i2p]).
depends(i2p_installed, freebsd, [i2p, javaservicewrapper]).
met(i2p_installed, freebsd) :- isfile('/home/_i2p/i2p/i2psvc').
meet(i2p_installed, freebsd) :-
	sudo_sh('pw useradd -n _i2p -m || true'),
	sysrc('i2p_enable'),
	sysrc('i2p_user', '_i2p'),
	sudo_sh('service i2p install >/dev/null 2>/dev/null'),
	sudo_sh('cp -f /usr/local/bin/javaservicewrapper /home/_i2p/i2p/i2psvc'),
	sudo_sh('cp -f /usr/local/lib/javaservicewrapper/lib/wrapper.jar /home/_i2p/i2p/lib/'),
	sudo_sh('cp -f /usr/local/lib/javaservicewrapper/lib/libwrapper.so /home/_i2p/i2p/lib/'),
	sudo_sh('sed -e s/\\$SYSTEM_java_io_tmpdir/\\\\/var\\\\/tmp/ -e s/\\$INSTALL_PATH/./ -I bak /home/_i2p/i2p/wrapper.config'),
	sudo_sh('chmod 0777 /home/_i2p/i2p/i2psvc /home/_i2p/i2p/lib/wrapper.jar /home/_i2p/i2p/lib/libwrapper.so').
idempotent_pkg(i2p_enabled).
depends(i2p_enabled, _, [i2p_installed]).
execute(i2p_enabled, freebsd) :-
	sysrc('i2p_user', '_i2p'),
	sysrc('i2p_enable').

managed_pkg(tor). % does not build with libressl :(
idempotent_pkg(tor_enabled).
depends(tor_enabled, _, [tor, freebsd_conf_common]).
execute(tor_enabled, freebsd) :-
	sudo_sh('cat ./marelle-tpls/torrc | sed -e s/%torpwd%/`cat /usr/local/etc/tor/torpwd`/g > /usr/local/etc/tor/torrc'),
	sudo_sh('chown _tor:_tor /usr/local/etc/tor'),
	sudo_sh('chown _tor:_tor /usr/local/etc/tor/torrc'),
	sudo_sh('chgrp _tor /dev/pf'),
	sudo_sh('chmod 660 /dev/pf'),
	sudo_sh('touch /var/log/tor'),
	sudo_sh('chown _tor:_tor /var/log/tor'),
	sysrc('tor_enable'),
	lo_alias('4', '127.0.0.5').

managed_pkg(syncthing).
