#!/bin/bash
DIR="$(cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

source "$DIR/config"

BUILDDIR="$DIR/cache"
PKGDEST="$BUILDDIR/bin"

set -e

pushd "$DIR/../ctlos_dev/x86_64"
for f in *${PKGEXT}; do
    [ -f "$f" ] || break
    echo "Archiving $f..."
    mv "$f" "$BUILDDIR"
    mv "${f}.sig" "$BUILDDIR"
done
for f in ${PKGDEST}/*${PKGEXT}; do
    [ -f "$f" ] || break
    echo "Deploying $f..."
    mv "$f" "./"
    mv "${f}.sig" "./"
    repo-add -s -v "${REPONAME}.db.tar.gz" "$(basename "$f")"
done
popd
