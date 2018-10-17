# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

SRC_URI="https://github.com/NVIDIA/nvidia-container-runtime/archive/v${PV}-1.tar.gz -> ${P}-1.tar.gz
"
KEYWORDS="~amd64 ~arm ~arm64 ~ppc64"

DESCRIPTION="NVIDIA container runtime hook"
HOMEPAGE="https://github.com/NVIDIA/nvidia-container-runtime"

LICENSE="BSD-3"
SLOT="0"
IUSE=""

DEPEND="dev-lang/go"
RDEPEND=""

src_unpack() {
	mkdir -p "${WORKDIR}/${P}/src/${PN}" || die
	tar -C "${WORKDIR}/${P}/src/${PN}" -x --strip-components 1 \
		-f "${DISTDIR}/${P}-1.tar.gz" || die
}

src_compile() {
	GOPATH=${S} \
		go get -ldflags "-s -w" -v ${PN}/hook/${PN}
}

src_install() {
	pushd bin || die
	dobin nvidia-container-runtime-hook
	popd || die
}
