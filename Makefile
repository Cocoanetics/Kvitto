documentation:
	@jazzy \
		--module Kvitto \
		--swift-build-tool spm \
		--build-tool-arguments -Xswiftc,-swift-version,-Xswiftc,5
