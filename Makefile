# Generate the architecture diagrams
CONTAINER_IMAGE = structurizr/cli:latest
pull-container:
	docker pull $(CONTAINER_IMAGE)

shell:
	docker run --rm -it \
		-v $(shell pwd)/architecture:/usr/local/structurizr \
		-w /usr/local/structurizr \
		$(CONTAINER_IMAGE) shell

generate-diagrams:
	docker run --rm \
		-v $(shell pwd)/architecture:/usr/local/structurizr \
		-w /usr/local/structurizr \
		$(CONTAINER_IMAGE) export -workspace workspace.dsl -format plantuml -output /usr/local/structurizr/diagrams
