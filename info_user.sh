#!/bin/bash

#######  DOCUMENTACIÓN
# Definiciones de códigos de salida
SUCCES=0
ERROR_GENERIC=1
ERROR_FILE_NOT_FOUND=2
ERROR_PERMISSION_DENIED=3

# Ruta del archivo auth.log
AUTH_LOG="./auth.log"
# Ruta del archivo info_user.log
LOG_FILE="./info_user.log"

{
#Mensajes de salida
echo ""
echo "----------------------------------------"
echo "Usuario que ejecuta el script: $(whoami)"
echo "Fecha y hora de ejecución: $(date)"
echo "Versión de Bash: $BASH_VERSION"
echo "----------------------------------------"
echo ""


# Ruta del archivo auth.log
AUTH_LOG="./auth.log"

# Funcion Output de --help y 0 argumentos
function echoHelp(){
	echo -e "$0 [-u usuario]|[-g grupo]|[--login]|[--help]\n\t-u usuario\tMostrar información sobre el usuario especificado\n\t-g grupo\tMostrar usuarios asociados al grupo especificado\n\t--login \tMostrar los 5 últimos usuarios que han accedido al sistema\n\t--help \t\tMostrar ayuda"
	exit $SUCCES
}

# más de dos argumentos
if test $# -gt 2; then
	echo -e "La cantidad de parámteros introducidos es excesiva.\nUse --help para obtener ayuda."
	exit 2

# dos argumentos
elif test $# -eq 2; then
	# -u
	if test "$1" = "-u"; then
		# Comprobar si uario existe
		if cat /etc/passwd | grep -wq "^$2:*"; then
			# Comprobar si el usuario introducio es el actual de la sesión
			if who | grep -wq "$2"; then
				echo "el usuario $2 está conectado actualmente"
				echo ""
			else
				echo "el usuario $2 NO está conectado actualmente"
				echo ""
			fi
			# Mostrar las 5 conexiones REMOTAS:
		 	echo ""
			echo "las últimas 5 conexiones REMOTAS son:"
			echo "---------------------------------------"
			grep -E "sshd\[[0-9]+\]: Accepted password for [a-zA-Z0-9_\-]+ from [0-9.]+ port [0-9]+ ssh2" ./auth.log | grep -w "$2" | cut -d ' ' -f1,2,3,11 | tail -5
			echo ""
			# Mostrar las 5 conexiones LOCALES:
			echo "las últimas 5 conexiones LOCALES son:"
			echo "-------------------------------------------"
			grep -E "pam_unix\(.*\): session opened for user" $AUTH_LOG | grep -Ev "root|CRON|ssh" | grep -w "$2" | cut -d ' ' -f1,2,3 | tail -5
			echo ""
			# Grupos a los que pertenece
			grupos=$(cat /etc/group | grep -w "$2" | cut -d: -f1 | tr '\n' "," | sed 's/,$//')
			# ---Comprobar si pertenece a algún grupo:
			if test -z "$grupos";then
				echo "el usuario $2 no existe en el sistema"
				echo ""
			else
				echo "$2 pertenece a los siguientes grupos : $grupos"
				echo ""
			fi
			# Comprobar el espacio ocupado por la carpeta del usuario
			echo "Espacio ocupado por la carpeta de $2 (/home/$2): $(du -sh /home/$2 | cut -f1)"
			echo ""
			# Comprobar cuantos archivos > 1MB contiene
			echo "Contiene $(find /home/$2 -type f -size +1M | wc -l) ficheros mayores de 1MB en la carpeta /home/$2"
			exit 1

		# Usuario NO existe
		else
			echo "El usuario $2 no existe en el sistema"
			exit 1
		fi
	# -g
	elif test "$1" = "-g"; then
		# Comprobar si el grupo existe:
		grupos=$(cat /etc/group | grep -w "$2" | cut -d: -f1)
		if test -z "$grupos"; then
			echo "El grupo $2 no existe en el sistema"
			exit 3
		else
			echo "Usuarios en el grupo $2:"
			echo "$grupos"
			exit 2
		fi
	fi

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
		grep -E "pam_unix\(.*\): session opened for user" $AUTH_LOG | grep -Ev "root|CRON|sshd" | cut -d ' ' -f1,2,3,11 | tail -5
		exit 2
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
} | tee -a $LOG_FILE
