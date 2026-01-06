CFLAGS += $(shell pkg-config --cflags libcrypto) -Wno-deprecated-declarations
LDLIBS += $(shell pkg-config --libs libcrypto)

LIBRARIES += md5.so

md5.so : ../../lib/src/md5.c ../../lib/src/md5.mk
	$(CC) -o md5.so -shared $(CFLAGS) $< $(LDLIBS)
