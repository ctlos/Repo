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

# Agregar PKGBUILD y Actualizar Repo de GitHub
add() {
	pushd "$DIR" || exit
		# git submodule add --force https://aur.archlinux.org/"$pkg" ./pkgbuild/"$pkg"
		git clone https://aur.archlinux.org/"$pkg" ./pkgbuild/"$pkg"
        rm -rf ./pkgbuild/$pkg/.git
        rm -rf ./pkgbuild/$pkg/.gitignore
        # git add .
        # git commit -m "Add $pkg Submodule"
        # git push origin main
	popd || exit
}

# Eliminar PKGBUILD y Actualizar Repo de GitHub
delete() {
	pushd "$DIR" || exit
        git rm --cached "$DIR/pkgbuild/${OPTARG}"
        rm -rf "$DIR/pkgbuild/${OPTARG}"
        rm -rf "$DIR/.git/modules/pkgbuild/${OPTARG}"
        git config -f .gitmodules --remove-section "submodule.pkgbuild/${OPTARG}"
        git config -f .git/config --remove-section "submodule.pkgbuild/${OPTARG}"
        git add .
        git commit -m "Removed ${OPTARG} Submodule"
        # git push origin main
    popd || exit
}

# Compilar o Generar PKG
build() {
	git submodule update --recursive --remote

	pushd "$DIR/pkgbuild"
	for f in *; do
	    if [ -d "$f" ]; then
	        echo "Prosesando $f..."
	        pushd "$f"
	        if [ -f "PKGBUILD" ]; then
	            echo "Se Encontro el PKGBUILD de $f. Empezando a Compilar..."
	            # clean build force overwrite and sign
	            makepkg -C -s -f --sign --noconfirm
	        fi
	        popd
	    fi
	done

}

# Actualizar PKGBUILD
refresh() {
    pushd "$DIR/pkgbuild" > /dev/null 2>&1 || exit
    echo -e "\n\e[1;33mActualizando todos los submódulos...\e[0m"
    
    # Actualizar todos los submódulos
    for D in */; do
        cd "$D" || exit;
        echo -e "\n\e[1;34mActualizando $D\e[0m"
        # Limpiar los cambios no deseados realizados en los submódulos localmente
        git clean -x -d -f -q
        git stash --quiet 

        # Rebase
        git rebase HEAD master

        # Actualizar submódulos
        git pull origin master
        cd ..;
    sleep 0.25s;
    done
    popd > /dev/null 2>&1 || exit
}

# Crear Repositorio
deploy() {
    # Mover paquetes construidos en caché/
    pushd "$DIR/ctlos_dev/x86_64"
    for f in *${PKGEXT}; do > /dev/null 2>&1 || exit
        [ -f "$f" ] || break
        echo "Archivando $f..."
        mv "$f" "$BUILDDIR"
        mv "${f}.sig" "$BUILDDIR"
    done

    # Agregar paquetes construidos a la base de datos del repositorio
    for f in ${PKGDEST}/*${PKGEXT}; do
        [ -f "$f" ] || break
        echo "Desplegando $f..."
        mv "$f" "./"
        mv "${f}.sig" "./"
        repo-add -R -s -v "${REPONAME}.db.tar.gz" "$(basename "$f")"
    done || exit
    popd
}

# Actualizar Repositorio
sync() {
    # Killer-Hacker-Oficial
    rsync --copy-links --delete -avr "$DIR/ctlos_dev" -avr "$DIR/ctlos_repo" "$KILLER"

    # CTLOS Linux
    rsync --copy-links --delete -avr "$DIR/ctlos_dev" -avr "$DIR/ctlos_repo" "$CTLOS"

    rm -rfv "$DIR"/cache/*
}

# Opciones
[ $# -eq 0 ] && usage
while getopts "ad:rbh:" arg; do
    case $arg in
        a) shift $(( OPTIND - 1 )); for pkg in "$@"; do add; done ;;
        b) build; deploy; sync; exit 0 ;;
        r) refresh ;;
        d) delete ;;
        h) usage ;;
        *) usage ;;
    esac
done
