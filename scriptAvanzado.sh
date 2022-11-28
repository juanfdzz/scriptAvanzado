#!/bin/bash

#Exit 0: Sale del programa sin problemas (opción 6 del menú)
#Exit 1: El archivo usuarios.csv está vacío (fallo al iniciar sesión)
es_numero='^[0-9]+$'
dni_valido='^[0-9]{8}+[A-Za-z]{1}'
datos='^[A-Za-zÁÉÍÓÚáéíóú]+$'
#///////////////////FUNCION COPIA//////////////////////////////////////////////////
copia(){

numero_copias=$(ls copia_usuarios*.zip | wc -l) #Se define la variable numero_copias como el valor numérico de las copias que existan
if [ $numero_copias -eq 2 ] #Primero cumprueba que este valor sea igual que dos. En caso de serlo borra la más antigua y crea la actual
then
    archivo1=$(ls copia_usuarios* | head -n1) #Almacena el primer archivo que salga en el ls
    archivo2=$(ls copia_usuarios* | tail -n1) #Almacena el segundo archivo que salga en el ls

    if [ "$archivo1" -ot "$archivo2" ] #Comprueba la antigüedad de los dos archivos 
    then #Si sale esta opción, es que el archivo1 es más antigüo que el archivo2.
        echo -e "Ya hay dos copias de seguridad. Borrando la de mayor antigüedad: $archivo1 \n"
        rm $archivo1
        echo "Creando la copia de seguridad 'copia_usuarios_`date +"%d%m%Y_%H-%M-%S"`.zip'"
        zip copia_usuarios_`date +"%d%m%Y_%H-%M-%S"`.zip usuarios.csv &>/dev/null #crea la copia de seguridad del archivo usuarios.csv y redirecciona la pantalla a /dev/null
        echo "COPIA DE SEGURIDAD realizada el `date +"%d%m%Y"` a las `date +"%H:%M"h`" >> log.log #inserta datos en el archivo log.log
    else #Si sale esta opción es que el archivo2 es más antigüo que el archivo1.
        echo -e "Ya hay dos copias de seguridad. Borrando la de mayor antigüedad: $archivo2 \n"
        rm $archivo2
        echo "Creando la copia de seguridad 'copia_usuarios_`date +"%d%m%Y_%H-%M-%S"`.zip'"
        zip copia_usuarios_`date +"%d%m%Y_%H-%M-%S"`.zip usuarios.csv &>/dev/null #crea la copia de seguridad del archivo usuarios.csv y redirecciona la pantalla a /dev/null
        echo "COPIA DE SEGURIDAD realizada el `date +"%d%m%Y"` a las `date +"%H:%M"h`" >> log.log #inserta datos en el archivo log.log
    fi

else #En caso de no haber más de dos copias, sólo crea la copia de seguridad con el formato indicado.
        echo "Creando la copia de seguridad 'copia_usuarios_`date +"%d%m%Y_%H-%M-%S"`.zip'"
        zip copia_usuarios_`date +"%d%m%Y_%H-%M-%S"`.zip usuarios.csv &>/dev/null #crea la copia de seguridad del archivo usuarios.csv y redirecciona la pantalla a /dev/null
        echo "COPIA DE SEGURIDAD realizada el `date +"%d%m%Y"` a las `date +"%H:%M"h`" >> log.log #inserta datos en el archivo log.log
fi

}
#///////////////////FIN FUNCION COPIA//////////////////////////////////////////////
#///////////////////FUNCIÓN ALTA/////////////////////////////////////////////////
alta(){

    echo "Introduce el nombre del usuario a dar de alta"
    read nombre

    if ! [[ $nombre =~ $datos ]] ; then #Comprueba que los datos introducidos coincidan con los caracteres de $datos
        echo "ERROR al introducir un nombre válido. Repitiendo el proceso"
        sleep 1
        alta
    fi

    echo "Introduce el primer apellido del usuario a dar de alta"
    read apellido1

    if ! [[ $apellido1 =~ $datos ]] ; then #Comprueba que los datos introducidos coincidan con los caracteres de $datos
        echo "ERROR al introducir un primer apellido válido. Repitiendo el proceso"
        sleep 1
        alta
    fi

    echo "Introduuce el segundo apellido del usuario a dar de alta"
    read apellido2

    if ! [[ $apellido2 =~ $datos ]] ; then #Comprueba que los datos introducidos coincidan con los caracteres de $datos
        echo "ERROR al introducir  un segundo apellido válido. Repitiendo el proceso"
        sleep 1
        alta
    fi

    echo "Introduce el DNI del usuario a dar de alta (8 números 1 letra)"
    read dniuser

    if [[ $dniuser =~ $dni_valido ]]; then #Comprueba que los datos introducidos coincidan con los caracteres de $dni_valido

        if [ "$(existe)" -gt 0 ]
        then
            echo "El usuario ya existe en nuestro sistema. Pruebe con otro usuario"

        else #Si el usuario no existe, lo añade a la base de usuarios.csv empleando el formato apropiado.
            echo $nombre:$apellido1:$apellido2:$dniuser:`generauser` >> usuarios.csv
            echo "Introduciendo los datos del usuario en el archivo usuarios.csv"
            echo "INSERTADO $nombre:$apellido1:$apellido2:$dniuser:`generauser` el `date +"%d%m%Y"` a las `date +"%H:%M"h`" >> log.log #inserta datos en el archivo log.log
        fi
    else
        echo "ERROR. El DNI debe de tener un formato válido: 8 números y 1 letra. Repitiendo el proceso"
        sleep 1
        alta
    fi
   
}
#///////////////////FIN FUNCIÓN ALTA///////////////////////////////////////////////
#///////////////////FUNCIÓN GENERAUSER////////////////////////////////////////////
generauser(){
        name=$(echo $nombre | cut -c1 | tr [:upper:] [:lower:])
        sur1=$(echo $apellido1 | cut -c 1-3 | tr [:upper:] [:lower:])
        sur2=$(echo $apellido2 | cut -c 1-3 | tr [:upper:] [:lower:])
        nif=$(echo $dniuser | cut -c 6-8)
        user=$(echo $name $sur1 $sur2 $nif | tr -d '[[:space:]]')

        echo $user
}
#///////////////////FIN FUNCIÓN GENERAUSER////////////////////////////////////////
#///////////////////FUNCIÓN EXISTE////////////////////////////////////////////
existe(){
    comprob=$(awk -F ":" '{print $4,$5}' usuarios.csv | grep -w $dniuser | wc -l)
    echo $comprob
}
#///////////////////FIN FUNCIÓN EXISTE////////////////////////////////////////
#///////////////////FUNCION BAJA///////////////////////////////////////////
baja(){
    echo "Introduce el DNI o nombre del usuario que desea dar de baja"
    read dniuser
    if [ "$(existe)" -gt 0 ]
    then
        
        userBorrado=$(grep $dniuser usuarios.csv) #Antes de borrar el usuario, lo almacena en esta variable para mostrar los datos en el fichero log.log
        echo "BORRADO $userBorrado el `date +"%d%m%Y"` a las `date +"%H:%M"h`" >> log.log #inserta datos en el archivo log.log

        grep -v $dniuser usuarios.csv > aux.tmp #Almacena todas las línas menos las del usuario que se va a borrar a un archivo 'aux.tmp'
        rm usuarios.csv ; mv aux.tmp usuarios.csv #Borra el archivo usuarios.csv y renombra el 'aux.tmp' a usuarios.csv, ya con el usuario borrado.
        echo "Eliminando al usuario $dniuser del archivo usuarios.csv"

    else 
        echo -e "El usuario introducido no existe, inténtalo de nuevo\n"
        sleep 1
        baja
    fi
  
}
#///////////////////FIN FUNCIÓN BAJA///////////////////////////////////////////////
#///////////////////FUNCIÓN MOSTRAR_USUARIOS///////////////////////////////////////
mostrar_usuarios(){
    echo "¿Desea ver la lista de usuarios ordenada (s/n)" 
    echo "S=ordena según nombre de usuario, N=muestra la lista con el orden normal"
    read respuesta
    if [[ $respuesta == 'S' ]] || [[ $respuesta == "s" ]]
    then 
        echo -e "Mostrando usuarios.csv ordenados según nombre de usuario:\n"
        cat usuarios.csv | awk -F ":" '{ print $5":"$1":"$2":"$3":"$4 }' | sort
    elif [[ $respuesta == "N" ]] || [[ $respuesta == "n" ]]
    then
    cat usuarios.csv
    else 
        echo "ERROR. Debe introducir 's' o 'n' para mostrar las opciones"
    fi

}
#///////////////////FIN FUNCIÓN MOSTRAR_USUARIOS////////////////////////////////////
#///////////////////FUNCIÓN MOSTRAR_LOG////////////////////////////////////////////
mostrar_log(){
    echo -e "///////////CONTENIDO DEL FICHERO LOG/////////////\n"
    cat log.log
}
#///////////////////FIN FUNCIÓN MOSTRAR_LOG///////////////////////////////////////
#///////////////////FUNCIÓN LOGIN////////////////////////////////////////////////
login(){

    if [ -s usuarios.csv ] # comprobamos si usuarios.csv está vacío
    then  #A continuación se ejecuta en caso de NO estar vacío
        echo "Bienvenido al programa. Introduce su nombre de usuario para iniciar sesión"
        read -s user

        existeUser=$(awk -F ":" '{print $5}' usuarios.csv | grep -w "$user" | wc -l)

        if [ $existeUser -eq 1 ]
        then
        user=$(awk -F ":" '{print $5}' usuarios.csv | grep -w "$user")
        echo -e "Has iniciado sesión con $user\n"
        sleep 1
        menu
        else
            i=3
            while [ $i -ge 1 ]; do
                echo "Usuario no encontrado, inténtelo de nuevo. Intentos ($i)"
                read -s user2
                existeUser2=$(awk -F ":" '{print $5}' usuarios.csv | grep -w "$user2" | wc -l)
                i=`expr $i - 1` 
                if [ $existeUser2 -eq 1 ]
                then
                    user=$(awk -F ":" '{print $5}' usuarios.csv | grep -w "$user2")
                    echo "Has iniciado sesión con $user2"
                    menu
                fi
            done
            echo "Se agotaron los intentos. Si no conoce su usuario o no dispone de uno, póngase en contacto con el Administrador"
        fi

    else 
        echo "El archivo usuarios.csv está vacío. Por favor, haga login como administrador para la introducción de usuarios."
        exit 1
    fi

}
#///////////////////FIN FUNCIÓN LOGIN/////////////////////////////////////////////
#///////////////////FUNCION MENU/////////////////////////////////////////////////
menu(){

    opcion1(){
        copia
    }
    opcion2(){

        if [[ $adminLogin -eq 1 ]]
        then
            alta
        else
            echo -e "ERROR. Esta opción sólo está disponible para el administrador!\n"
            sleep 1
            menu
        fi
    }
    opcion3(){
        if [[ $adminLogin -eq 1 ]]
        then
            baja
        else
            echo -e "ERROR. Esta opción sólo está disponible para el administrador!\n"
            sleep 1
            menu
        fi
    }
    opcion4(){
        mostrar_usuarios
    }
    opcion5(){
        mostrar_log
    }
    opcion6(){
        echo "Saliendo..."
    }

    echo "1.- EJECUTAR COPIA DE SEGURIDAD"
    echo "2.- DAR DE ALTA USUARIO"
    echo "3.- DAR DE BAJA AL USUARIO"
    echo "4.- MOSTRAR USUARIOS"
    echo "5.- MOSTRAR LOG DEL SISTEMA"
    echo "6.- SALIR"
    read opcion

    case $opcion in
    1) opcion1;;
    2) opcion2;;
    3) opcion3;;
    4) opcion4;;
    5) opcion5;;
    6) opcion6;;

    esac
    exit 0
}
#///////////////////FIN DE FUNCION MENU////////////////////////////////////////////
#///////////////////PROGRAMA PRINCIPAL//////////////////////////////////////////////
if ! [ -f usuarios.csv ]  #Comprobamos que exista el archivo usuarios.csv
then
    echo "No se ha encontrado el archivo 'usuarios.csv'. Creándolo..."
    touch usuarios.csv
    sleep 1
    login
    sleep 1
fi

if [ $1 == "-root" ] #Una vez sabe que se le ha introducido un parámetro, comprueba que este sea -root.
then
    adminLogin=1 # Igualamos la variable adminLogin a cualquier valor, en mi caso 1, para ponerlo en el menú como argumento del if.
    echo -e "Has iniciado sesión como Administrador!\n" 
    menu
else #No has iniciado sesión como admin así que te logueas normal
    #echo "#No se reconoce el parámetro..."
    login  
fi

#///////////////////FIN PROGRAMA PRINCIPAL//////////////////////////////////////////