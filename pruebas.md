# Guía COMPLETA de Pruebas y Captura de Evidencias

**Instrucciones paso a paso muy detalladas para probar todos los servicios.**

**NOTA IMPORTANTE: Estas pruebas están adaptadas para WSL Debian. Las conexiones SSH se hacen a localhost usando diferentes usuarios para simular equipos remotos.**

**Luego usa las nuevas contraseñas en las pruebas.**

---

## ANTES DE EMPEZAR

### Requisitos del Sistema
- WSL2 Debian instalado
- Script `setup.sh` ejecutado exitosamente
- Terminal abierta en la carpeta del proyecto

### Credenciales Principales
```
Usuario Admin Sistemas: sistemas_admin / sistemas123
Usuario Soporte Sistemas: sistemas_soporte / soporte123
Usuario Jefe Ventas: ventas_jefe / ventas123
Usuario Jefe RRHH: rrhh_jefe / rrhh123
Usuario Jefe Dirección: gerencia_jefe / gerencia123
```

---

## 1. PRUEBAS DE SERVICIO SSH (Acceso Remoto)

### Objetivo
Demostrar conexión segura desde el equipo de sistemas a otros usuarios del sistema (simulando equipos remotos en WSL).

### PASO 1: Verificar que SSH está activo
```bash
# Abre una terminal y ejecuta:
sudo systemctl status ssh
```
**ESPERADO:** Deberías ver `active (running)` en verde.

**CAPTURA 1:** Screenshot del estado de SSH activo.

---

### PASO 2: Cambiar al usuario de sistemas
```bash
# Cambiar al usuario sistemas_soporte
su - sistemas_soporte

# Te pedirá contraseña:
# Ingresa: S0p0rt3!
```
**ESPERADO:** Tu prompt debe mostrar `sistemas_soporte@[hostname]:~$`

**CAPTURA 2:** Screenshot mostrando prompt del usuario sistemas_soporte.

---

### PASO 3: Conectar a Tienda 1 (Simulada con usuario ventas_jefe)
```bash
# Estando como sistemas_soporte, ejecuta:
ssh ventas_jefe@localhost
```
**ESPERADO:** 
- Primera vez: Preguntará `Are you sure you want to continue connecting? (yes/no/[fingerprint])?`
- Responde: `yes`
- Luego pide: `Password for ventas_jefe@localhost:`
- Ingresa: `ventas123`

**CAPTURA 3:** Screenshot de la pantalla de login solicitando contraseña.

---

### PASO 4: Verificar sesión remota en Tienda 1
Ahora estás conectado remotamente. Ejecuta estos comandos:
```bash
# Ver usuario actual
whoami

# Ver nombre del servidor
hostname

# Ver fecha/hora de la conexión
date

# Ver directorio actual
pwd
```
**ESPERADO:** 
- whoami muestra: `ventas_jefe`
- hostname muestra: `localhost` o nombre de tu WSL
- date muestra fecha/hora actual

**CAPTURA 4:** Screenshot mostrando salida de whoami, hostname y date.

---

### PASO 5: Revisar conexiones SSH en logs
Aún en la sesión remota, ejecuta:
```bash
# Ver intentos de conexión SSH
sudo tail -20 /var/log/auth.log | grep ventas_jefe
```
**ESPERADO:** Verás línea como:
```
Apr 30 14:25:33 localhost sshd[1234]: Accepted password for ventas_jefe from ::1 port 54321 ssh2
```

**CAPTURA 5:** Screenshot del log mostrando conexión exitosa.

---

### PASO 6: Desconectar de Tienda 1
```bash
# Cierra la sesión SSH
exit

# O presiona: Ctrl + D
```
**ESPERADO:** Regresa a prompt de `sistemas_soporte@[hostname]:~$`

**CAPTURA 6:** Screenshot confirmando desconexión.

---

### PASO 7: Conectar a Tienda 2 (Simulada con usuario rrhh_jefe)
```bash
# Estando como sistemas_soporte, ejecuta:
ssh rrhh_jefe@localhost

# Ingresa contraseña: RRHHJ3!
```
**ESPERADO:** Conexión exitosa al "equipo remoto" de Tienda 2.

**CAPTURA 7:** Screenshot de prompt en Tienda 2 mostrando usuario rrhh_jefe.

---

### PASO 8: Ejecutar comando remoto
```bash
# Ver usuarios conectados
w

# Ver procesos activos
ps aux | head -10
```
**CAPTURA 8:** Screenshot de comandos ejecutados en Tienda 2.

---

### PASO 9: Salir de sesión remota
```bash
exit
```

### PASO 10: Volver a usuario root
```bash
exit

# Ahora estás como root nuevamente
```

---

## 2. PRUEBAS WEB Y BASE DE DATOS

### Objetivo
Verificar que el sitio de inventarios funciona y conecta a MariaDB.

### PASO 1: Verificar que Apache2 está activo
```bash
sudo systemctl status apache2
```
**ESPERADO:** `active (running)` en verde.

**CAPTURA 9:** Screenshot de Apache2 activo.

---

### PASO 2: Verificar que MariaDB está activo
```bash
sudo systemctl status mariadb
```
**ESPERADO:** `active (running)` en verde.

**CAPTURA 10:** Screenshot de MariaDB activo.

---

### PASO 3: Verificar que localhost está en hosts
```bash
cat /etc/hosts | grep inventario
```
**ESPERADO:** Debe mostrar:
```
127.0.0.1 inventario.local
```

**NOTA:** Desde Windows, usa directamente la IP de WSL: `172.21.133.151`

**CAPTURA 11:** Screenshot del archivo hosts.

---

### PASO 4: Acceder a sitio web (OPCIÓN A - Desde navegador en Windows)
1. Abre navegador (Chrome, Firefox, Edge, etc.)
2. Ingresa en la barra: `http://172.21.133.151/`
3. O desde WSL: `http://inventario.local/` o `http://localhost/inventario/`

**ESPERADO:** Página carga mostrando:
```
Inventario Web
Conexión establecida con MariaDB.

[Tabla con equipos: SERV-MAT, SERV-ALM, POS-01]
```

**CAPTURA 12:** Screenshot de página web cargada en navegador.

---

### PASO 5: Verificar tabla de equipos en web
En la misma página, deberías ver una tabla como:
```
| Equipo   | Ubicación | Estado |
|----------|-----------|--------|
| SERV-MAT | Matriz    | Activo |
| SERV-ALM | Almacén   | Activo |
| POS-01   | Tienda1   | Activo |
```

**CAPTURA 13:** Screenshot mostrando tabla de equipos en página web.

---

### PASO 6: Acceder a MariaDB directamente
```bash
# Conectar a base de datos como usuario de aplicación
mysql -u inventario_app -p inventarios_db

# Te pide contraseña:
# Ingresa: Inv3nt@r10!
```
**ESPERADO:** Prompt cambia a `MariaDB [inventarios_db]>`

**CAPTURA 14:** Screenshot del prompt de MariaDB.

---

### PASO 7: Ver estructura de tabla
```sql
-- Ver estructura de tabla
DESCRIBE equipos;

-- Salida esperada:
-- id | nombre | ubicacion | estado
```

**CAPTURA 15:** Screenshot de DESCRIBE equipos.

---

### PASO 8: Ver datos de equipos
```sql
-- Ver todos los equipos
SELECT * FROM equipos;

-- Salida esperada:
-- 1 | SERV-MAT | Matriz  | Activo
-- 2 | SERV-ALM | Almacén | Activo
-- 3 | POS-01   | Tienda1 | Activo
```

**CAPTURA 16:** Screenshot de SELECT * FROM equipos.

---

### PASO 9: Insertar nuevo equipo (demo)
```sql
-- Insertar nuevo equipo
INSERT INTO equipos (nombre, ubicacion, estado) 
VALUES ('PC-TEST', 'TestLab', 'Prueba');

-- Ver inserción
SELECT * FROM equipos WHERE nombre='PC-TEST';
```

**CAPTURA 17:** Screenshot mostrando inserción exitosa.

---

### PASO 10: Salir de MariaDB
```sql
EXIT;
```

---

## 3. PRUEBAS SAMBA (Carpetas Compartidas)

### Objetivo
Validar que las carpetas de departamentos tienen permisos correctos.

### PASO 1: Verificar que Samba está activo
```bash
sudo systemctl status smbd
```
**ESPERADO:** `active (running)` en verde.

**CAPTURA 18:** Screenshot de Samba activo.

---

### PASO 2: Listar carpetas compartidas disponibles
```bash
# Ver todas las carpetas disponibles
smbclient -L //localhost -U sistemas_admin%S1st3m@S! -m SMB2

# O sin contraseña en línea (interactivo):
smbclient -L //localhost
# Luego pide usuario: sistemas_admin
# Luego pide contraseña: S1st3m@S!
```
**ESPERADO:** Lista de carpetas:
```
[sistemas]
[ventas]
[marketing]
[rrhh]
[direccion]
[invitados]
```

**CAPTURA 19:** Screenshot del listado de carpetas compartidas.

---

### PASO 3: Cambiar a usuario de sistemas
```bash
su - sistemas_admin

# Contraseña: S1st3m@S!
```

---

### PASO 4: Conectar a carpeta SISTEMAS
```bash
smbclient //localhost/sistemas -U sistemas_admin%S1st3m@S!
```
**ESPERADO:** Prompt cambia a `smb: \>`

**CAPTURA 20:** Screenshot del prompt de Samba.

---

### PASO 5: Crear archivo de prueba
```bash
# En prompt de Samba, crea un archivo
put /etc/hostname test-archivo.txt

# Listar archivos
ls

# Salida esperada:
#  test-archivo.txt  A     35  Wed Apr 30 14:35:00 2026
```

**CAPTURA 21:** Screenshot mostrando archivo creado.

---

### PASO 6: Salir de Samba
```bash
quit
```

---

### PASO 7: Cambiar a usuario de Ventas
```bash
su - ventas_jefe

# Contraseña: V3nt@sJ! (o ventas123 si cambiaste)
```

---

### PASO 8: Conectar a carpeta de VENTAS
```bash
smbclient //localhost/ventas -U ventas_jefe%V3nt@sJ!
```
**ESPERADO:** Conexión exitosa.

**CAPTURA 22:** Screenshot conectado a carpeta ventas.

---

### PASO 9: Intentar acceder a carpeta de RRHH (debe fallar)
```bash
# Salir de ventas primero
quit

# Intentar acceder a RRHH como ventas_jefe
smbclient //localhost/rrhh -U ventas_jefe%V3nt@sJ!
```
**ESPERADO:** Error como:
```
Connection failed: NT_STATUS_ACCESS_DENIED
```

**CAPTURA 23:** Screenshot del acceso denegado.

---

### PASO 10: Volver a root
```bash
# Si estás en Samba
quit

# Si estás en shell como usuario
exit

# Ahora deberías ser root
```

---

## 4. PRUEBAS CUPS (Impresoras)

### Objetivo
Validar que las impresoras están configuradas y accesibles.

### PASO 1: Verificar que CUPS está activo
```bash
sudo systemctl status cups
```
**ESPERADO:** `active (running)` en verde.

**CAPTURA 24:** Screenshot de CUPS activo.

---

### PASO 2: Acceder a panel web de CUPS
1. Abre navegador
2. Ingresa: `http://localhost:631/`

**ESPERADO:** Panel de administración de CUPS carga.

**CAPTURA 25:** Screenshot de página CUPS cargada.

---

### PASO 3: Navegar a Administración > Impresoras
1. Busca pestaña "Administration"
2. Click en "Printers"

**ESPERADO:** Lista de impresoras.

**CAPTURA 26:** Screenshot del listado de impresoras.

---

### PASO 4: Verificar que existen 5 impresoras
Deberías ver en la lista:
- CUPS-GER-01 (Gerencia)
- CUPS-MAT-01 (Sistemas)
- CUPS-ALM-01 (Almacén)
- TKT-01 (Tienda 1)
- TKT-02 (Tienda 2)

**CAPTURA 27:** Screenshot mostrando 5 impresoras listadas.

---

### PASO 5: Crear archivo de prueba para impresora
```bash
# Crea archivo de texto simple
echo "Prueba de impresión CUPS" > prueba.txt

# Ver contenido
cat prueba.txt
```

**CAPTURA 28:** Screenshot del archivo de prueba creado.

---

### PASO 6: Enviar trabajo a impresora
```bash
# Enviar archivo a imprimir
lp -d CUPS-GER-01 prueba.txt

# Salida esperada:
# request id is CUPS-GER-01-1 (1 file(s))
```

**CAPTURA 29:** Screenshot del comando lp ejecutado.

---

### PASO 7: Ver cola de impresión
```bash
# Ver trabajos en cola
lpstat -o

# Salida esperada:
# CUPS-GER-01-1      prueba.txt (128 bytes) Tue Apr 30 14:40:00 2026
```

**CAPTURA 30:** Screenshot de cola de impresión.

---

### PASO 8: Ver estado de trabajos
```bash
# Ver estado de trabajos
lpstat -t

# Incluye información de:
# - Dispositivos configurados
# - Aceptadores de trabajos
# - Impresoras habilitadas
```

**CAPTURA 31:** Screenshot de lpstat -t mostrando estado completo.

---

### PASO 9: Ver historial de trabajos en web CUPS
1. Regresa al navegador
2. Navegación > Impresoras > CUPS-GER-01
3. Busca pestaña "Show Completed Jobs"

**ESPERADO:** Lista de trabajos procesados con timestamps.

**CAPTURA 32:** Screenshot del historial de trabajos.

---

### PASO 10: Verificar archivos de log de CUPS
```bash
# Ver logs de CUPS
sudo tail -30 /var/log/cups/error_log

# Deberías ver líneas sin errores críticos
```

**CAPTURA 33:** Screenshot de logs de CUPS sin errores.

---

## 5. PRUEBAS CRON (Tareas Programadas)

### Objetivo
Validar que las tareas de actualización y respaldo están programadas.

### PASO 1: Ver tareas CRON configuradas
```bash
# Ver todas las tareas programadas del root
sudo crontab -l

# Salida esperada:
# 0 20 * * 5 apt update && apt upgrade -y
# 30 20 * * 5 tar czf /var/backups/home-\%F.tar.gz /home
```

**CAPTURA 34:** Screenshot del crontab listado.

---

### PASO 2: Entender la sintaxis CRON
```
Significado de línea: 0 20 * * 5 apt update && apt upgrade -y
└─ 0      = Minuto (0)
└─ 20     = Hora (8 PM / 20:00)
└─ *      = Día del mes (cualquiera)
└─ *      = Mes (cualquier mes)
└─ 5      = Día de semana (5 = Viernes)
└─ Comando a ejecutar (apt update && apt upgrade)

Se ejecuta: VIERNES a las 20:00 (8 PM)
```

**CAPTURA 35:** Screenshot con explicación de sintaxis.

---

### PASO 3: Ver historial de tareas CRON ejecutadas
```bash
# Ver logs de CRON (pueden estar en syslog o var/log)
sudo tail -50 /var/log/syslog | grep CRON

# O si existe cron.log:
sudo tail -50 /var/log/cron

# Salida esperada:
# Apr 27 20:00:01 servidor CRON[12345]: (root) CMD (apt update && apt upgrade -y)
# Apr 27 20:30:01 servidor CRON[12346]: (root) CMD (tar czf /var/backups/home-...)
```

**CAPTURA 36:** Screenshot del historial de CRON.

---

### PASO 4: Ver carpeta de respaldos
```bash
# Ver archivos de backup creados
ls -lh /var/backups/

# Deberías ver archivos como:
# home-2026-04-27.tar.gz
# home-2026-04-20.tar.gz
# home-2026-04-13.tar.gz
```

**CAPTURA 37:** Screenshot de archivos de backup listados.

---

### PASO 5: Crear backup manual (para demostración)
```bash
# Ejecutar comando de backup manualmente
sudo tar czf /var/backups/home-demo-$(date +%F).tar.gz /home

# Verificar que se creó
ls -lh /var/backups/home-demo-*.tar.gz
```

**CAPTURA 38:** Screenshot del backup manual creado.

---

### PASO 6: Ver contenido de archivo backup
```bash
# Listar archivos dentro del tar.gz sin extraer
sudo tar tzf /var/backups/home-demo-$(date +%F).tar.gz | head -30

# Salida esperada:
# home/
# home/sistemas_admin/
# home/sistemas_admin/.bashrc
# home/sistemas_soporte/
# ... etc
```

**CAPTURA 39:** Screenshot mostrando contenido del backup.

---

### PASO 7: Validar integridad del backup
```bash
# Probar que archivo tar es válido
sudo tar tzf /var/backups/home-demo-$(date +%F).tar.gz > /dev/null && echo "Backup VÁLIDO"

# Salida esperada:
# Backup VÁLIDO
```

**CAPTURA 40:** Screenshot de validación exitosa.

---

### PASO 8: Ver espacio usado por backups
```bash
# Ver tamaño total de backups
du -sh /var/backups/

# Salida esperada:
# 245M	/var/backups/
```

**CAPTURA 41:** Screenshot de espacio de backups.

---

## 6. PRUEBAS DE USUARIOS Y GRUPOS

### Objetivo
Validar que todos los usuarios y grupos están creados correctamente.

### PASO 1: Listar todos los usuarios
```bash
# Ver usuarios del sistema
cat /etc/passwd | grep -E "sistemas_|ventas_|rrhh_|gerencia_"

# Salida esperada: Lista de 13 usuarios
```

**CAPTURA 42:** Screenshot de usuarios listados.

---

### PASO 2: Contar usuarios creados
```bash
# Contar exactamente cuántos usuarios de proyecto hay
cat /etc/passwd | grep -E "sistemas_|ventas_|rrhh_|gerencia_" | wc -l

# Salida esperada: 13
```

**CAPTURA 43:** Screenshot mostrando total de 13 usuarios.

---

### PASO 3: Listar todos los grupos
```bash
# Ver grupos funcionales y operativos
cat /etc/group | grep -E "sistemas|ventas|marketing|rrhh|direccion|oper_"

# Salida esperada: 9 grupos
```

**CAPTURA 44:** Screenshot de grupos listados.

---

### PASO 4: Ver miembros de grupo SISTEMAS
```bash
# Ver quién pertenece al grupo sistemas
getent group sistemas

# Salida esperada:
# sistemas:x:1001:sistemas_admin,sistemas_soporte,sistemas_infra,sistemas_guest
```

**CAPTURA 45:** Screenshot de miembros de grupo.

---

### PASO 5: Ver miembros de grupo VENTAS
```bash
# Ver quién pertenece a grupo ventas
getent group ventas

# Salida esperada:
# ventas:x:1002:ventas_jefe,ventas_apo1,ventas_apo2
```

**CAPTURA 46:** Screenshot del grupo ventas.

---

### PASO 6: Listar grupos de un usuario específico
```bash
# Ver a qué grupos pertenece sistemas_soporte
groups sistemas_soporte

# Salida esperada:
# sistemas_soporte : sistemas oper_soporte
```

**CAPTURA 47:** Screenshot de grupos de usuario.

---

### PASO 7: Ver permisos de carpetas Samba
```bash
# Ver permisos exactos de cada carpeta
ls -ld /srv/samba/*/

# Salida esperada:
# drwxrws--- sistemas sistemas /srv/samba/sistemas
# drwxrws--- ventas   ventas   /srv/samba/ventas
# drwxrws--- marketing marketing /srv/samba/marketing
# drwxrws--- rrhh     rrhh     /srv/samba/rrhh
# drwxrws--- direccion direccion /srv/samba/direccion
# drwxrwxrwt invitados invitados /srv/samba/invitados (público)
```

**CAPTURA 48:** Screenshot de permisos de carpetas.

---

### PASO 8: Cambiar a usuario y verificar grupos
```bash
# Cambiar a usuario sistemas_soporte
su - sistemas_soporte

# Contraseña: S0p0rt3!

# Ver identificación del usuario
id

# Salida esperada:
# uid=1004(sistemas_soporte) gid=1001(sistemas) groups=1001(sistemas),1005(oper_soporte)
```

**CAPTURA 49:** Screenshot de ID de usuario.

---

### PASO 9: Listar archivos del home del usuario
```bash
# Ver contenido del home del usuario
ls -la ~

# Deberías ver archivos típicos de shell:
# .bashrc
# .bash_logout
# .profile
```

**CAPTURA 50:** Screenshot del home del usuario.

---

### PASO 10: Volver a root
```bash
exit

# Ahora eres root nuevamente
```

---

## 7. PRUEBAS DE SERVICIOS ACTIVOS

### Objetivo
Verificar que todos los servicios principales están corriendo.

### PASO 1: Verificar estado de Apache2
```bash
sudo systemctl status apache2

# Salida esperada:
# active (running) - en verde
```

**CAPTURA 51:** Screenshot de Apache2 activo.

---

### PASO 2: Verificar estado de MariaDB
```bash
sudo systemctl status mariadb

# Salida esperada:
# active (running) - en verde
```

**CAPTURA 52:** Screenshot de MariaDB activo.

---

### PASO 3: Verificar estado de Samba (smbd)
```bash
sudo systemctl status smbd

# Salida esperada:
# active (running) - en verde
```

**CAPTURA 53:** Screenshot de Samba activo.

---

### PASO 4: Verificar estado de CUPS
```bash
sudo systemctl status cups

# Salida esperada:
# active (running) - en verde
```

**CAPTURA 54:** Screenshot de CUPS activo.

---

### PASO 5: Verificar estado de SSH
```bash
sudo systemctl status ssh

# Salida esperada:
# active (running) - en verde
```

**CAPTURA 55:** Screenshot de SSH activo.

---

### PASO 6: Verificar estado de CRON
```bash
sudo systemctl status cron

# Salida esperada:
# active (running) - en verde
```

**CAPTURA 56:** Screenshot de CRON activo.

---

### PASO 7: Verificar servicios habilitados
```bash
# Ver si servicios están habilitados al inicio
for service in apache2 mariadb smbd cups ssh cron; do
  echo -n "$service: "
  sudo systemctl is-enabled $service
done

# Salida esperada:
# apache2: enabled
# mariadb: enabled
# smbd: enabled
# cups: enabled
# ssh: enabled
# cron: enabled
```

**CAPTURA 57:** Screenshot mostrando todos los servicios habilitados.

---

### PASO 8: Ver puertos abiertos
```bash
# Ver puertos en escucha
sudo netstat -tlnp 2>/dev/null | grep LISTEN

# O con ss (más moderno):
sudo ss -tlnp

# Deberías ver:
# :22      SSH
# :80      HTTP (Apache)
# :139     Samba
# :445     Samba
# :3306    MariaDB
# :631     CUPS
```

**CAPTURA 58:** Screenshot de puertos abiertos.

---

### PASO 9: Ver procesos por servicio
```bash
# Ver procesos de cada servicio
ps aux | grep -E "apache2|mariadb|smbd|cups|sshd|cron"

# Cada uno debe aparecer en la lista
```

**CAPTURA 59:** Screenshot de procesos activos.

---

### PASO 10: Verificar logs de servicios (sin errores)
```bash
# Revisar logs de Apache
sudo tail -10 /var/log/apache2/error.log

# Revisar logs de Samba
sudo tail -10 /var/log/samba/log.smbd

# No deben contener errores críticos
```

**CAPTURA 60:** Screenshot de logs sin errores críticos.

---

## RESUMEN FINAL DE CAPTURAS

Deberías tener un total de **60 capturas**:

- **SSH:** 10 capturas (Pasos 1-10)
- **Web/BD:** 8 capturas (Pasos 9-17)
- **Samba:** 8 capturas (Pasos 18-33)
- **CUPS:** 10 capturas (Pasos 24-33)
- **CRON:** 8 capturas (Pasos 34-41)
- **Usuarios:** 10 capturas (Pasos 42-51)
- **Servicios:** 10 capturas (Pasos 51-60)

---

## DOCUMENTO DE EVIDENCIAS RECOMENDADO

Crea un documento (Google Docs, Word, PDF) con esta estructura:

```
PROYECTO DE INFRAESTRUCTURA - DOCUMENTO DE EVIDENCIAS
======================================================

Fecha de Prueba: [DD/MM/YYYY]
Responsable: [Tu nombre]
Servidor Probado: Debian WSL2

---

1. PRUEBAS SSH (10 capturas)
   ✓ Captura 1: Estado SSH activo
   ✓ Captura 2: Usuario sistemas_soporte activo
   ✓ Captura 3: Login a ventas_jefe@localhost solicitando contraseña
   ... (continúa con 7 capturas más)

2. PRUEBAS WEB/BD (8 capturas)
   ✓ Captura 9: Apache2 activo
   ... (continúa)

3. PRUEBAS SAMBA (8 capturas)
   ... (continúa)

[ETC...]

---

RESUMEN:
- Total capturas: 60
- Servicios funcionales: 6/6 ✓
- Usuarios creados: 13/13 ✓
- Carpetas compartidas: 6/6 ✓
- Estado: EXITOSO ✓

Firma: _________________ Fecha: __________
```

---

## PRÓXIMOS PASOS

1. ✓ Ejecuta cada sección en orden
2. ✓ Captura pantalla de cada paso
3. ✓ Guarda capturas con nombres: `01-ssh-activo.png`, `02-usuario-soporte.png`, etc.
4. ✓ Abre documento externo (Google Docs/Word/PDF)
5. ✓ Pega capturas en orden
6. ✓ Agrega comentarios/observaciones bajo cada captura
7. ✓ Guarda y comparte documento final


