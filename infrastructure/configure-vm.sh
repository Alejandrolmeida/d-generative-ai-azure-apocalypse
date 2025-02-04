#!/bin/bash

# ==========================
# 🚀 Script para convertir una VM de Kali en Metasploitable 2
# ⚠️ ADVERTENCIA: NO usar en entornos de producción
# ==========================

echo "🔧 Actualizando repositorios y paquetes..."
sudo apt update -y && sudo apt upgrade -y

echo "🔥 Instalando herramientas de pentesting..."
sudo apt install -y apache2 php mysql-server openssh-server ftp vsftpd \
    metasploit-framework nmap netcat telnetd samba

# ==========================
# 🔥 Configuración de Apache y DVWA
# ==========================
echo "🌐 Configurando Damn Vulnerable Web App (DVWA)..."
cd /var/www/html
sudo rm index.html
sudo git clone https://github.com/digininja/DVWA.git dvwa
sudo chown -R www-data:www-data dvwa
sudo chmod -R 777 dvwa
echo "✅ DVWA instalado en http://<tu-ip>/dvwa"

# ==========================
# 💀 Configuración insegura de MySQL
# ==========================
echo "💀 Configurando MySQL sin autenticación..."
sudo systemctl start mysql
sudo mysql -e "UPDATE mysql.user SET plugin='mysql_native_password' WHERE User='root';"
sudo mysql -e "FLUSH PRIVILEGES;"
echo "✅ MySQL está corriendo sin contraseña de root"

# ==========================
# 🔓 Configuración insegura de SSH
# ==========================
echo "🔓 Habilitando acceso SSH con root..."
sudo sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
sudo systemctl restart ssh
echo "✅ SSH habilitado para root (sin clave segura)"

# ==========================
# 📂 Configuración insegura de FTP
# ==========================
echo "📂 Configurando FTP sin autenticación..."
sudo sed -i 's/anonymous_enable=NO/anonymous_enable=YES/' /etc/vsftpd.conf
sudo systemctl restart vsftpd
echo "✅ FTP ahora permite acceso anónimo"

# ==========================
# 🖥️ Habilitar servicios vulnerables adicionales
# ==========================
echo "🛠️ Configurando servicios adicionales inseguros..."
sudo systemctl enable mysql ssh vsftpd apache2

echo "💀 Iniciando Netcat listener en el puerto 4444..."
nc -lvp 4444 &

echo "🔥 Tu VM de Kali ahora es un desastre de seguridad"
echo "🚨 IP pública de la máquina: $(curl -s ifconfig.me)"
echo "⚠️ No uses esto en producción. ¡Feliz hacking!"