#!/bin/bash

# Lista el Directorio Actual
DIR="$(cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# Agregar el Archivo con la Configuracion
source "$DIR/config"

# Exporta las Variables de Archivo de Configuracion
export PKGEXT
export COMPRESSXZ
export PACKAGER
export GPGKEY
export BUILDDIR="$DIR/cache"
export PKGDEST="$BUILDDIR/bin"
export SRCDEST="$BUILDDIR/src"

# Salga inmediatamente si un comando sale con un estado distinto de cero
set -e
shopt -s expand_aliases

# Mustra Menu de Ayuda
usage() {
    echo -e "Menu de Ayuda" ;
}

# Agregar PKGBUILD
add() {
	
	cd $DIR

	git submodule add --force https://aur.archlinux.org/"$pkg" ./pkgbuild/"$pkg"
}

# Eliminar PKGBUILD
delete() {
	pushd "$DIR" || exit
        git rm --cached "$DIR/pkgbuild/${OPTARG}"
        rm -rf "$DIR/pkgbuild/${OPTARG}"
        # git commit -m "Removed ${OPTARG} submodule"
        rm -rf "$DIR/.git/modules/pkgbuild/${OPTARG}"
        git config -f .gitmodules --remove-section "submodule.pkgbuild/${OPTARG}"
        git config -f .git/config --remove-section "submodule.pkgbuild/${OPTARG}"
    popd || exit
}

# Compilar o Generar PKG
build() {
	echo -e "Build" ;
}

# Actualizar PKGBUILD
refresh() {
	echo -e "Refresh" ;
}

# Crear Repositorio
deploy() {
	echo -e "Deploy" ;
}

# Actualizar Repositorio
sync() {
	echo -e "Sync" ;
}

# Opciones
[ $# -eq 0 ] && usage
while getopts "ad:rbh:" arg; do
    case $arg in
        a) shift $(( OPTIND - 1 )); for pkg in "$@"; do add; done ;;
        b) build; deploy; sync; grep -rnw 'pkgbuild/' -e 'Tiempo de ejecución total'; exit 0 ;;
        r) refresh ;;
        d) delete ;;
        h) usage ;;
        *) usage ;;
    esac
done
