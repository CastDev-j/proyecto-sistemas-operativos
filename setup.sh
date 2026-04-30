#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(pwd)"
DEBIAN_FRONTEND=noninteractive
export DEBIAN_FRONTEND

log() {
  echo "[setup] $*"
}

install_packages() {
  log "Actualizando apt y asegurando paquetes necesarios..."
  apt update -y
  apt install -y apache2 mariadb-server samba cups openssh-server php libapache2-mod-php php-mysql smbclient curl wget pwgen
}

create_groups_users() {
  log "Creando grupos funcionales y operativos..."
  for g in sistemas ventas marketing rrhh direccion oper_vendedor oper_proveedor oper_soporte oper_admin; do
    if ! getent group "$g" >/dev/null; then
      groupadd "$g"
    fi
  done

  log "Creando usuarios y asignando grupos..."

  add_user() {
    local user="$1" pass="$2" groups="$3" gecos="$4"
    if ! id "$user" >/dev/null 2>&1; then
      useradd -m -s /bin/bash -G "$groups" -c "$gecos" "$user"
      echo "$user:$pass" | chpasswd
    fi
  }

  add_user sistemas_admin 'S1st3m@S!' 'sistemas,oper_admin' 'Administrador de Sistemas'
  add_user sistemas_soporte 'S0p0rt3!' 'sistemas,oper_soporte' 'Soporte Técnico'
  add_user sistemas_infra '1nfr4S!' 'sistemas,oper_admin' 'Infraestructura'
  add_user sistemas_guest 'Gue$tS!' 'sistemas' 'Invitado de Sistemas'

  add_user ventas_jefe 'V3nt@sJ!' 'ventas,oper_vendedor' 'Jefe de Ventas'
  add_user ventas_apo1 'ApoVen1!' 'ventas,oper_vendedor' 'Apoyo Ventas'
  add_user ventas_apo2 'ApoVen2!' 'ventas,oper_vendedor' 'Apoyo Ventas'

  add_user rrhh_jefe 'RRHHJ3!' 'rrhh,oper_proveedor' 'Jefe de RRHH'
  add_user rrhh_apo1 'RHH1!' 'rrhh,oper_proveedor' 'Apoyo RRHH'
  add_user rrhh_apo2 'RHH2!' 'rrhh,oper_proveedor' 'Apoyo RRHH'

  add_user gerencia_jefe 'G3r3nc!@' 'direccion,oper_admin' 'Director General'
  add_user gerencia_apo1 'GereApo1!' 'direccion,oper_admin' 'Apoyo Gerencia'
  add_user gerencia_apo2 'GereApo2!' 'direccion,oper_admin' 'Apoyo Gerencia'
}

create_samba_shares() {
  log "Creando carpetas compartidas de Samba..."
  mkdir -p /srv/samba/{ventas,marketing,rrhh,direccion,sistemas,invitados}
  chown root:sistemas /srv/samba/sistemas
  chmod 2770 /srv/samba/sistemas
  chown root:ventas /srv/samba/ventas
  chmod 2770 /srv/samba/ventas
  chown root:marketing /srv/samba/marketing
  chmod 2770 /srv/samba/marketing
  chown root:rrhh /srv/samba/rrhh
  chmod 2770 /srv/samba/rrhh
  chown root:direccion /srv/samba/direccion
  chmod 2770 /srv/samba/direccion
  chmod 1777 /srv/samba/invitados

  log "Configurando Samba..."
  cp /etc/samba/smb.conf "/etc/samba/smb.conf.bak.$(date +%F)"
  cat > /etc/samba/smb.conf <<'EOF'
[global]
  workgroup = WORKGROUP
  server string = Infraestructura Empresarial Samba Server
  security = user
  map to guest = Bad User
  log file = /var/log/samba/log.%m
  max log size = 1000
  panic action = /usr/share/samba/panic-action %d
  server role = standalone server
  obey pam restrictions = yes
  unix password sync = yes
  passwd program = /usr/bin/passwd %u
  passwd chat = *Enter\snew\s*password:* %n\n *Retype\snew\s*password:* %n\n *password\supdated\ssuccessfully* .

[ventas]
  path = /srv/samba/ventas
  valid users = @ventas
  read only = no
  create mask = 0660
  directory mask = 2770

[marketing]
  path = /srv/samba/marketing
  valid users = @marketing
  read only = no
  create mask = 0660
  directory mask = 2770

[rrhh]
  path = /srv/samba/rrhh
  valid users = @rrhh
  read only = no
  create mask = 0660
  directory mask = 2770

[direccion]
  path = /srv/samba/direccion
  valid users = @direccion
  read only = no
  create mask = 0660
  directory mask = 2770

[sistemas]
  path = /srv/samba/sistemas
  valid users = @sistemas
  read only = no
  create mask = 0660
  directory mask = 2770

[invitados]
  path = /srv/samba/invitados
  guest ok = yes
  read only = no
  create mask = 0666
  directory mask = 1777
  guest only = yes
EOF

  for user in sistemas_admin sistemas_soporte sistemas_infra sistemas_guest ventas_jefe ventas_apo1 ventas_apo2 rrhh_jefe rrhh_apo1 rrhh_apo2 gerencia_jefe gerencia_apo1 gerencia_apo2; do
    echo -e "${user}
${user}" | smbpasswd -s -a "$user" || true
  done
}

configure_apache_mariadb() {
  log "Configurando Apache y MariaDB..."
  mkdir -p /var/www/inventario
  cat > /var/www/inventario/index.php <<'EOF'
<?php
$servername = 'localhost';
$username = 'inventario_app';
$password = 'Inv3nt@r10!';
$dbname = 'inventarios_db';

try {
    $conn = new PDO("mysql:host=$servername;dbname=$dbname;charset=utf8mb4", $username, $password);
    $conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    echo "<h1>Inventario Web</h1>";
    echo "<p>Conexión establecida con MariaDB.</p>";
    $stmt = $conn->query('SELECT nombre, ubicacion, estado FROM equipos LIMIT 5');
    echo '<table border="1" cellpadding="6"><tr><th>Equipo</th><th>Ubicación</th><th>Estado</th></tr>';
    while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
        echo '<tr><td>' . htmlspecialchars($row['nombre']) . '</td><td>' . htmlspecialchars($row['ubicacion']) . '</td><td>' . htmlspecialchars($row['estado']) . '</td></tr>';
    }
    echo '</table>';
} catch (PDOException $e) {
    echo 'Error de conexión: ' . $e->getMessage();
}
?>
EOF
  chown -R www-data:www-data /var/www/inventario

  cat > /etc/apache2/sites-available/inventario.conf <<'EOF'
<VirtualHost *:80>
    ServerName inventario.local
    DocumentRoot /var/www/inventario
    <Directory /var/www/inventario>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
    ErrorLog ${APACHE_LOG_DIR}/inventario_error.log
    CustomLog ${APACHE_LOG_DIR}/inventario_access.log combined
</VirtualHost>
EOF
  if ! grep -q 'inventario.local' /etc/hosts; then
    echo '127.0.0.1 inventario.local' >> /etc/hosts
  fi
  a2ensite inventario.conf
  a2enmod php8.4
  systemctl restart apache2

  log "Inicializando base de datos inventarios_db..."
  systemctl restart mariadb
  mysql -e "CREATE DATABASE IF NOT EXISTS inventarios_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
  mysql -e "CREATE USER IF NOT EXISTS 'inventario_app'@'localhost' IDENTIFIED BY 'Inv3nt@r10!';"
  mysql -e "GRANT ALL PRIVILEGES ON inventarios_db.* TO 'inventario_app'@'localhost';"
  mysql -e "FLUSH PRIVILEGES;"
  mysql inventarios_db -e "CREATE TABLE IF NOT EXISTS equipos (id INT AUTO_INCREMENT PRIMARY KEY, nombre VARCHAR(80), ubicacion VARCHAR(80), estado VARCHAR(30));"
  mysql inventarios_db -e "INSERT INTO equipos (nombre, ubicacion, estado) VALUES ('SERV-MAT','Matriz','Activo'),('SERV-ALM','Almacén','Activo'),('POS-01','Tienda1','Activo') ON DUPLICATE KEY UPDATE nombre=VALUES(nombre), ubicacion=VALUES(ubicacion), estado=VALUES(estado);"
}

configure_ssh() {
  log "Asegurando configuración SSH..."
  systemctl enable ssh
  systemctl restart ssh
  if ! grep -q '^AllowUsers' /etc/ssh/sshd_config; then
    cat >> /etc/ssh/sshd_config <<'EOF'
AllowUsers sistemas_admin sistemas_soporte sistemas_infra
EOF
  else
    sed -i 's/^AllowUsers.*/AllowUsers sistemas_admin sistemas_soporte sistemas_infra/' /etc/ssh/sshd_config
  fi
  systemctl restart ssh
}

configure_cron() {
  log "Instalando tareas programadas CRON..."
  local cronfile
  cronfile="/tmp/project_cronlist.txt"
  crontab -l > "$cronfile" 2>/dev/null || true
  grep -q '^0 20 \* \* 5 apt update -y && apt upgrade -y$' "$cronfile" || cat >> "$cronfile" <<'EOF'
0 20 * * 5 apt update -y && apt upgrade -y
EOF
  grep -q '^30 20 \* \* 5 tar czf /var/backups/home-\\%F.tar.gz /home$' "$cronfile" || cat >> "$cronfile" <<'EOF'
30 20 * * 5 tar czf /var/backups/home-\%F.tar.gz /home
EOF
  crontab "$cronfile"
  rm -f "$cronfile"
}

create_inventory_file() {
  log "Generando archivo de inventario YAML..."
  cat > "$PROJECT_ROOT/inventory.yml" <<'EOF'
version: 1
locations:
  - name: Matriz
    type: oficina
    server: 10.10.0.10
    devices:
      - hostname: SERV-MAT
        ip: 10.10.0.10
        role: servidor
        services: [apache2, mariadb, samba, cups, ssh, cron]
      - hostname: PC-SIS-01
        ip: 10.10.0.20
        role: pc
        user: sistemas_soporte
        department: sistemas
        services: [ssh, samba]
  - name: Almacén
    type: almacen
    server: 10.10.1.10
    devices:
      - hostname: SERV-ALM
        ip: 10.10.1.10
        role: servidor
        services: [apache2, mariadb, samba, ssh]
  - name: Tienda 1
    type: tienda
    devices:
      - hostname: POS-01
        ip: 10.10.2.11
        role: punto de venta
        user: ventas_jefe
        services: [ssh, samba]
      - hostname: TKT-01
        ip: 10.10.2.50
        role: impresora
        service: cups
  - name: Tienda 2
    type: tienda
    devices:
      - hostname: POS-02
        ip: 10.10.3.11
        role: punto de venta
        user: ventas_apo1
        services: [ssh, samba]
      - hostname: TKT-02
        ip: 10.10.3.50
        role: impresora
        service: cups
users:
  - username: sistemas_admin
    department: sistemas
    role: admin
  - username: sistemas_soporte
    department: sistemas
    role: soporte
  - username: sistemas_infra
    department: sistemas
    role: infraestructura
  - username: ventas_jefe
    department: ventas
    role: jefe
  - username: ventas_apo1
    department: ventas
    role: apoyo
  - username: ventas_apo2
    department: ventas
    role: apoyo
  - username: rrhh_jefe
    department: rrhh
    role: jefe
  - username: rrhh_apo1
    department: rrhh
    role: apoyo
  - username: rrhh_apo2
    department: rrhh
    role: apoyo
  - username: gerencia_jefe
    department: direccion
    role: jefe
  - username: gerencia_apo1
    department: direccion
    role: apoyo
  - username: gerencia_apo2
    department: direccion
    role: apoyo
EOF
}

enable_services() {
  log "Habilitando servicios para inicio..."
  systemctl enable apache2 mariadb smbd cups ssh cron
  systemctl restart apache2 mariadb smbd cups ssh cron
}

main() {
  install_packages
  create_groups_users
  create_samba_shares
  configure_apache_mariadb
  configure_ssh
  configure_cron
  enable_services
  create_inventory_file
  log "Instalación completa. Revisa http://inventario.local/ desde WSL o localhost al agregar inventario.local en hosts."
}

main "$@"

