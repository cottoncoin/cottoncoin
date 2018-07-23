
Debian
====================
This directory contains files used to package cottond/cotton-qt
for Debian-based Linux systems. If you compile cottond/cotton-qt yourself, there are some useful files here.

## cotton: URI support ##


cotton-qt.desktop  (Gnome / Open Desktop)
To install:

	sudo desktop-file-install cotton-qt.desktop
	sudo update-desktop-database

If you build yourself, you will either need to modify the paths in
the .desktop file or copy or symlink your cottonqt binary to `/usr/bin`
and the `../../share/pixmaps/cotton128.png` to `/usr/share/pixmaps`

cotton-qt.protocol (KDE)

