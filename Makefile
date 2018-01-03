CURRENT_REVISION = $(shell git rev-parse --short HEAD)
REPO_OWNER = mpppk
REPO_NAME = goreleng-test
BUILD_PATH = ./cmd/
ifdef update
  u=-u
endif

bindata:
	go-bindata -pkg etc -o etc/bindata.go tmpl/

deps:
	dep ensure

devel-deps:
	go get ${u} github.com/golang/dep/cmd/dep
	go get ${u} github.com/motemen/gobump/cmd/gobump
	go get ${u} github.com/Songmu/goxz/cmd/goxz
	go get ${u} github.com/Songmu/ghch/cmd/ghch
	go get ${u} github.com/tcnksm/ghr

test: deps
	go test ./...

build: deps
	go build $(BUILD_PATH)

install: deps
	go install $(BUILD_PATH)

crossbuild: deps test
	goxz -pv=v`gobump show -r $(BUILD_PATH)` -d=./dist/v`gobump show -r $(BUILD_PATH)` $(BUILD_PATH)

bump-and-commit: deps test
	gobump patch -w $(BUILD_PATH)
	ghch -w -N v`gobump show -r $(BUILD_PATH)`
	git add CHANGELOG.md
	git commit -am "Checking in changes prior to tagging of version v`gobump show -r $(BUILD_PATH)`"
	git tag `gobump show -r $(BUILD_PATH)`
	git push "https://$(GITHUB_TOKEN)@github.com/$(REPO_OWNER)/$(REPO_NAME)" HEAD:master

release: crossbuild
	ghr --username $(REPO_OWNER) `gobump show -r $(BUILD_PATH)` dist/v`gobump show -r $(BUILD_PATH)`

.PHONY: bump test deps devel-deps crossbuild release