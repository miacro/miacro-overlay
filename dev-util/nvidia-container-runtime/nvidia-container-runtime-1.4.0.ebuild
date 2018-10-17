# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

EGIT_COMMIT="v${MY_PV}"
RUNC_PV="1.0.0_rc5-r1"
EGO_PN="github.com/opencontainers/runc"
RUNC_COMMIT="4fc53a81fb7c994640722ac585fa9ca548971871" # Change this when you update the ebuild
SRC_URI="https://${EGO_PN}/archive/${RUNC_COMMIT}.tar.gz -> runc-${RUNC_PV}.tar.gz
	https://github.com/NVIDIA/nvidia-container-runtime/archive/v${PV}-1.tar.gz -> ${P}-1.tar.gz
"
KEYWORDS="~amd64 ~arm ~arm64 ~ppc64"
inherit golang-build golang-vcs-snapshot

DESCRIPTION="NVIDIA container runtime"
HOMEPAGE="https://github.com/NVIDIA/nvidia-container-runtime"

LICENSE="BSD-3"
SLOT="0"
IUSE="+ambient apparmor hardened +seccomp"

RDEPEND="
	apparmor? ( sys-libs/libapparmor )
	seccomp? ( sys-libs/libseccomp )
	dev-util/nvidia-container-runtime-hook
"

src_unpack() {
	golang-vcs-snapshot_src_unpack runc-${RUNC_PV}.tar.gz
	mkdir -p "${WORKDIR}/patch/${P}" || die
	tar -C "${WORKDIR}/patch/${P}" -x --strip-components 1 \
		-f "${DISTDIR}/${P}-1.tar.gz" || die
}

src_prepare() {
	cd "${WORKDIR}/${P}/src/${EGO_PN%/...}" || die
	eapply ${WORKDIR}/patch/${P}/runtime/runc/${RUNC_COMMIT}/*

	eapply_user
}

src_compile() {
	# Taken from app-emulation/docker-1.7.0-r1
	export CGO_CFLAGS="-I${ROOT}/usr/include"
	export CGO_LDFLAGS="$(usex hardened '-fno-PIC ' '')
		-L${ROOT}/usr/$(get_libdir)"

	# build up optional flags
	local options=(
		$(usex ambient 'ambient')
		$(usex apparmor 'apparmor')
		$(usex seccomp 'seccomp')
	)

	GOPATH="${S}"\
		emake BUILDTAGS="${options[*]}" \
		COMMIT="${RUNC_COMMIT}" -C src/${EGO_PN}

	cd "src/${EGO_PN%/...}" || die
	mv runc nvidia-container-runtime || die
}

src_install() {
	pushd src/${EGO_PN} || die
	dobin nvidia-container-runtime
	dodoc README.md PRINCIPLES.md
	popd || die
}
