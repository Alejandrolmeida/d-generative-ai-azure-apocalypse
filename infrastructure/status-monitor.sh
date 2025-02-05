#!/bin/bash
# filepath: /home/aalmeida/source/github/alejandrolmeida/d-generative-ai-azure-apocalypse/infrastructure/check-services.sh
# Descripción: Este script comprueba el estado de los servicios configurados en Kali Linux,
# incluyendo vsftpd, mysql, ssh, apache2 y verifica si hay un listener de Netcat en el puerto 4444.
# Ejecuta este script en la VM para verificar si los servicios están activos.

# Array de servicios a comprobar
services=( "vsftpd" "mysql" "ssh" "apache2" )

echo "Comprobando estado de servicios..."

for service in "${services[@]}"; do
  status=$(systemctl is-active "$service")
  if [ "$status" == "active" ]; then
    echo "✅ $service: Activo"
  else
    echo "❌ $service: Inactivo (estado: $status)"
  fi
done

# Comprobar si Netcat está escuchando en el puerto 4444
echo -n "Netcat listener en puerto 4444: "
if ss -ltn | grep -q ':4444 '; then
  echo "✅ Activo"
else
  echo "❌ Inactivo"
fi