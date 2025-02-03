# .Devcontainer

## Configuración del entorno de desarrollo

Esta carpeta contiene los archivos necesarios para configurar un entorno de desarrollo reproducible utilizando **Devcontainer**. Un Devcontainer es un entorno de desarrollo basado en contenedores que permite a los desarrolladores trabajar en un entorno consistente, sin importar la configuración de su máquina local.

---

## ¿Qué es un Devcontainer?

Un Devcontainer es un contenedor de Docker configurado específicamente para proporcionar un entorno de desarrollo completo. Al usar Devcontainers:
- Todos los desarrolladores trabajan en el mismo entorno.
- No es necesario instalar dependencias localmente, ya que todo está contenido en el Devcontainer.
- Se pueden personalizar herramientas, extensiones de Visual Studio Code, y configuraciones para proyectos específicos.

---

## ¿Qué incluye este Devcontainer?

Este Devcontainer utiliza **Miniconda** como entorno base y está configurado para trabajar con **Azure** y otras herramientas necesarias para este laboratorio. A continuación, se describen las principales configuraciones:

### 1️⃣ **Configuración Base**
- Basado en un **Dockerfile** ubicado en la raíz del repositorio.
- Utiliza Miniconda para gestionar dependencias de Python.

### 2️⃣ **Herramientas preinstaladas**
- **Azure CLI** con soporte para Bicep.
- **Azure Bicep Tools** para gestionar despliegues de infraestructura.
- **Utilidades comunes** como Zsh, Oh-My-Zsh y herramientas de desarrollo.

### 3️⃣ **Extensiones preconfiguradas**
El Devcontainer incluye extensiones de Visual Studio Code esenciales para el laboratorio:
- Desarrollo con Python (`ms-python.vscode-pylance`, `ms-python.python`).
- Soporte para Jupyter Notebooks (`ms-toolsai.jupyter`).
- Integración con Azure (`ms-azuretools.vscode-bicep`, `ms-azuretools.vscode-docker`).
- Herramientas de PromptFlow (`prompt-flow.prompt-flow`).
- GitHub Copilot y otras utilidades.

### 4️⃣ **Puertos expuestos**
Los puertos **80** y **443** están expuestos para pruebas locales y comunicación con servicios.

### 5️⃣ **Script Post-Creación**
Después de crear el contenedor, se ejecuta un script `post-create.sh` que:
- Configura permisos y prepara el entorno.
- Descarga y configura **Oh My Posh** para mejorar la experiencia de la terminal.

---

## ¿Cómo usar este Devcontainer?

1. **Instalar Docker y Visual Studio Code**:
   - Asegúrate de tener [Docker](https://www.docker.com/) instalado y en ejecución.
   - Instala [Visual Studio Code](https://code.visualstudio.com/) y la extensión `Remote - Containers`.

2. **Abrir el proyecto en un Devcontainer**:
   - Abre Visual Studio Code.
   - Desde la paleta de comandos (`Ctrl+Shift+P` o `Cmd+Shift+P`), selecciona `Dev Containers: Reopen in Container`.

3. **Trabajar en el entorno**:
   - Una vez que el contenedor se haya iniciado, estarás listo para trabajar con todas las herramientas y configuraciones disponibles.

---

## Recursos adicionales

- [Introducción a Devcontainers](https://containers.dev/)
- [Configuración avanzada de Devcontainers](https://code.visualstudio.com/docs/remote/containers)
- [Documentación de Azure CLI](https://learn.microsoft.com/es-es/cli/azure/)

---

¡Disfruta trabajando en un entorno de desarrollo completamente configurado y listo para usar!
