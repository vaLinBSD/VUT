# Návod: Kontejnerová aplikace pro měřicí systém

Tento dokument vás provede instalací Docker, uspořádáním projektu a implementací jednotlivých částí aplikace, která se skládá ze čtyř kontejnerů:

1. **Frontend** – jednoduché webové UI (Streamlit)
2. **Backend** – REST API (Python Flask/FastAPI)
3. **Ingestion** – generátor dat, který posílá měření do backendu
4. **Databáze** – PostgreSQL

---

# 1. Instalace Docker prostředí

##  1.1 Instalace Docker Engine (doporučeno)

### **Linux (Ubuntu/Debian)**

Nejjednodušší metoda:

```bash
curl -fsSL https://get.docker.com | sudo sh
```

Přidejte uživatele do skupiny `docker`, abyste mohli používat Docker bez `sudo`:

```bash
sudo usermod -aG docker $USER
newgrp docker
```

### **Ověření instalace**

```bash
docker run hello-world
```

Docker Compose je dnes součástí Dockeru jako příkaz:

```bash
docker compose version
```

Pokud se vypíše verze → OK.

---

# 2. Organizace projektu

Struktura složek projektu může vypadat takto:

```
measurement-system/
│
├── docker-compose.yml
│
├── backend/
│   ├── app.py
│   ├── requirements.txt
│   └── Dockerfile
│
├── frontend/
│   ├── app.py
│   ├── requirements.txt
│   └── Dockerfile
│
├── ingestion/
│   ├── app.py
│   ├── requirements.txt
│   └── Dockerfile
│
└── init_db/
    └── init.sql
```

Každý adresář obsahuje:

* `Dockerfile` – jak postavit image
* `app.py` - zdrojový kód aplikace 
* `requirements.txt` – pythoní závislosti, které je nutné naistalovat pomocí pip v kontejnery (RUN ...)

Centrální soubor `docker-compose.yml` propojuje všechny kontejnery.

---

# 3. Jednotlivé implementované aplikace

## 3.1 Backend (REST API)

Backend zajišťuje serverovou logiku aplikace.
Jeho úkolem je:

* přijímat HTTP POST požadavky s novými měřeními z ingestion služby
* ukládat přijatá data do databáze PostgreSQL
* poskytovat endpoint `/latest` pro načtení posledních měření frontendem
* vzorová implementace: [backend/app.py](./backend/app.py)

## 3.2 Frontend (Streamlit)

Frontend poskytuje uživatelské rozhraní pro zobrazení naměřených dat.
Charakteristiky:

* data **nečte přímo z databáze**
* pro veškerou komunikaci využívá REST API backendu
* zobrazuje tabulku posledních měření
* vzorová implementace: [frontend/app.py](./frontend/app.py)

## 3.3 Ingestion (generátor dat)

Ingestion služba simuluje měřicí zařízení.
Jejím úkolem je:

* generovat v pravidelných intervalech pseudo-náhodná měření
* odesílat je pomocí HTTP POST na backend
* sloužit jako ukázka automatizovaného sběru dat
* vzorová implementace: [ingestion/app.py](./ingestion/app.py)


## 3.4 Databáze PostgreSQL

Použijete oficiální image `postgres`.

Docker Compose zajistí:

* vytvoření databáze a tabulky pro data (measurements)
* uživatele
* persistentní volume

Zde není Dockerfile. Pro vytvoření kontejneru použijte následující blok v services v souboru `docker-compose.yaml`:

```
  db:
    image: postgres:15
    container_name: measurement_db
    environment:
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres
      POSTGRES_DB: measurements
    volumes:
      - db_data:/var/lib/postgresql/data
      - ./init_db/init.sql:/docker-entrypoint-initdb.d/init.sql
    ports:
      - "5432:5432"
```

# 4. Docker a Docker Compose 

**Vaším úkolem na napsat jednotlivé *Dockerfile* a *docker-compose.yaml*, tak aby byla aplikace spustitelná.**

Mapování portů jednotlivých služeb:

| Služba                    | Interní port (v kontejneru) | Mapování na hostitele     | Dostupnost z hostitele                         | Poznámka                                |
| ------------------------- | --------------------------- | ------------------------- | ---------------------------------------------- | --------------------------------------- |
| **Backend (API)**         | 5000                        | `5000:5000`               | [http://localhost:5000](http://localhost:5000) | REST API pro frontend a ingestion       |
| **Frontend (UI)**         | 8501                        | `8501:8501`               | [http://localhost:8501](http://localhost:8501) | Webové rozhraní Streamlit               |
| **Ingestion**             | –                           | -                         | -                                              | Komunikuje pouze uvnitř Docker sítě     |
| **Databáze (PostgreSQL)** | 5432                        | `5432:5432` *(volitelné)* | pokud namapováno → `localhost:5432`            | Pro backend vždy dostupná v Docker síti |


# 5. Spuštění celé aplikace

V kořenové složce projektu:

```bash
docker compose up --build
```

Frontend bude dostupný na:

```
http://localhost:8501
```

Backend API na:

```
http://localhost:5000/latest
```
