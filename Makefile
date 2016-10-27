DISTRIBUTIONS = Broker-Async \
				Broker-Async-AnyEvent \
				Broker-Async-IO-Async \
				Broker-Async-POE

DIST_PERL5OPT = PERL5OPT="$(foreach lib,$(wildcard Broker-Async*/lib),-I$(PWD)/$(lib))"

CARTON = $(DIST_PERL5OPT) PERL_CARTON_CPANFILE=$(PWD)/cpanfile PERL_CARTON_PATH=$(PWD)/local carton


.SUFFIXES: .PL

.PL:
	cd $(dir $<) && $(CARTON) exec perl Makefile.PL


default: build


configure: cpanfile.snapshot $(DISTRIBUTIONS:%=%/Makefile)

build: configure $(DISTRIBUTIONS:%=build-%)

build-%:
	cd $(subst build-,,$@) && $(CARTON) exec make

cpanfile.snapshot: cpanfile $(DISTRIBUTIONS:%=%/cpanfile)
	$(CARTON) install


test: build prove $(DISTRIBUTIONS:%=test-%)

prove:
	$(CARTON) exec prove t

test-%:
	cd $(subst test-,,$@) && $(CARTON) exec make test

cover: build $(DISTRIBUTIONS:%=cover-%)

cover-%:
	cd $(subst cover-,,$@) && $(CARTON) exec -- cover -test

clean: $(DISTRIBUTIONS:%=clean-%)

clean-%:
	cd $(subst clean-,,$@) && $(CARTON) exec make clean


readme: README.md

README.md: Broker-Async/lib/Broker/Async.pm
	pod2markdown $< $@

dist: configure manifest $(DISTRIBUTIONS:%=dist-%)

dist-%:
	cd $(subst dist-,,$@) && $(CARTON) exec make dist

distcheck: configure $(DISTRIBUTIONS:%=distcheck-%)

distcheck-%:
	cd $(subst distcheck-,,$@) && $(CARTON) exec make distcheck

manifest: $(DISTRIBUTIONS:%=%/Makefile) $(DISTRIBUTIONS:%=manifest-%)

manifest-%:
	cd $(subst manifest-,,$@) && $(CARTON) exec make manifest

version:
ifndef VERSION
	$(error VERSION is undefined)
endif
	for file in $(shell find $(DISTRIBUTIONS) -name '*.pm'); \
	do \
		perl -pi -e 's/(our \$$VERSION = )(.*)(; # version set by makefile)/$$1"$(VERSION)"$$3/' $$file; \
	done

