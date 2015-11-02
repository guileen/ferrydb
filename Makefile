install_rocks:
	cd extern/rocksdb && make install-shared

install_golibs:
	go get -u github.com/gpmgo/gopm

install: install_rocks install_golibs

.PHONY: install

