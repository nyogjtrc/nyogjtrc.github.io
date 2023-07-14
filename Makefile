# start hugo dev server with draft post
.PHONY: server
server:
	hugo server -D --logLevel info

# render static file
.PHONY: build
build:
	hugo --logLevel info

# create new post
.PHONY: new-post
new-post:
ifdef POST
	hugo new --logLevel info posts/$$(date +%Y/%m)/$$(echo $(POST) | sed 's/ /-/g').md
endif
ifndef POST
	@echo empty post title
endif

