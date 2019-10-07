build: install-dependencies quickbuild

quickbuild:
	@echo Building plugin

	rm -rf dist
	cd server && go get github.com/mitchellh/gox
	$(shell go env GOPATH)/bin/gox -osarch='darwin/amd64 linux/amd64 windows/amd64' -gcflags='all=-N -l' -output 'dist/intermediate/plugin_{{.OS}}_{{.Arch}}' ./server

	mkdir -p dist/bigbluebutton/server

	# Clean old dist
	rm -rf webapp/dist
	cd webapp && npm run build

	# Copy files from webapp
	mkdir -p dist/bigbluebutton/webapp
	cp webapp/dist/* dist/bigbluebutton/webapp/

	# Copy plugin files
	cp plugin.yaml dist/bigbluebutton/

	# Package darwin pakckage
	mv dist/intermediate/plugin_darwin_amd64 dist/bigbluebutton/server/plugin.exe
	cd dist && tar -zcvf bigbluebutton_darwin_amd64.tar.gz bigbluebutton/*

	# Package linux package
	mv dist/intermediate/plugin_linux_amd64 dist/bigbluebutton/server/plugin.exe
	cd dist && tar -zcvf bigbluebutton_linux_amd64.tar.gz bigbluebutton/*

	# Package windows package
	mv dist/intermediate/plugin_windows_amd64.exe dist/bigbluebutton/server/plugin.exe
	cd dist && tar -zcvf bigbluebutton_windows_amd64.tar.gz bigbluebutton/*

	# Clean up temp files
	rm -rf dist/bigbluebutton
	rm -rf dist/intermediate

	@echo Plugin built at: dist/bigbluebutton.tar.gz

install-dependencies:
	cd server && go get github.com/Masterminds/glide
	cd server && $(shell go env GOPATH)/bin/glide install

	#installs node modules
	cd webapp && npm install

clean:
	@echo Cleaning plugin

	rm -rf dist
	cd webapp && rm -rf node_modules
	cd webapp && rm -f .npminstall
