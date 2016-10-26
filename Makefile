DISTRIBUTIONS = Broker-Async \
				Broker-Async-AnyEvent \
				Broker-Async-IO-Async \
				Broker-Async-POE

CARTON = PERL_CARTON_CPANFILE=$(PWD)/cpanfile PERL_CARTON_PATH=$(PWD)/local carton exec

default: build

build:
	carton install
	for dist in $(DISTRIBUTIONS); \
	do \
		( \
			cd $(PWD)/$$dist; \
			$(CARTON) perl Makefile.PL; \
			$(CARTON) make; \
		) \
	done

test: build
	for dist in $(DISTRIBUTIONS); \
	do \
		( \
			cd $(PWD)/$$dist; \
			$(CARTON) perl Makefile.PL; \
			$(CARTON) make test; \
		) \
	done; \
	$(CARTON) prove t

clean:
	for dist in $(DISTRIBUTIONS); \
	do \
		( \
			cd $(PWD)/$$dist; \
			make clean; \
		) \
	done

