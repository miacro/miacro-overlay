# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit git-r3 versionator

DESCRIPTION="NVIDIA container runtime library"
HOMEPAGE="https://github.com/NVIDIA/libnvidia-container"
# SRC_URI="https://github.com/NVIDIA/libnvidia-container/archive/v${PV}.tar.gz -> ${P}.tar.gz"
EGIT_REPO_URI="https://github.com/NVIDIA/libnvidia-container.git"
EGIT_OVERRIDE_COMMIT_NVIDIA_LIBNVIDIA_CONTAINER=v${PV}

LICENSE="BSD-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="+elf +seccomp"
MY_FLAGS=
MY_MAJOR_VERSON=$(get_major_version)

DEPEND="seccomp? ( sys-libs/libseccomp )"
RDEPEND="${DEPEND}"

my_configure() {
	if use elf ; then
		MY_FLAGS="${MY_FLAGS} WITH_LIBELF=yes"
	else
		MY_FLAGS="${MY_FLAGS} WITH_LIBELF=no"
	fi

	if use seccomp ; then
		MY_FLAGS="${MY_FLAGS} WITH_SECCOMP=yes"
	else
		MY_FLAGS="${MY_FLAGS} WITH_SECCOMP=no"
	fi

	MY_FLAGS="${MY_FLAGS} WITH_TIRPC=yes"
}

src_unpack() {
	git-r3_src_unpack "$@"

	cd ${WORKDIR}/${P} || die
	my_configure
	make ${MY_FLAGS} deps || die
}

src_configure() {
	return
}

src_compile() {
	CFLAGS=-Ideps/usr/local/include/tirpc
	emake ${MY_FLAGS} all
}

src_install() {
	dolib.so ${PN}.so.${PV}
	dolib.a ${PN}.a
	dosym ${PN}.so.${PV} /usr/$(get_libdir)/${PN}.so.${MY_MAJOR_VERSON}
	dobin  nvidia-container-cli
}
