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
	echo -e "Add" ;
}

# Eliminar PKGBUILD
delete() {
	echo -e "Delete" ;
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