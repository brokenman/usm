usm
===

Unified Slackware Package Manager

A slackware package manager that resolves dependencies and searches across multiple slackware repositories.
It includes a CLI (/usr/bin/usm) and GUI (/usr/bin/usmgui)

Beta only runs on slackware 14.1

By default the build strips all comments

Example build usages:

    make STRIP_COMMENTS=false DESTDIR=/tmp/usmbuild install
    
    make uninstall
    
    make PREFIX=/usr install


[Get the slackware package here](http://sourceforge.net/projects/usm)
