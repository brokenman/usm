# If PREFIX is set when calling then initialise with that,
# otherwise initialise with whatever is shown here.
PREFIX?=/usr
SYSCONFDIR=/etc
BINDIR=$(PREFIX)/bin
DATADIR=$(PREFIX)/share
PACKAGE_DATA_DIR=$(DATADIR)/$(TARGET)
LOCALSTATEDIR=/var/$(TARGET)
MANDIR=/usr/man/man8

# Strip comments from source files to reduce their size: true or false.
STRIP_COMMENTS?=true

# You shouldn't need to edit anything below this -----------------------
TARGET=`grep "TARGET=" main | sed 's|.*=||'`
VERSION=`grep "USMVERSION=" conf/usm.conf | sed 's|.*=||'`

.PHONY: all check dist install uninstall

all: check
	@echo
	@echo "Defaults:"
	@echo "    PREFIX=$(PREFIX)"
	@echo "    DESTDIR=$(DESTDIR)"
	@echo "    STRIP_COMMENTS=$(STRIP_COMMENTS)"
	@echo
	@echo "Usage examples:"
	@echo "    make install"
	@echo "    make STRIP_COMMENTS=false install"
	@echo "    make PREFIX=/usr install"
	@echo "    make DESTDIR=$(TARGET)-$(VERSION) install"
	@echo "    make uninstall"
	@echo "    make PREFIX=/usr uninstall"
	@echo
	
check:
	@if [ -z "$(TARGET)" -o -z "$(VERSION)" ]; then \
		echo "Error: TARGET and/or VERSION not set."; \
		exit 1; \
	fi
	
dist: check
	rm -rf $(TARGET)-$(VERSION)
	mkdir $(TARGET)-$(VERSION)
	cp -r txt png func* main Makefile conf packagetools usmgui *.man \
		$(TARGET).desktop $(TARGET)-$(VERSION)
	tar czpf $(TARGET)-$(VERSION).tar.gz $(TARGET)-$(VERSION)/
	rm -rf $(TARGET)-$(VERSION)

install: check
	mkdir -p $(DESTDIR)$(LOCALSTATEDIR)/{local,alien,salix,slackware,slacky,ponce}
	mkdir -p $(DESTDIR)$(BINDIR)
	mkdir -p $(DESTDIR)$(DATADIR)/applications
	mkdir -p $(DESTDIR)$(DATADIR)/icons/hicolor/48x48/apps
	mkdir -p $(DESTDIR)$(PACKAGE_DATA_DIR)
	mkdir -p $(DESTDIR)$(SYSCONFDIR)/$(TARGET)

	if [ "$(STRIP_COMMENTS)" = true ] ; then \
		sed -e '/## /d' -e '/ ##/d' \
			-e "s|^\(PACKAGE_DATA_DIR=\)\(.*\)|\1$(PACKAGE_DATA_DIR)|" \
			main > $(DESTDIR)$(BINDIR)/$(TARGET); \
	else \
		sed -e "s|^\(PACKAGE_DATA_DIR=\)\(.*\)|\1$(PACKAGE_DATA_DIR)|" \
			main > $(DESTDIR)$(BINDIR)/$(TARGET); \
	fi
	chmod 755 $(DESTDIR)$(BINDIR)/$(TARGET)

	sed -e "s|^\(Icon=\)\(.*\)|\1$(DATADIR)/icons/hicolor/48x48/apps/$(TARGET).png|" \
		$(TARGET).desktop > $(DESTDIR)$(DATADIR)/applications/$(TARGET).desktop; \
	cp png/usm* $(DESTDIR)$(DATADIR)/icons/hicolor/48x48/apps/; \
	cp conf/*.conf $(DESTDIR)$(SYSCONFDIR)/$(TARGET); \
	echo "PREFIX=$(PREFIX)" >> $(DESTDIR)$(SYSCONFDIR)/$(TARGET)/$(TARGET).conf; \
	cp txt/mirror* txt/supp* $(DESTDIR)$(SYSCONFDIR)/$(TARGET); \
	cp -r i18n/usr $(DESTDIR); \
	cp usmgui $(DESTDIR)$(BINDIR)

	for func in func*; do \
		if [ "$(STRIP_COMMENTS)" = true ] ; then \
			sed -e '/## /d' -e '/ ##/d' $$func > $(DESTDIR)$(PACKAGE_DATA_DIR)/$$func; \
		else \
			cp $$func $(DESTDIR)$(PACKAGE_DATA_DIR); \
		fi; \
		chmod 755 $(DESTDIR)$(PACKAGE_DATA_DIR)/$$func; \
	done
	for func in packagetools; do \
		if [ "$(STRIP_COMMENTS)" = true ] ; then \
			sed -e '/## /d' -e '/ ##/d' packagetools > $(DESTDIR)$(BINDIR)/packagetools; \
		else \
			cp packagetools $(DESTDIR)$(BINDIR); \
		fi; \
		chmod 755 $(DESTDIR)$(BINDIR)/packagetools; \
	done
	cp txt/README $(DESTDIR)$(PACKAGE_DATA_DIR); \
	chmod 755 $(DESTDIR)$(BINDIR)/usmgui; \
	install -Dm644 $(TARGET).man $(DESTDIR)/$(MANDIR)/$(TARGET).8; \
	gzip -9 $(DESTDIR)/$(MANDIR)/$(TARGET).8
	
uninstall: check
	rm -f $(DESTDIR)$(BINDIR)/$(TARGET)
	rm -f $(DESTDIR)$(BINDIR)/$(TARGET)gui
	rm -f $(DESTDIR)$(BINDIR)/packagetools
	rm -f $(DESTDIR)$(DATADIR)/applications/$(TARGET).desktop
	rm -f $(DESTDIR)$(DATADIR)/icons/hicolor/48x48/apps/usm*
	rm -rf $(DESTDIR)$(PACKAGE_DATA_DIR)
	rm -rf $(DESTDIR)$(SYSCONFDIR)/$(TARGET)
	rm -rf $(PACKAGE_DATA_DIR)
	rm -f $(DESTDIR)/$(MANDIR)/$(TARGET).8*
