#!/bin/bash

# Funcion Output de --help y 0 argumentos
function echoHelp(){
	echo -e "$0 [-u usuario]|[-g grupo]|[--login]|[--help]\n\t-u usuario\tMostrar información sobre el usuario especificado\n\t-g grupo\tMostrar usuarios asociados al grupo especificado\n\t--login \tMostrar los 5 últimos usuarios que han accedido al sistema\n\t--help \t\tMostrar ayuda"
	exit 1
}

# más de dos argumentos
if test $# -gt 2; then
	echo -e "La cantidad de parámteros introducidos es excesiva.\nUse --help para obtener ayuda."
	exit 2

# dos argumentos
elif test $# -eq 2; then
	# -u
	
	# -g
	echo "u-g"

# un argumento
elif test $# -eq 1; then
	# --login
	

	# -u
	if test "$1" = "-u"; then
		echo "Error: Se debe proporcionar el nombre del usuario para el parámetro -u"
		exit 1

	# -g
	elif test "$1" = "-g"; then
		echo "Error: Se debe proporcionar el nombre del grupo para el parámetro -g"
		exit 1

	# --help
	elif test "$1" = "--help"; then
		echoHelp

	# resto de caso
	else
		echo "Error: Opción no vállida. Use --help para obtener ayuda."
		exit 1
	fi

# ningun argumento 
elif test $# -eq 0; then
	echoHelp
fi
