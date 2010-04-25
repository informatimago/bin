all:help
help:
	@echo 'make access-rights'
	@echo 'make symlinks'
	@echo 'make tally'
rights access-rights:
	chmod a+rx *
symlinks:
	-rm    check-program-prefix
	ln -s  update-program-prefix                           check-program-prefix
	-rm    make-class
	ln -s  $$HOME/src/pjb/admin/templates/make-class       make-class
	-rm    make-template
	ln -s  $$HOME/src/public/common/makedir/make-template  make-template
	-rm    update-class
	ln -s  $$HOME/src/pjb/admin/templates/update-class     update-class
tally:
	~/bin/tally-bin

#### Makefile                         --                     --          ####
