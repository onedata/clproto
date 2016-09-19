.PHONY: deps

all: deps compile

deps:
	@./rebar get-deps

compile:
	@./rebar compile

clean:
	@./rebar clean

distclean: clean
	@./rebar delete-deps

include/messages.hrl:
	mkdir -p build priv include
	if [ -x ./_build/default/lib/gpb/bin/protoc-erl ]; then \
	    PROTOCERL=./_build/default/lib/gpb/bin/protoc-erl; \
	else \
	    PROTOCERL=../gpb/bin/protoc-erl; \
	fi; \
	$$PROTOCERL -il -strbin -nif -I`pwd`/proto -o-erl src -o-hrl include -o-nif-cc build `pwd`/proto/messages.proto; \

priv/messages.nif.so: include/messages.hrl
	cd build && LDFLAGS= CFLAGS= CXXFLAGS= cmake .. -GNinja -Wno-dev \
	    -DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_FLAGS="$$ERL_CFLAGS" \
	    -DCMAKE_POSITION_INDEPENDENT_CODE=On -DBUILD_NIF_LIBS=On
	cmake --build build --target messages.nif
	cp build/messages.nif.so priv/
