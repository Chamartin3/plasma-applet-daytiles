PLASMOID_ID := com.ogspain.daytiles
# Plasma 5: make install PKG=package-plasma5 KPT=kpackagetool5
PKG := package
KPT := kpackagetool6
VERSION := $(shell python3 -c "import json; print(json.load(open('$(PKG)/metadata.json'))['KPlugin']['Version'])")

.PHONY: install upgrade uninstall package run sync clean

sync:
	cp vendor/daytiles/index.js $(PKG)/contents/web/daytiles.js

install:
	$(KPT) -t Plasma/Applet --install $(PKG) 2>/dev/null || \
	    $(KPT) -t Plasma/Applet --upgrade $(PKG)

upgrade:
	$(KPT) -t Plasma/Applet --upgrade $(PKG) 2>/dev/null || \
	    $(KPT) -t Plasma/Applet --install $(PKG)

uninstall:
	$(KPT) -t Plasma/Applet --remove $(PLASMOID_ID)

run: upgrade
	plasmoidviewer -a $(PLASMOID_ID) -s 900x650

package:
	cd package && zip -r ../$(PLASMOID_ID)-$(VERSION)-plasma6.plasmoid . -x '*.swp' '*~'
	cd package-plasma5 && zip -r ../$(PLASMOID_ID)-$(VERSION)-plasma5.plasmoid . -x '*.swp' '*~'

clean:
	rm -f $(PLASMOID_ID)-*.plasmoid
