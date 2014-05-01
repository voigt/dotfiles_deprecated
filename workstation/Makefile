GITCOMMIT := $(shell git rev-parse --short=7 HEAD 2>/dev/null)
NAME=dev

all: build

build:
	docker build -t voigt/${NAME}:${GITCOMMIT} .

push:
	@echo "==> Publishing voigt/${NAME}:$(GITCOMMIT)"
	@docker tag voigt/${NAME}:$(GITCOMMIT) voigt/${NAME}:latest
	@docker push voigt/${NAME}:$(GITCOMMIT)
	@docker push voigt/${NAME}:latest
	@echo "==> Your image is now available at voigt/${NAME}:$(GITCOMMIT)"

run: kill
	docker run -it -h dev -d -p 3222:3222 --rm -v /var/run/docker.sock:/var/run/docker.sock -v /Users/christophvoigt/go:/home/voigt/go -v /Users/christophvoigt/.ssh:/home/voigt/.ssh -v /Users/christophvoigt/.zsh_history:/home/voigt/.zsh_history --cap-add=SYS_PTRACE --security-opt seccomp=unconfined --privileged --name dev voigt/dev:${GITCOMMIT}
	@# docker run -it -h dev -d --net=host -p 3222:3222 --rm -v /var/run/docker.sock:/var/run/docker.sock -v /Users/christophvoigt/go:/home/voigt/go -v /Users/christophvoigt/.ssh:/home/voigt/.ssh -v /Users/christophvoigt/.zsh_history:/home/voigt/.zsh_history --cap-add=SYS_PTRACE --security-opt seccomp=unconfined --privileged --name dev voigt/dev:${GITCOMMIT}
	@# docker run -it -h dev -d --net=host --rm -v /var/run/docker.sock:/var/run/docker.sock -v /Users/christophvoigt/code:/home/voigt/code -v /Users/christophvoigt/.ssh:/home/voigt/.ssh -v /Users/christophvoigt/.zsh_private:/home/voigt/.zsh_private -v /Users/christophvoigt/.zsh_history:/home/voigt/.zsh_history --cap-add=SYS_PTRACE --security-opt seccomp=unconfined --privileged --name dev voigt:dev 

ssh:
	@mosh --no-init --ssh="ssh -o StrictHostKeyChecking=no -i ~/.ssh/github_rsa -p 3222" root@workstation.christophvoigt.com -- tmux new-session -AD -s main

kill:
	docker kill dev | true

infra:
	op signin https://my.1password.com voigt.christoph@gmail.com --output=raw | \
	op get document 'workstation_env.tfvars' > env.tfvars
	terraform init
	terraform apply -auto-approve -var-file=env.tfvars

.PHONY: all build run kill
