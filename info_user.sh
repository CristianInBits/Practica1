#!/bin/bash

#######  DOCUMENTACIÓN
# Definiciones de códigos de salida
SUCCES=0
ERROR_GENERIC=1
ERROR_NOT_FOUND=2
ERROR_PERMISSION_DENIED=3
ERROR_ARGS=4

# Ruta del archivo auth.log
AUTH_LOG="/var/log/auth.log"
# Ruta del archivo info_user.log
LOG_FILE="/var/log/info_user.log"

{
#Mensajes de salida
echo "------------------------------------------------------------"
echo "Usuario que ejecuta el script: $(whoami)"
echo "Fecha y hora de ejecución: $(date)"
echo "Versión de Bash: $BASH_VERSION"
echo -e "------------------------------------------------------------\n"

# Funcion Output de --help y 0 argumentos
function echoHelp(){
	echo -e "$0 [-u usuario]|[-g grupo]|[--login]|[--help]\n\t-u usuario\tMostrar información sobre el usuario especificado\n\t-g grupo\tMostrar usuarios asociados al grupo especificado\n\t--login \tMostrar los 5 últimos usuarios que han accedido al sistema\n\t--help \t\tMostrar ayuda"
	return 0
}

# más de dos argumentos
if test $# -gt 2; then
	echo -e "La cantidad de parámteros introducidos es excesiva.\nUse --help para obtener ayuda."
	exit $ERROR_ARGS

# dos argumentos
elif test $# -eq 2; then
	# -u como primer argumento
	if test "$1" = "-u"; then
		# Comprobar si usuario existe:
		if cat /etc/passwd | grep -wq "^$2:*"; then
			# Comprobar si el usuario introducio es el actual de la sesión:
			if who | grep -wq "$2"; then
				echo -e "el usuario $2 está conectado actualmente\n"
			else
				echo -e "el usuario $2 NO está conectado actualmente\n"
			fi
			# Mostrar las 5 conexiones REMOTAS:
			echo "las últimas 5 conexiones REMOTAS son:"
			echo "---------------------------------------"
			grep -E "sshd\[[0-9]+\]: Accepted password for [a-zA-Z0-9_\-]+ from [0-9.]+ port [0-9]+ ssh2" $AUTH_LOG | grep -w "$2" | cut -d ' ' -f1,2,3,11 | tail -5
			# Mostrar las 5 conexiones LOCALES:
			echo -e "\nlas últimas 5 conexiones LOCALES son:"
			echo "-------------------------------------------"
			grep -E "pam_unix\(.*\): session opened for user" $AUTH_LOG | grep -Ev "root|CRON|ssh" | grep -w "$2" | cut -d ' ' -f1,2,3 | tail -5
			# Grupos a los que pertenece
			grupos=$(cat /etc/group | grep -w "$2" | cut -d: -f1 | tr '\n' "," | sed 's/,$//')
			# ---Comprobar si pertenece a algún grupo:
			if test -z "$grupos";then
				echo -e "\nel usuario $2 no existe en el sistema\n"
			else
				echo -e "\n$2 pertenece a los siguientes grupos : $grupos\n"
			fi
			# Comprobar el espacio ocupado por la carpeta del usuario:
			espacio=$(du -sh /home/$2 2> /dev/null)
			# --- Si hay conflictos de permisos:
			if test $? -eq 1; then
				echo "Error: Permiso Denegado. No se puede leer el contenido del directorio."
				exit $ERROR_PERMISSION_DENNIED
			# --- Si no existe conflicto de permisos:
			else
				echo "Espacio ocupado por la carpeta de $2 (/home/$2): $espacio" | sed 's/[ \t][^ \t]*$//'
			# Comprobar cuantos archivos > 1MB contiene
			echo -e  "\nContiene $(find /home/$2 -type f -size +1M | wc -l) ficheros mayores de 1MB en la carpeta /home/$2"
			fi
			exit $SUCCES

		# Usuario NO existe
		else
			echo "El usuario $2 no existe en el sistema"
			exit $ERROR_NOT_FOUND
		fi
	# -g
	elif test "$1" = "-g"; then
		# Comprobar si el grupo existe:
		grupos=$(cat /etc/group | grep -w "$2" | cut -d: -f1)
		if test -z "$grupos"; then
			echo "El grupo $2 no existe en el sistema"
			exit $ERROR_NOT_FOUND
		else
			echo "Usuarios en el grupo $2:"
			echo "$grupos"
			exit $SUCCES
		fi
	else
		echo "Error: Opción no vállida. Use --help para obtener ayuda."
                exit $ERROR_ARGS
	fi

# un argumento
elif test $# -eq 1; then
	# --login
	if test "$1" = "--login"; then
		echo "las últimas 5 conexiones REMOTAS son:"
		echo "-------------------------------------------"
		grep -E "sshd\[[0-9]+\]: Accepted password for [a-zA-Z0-9_\-]+ from [0-9.]+ port [0-9]+ ssh2" $AUTH_LOG | cut -d ' ' -f1,2,3,9,11 | tail -5
		echo -e "\nlas últimas 5 conexiones LOCALES son:"
		echo "-------------------------------------------"
		grep -E "pam_unix\(.*\): session opened for user" $AUTH_LOG | grep -Ev "root|CRON|sshd" | cut -d ' ' -f1,2,3,11 | tail -5
		exit $SUCCES
	fi

	# -u
	if test "$1" = "-u"; then
		echo "Error: Se debe proporcionar el nombre del usuario para el parámetro -u"
		exit $ERROR_ARGS

	# -g
	elif test "$1" = "-g"; then
		echo "Error: Se debe proporcionar el nombre del grupo para el parámetro -g"
		exit $ERROR_ARGS

	# --help
	elif test "$1" = "--help"; then
		echoHelp
		exit $SUCCES

	# resto de caso
	else
		echo "Error: Opción no vállida. Use --help para obtener ayuda."
		exit $ERROR_ARGS
	fi

# ningun argumento 
elif test $# -eq 0; then
	echoHelp
	exit $ERROR_ARGS
else
	echo "ERROR Desconocido"
	exit $ERROR_GENERIC
fi
} | sudo tee -a $LOG_FILE
