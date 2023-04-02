BIN = a.out
DOCKER_IMAGE_NAME = chameleon-v1
DOCKER_CONTAINER_NAME = container-$(DOCKER_IMAGE_NAME)

all: compile

compile:
	cd src &&\
	flex lex.l &&\
	yacc translate.y -d -v &&\
	gcc -o $(BIN) symbol.h symbol.c -lm montador_lexer.h montador_lexer.c -lm\
		hash-table.h hash-table.c y.tab.c lex.yy.c y.tab.h -ll ;\
	cd ..

llvm:
	llvm-as cod.ll -o cod.bc &&\
	llc cod.bc -o cod.s &&\
	clang-10 cod.s -o cod.native &&\
	echo "\nTo run the code, please execute: make run_native"

run:
	./src/$(BIN)

run_native:
	./cod.native

reset_docker:
	docker stop $(DOCKER_CONTAINER_NAME) && docker rm $(DOCKER_CONTAINER_NAME) && docker rmi $(DOCKER_IMAGE_NAME)

run_docker:
	echo "Deleting container and image"
	-make reset_docker
	wait

	echo "Building image: $(DOCKER_IMAGE_NAME)"
	docker build -t $(DOCKER_IMAGE_NAME) .

	echo "Starting container: $(DOCKER_CONTAINER_NAME)"
	docker run --name $(DOCKER_CONTAINER_NAME) -d -i -t $(DOCKER_IMAGE_NAME) /bin/sh

	echo "Container '$(DOCKER_CONTAINER_NAME)' started"

enter_docker_container:
	docker exec -it $(DOCKER_CONTAINER_NAME) sh