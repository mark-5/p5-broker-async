DISTRIBUTIONS = Broker-Async \
				Broker-Async-AnyEvent \
				Broker-Async-IO-Async \
				Broker-Async-POE

DIST_PERL5OPT = PERL5OPT="$(DISTRIBUTIONS:%=-I$(PWD)/%/lib)"

CARTON = $(DIST_PERL5OPT) PERL_CARTON_CPANFILE=$(PWD)/cpanfile PERL_CARTON_PATH=$(PWD)/local carton


.SUFFIXES: .PL

.PL:
	cd $(dir $<) && $(CARTON) exec perl Makefile.PL


default: build

build: cpanfile.snapshot $(DISTRIBUTIONS:%=%/Makefile)

cpanfile.snapshot: $(DISTRIBUTIONS:%=%/cpanfile)
	$(CARTON) install


test: build prove $(DISTRIBUTIONS:%=test-%)

prove:
	$(CARTON) exec prove t

test-%:
	cd $(subst test-,,$@) && $(CARTON) exec make test


clean: $(DISTRIBUTIONS:%=clean-%)

clean-%:
	cd $(subst clean-,,$@) && $(CARTON) exec make clean


version:
ifndef VERSION
	$(error VERSION is undefined)
endif
	for file in $(shell find $(DISTRIBUTIONS) -name '*.pm'); \
	do \
		perl -pi -e 's/(our \$$VERSION = )(.*)(; # version set by makefile)/$$1"$(VERSION)"$$3/' $$file; \
	done

