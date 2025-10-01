# Generate the architecture diagrams
STRUCTURIZR_CONTAINER_IMAGE = structurizr/cli:latest
SIMULATOR_CONTAINER_IMAGE = ghcr.io/alzi-88/ignition_simulator_container:latest
LOCAL_SIMULATOR_IMAGE = docker.io/library/simulation_container:latest

pull-container:
	docker pull $(STRUCTURIZR_CONTAINER_IMAGE) \
		&& docker pull --platform linux/amd64 $(SIMULATOR_CONTAINER_IMAGE)

diagrams-shell:
	docker run --rm -it \
		-v $(shell pwd)/architecture:/usr/local/structurizr \
		-w /usr/local/structurizr \
		$(STRUCTURIZR_CONTAINER_IMAGE) shell

generate-diagrams:
	docker run --rm \
		-v $(shell pwd)/architecture:/usr/local/structurizr \
		-w /usr/local/structurizr \
		$(STRUCTURIZR_CONTAINER_IMAGE) export -workspace workspace.dsl -format plantuml -output /usr/local/structurizr/diagrams

build-sim-container:
	cd docker/simulator_container && \
	export DOCKER_BUILDKIT=1 && \
	docker build -t $(LOCAL_SIMULATOR_IMAGE) -f Dockerfile .

local-sim-shell:
	docker run --rm -it \
			-p 8765:8765 -p 11345:11345 -p 14550:14550 -p 8888:8888 \
			--mount type=bind,source="$(shell pwd)",target=/px4_sim \
			-w /px4_sim/docker/simulator_container/references/px4-ComPiAutopilot \
		$(LOCAL_SIMULATOR_IMAGE) bash -c "\
			chmod +x /px4_sim/px4_airframes/sync_airframes.sh && \
			chmod +x /px4_sim/models/sync_models.sh && \
			. /px4_sim/models/sync_models.sh && \
			. /px4_sim/px4_airframes/sync_airframes.sh && \
			cp -r /px4_sim/models/* Tools/simulation/gz/models/ && \
			bash"

sim-container-shell:
	docker run --rm -it \
		-p 8765:8765 -p 11345:11345 -p 14550:14550 -p 8888:8888 \
		--mount type=bind,source="$(shell pwd)",target=/px4_sim \
		-w /px4_sim/docker/simulator_container/references/px4-ComPiAutopilot \
		$(SIMULATOR_CONTAINER_IMAGE) bash

open-sim-gui:
	# Check if /usr/local/opt/ruby/bin is in PATH otherwise add it
	( \
		if [[ ":$$PATH:" != *":/usr/local/opt/ruby/bin:"* ]]; then \
			export PATH="/usr/local/opt/ruby/bin:$$PATH"; \
		fi; \
		export GZ_VERSION=harmonic; \
		export GZ_SIM_RESOURCE_PATH=$(shell pwd)/docker/simulator_container/references/px4-ComPiAutopilot/Tools/simulation/gz/models; \
		gz sim $(shell pwd)/docker/simulator_container/references/px4-ComPiAutopilot/Tools/simulation/gz/worlds/baylands.sdf -v 4 -s & \
	)
	# Start the gui in another terminal
	( \
		if [[ ":$$PATH:" != *":/usr/local/opt/ruby/bin:"* ]]; then \
			export PATH="/usr/local/opt/ruby/bin:$$PATH"; \
		fi; \
		gz sim -v 4 -g & \
	)