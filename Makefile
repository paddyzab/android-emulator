SHELL := /bin/bash
ALIAS = "android"
EXISTS := $(shell docker ps -a -q -f name=$(ALIAS))
RUNNED := $(shell docker ps -q -f name=$(ALIAS))
ifneq "$(RUNNED)" ""
IP := $(shell docker inspect $(ALIAS) | grep "IPAddress\"" | head -n1 | cut -d '"' -f 4)
endif
STALE_IMAGES := $(shell docker images | grep "<none>" | awk '{print($$3)}')
EMULATOR ?= "android-21"
ARCH ?= "x86"

COLON := :

.PHONY = run ports kill ps

all:
	@docker build -q -t tracer0tong/android-emulator\:latest .
	@docker images

run: clean
	@docker run -it "EMULATOR=$(EMULATOR)" -e "ARCH=$(ARCH)" -d -P --name android --log-driver=json-file paddyzab/android-emulator

ports:
ifneq "$(RUNNED)" ""
	$(eval ADBPORT := $(shell docker port $(ALIAS) | grep '5555/tcp' | awk '{split($$3,a,"$(COLON)");print a[2]}'))
	@echo -e "Use:\n adb kill-server\n adb connect $(IP):$(ADBPORT)"
	@echo -e "or\n adb connect 0.0.0.0:$(ADBPORT)"
else
	@echo "Run container"
endif

clean: kill
	@docker ps -a -q | xargs -n 1 -I {} docker rm -f {}
ifneq "$(STALE_IMAGES)" ""
	@docker rmi -f $(STALE_IMAGES)
endif

kill:
ifneq "$(RUNNED)" ""
	@docker kill $(ALIAS)
endif

ps:
	@docker ps -a -f name=$(ALIAS)
