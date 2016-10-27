DISTRIBUTIONS = Broker-Async \
				Broker-Async-AnyEvent \
				Broker-Async-IO-Async \
				Broker-Async-POE

CPANFILES = cpanfile $(foreach dist,$(DISTRIBUTIONS),$(PWD)/$(dist)/cpanfile)

DIST_MAKEFILES = $(foreach dist,$(DISTRIBUTIONS),$(PWD/)$(dist)/Makefile)

DIST_PERL5OPT = PERL5OPT="$(foreach dist,$(DISTRIBUTIONS),-I$(PWD)/$(dist)/lib)"

CARTON = $(DIST_PERL5OPT) PERL_CARTON_CPANFILE=$(PWD)/cpanfile PERL_CARTON_PATH=$(PWD)/local carton


.SUFFIXES: .PL

.PL:
	(cd $(dir $<) && $(CARTON) exec perl Makefile.PL)


default: build

build:
	$(MAKE) cpanfile.snapshot
	$(MAKE) $(DIST_MAKEFILES)
	for dist in $(DISTRIBUTIONS); \
	do \
		( \
			cd $(PWD)/$$dist; \
			$(CARTON) exec make; \
		) \
	done

cpanfile.snapshot: $(CPANFILES)
	$(CARTON) install

test: build
	for dist in $(DISTRIBUTIONS); \
	do \
		( \
			cd $(PWD)/$$dist; \
			$(CARTON) exec make test; \
		) \
	done; \
	$(CARTON) exec prove t

clean:
	for dist in $(DISTRIBUTIONS); \
	do \
		( \
			cd $(PWD)/$$dist; \
			make clean; \
		) \
	done

version:
ifndef VERSION
	$(error VERSION is undefined)
endif
	for file in $(shell find $(DISTRIBUTIONS) -name '*.pm'); \
	do \
		( \
			perl -pi -e 's/(our \$$VERSION = )(.*)(; # version set by makefile)/$$1"$(VERSION)"$$3/' $$file; \
		) \
	done

