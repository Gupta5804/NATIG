```markdown
# NATIG-Replay-Detection Testbed

> **Fork of PNNL’s [NATIG: Network Attack Testbed In \[Power\] Grid](https://github.com/pnnl/NATIG)**  
> Adapted for the thesis **“A Robust Stateful and Adaptive Framework for Detecting and Mitigating Replay Attacks in MODBUS TCP/IP Networks.”**

This repository provides a fully containerised co-simulation environment for **Modbus-based industrial control systems (ICS)**. It lets you

* spin up a realistic power-grid + network testbed,  
* inject replay attacks, and  
* evaluate a custom **Python-based detection federate** developed for the thesis.

---

## Table of Contents
1. [Architecture](#architecture)
2. [Prerequisites](#prerequisites)
3. [Quick-start](#quick-start)
4. [Detailed Setup](#detailed-setup)
5. [Verification Run](#verification-run)
6. [Development Workflow](#development-workflow)
7. [.gitignore Template](#gitignore-template)
8. [License](#license)

---

## Architecture 🏛️
The environment is orchestrated with **Docker** and binds your project folder directly into the container for painless, rebuild-free development.

| Simulator | Purpose | Notes |
|-----------|---------|-------|
| **GridLAB-D** | Physical power-grid dynamics | Installed to `/usr/local` |
| **ns-3** | Communication-network & attacker traffic | Custom build in `/rd2c/ns-3-dev` |
| **HELICS** | Co-simulation broker keeping everything in sync | |

```

host ──docker──────────────────────────────────────────────────────
│
│  bind-mount: <repo-root>  ↔  /rd2c   (inside container)
│
└─►  GridLAB-D  ⇄  HELICS  ⇄  ns-3  ⇄  (attack scripts)

````

---

## Prerequisites ✅
* **Docker Desktop** (or Docker Engine + Docker Compose)  
* **Git**

---

## Quick start 🚀

```bash
# 1) Clone your fork
git clone <URL_to_your_forked_repo>
cd <your_repo_name>

# 2) Pull dependencies into the expected structure
git clone https://github.com/nsnam/ns-3-dev-git.git ns-3-dev
mkdir -p PUSH && cd PUSH
git clone https://github.com/pnnl/NATIG.git
cd ..

# 3) Build the image  (⚠️ first time only – this is long!)
docker build --network=host -f Dockerfile -t pnnl/natig:natigbase --no-cache .

# 4) Run the container with the helper script
bash rundocker.sh

# 5) Jump into the running container
docker exec -it natigbase_container bash
````

---

## Detailed Setup 🛠️

### 1 · Clone this repo

```bash
git clone <URL_to_your_forked_repo>
cd <your_repo_name>
```

### 2 · Create the directory layout **exactly** as scripts expect

```bash
git clone https://github.com/nsnam/ns-3-dev-git.git ns-3-dev
mkdir PUSH && cd PUSH
git clone https://github.com/pnnl/NATIG.git
cd ..
```

Your tree now contains:

```
<repo>
├── ns-3-dev/
└── PUSH/
    └── NATIG/
```

### 3 · Build the Docker image

```bash
docker build --network=host -f Dockerfile -t pnnl/natig:natigbase --no-cache .
```

> The first build compiles GCC, CMake, HELICS, GridLAB-D etc. – grab a coffee ☕.

### 4 · Run / restart the container

```bash
docker stop natigbase_container 2>/dev/null || true
docker rm   natigbase_container 2>/dev/null || true
bash rundocker.sh
```

### 5 · Attach to the container shell

```bash
docker exec -it natigbase_container bash
```

### 6 · Compile ns-3 (one-time inside the container)

```bash
cd /rd2c/PUSH/NATIG
./build_ns3.sh "" /rd2c
```

If you've installed the code to a different directory, set the `RD2C` variable
before running helper scripts. For example:

```bash
export RD2C=/custom/path
bash update_workstation.sh
```

---

## Verification Run ⚙️

Inside the container:

```bash
cd /rd2c/integration/control
sudo bash run.sh /rd2c/ 3G "" 123 conf
```

Expected result: logs from HELICS, GridLAB-D, and ns-3 appear; the simulation finishes without **“No such file or directory”** errors.

---

## Development Workflow 💻

1. **Edit locally** – code, configs, docs (VS Code, vim, etc.).
2. **Attach** to the running container:
   `docker exec -it natigbase_container bash`
3. **Run simulations** from inside `/rd2c/integration/control`.
   Changes are picked up instantly thanks to the bind mount.

---

## .gitignore Template 📄

Create `.gitignore` in the repo root:

```gitignore
# Large dependencies (re-clonable)
ns-3-dev/
PUSH/

# Python artefacts
__pycache__/
*.py[co]

# ns-3 build artefacts
/build/
*.o
*.so
*.a
.sconsign.dblite

# Simulation output
/output/
integration/control/output/
*.log
*.pcap
*.csv
*.txt

# IDE settings
.vscode/
.idea/
```

---

## License 📝

This fork inherits the original **PNNL NATIG** license.
See `LICENSE` for details.

---

> **Questions or issues?**
> Open an [issue](../../issues) or start a discussion – contributions are welcome!

```
```
