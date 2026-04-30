# Contexto del Proyecto

## Resumen del servicio
Una empresa contrata el servicio de consultoría e implementación de una infraestructura de TI para:
- 1 sede matriz (oficina central)
- 1 almacén logístico
- 2 puntos de venta (tiendas)

El objetivo es diseñar el esquema de servicios y la red, integrar servicios de SQL, CROND, SSH, APACHE2, CUPS y SAMBA, y elaborar documentación técnica que incluya mapas WAN y LAN, inventario, usuarios, grupos y permisos.

## Alcance del proyecto
1. Esquema de servicios:
   - SQL (servicio de base de datos)
   - CROND (planificación de tareas)
   - SSH (acceso remoto seguro)
   - APACHE2 (servidor web)
   - CUPS (servicio de impresión)
   - SAMBA (recursos compartidos)
2. Mapas de red:
   - WAN: conectividad entre matriz, almacén y tiendas con enlaces VPN/Internet.
   - LAN: distribución de sistemas, PCs y servidores en cada ubicación.
3. Inventario de equipos: IP, usuario, departamento, rol, servicios, impresoras, carpetas.
4. Usuarios y permisos: 4 departamentos, 3 usuarios por departamento, grupos funcionales y operativos.
5. Configuración de servicios por ubicación y roles.
6. Evidencias de conexión SSH y respaldo CROND.

## Ubicaciones del proyecto
- Matriz: oficina central de la empresa.
- Almacén: centro de logística e inventarios.
- Tienda 1: punto de venta principal.
- Tienda 2: segundo punto de venta.

## Asunciones y tecnología
- Se utiliza Debian en WSL para documentar la implementación.
- La solución se describe como propuesta técnica sin desplegar servicios reales en este repositorio.
- Los servicios se modelan en base a un entorno Linux con Apache2, MariaDB/MySQL, Samba, CUPS, SSH y cron.
- Google Maps se usa como referencia de ubicación en el mapa WAN.

## Credenciales y usuarios base
> Estas credenciales son de ejemplo y deben ajustarse a la política de seguridad real antes de desplegar.

### Usuarios del departamento de Sistemas
- `sistemas_admin` / `S1st3m@S!` — Admin root de sistemas.
- `sistemas_soporte` / `S0p0rt3!` — Soporte técnico.
- `sistemas_infra` / `1nfr4S!` — Administración de infraestructura.

### Departamento de Ventas
- `ventas_jefe` / `V3nt@sJ!` — Jefe de ventas (permiso intermedio).
- `ventas_apo1` / `ApoVen1!` — Soporte ventas.
- `ventas_apo2` / `ApoVen2!` — Soporte ventas.

### Departamento de Recursos Humanos
- `rrhh_jefe` / `RRHHJ3!` — Jefe de RR.HH. (permiso intermedio).
- `rrhh_apo1` / `RHH1!` — Apoyo administrativo.
- `rrhh_apo2` / `RHH2!` — Apoyo administrativo.

### Departamento de Dirección/Gerencia
- `gerencia_jefe` / `G3r3nc!@` — Director general (permiso alto/intermedio).
- `gerencia_apo1` / `GereApo1!` — Apoyo de dirección.
- `gerencia_apo2` / `GereApo2!` — Apoyo de dirección.

### Departamento de Sistemas adicional
- `sistemas_guest` / `Gue$tS!` — Usuario invitado para acceso limitado a recursos.

## Grupos funcionales y operativos
- Grupos funcionales:
  - `ventas`
  - `marketing`
  - `rrhh`
  - `direccion`
  - `sistemas`
- Grupos operativos:
  - `oper_vendedor`
  - `oper_proveedor`
  - `oper_soporte`
  - `oper_admin`

## Permisos y roles
- `permiso_alto`: acceso administrativo a recursos del departamento y servicios críticos.
- `permiso_intermedio`: acceso a recursos de trabajo del departamento y algunos sistemas de reporte.
- `permiso_comun`: acceso básico a carpetas compartidas, aplicaciones de usuario e impresoras.
- El jefe de cada departamento recibe permiso intermedio; los apoyos reciben permiso común.
- En sistemas, el equipo root controla todas las carpetas de infraestructura.

## Servicios por ubicación
- Matriz:
  - Servidor web/inventario: Apache2 + SQL.
  - Servidor Samba: compartición de carpetas de departamentos.
  - Servidor CUPS: gestión de impresoras y colas de impresión.
  - SSH: acceso remoto de sistemas a equipos de tiendas para soporte.
  - CROND: actualizaciones y respaldos programados.
- Almacén:
  - Servicio web de inventarios + base de datos.
  - Acceso a impresoras y carpetas compartidas.
- Tiendas 1 y 2:
  - PCs de punto de venta.
  - Acceso remoto SSH para soporte.
  - Impresoras locales para tickets y reportes.

## Recursos compartidos y permisos de carpeta
- Carpeta compartida por departamento:
  - `/srv/samba/ventas` — permiso intermedio para ventas.
  - `/srv/samba/marketing` — permiso intermedio para marketing.
  - `/srv/samba/rrhh` — permiso intermedio para RR.HH.
  - `/srv/samba/direccion` — permiso intermedio para dirección.
  - `/srv/samba/sistemas` — acceso root y pública para invitados.
- Carpeta invitada en sistemas:
  - `/srv/samba/invitados` — abierta para usuarios invitados con lectura básica.

## Detalles de inventario y red
- IPs modelo:
  - Matriz servidor: `10.10.0.10`
  - Almacén servidor: `10.10.1.10`
  - Tienda 1 PC: `10.10.2.11`, Tienda 1 impresora: `10.10.2.50`
  - Tienda 2 PC: `10.10.3.11`, Tienda 2 impresora: `10.10.3.50`
- Red WAN: enlaces VPN/IPsec entre matriz, almacén y tiendas.
- Red LAN: segmentos internos por ubicación y subredes de servicios.

## Objetivo de continuidad para otro agente
El siguiente agente debe poder continuar desarrollando la app con esta información:
- contexto del cliente, alcance y ubicaciones.
- servicios y funciones requeridas.
- usuarios, grupos y permisos.
- infraestructura WAN y LAN.
- requerimientos funcionales de SSH, web, BD, impresoras, Samba y CROND.
- credenciales de ejemplo para pruebas.
- estructura de documentación (`context.md`, `proyecto.tx`) y páginas disponibles.

## Recomendaciones de siguiente paso
1. Crear un repositorio con la documentación y diagramas visuales.
2. Implementar un inventario real en YAML/JSON para automatización.
3. Desarrollar scripts de configuración para Apache2, MariaDB, Samba, CUPS y cron.
4. Preparar planos de red WAN/LAN y plantillas de Google Maps.
