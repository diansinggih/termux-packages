TERMUX_PKG_HOMEPAGE=https://www.tug.org/texlive/tlmgr.html
TERMUX_PKG_DESCRIPTION="TeX Lives package manager"
TERMUX_PKG_MAINTAINER="Henrik Grimler @Grimler91"
TERMUX_PKG_VERSION=20180414
TERMUX_PKG_REVISION=2
TERMUX_PKG_SRCURL="ftp://ftp.tug.org/texlive/historic/${TERMUX_PKG_VERSION:0:4}/install-tl-unx.tar.gz"
TERMUX_PKG_SHA256="82c13110852af162c4c5ef1579fa2f4f51c2040850ec02fb7f97497da45eb446"
TERMUX_PKG_DEPENDS="perl, wget, gnupg, xz-utils, texlive"
TERMUX_PKG_CONFFILES="share/texlive/tlpkg/texlive.tlpdb"
TERMUX_PKG_CONFLICTS="texlive (<< 20180414-1)"
TERMUX_PKG_PLATFORM_INDEPENDENT=yes

TL_ROOT=$TERMUX_PREFIX/share/texlive
TL_BINDIR=$TERMUX_PREFIX/bin

termux_step_make () {
	mkdir -p $TL_ROOT/{tlpkg/{backups,tlpobj},texmf-var/web2c}
	cp -r $TERMUX_PKG_SRCDIR/* $TL_ROOT/
	cp $TERMUX_PKG_BUILDER_DIR/texlive.tlpdb $TL_ROOT/tlpkg/
}

termux_step_post_make_install () {
	# Replace tlmgr link with a small wrapper that prevents error on "tlmgr update --self"
	rm -rf $TL_BINDIR/tlmgr
	ln -sf ../share/texlive/texmf-dist/scripts/texlive/tlmgr.pl $TL_BINDIR/tlmgr.ln
	echo "#!$TERMUX_PREFIX/bin/sh" > $TL_BINDIR/tlmgr
	echo "termux-fix-shebang $TL_ROOT/texmf-dist/scripts/texlive/tlmgr.pl" >> $TL_BINDIR/tlmgr
	echo "sed -i 's%\`kpsewhich -var-value=SELFAUTOPARENT\`);%\`kpsewhich -var-value=TEXMFROOT\`);%g' $TL_ROOT/texmf-dist/scripts/texlive/tlmgr.pl" >> $TL_BINDIR/tlmgr
	echo "sed -i 's%TEXMFROOT = \$SELFAUTOPARENT%TEXMFROOT = \$SELFAUTODIR/share/texlive%g' $TL_ROOT/texmf-dist/web2c/texmf.cnf" >> $TL_BINDIR/tlmgr
	echo "sed -i '"'s@`/bin/sh@`'$TERMUX_PREFIX"/bin/sh@g' ${TL_ROOT}/tlpkg/TeXLive/TLUtils.pm" >> $TL_BINDIR/tlmgr
	echo 'tlmgr.ln "$@"' >> $TL_BINDIR/tlmgr
	chmod 0744 $TL_BINDIR/tlmgr
}

termux_step_create_debscripts () {
	echo "#!$TERMUX_PREFIX/bin/bash" > postinst
	echo "mkdir -p $TL_ROOT/{tlpkg/{backups,tlpobj},texmf-var/{web2c,tex/generic/config}}" >> postinst
	echo "export TMPDIR=$TERMUX_PREFIX/tmp" >> postinst
	echo "echo Updating tlmgr" >> postinst
	echo "tlmgr update --self" >> postinst
	echo "echo Generating language files and setting up symlinks" >> postinst
	echo "tlmgr -q generate language" >> postinst
	echo "exit 0" >> postinst
	chmod 0755 postinst
	# Don't remove installed stuff on removal, do that in the pkg texlive instead.
}

TERMUX_PKG_RM_AFTER_INSTALL="
share/texlive/LICENSE.TL
share/texlive/LICENSE.CTAN
share/texlive/release-texlive.txt
share/texlive/install-tl
share/texlive/texmf-dist/scripts/texlive/uninstall-win32.pl
share/texlive/texmf-dist/scripts/texlive/tlmgr-gui.pl
share/texlive/texmf-dist/web2c
share/texlive/tlpkg/installer/COPYING.MinGW-runtime.txt
share/texlive/tlpkg/installer/ctan-mirrors.pl
share/texlive/tlpkg/installer/install-menu-perltk.pl
share/texlive/tlpkg/installer/install-menu-text.pl
share/texlive/tlpkg/installer/install-menu-wizard.pl
share/texlive/tlpkg/installer/install-tl.html
share/texlive/tlpkg/installer/installer-options.txt
share/texlive/tlpkg/installer/texlive.png
share/texlive/tlpkg/installer/tl-cmd.bat
share/texlive/tlpkg/installer/tl-tray-menu.ini
share/texlive/tlpkg/installer/tracked-install.pl
share/texlive/tlpkg/installer/wget
share/texlive/tlpkg/installer/xz"
