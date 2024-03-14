#!/bin/bash

# Ruta del archivo auth.log
AUTH_LOG="/home/cristianinbits/SSOO/Practica1/auth.log"

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
	exit 3

# un argumento
elif test $# -eq 1; then
	# --login
	if test "$1" = "--login"; then
		echo ""
		echo "las últimas 5 conexiones REMOTAS son:"
		echo "-------------------------------------------"
		grep -E "sshd\[[0-9]+\]: Accepted password for [a-zA-Z0-9_\-]+ from [0-9.]+ port [0-9]+ ssh2" $AUTH_LOG | cut -d ' ' -f1,2,3,9,11 | tail -5
		echo ""
		echo "las últimas 5 conexiones LOCALES son:"
		echo "-------------------------------------------"
		grep -E "pam_unix\(.*\): session opened for user" ./auth.log | grep -Ev "root|CRON|sshd" | cut -d ' ' -f1,2,3,11 | tail -5
		exit 5
	fi

	# -u
	if test "$1" = "-u"; then
		echo "Error: Se debe proporcionar el nombre del usuario para el parámetro -u"
		exit 3

	# -g
	elif test "$1" = "-g"; then
		echo "Error: Se debe proporcionar el nombre del grupo para el parámetro -g"
		exit 3

	# --help
	elif test "$1" = "--help"; then
		echoHelp

	# resto de caso
	else
		echo "Error: Opción no vállida. Use --help para obtener ayuda."
		exit 2
	fi

# ningun argumento 
elif test $# -eq 0; then
	echoHelp
fi
