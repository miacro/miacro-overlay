# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

CUDA_PV=9.0

inherit versionator

DESCRIPTION="NVIDIA Accelerated Deep Learning on GPU library"
HOMEPAGE="https://developer.nvidia.com/cuDNN"

MY_PV_MAJOR=$(get_major_version)
MY_VERSION_COMPONENTS=$(get_version_components)
MY_PV_MINOR=${MY_VERSION_COMPONENTS#* }
MY_PV_MINOR=${MY_PV_MINOR% *}
SRC_URI="cudnn-${CUDA_PV}-linux-x64-v${MY_PV_MAJOR}.${MY_PV_MINOR}.tgz"

SLOT="0/7"
KEYWORDS="~amd64 ~amd64-linux"
RESTRICT="fetch"
LICENSE="NVIDIA-cuDNN"

S="${WORKDIR}"

DEPEND="=dev-util/nvidia-cuda-toolkit-${CUDA_PV}*"
RDEPEND="${DEPEND}"

src_install() {
	insinto /opt
	doins -r *
}
