PLASMOID_ID := com.ogspain.daytiles
PKG := package
VERSION := $(shell python3 -c "import json; print(json.load(open('$(PKG)/metadata.json'))['KPlugin']['Version'])")

.PHONY: install upgrade uninstall package run sync clean

sync:
	cp vendor/daytiles/index.js $(PKG)/contents/web/daytiles.js

install:
	kpackagetool5 -t Plasma/Applet --install $(PKG)

upgrade:
	kpackagetool5 -t Plasma/Applet --upgrade $(PKG)

uninstall:
	kpackagetool5 -t Plasma/Applet --remove $(PLASMOID_ID)

run:
	plasmoidviewer $(PKG)

run-installed:
	plasmoidviewer -a $(PLASMOID_ID)

package:
	cd $(PKG) && zip -r ../$(PLASMOID_ID)-$(VERSION).plasmoid . -x '*.swp' '*~'

clean:
	rm -f $(PLASMOID_ID)-*.plasmoid
