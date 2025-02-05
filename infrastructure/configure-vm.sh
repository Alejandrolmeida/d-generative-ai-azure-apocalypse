#!/bin/bash
# filepath: /home/aalmeida/source/github/alejandrolmeida/d-generative-ai-azure-apocalypse/infrastructure/configure-vm.sh
# Descripción: Script actualizado para configurar correctamente una VM de Kali Linux.
# Advertencia: No usar en producción.

set -e

echo "🔧 Actualizando repositorios y paquetes..."
sudo dpkg --configure -a
sudo apt update && sudo apt upgrade -y

echo "🔥 Instalando paquetes necesarios..."
# Instalamos netcat-openbsd en lugar de netcat para evitar el error de candidato no disponible
sudo apt install -y apache2 mariadb-server vsftpd curl netcat-openbsd git php libapache2-mod-php php-mysqli php-gd php-xml php-curl

echo "🌐 Configurando Damn Vulnerable Web App (DVWA)..."
# Asegurarse que /var/www/html existe y está vacío (para DVWA)
if [ ! -d "/var/www/html" ]; then
  sudo mkdir -p /var/www/html
fi
cd /var/www/html || exit
if [ -f "index.html" ]; then
  sudo rm index.html
fi
# Clonar DVWA; si ya existe, actualizar
if [ -d "dvwa" ]; then
  cd dvwa && sudo git pull && cd ..
else
  sudo git clone https://github.com/digininja/DVWA.git dvwa
fi
# Copiar el archivo de configuración por defecto si no existe
if [ -f "dvwa/config/config.inc.php.dist" ] && [ ! -f "dvwa/config/config.inc.php" ]; then
  sudo cp dvwa/config/config.inc.php.dist dvwa/config/config.inc.php
  echo "Archivo de configuración copiado a dvwa/config/config.inc.php"
fi

echo "✅ DVWA instalado en http://$(curl -s ifconfig.me)/dvwa"

echo "💀 Configurando MariaDB sin autenticación..."
# Configurar MariaDB: remove password for root (esto es inseguro)
sudo systemctl enable mariadb
sudo systemctl start mariadb
# Ejecutar comandos SQL sin contraseña (ajustar según sea necesario)
sudo mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED BY ''; FLUSH PRIVILEGES;" || echo "❌ Error configurando MariaDB"
echo "✅ MariaDB está corriendo sin contraseña de root"

echo "🔓 Habilitando acceso SSH para root..."
# Permitir acceso root en SSH
sudo sed -i 's/^#*PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config
sudo systemctl restart ssh
echo "✅ SSH habilitado para root (sin clave segura)"

echo "📂 Configurando FTP sin autenticación..."
if [ -f "/etc/vsftpd.conf" ]; then
    sudo sed -i 's/anonymous_enable=NO/anonymous_enable=YES/' /etc/vsftpd.conf
    sudo systemctl restart vsftpd
    echo "✅ FTP ahora permite acceso anónimo"
else
    echo "❌ Archivo /etc/vsftpd.conf no encontrado. Verifica la instalación de vsftpd."
fi

echo "🛠️ Configurando servicios adicionales inseguros..."
# Habilitar servicios; aunque algunos ya estén en ejecución o se usen nombres distintos
sudo systemctl enable ssh || true
sudo systemctl enable mariadb || true
sudo systemctl enable vsftpd || true
sudo systemctl enable apache2 || true

echo "🚀 Arrancando Apache2..."
sudo systemctl start apache2
echo "✅ Apache2 está activo"

echo "💀 Iniciando Netcat listener en el puerto 4444..."
# Usar la opción -d para ejecutar netcat en modo detached (no interactivo)
nohup nc -d -lvp 4444 >/dev/null 2>&1 &
sleep 1

echo "🔥 Tu VM de Kali ahora es un desastre de seguridad"
echo "🚨 IP pública de la máquina: $(curl -s ifconfig.me)"
echo "⚠️ No uses esto en producción. ¡Feliz hacking!"