BUILD_PATH=$(shell pwd)
EXTERN=$(BUILD_PATH)/extern
ROCKS_PATH=$(EXTERN)/rocksdb
ROCKS_INCLUDE=$(ROCKS_PATH)/include
LIBRARY=$(BUILD_PATH)/extern/lib
LZ4_PATH=$(EXTERN)/lz4

install: install_gorocks

$(LIBRARY)/liblz4.a:
	-mkdir -p $(LIBRARY)
	cd $(LZ4_PATH)/lib && make CFLAGS='-fPIC' all
	cp $(LZ4_PATH)/lib/liblz4.a $(LIBRARY)

rocksdb: $(LIBRARY)/liblz4.a
	# install-shared
	# cd $(ROCKS_PATH) && DYLD_LIBRARY_PATH=$(LIBRARY) make -j4 shared_lib
	cd $(ROCKS_PATH) && DYLD_LIBRARY_PATH=$(LIBRARY) LD_LIBRARY_PATH=$(LIBRARY) make -j8 static_lib
	cd $(ROCKS_PATH) && DYLD_LIBRARY_PATH=$(LIBRARY) LD_LIBRARY_PATH=$(LIBRARY) make -j8 install-shared
	cp -r $(ROCKS_PATH)/librocksdb.* $(LIBRARY)

install_gorocks: rocksdb
	go get github.com/gpmgo/gopm
	# -lz -lz4
	cd extern/gorocks && go clean -i ./ && DYLD_LIBRARY_PATH=$(LIBRARY) LD_LIBRARY_PATH=$(LIBRARY) CGO_CFLAGS="-I$(ROCKS_INCLUDE)" CGO_LDFLAGS="-L$(LIBRARY) -lz -llz4" go install ./
	# cd extern/gorocks && go clean -i ./ && CGO_CFLAGS="-I$(ROCKS_INCLUDE) -I$(SNAPPY_INCLUDE)" CGO_LDFLAGS="-L$(ROCKS_LIB) -L$(SNAPPY_LIB)" go install ./

clean:
	cd $(ROCKS_PATH) && make clean
	cd $(LZ4_PATH)/lib && make clean
	rm -rf $(LIBRARY)/lib*

test:
	DYLD_LIBRARY_PATH=$(LIBRARY) LD_LIBRARY_PATH=$(LIBRARY) CGO_CFLAGS="-I$(ROCKS_INCLUDE)" CGO_LDFLAGS="-L$(LIBRARY) -lz -llz4" go test -v ./...
