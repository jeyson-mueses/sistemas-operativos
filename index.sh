#!/bin/bash

# Configuración
ORIGEN="/ruta/origen/"
DESTINO="/ruta/destino/"
REPORTE="/ruta/reporte.txt"
EMAIL="usuario@example.com"


##### 1. Función: Limpiar Temporales - Julián Solórzano

# Limpiar archivos temporales en Ubuntu
echo "Inicio de la limpieza de archivos temporales..."

# Directorio temporal del sistema
echo "Eliminando archivos en /tmp..."
sudo rm -rf /tmp/*

# Directorio temporal del usuario
echo "Eliminando archivos temporales del usuario..."
rm -rf ~/.cache/*

# Directorio de miniaturas (thumbnails)
echo "Eliminando miniaturas innecesarias..."
rm -rf ~/.thumbnails/*
rm -rf ~/.cache/thumbnails/*

# Limpiar archivos de registro antiguos
echo "Limpiando registros antiguos..."
sudo find /var/log -type f -name "*.log" -delete

# Sincronizar para liberar memoria caché
echo "Liberando memoria caché..."
sync; sudo sh -c "echo 3 > /proc/sys/vm/drop_caches"

echo "Limpieza completada con éxito."


##### 2. Función: Actualizar Sistema - Valentino Vargas

# Función para actualizar los paquetes del sistema
actualizar_sistema() {
    echo "Actualizando la lista de paquetes..."
    sudo apt update && sudo apt upgrade -y
    echo "Sistema actualizado correctamente."
}

# Función para limpiar paquetes innecesarios
limpiar_sistema() {
    echo "Eliminando paquetes innecesarios..."
    sudo apt autoremove -y && sudo apt autoclean
    echo "Sistema limpio."
}

# Función para comprobar el espacio en disco
comprobar_espacio() {
    echo "Comprobando espacio en disco..."
    df -h
}

# Función para buscar paquetes obsoletos
buscar_obsoletos() {
    echo "Buscando paquetes obsoletos..."
    sudo apt list --upgradable
}

# Función para reiniciar el sistema
reiniciar_sistema() {
    echo "¿Estás seguro de que deseas reiniciar el sistema? (s/n)"
    read -r respuesta
    if [[ "$respuesta" == "s" || "$respuesta" == "S" ]]; then
        echo "Reiniciando el sistema..."
        sudo reboot
    else
        echo "Operación cancelada."
    fi
}

# Menú principal
mostrar_menu() {
    echo "=============================="
    echo "  Script de Gestión del Sistema"
    echo "=============================="
    echo "1) Actualizar el sistema"
    echo "2) Limpiar el sistema"
    echo "3) Comprobar espacio en disco"
    echo "4) Buscar paquetes obsoletos"
    echo "5) Reiniciar el sistema"
    echo "6) Salir"
    echo "=============================="
    echo "Elige una opción: "
}

# Función principal
main() {
    while true; do
        mostrar_menu
        read -r opcion
        case $opcion in
            1) actualizar_sistema ;;
            2) limpiar_sistema ;;
            3) comprobar_espacio ;;
            4) buscar_obsoletos ;;
            5) reiniciar_sistema ;;
            6) echo "Saliendo del script. ¡Hasta luego!"; exit 0 ;;
            *) echo "Opción no válida. Intenta de nuevo." ;;
        esac
        echo ""
    done
}

# Llamada a la función principal
main


##### 3. Función: Sincronizar Archivos

sincronizar_archivos() {
    echo "Iniciando sincronización de archivos desde $ORIGEN a $DESTINO..."
    rsync -avh --delete "$ORIGEN/" "$DESTINO/"
    if [ $? -eq 0 ]; then
        echo "Sincronización completada con éxito."
    else
        echo "Error durante la sincronización de archivos."
    fi
}


##### 4. Función: Programar Tareas - Josué Cruz

# Nombre del archivo de log
LOG_FILE="$HOME/tareas_diarias.log"

# Función para registrar mensajes en el log
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> $LOG_FILE
}

# Actualizar el sistema operativo
echo "Actualizando el sistema..."
log_message "Inicio de actualización del sistema."
sudo apt update && sudo apt upgrade -y
if [ $? -eq 0 ]; then
    log_message "Sistema actualizado con éxito."
else
    log_message "Error durante la actualización del sistema."
fi

# Realizar copia de seguridad
ORIGEN="$HOME/Documents"
DESTINO="$HOME/Backup"
echo "Realizando copia de seguridad de $ORIGEN a $DESTINO..."
log_message "Inicio de la copia de seguridad."
mkdir -p "$DESTINO"
rsync -avh --delete "$ORIGEN/" "$DESTINO/"
if [ $? -eq 0 ]; then
    log_message "Copia de seguridad realizada con éxito."
else
    log_message "Error durante la copia de seguridad."
fi

# Limpiar archivos temporales y caché
echo "Limpiando archivos temporales y caché..."
log_message "Inicio de limpieza del sistema."
sudo apt autoremove -y && sudo apt autoclean -y && sudo rm -rf /tmp/*
if [ $? -eq 0 ]; then
    log_message "Limpieza del sistema completada con éxito."
else
    log_message "Error durante la limpieza del sistema."
fi

# Finalización del script
echo "Todas las tareas diarias se han completado."
log_message "Script completado con éxito."

# Mostrar log reciente al usuario
echo "Registro de actividades recientes:"
tail -n 10 $LOG_FILE


##### 5. Función: Enviar Reporte - Jeyson Mueses

enviar_reporte() {
    echo "Generando reporte en $REPORTE..."
    echo "Reporte generado el $(date '+%Y-%m-%d %H:%M:%S')" > $REPORTE
    echo "Estado del sistema:" >> $REPORTE
    df -h >> $REPORTE
    echo "" >> $REPORTE
    echo "Últimas actualizaciones:" >> $REPORTE
    grep "upgraded" /var/log/apt/history.log | tail -n 5 >> $REPORTE
    echo "" >> $REPORTE
    echo "Registro de tareas diarias:" >> $REPORTE
    tail -n 10 $LOG_FILE >> $REPORTE

    echo "Enviando reporte por correo electrónico a $EMAIL..."
    mail -s "Reporte del Sistema" $EMAIL < $REPORTE
    if [ $? -eq 0 ]; then
        echo "Reporte enviado con éxito."
    else
        echo "Error al enviar el reporte."
    fi
}

# Llamada a la función para enviar el reporte
enviar_reporte
