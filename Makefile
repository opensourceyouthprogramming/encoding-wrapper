all: test

testdeps:
	go get -d -t ./...

checkfmt: testdeps
	@export output="$$(gofmt -s -l .)" && \
		[ -n "$${output}" ] && \
		echo "Unformatted files:" && \
		echo && echo "$${output}" && \
		echo && echo "Please fix them using 'gofmt -s -w .'" && \
		export status=1; exit $${status:-0}

deadcode:
	go get github.com/remyoudompheng/go-misc/deadcode
	go list ./... | sed -e "s;github.com/NYTimes/encoding-wrapper/;;" | xargs deadcode

lint: testdeps
	go get github.com/golang/lint/golint
	@for file in $$(git ls-files '*.go'); do \
		export output="$$(golint $${file})"; \
		[ -n "$${output}" ] && echo "$${output}" && export status=1; \
	done; \
	exit $${status:-0}

test: checkfmt lint vet deadcode
	go test ./...

vet: testdeps
	go get golang.org/x/tools/cmd/vet
	go vet ./...
