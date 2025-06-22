PLASMOID_ID := com.ogspain.daytiles
PKG := package

.PHONY: install upgrade uninstall package run

install:
	kpackagetool5 -t Plasma/Applet --install $(PKG)

upgrade:
	kpackagetool5 -t Plasma/Applet --upgrade $(PKG)

uninstall:
	kpackagetool5 -t Plasma/Applet --remove $(PLASMOID_ID)

run:
	plasmoidviewer -a $(PKG)

package:
	cd $(PKG) && zip -r ../$(PLASMOID_ID).plasmoid . -x '*.swp' '*~'
