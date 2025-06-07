This repository is a fork of PNNL's Network Attack Testbed In [Power] Grid (NATIG) co-simulation environment. It has been specifically configured and adapted for the thesis project, "A Robust Stateful and Adaptive Framework for Detecting and Mitigating Replay Attacks in MODBUS TCP/IP Networks."The primary goal is to provide a stable, containerized environment to simulate Modbus-based industrial control system (ICS) networks, introduce replay attacks, and evaluate the performance of a custom Python-based detection federate.🏛️ Architecture and Setup StrategyThis environment uses Docker to orchestrate three main simulators:GridLAB-D: Simulates the physical power grid.NS-3: Simulates the underlying communication network (including attackers).HELICS: A co-simulation framework that allows GridLAB-D and NS-3 to communicate and stay in sync.Our setup uses a bind mount, which links your local project folder directly to the /rd2c directory inside the Docker container. This is great for development, as you can edit files locally and run them inside the container without rebuilding the image.IMPORTANT: Because of this bind mount, the directory structure of your local machine must match the structure the scripts inside the container expect. The setup instructions below ensure this is the case by cloning necessary dependencies (ns-3-dev, NATIG) into your local project folder.✅ PrerequisitesBefore you begin, ensure you have the following installed on your system:Docker DesktopGit🚀 Step-by-Step Setup InstructionsFollow these steps precisely to create a functional development environment.1. Clone This RepositoryFirst, get a copy of this project on your local machine.git clone <URL_to_your_forked_repo>
cd <your_repo_name>
2. Set Up the Local Directory StructureThis is the most critical step. The following commands download the necessary dependencies (ns-3-dev and a copy of NATIG) into your local project, matching the directory structure that the simulation scripts expect to find inside the container's /rd2c folder.# Clone the required NS-3 development repository
git clone https://github.com/nsnam/ns-3-dev-git.git ns-3-dev

# Create the PUSH directory, which the scripts also need
mkdir PUSH
cd PUSH

# Clone the NATIG repository inside the PUSH directory
git clone https://github.com/pnnl/NATIG.git

# Go back to your project's root directory
cd ..
After this step, your local project folder will contain ns-3-dev/ and PUSH/.3. Build the Docker ImageThis command builds the Docker image using the provided Dockerfile. This process will take a very long time as it compiles GCC, CMake, HELICS, and other dependencies. This is a one-time setup.docker build --network=host -f Dockerfile -t pnnl/natig:natigbase --no-cache .
Note: Ensure you have made the Dockerfile edit from our previous conversation to install GridLAB-D to /usr/local.4. Run the Docker ContainerUse the provided script to run the container. It correctly sets up the bind mount, linking your current directory to /rd2c inside the container.# Stop and remove any old container to avoid conflicts
docker stop natigbase_container
docker rm natigbase_container

# Run the new container
bash rundocker.sh
5. Connect to the ContainerYour container is now running in the background. Connect to its shell to perform the final setup steps.docker exec -it natigbase_container bash
You are now inside the Docker container.6. Compile NS-3 (One-Time Setup)The last step is to compile the NS-3 source code that you cloned locally and is now visible inside the container at /rd2c/ns-3-dev.# Navigate to the directory containing the build script
cd /rd2c/PUSH/NATIG

# Run the build script, telling it where the project root is
./build_ns3.sh "" /rd2c
This compilation will also take a significant amount of time.⚙️ Verification: Running a Test ScenarioYour environment is now fully configured. To verify that everything works, run one of the pre-configured scenarios.Navigate to the control directory:cd /rd2c/integration/control/
Execute a standard test run based on the project's documentation:sudo bash run.sh /rd2c/ 3G "" 123 conf
Expected Outcome: The simulation will start, printing logs from the HELICS broker, GridLAB-D, and NS-3. It will run for several minutes and then exit cleanly without any No such file or directory or command not found errors.Congratulations! You now have a working NATIG co-simulation environment for your thesis research.💻 Development WorkflowEdit code (Python detector, NS3 C++ apps, config files) on your local machine using your favorite editor (e.g., VS Code).Connect to the running container shell using docker exec -it natigbase_container bash.Run simulations from inside the container (e.g., from /rd2c/integration/control). Your code changes will be reflected immediately.📄 Recommended .gitignore fileTo keep your forked repository clean and lightweight, create a file named .gitignore in the root of your project with the following content. This will prevent you from accidentally committing the large dependency folders and generated output files.# Ignore large dependency folders that can be re-cloned
/ns-3-dev/
/PUSH/

# Ignore Python cache files
__pycache__/
*.pyc
*.pyo

# Ignore NS-3 build artifacts
/build/
*.o
*.so
*.a
.sconsign.dblite

# Ignore simulation output files
/output/
/integration/control/output/
*.log
*.pcap
*.csv
*.txt

# Ignore IDE/editor configuration files
.vscode/
.idea/
