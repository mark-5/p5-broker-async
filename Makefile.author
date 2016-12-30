export AUTHOR_TESTING  = 1
export RELEASE_TESTING = 1

ifeq ($(TEST_VERBOSE), 0)
	PROVE_FLAGS=
else
	PROVE_FLAGS=-v
endif

PROVE = prove $(PROVE_FLAGS)


cpanfile: Makefile.PL
	perl -MCPAN::Meta -MModule::CPANfile -e 'Module::CPANfile->from_prereqs(CPAN::Meta->load_file("MYMETA.json")->prereqs)->save("cpanfile")'

readme: README.md

README.md: lib/Broker/Async.pm
	pod2markdown $< $@

check-version:
ifndef version
	$(error version is undefined)
endif

release: check-version cpanfile readme test-release
	perl -pi -e 's/(.*)(# __VERSION__)/our \$$VERSION = "$(version)"; $$2/g' `find lib -name '*.pm'`
	perl -pi -e 's/(\{\{\$$NEXT\}\})/$$1\n\n$(version) @{[scalar(localtime)]}/g' Changes
	git commit -a -m 'bump version to $(version)' && git tag $(version)
	git push origin HEAD $(version)

test-release: test
	$(PROVE) xt

