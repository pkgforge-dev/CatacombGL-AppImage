#!/bin/sh

set -eu

ARCH=$(uname -m)

echo "Installing package dependencies..."
echo "---------------------------------------------------------------"
pacman -Syu --noconfirm \
    cmake    \
    libdecor \
    sdl2

echo "Installing debloated packages..."
echo "---------------------------------------------------------------"
get-debloated-pkgs --add-common --prefer-nano

echo "Building CatacombGL..."
echo "---------------------------------------------------------------"
REPO="https://github.com/ArnoAnsems/CatacombGL"
if [ "${DEVEL_RELEASE-}" = 1 ]; then
    echo "Making nightly build of CatacombGL..."
    echo "---------------------------------------------------------------"
    VERSION="$(git ls-remote "$REPO" HEAD | cut -c 1-9 | head -1)"
    git clone "$REPO" ./CatacombGL
else
	echo "Making stable build of CatacombGL..."
	VERSION="$(git ls-remote --tags --sort="v:refname" "$REPO" | tail -n1 | sed 's/.*\///; s/\^{}//; s/^v//')"
	git clone --branch v"$VERSION" --single-branch "$REPO" ./CatacombGL
fi
echo "$VERSION" > ~/version

mkdir -p ./AppDir/bin
cd ./CatacombGL
mkdir build && cd build
cmake .. -DCMAKE_BUILD_TYPE=Release
make -j$(nproc)
mv -v CatacombGL ../../AppDir/bin
