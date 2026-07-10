# Oracle Docker Installation on HAL9000

This guide describes how to install a complete Oracle development environment on HAL9000 using Docker.

The environment includes:

- Oracle Database 26ai
- Oracle APEX
- Oracle REST Data Services (ORDS)
- Database Actions
- Persistent Docker storage
- Access from the Windows virtual machine

This setup is intended primarily for Oracle, PL/SQL, APEX, REST, and InsightViewer development rather than database administration.

---

## 1. Recommended architecture

```text
HAL9000
├── Ubuntu host
│   ├── NVIDIA drivers
│   ├── Ollama
│   ├── Docker
│   └── Oracle Autonomous Database Free container
│       ├── Oracle Database 26ai
│       ├── Oracle APEX
│       ├── ORDS
│       └── Database Actions
│
└── Windows virtual machine — 8 GB RAM
    ├── InsightViewer development
    ├── SQL Developer
    ├── browser
    └── other Windows tools
```

The Oracle environment will run directly in Docker on the Ubuntu host. The Windows virtual machine will act as a client and development workstation.

---

## 2. Check HAL9000

Run the following commands on HAL9000:

```bash
cat /etc/os-release
uname -m
docker --version
docker compose version
free -h
df -h
nvidia-smi
```

The architecture should normally be:

```text
x86_64
```

Confirm that Docker works:

```bash
sudo docker run --rm hello-world
```

If Docker requires `sudo`, add your user to the Docker group:

```bash
sudo usermod -aG docker "$USER"
```

Then log out and log back in.

Verify access:

```bash
docker ps
```

---

## 3. Check FUSE support

The Autonomous Database Free container uses `/dev/fuse`.

```bash
ls -l /dev/fuse
```

Expected output resembles:

```text
crw-rw-rw- 1 root root 10, 229 ... /dev/fuse
```

If `/dev/fuse` does not exist, run:

```bash
sudo modprobe fuse
ls -l /dev/fuse
```

---

## 4. Create the project directory

Create the main installation directory:

```bash
sudo mkdir -p /srv/oracle-adb
sudo chown -R "$USER":"$USER" /srv/oracle-adb
cd /srv/oracle-adb
```

Create directories for persistent files and exports:

```bash
mkdir -p data exports backups scripts
```

The directory structure will be:

```text
/srv/oracle-adb/
├── compose.yaml
├── .env
├── data/
├── exports/
├── backups/
└── scripts/
```

---

## 5. Create passwords

Create the `.env` file:

```bash
nano .env
```

Add:

```text
ADB_ADMIN_PASSWORD=ReplaceWithAStrongAdminPassword
ADB_WALLET_PASSWORD=ReplaceWithAnotherStrongPassword
```

Use passwords containing uppercase letters, lowercase letters, numbers, and symbols.

Avoid `$` in the initial passwords because Docker Compose may interpret it as variable syntax.

Protect the file:

```bash
chmod 600 .env
```

Do not commit `.env` to Git.

---

## 6. Create `compose.yaml`

Create the file:

```bash
nano compose.yaml
```

Add:

```yaml
services:
  oracle-adb:
    image: ghcr.io/oracle/adb-free:latest-26ai
    container_name: oracle-adb
    hostname: oracle-adb

    environment:
      WORKLOAD_TYPE: ATP
      DATABASE_NAME: HALADB
      ADMIN_PASSWORD: ${ADB_ADMIN_PASSWORD}
      WALLET_PASSWORD: ${ADB_WALLET_PASSWORD}

    ports:
      # Oracle TLS listener
      - "1521:1522"

      # Optional direct access to the internal listener
      - "1522:1522"

      # APEX, ORDS, and Database Actions
      - "8443:8443"

      # MongoDB API; remove if not needed
      - "27017:27017"

    cap_add:
      - SYS_ADMIN

    devices:
      - "/dev/fuse:/dev/fuse"

    volumes:
      - oracle-adb-data:/u01/data
      - ./exports:/home/oracle/exports
      - ./backups:/home/oracle/backups
      - ./scripts:/home/oracle/scripts

    shm_size: "2gb"

    deploy:
      resources:
        limits:
          memory: 10g
          cpus: "4"

    restart: unless-stopped

volumes:
  oracle-adb-data:
    name: oracle-adb-data
```

### Resource limit note

Some older Docker Compose installations may ignore `deploy.resources` when Docker is not running in Swarm mode.

After the container starts, inspect the effective limits:

```bash
docker inspect oracle-adb \
  --format 'Memory={{.HostConfig.Memory}} NanoCPUs={{.HostConfig.NanoCpus}}'
```

---

## 7. Pull and start the container

Run:

```bash
cd /srv/oracle-adb
docker compose pull
docker compose up -d
```

Watch the initialization log:

```bash
docker compose logs -f oracle-adb
```

The first start initializes the database, creates the wallet, and starts APEX and ORDS.

Do not interrupt the container while initialization is still in progress.

Press `Ctrl+C` to stop following the logs. This does not stop the container.

Check the status:

```bash
docker compose ps
docker ps --filter name=oracle-adb
```

Display recent logs:

```bash
docker compose logs --tail=100 oracle-adb
```

---

## 8. Open APEX

From HAL9000 itself:

```text
https://localhost:8443/ords/
```

From the Windows virtual machine:

```text
https://HAL9000-IP:8443/ords/
```

The APEX Builder address should be:

```text
https://HAL9000-IP:8443/ords/apex
```

Database Actions should be available below the same ORDS endpoint.

The browser may initially display a certificate warning because the local development environment uses a self-signed certificate.

---

## 9. Find HAL9000's IP address

Run:

```bash
hostname -I
```

Or:

```bash
ip -br address
```

Example result:

```text
192.168.1.50
```

Then open:

```text
https://192.168.1.50:8443/ords/
```

Do not expose ports `1521`, `1522`, or `8443` through the internet router at this stage.

---

## 10. Configure the Ubuntu firewall

Check whether UFW is active:

```bash
sudo ufw status
```

If it is active, allow access only from the local network.

Example:

```bash
sudo ufw allow from 192.168.1.0/24 to any port 8443 proto tcp
sudo ufw allow from 192.168.1.0/24 to any port 1521 proto tcp
```

Adjust `192.168.1.0/24` to match your actual network.

Avoid unrestricted rules such as:

```bash
sudo ufw allow 1521
```

That would allow database access from every reachable network interface.

---

## 11. Create an APEX workspace

Open:

```text
https://HAL9000-IP:8443/ords/apex
```

Log in with the administrator credentials created during container initialization.

Suggested workspace structure:

```text
Workspace: INSIGHTVIEWER
Schema: INSIGHT
Administrator: ROBERT
```

Use a separate schema for application development rather than developing as `ADMIN`.

Recommended arrangement:

```text
ADMIN
  Container and database administration only

INSIGHT
  InsightViewer tables, packages, procedures, and views

INSIGHT_RUNTIME
  Optional runtime profiling and tracing tables

APEX workspace INSIGHTVIEWER
  Associated with schema INSIGHT
```

---

## 12. Connect from SQL Developer

The container generates an Oracle wallet.

Enter the container:

```bash
docker exec -it oracle-adb bash
```

Locate wallet files:

```bash
find /u01 -iname "tnsnames.ora" 2>/dev/null
find /u01 -iname "*.zip" 2>/dev/null
```

Exit the container:

```bash
exit
```

Copy the wallet ZIP to the host using the path returned by the previous command:

```bash
docker cp oracle-adb:/path/found/in/container/wallet.zip \
  /srv/oracle-adb/HALADB_wallet.zip
```

Copy `HALADB_wallet.zip` to Windows and configure SQL Developer with a Cloud Wallet connection.

Typical connection settings:

```text
Username: ADMIN
Password: value of ADB_ADMIN_PASSWORD
Connection type: Cloud Wallet
Configuration file: HALADB_wallet.zip
Service: haladb_medium or haladb_tp
```

The exact service aliases are listed in the wallet's `tnsnames.ora` file.

---

## 13. Connect from inside the container

Enter the container:

```bash
docker exec -it oracle-adb bash
```

Check available Oracle command-line clients:

```bash
which sql
which sqlplus
```

Inspect environment variables and listening ports:

```bash
env | sort
ss -lnt
```

---

## 14. Verify the database

After connecting as `ADMIN`, run:

```sql
SELECT banner_full
FROM v$version;
```

Check the current database and schema:

```sql
SELECT
    sys_context('USERENV', 'DB_NAME')        AS db_name,
    sys_context('USERENV', 'CON_NAME')       AS container_name,
    sys_context('USERENV', 'CURRENT_SCHEMA') AS current_schema
FROM dual;
```

Check the APEX version:

```sql
SELECT version_no
FROM apex_release;
```

Check ORDS-related users:

```sql
SELECT username
FROM dba_users
WHERE username LIKE 'ORDS%'
ORDER BY username;
```

---

## 15. Create the development schema

Create a normal application schema through Database Actions or SQL Developer.

Where direct user creation is permitted:

```sql
CREATE USER insight
    IDENTIFIED BY "UseAnotherStrongPassword";

GRANT CREATE SESSION TO insight;
GRANT CREATE TABLE TO insight;
GRANT CREATE VIEW TO insight;
GRANT CREATE PROCEDURE TO insight;
GRANT CREATE SEQUENCE TO insight;
GRANT CREATE TRIGGER TO insight;
GRANT CREATE TYPE TO insight;
GRANT CREATE JOB TO insight;
GRANT UNLIMITED TABLESPACE TO insight;
```

For development, `UNLIMITED TABLESPACE` is convenient. For shared or production systems, use an explicit quota instead.

---

## 16. Test SQL and PL/SQL

Connect as `INSIGHT` and create a test table:

```sql
CREATE TABLE iv_test (
    id          NUMBER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    description VARCHAR2(200),
    created_at  TIMESTAMP DEFAULT SYSTIMESTAMP
);
```

Insert a test row:

```sql
INSERT INTO iv_test(description)
VALUES ('HAL9000 Oracle test');

COMMIT;
```

Verify the result:

```sql
SELECT *
FROM iv_test;
```

Create a package:

```sql
CREATE OR REPLACE PACKAGE iv_demo_pkg AS
    PROCEDURE add_message(p_description IN VARCHAR2);
END iv_demo_pkg;
/

CREATE OR REPLACE PACKAGE BODY iv_demo_pkg AS
    PROCEDURE add_message(p_description IN VARCHAR2) IS
    BEGIN
        INSERT INTO iv_test(description)
        VALUES (p_description);
    END add_message;
END iv_demo_pkg;
/
```

Test it:

```sql
BEGIN
    iv_demo_pkg.add_message('PL/SQL package works');
    COMMIT;
END;
/

SELECT *
FROM iv_test
ORDER BY id;
```

---

## 17. Container management

### Start

```bash
cd /srv/oracle-adb
docker compose start
```

### Stop

```bash
docker compose stop
```

### Restart

```bash
docker compose restart
```

### View logs

```bash
docker compose logs -f
```

### Show resource usage

```bash
docker stats oracle-adb
```

### Remove the container but preserve the database volume

```bash
docker compose down
```

### Recreate the container

```bash
docker compose up -d
```

### Important warning

Do not run this command casually:

```bash
docker compose down -v
```

The `-v` option removes the persistent database volume.

---

## 18. Ollama and Oracle resource usage

HAL9000 has 32 GB RAM and a 16 GB NVIDIA GPU.

A practical resource distribution is:

```text
Windows virtual machine     8 GB
Oracle container        up to 10 GB
Ubuntu and filesystem       3–4 GB
Ollama and other tools      remaining RAM
NVIDIA VRAM                 16 GB
```

Monitor the system with:

```bash
free -h
docker stats
nvidia-smi
```

Ollama can still use system RAM even when most of the model is loaded into GPU memory.

During large Oracle imports or profiling tests, avoid loading an Ollama model that exceeds available GPU memory and spills heavily into system RAM.

---

## 19. Backup strategy

At minimum, preserve:

- APEX application exports
- Schema Data Pump exports
- ORDS REST module scripts or exports
- SQL installation and migration scripts
- Docker Compose configuration
- Database package and object source code

Suggested Git repository structure:

```text
insightviewer-oracle/
├── apex/
├── database/
│   ├── tables/
│   ├── views/
│   ├── packages/
│   └── migrations/
├── ords/
├── profiler/
└── docker/
```

Do not treat the Docker volume as the only backup.

---

## 20. Important limitation

The Autonomous Database Free container is a convenient complete programmer environment, but it is not identical to a conventional unrestricted Oracle installation.

Some administrative privileges, initialization parameters, operating-system access, tracing options, and file access may be restricted compared with a traditional Oracle Database installation.

For normal development, it should support:

- SQL and PL/SQL development
- Oracle APEX
- ORDS and REST services
- Database Actions
- Schema development
- InsightViewer integration
- Most profiling experiments

If later testing requires conventional Oracle behavior, unrestricted trace-file access, native listener configuration, or closer compatibility with enterprise Oracle installations, add a second environment using a standard Oracle Database Free container with a separate ORDS container.

---

## 21. Initial command checklist

Run these commands first:

```bash
cat /etc/os-release
uname -m
docker --version
docker compose version
free -h
df -h
nvidia-smi
ls -l /dev/fuse
```

Then create and start the environment:

```bash
sudo mkdir -p /srv/oracle-adb
sudo chown -R "$USER":"$USER" /srv/oracle-adb
cd /srv/oracle-adb
mkdir -p data exports backups scripts
nano .env
nano compose.yaml
docker compose pull
docker compose up -d
docker compose logs -f oracle-adb
```
