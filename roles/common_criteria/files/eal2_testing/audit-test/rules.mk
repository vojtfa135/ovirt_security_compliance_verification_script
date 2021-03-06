##########################################################################
#   Copyright (C) International Business Machines  Corp., 2003
#   (c) Copyright Hewlett-Packard Development Company, L.P., 2005
#
#   This program is free software: you can redistribute it and/or modify
#   it under the terms of version 2 the GNU General Public License as
#   published by the Free Software Foundation.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
#
#
#  FILE   : rules.mk
#
#  PURPOSE: This rules file facilitates the compiling, linking and running
#           of the Linux Auditing System test suite.
#
#           Rules are provided for dependency building, compiling, sub
#           directory traversal and running of the tests.
#
#
#  HISTORY:
#    08/03 originated by Tom Lendacky (toml@us.ibm.com)
#
##########################################################################

SHELL := /bin/bash

MACHINE		= $(strip $(shell uname -m))
VIRT_TYPE	= $(shell virt-what)
X		= i486 i586 i686 ix86
P		= ppc powerpc
IP		= ppc64 powerpc64
Z		= s390
Z64		= s390x
X86_64		= x86_64
IA		= ia64
CFLAGS          += -g -O2 -Wall -Werror -D_GNU_SOURCE -fno-strict-aliasing
LDFLAGS         +=

LINK_AR		= $(AR) rc $@ $^
LINK_EXE	= $(CC) $(LDFLAGS) -o $@ $^ $(LOADLIBES) $(LDLIBS)
LINK_SO		= $(CC) $(LDFLAGS) -shared -o $@ $^ $(LOADLIBES) $(LDLIBS)

export MACHINE

# If MODE isn't set explicitly, the default for the machine is used
NATIVE		= $(strip $(shell file /bin/bash | awk -F'[ -]' '{print $$3}'))
export MODE	?= $(NATIVE)
ifneq ($(MODE), $(NATIVE))
    ifeq ($(MODE), 32)
	    ifneq (,$(findstring $(MACHINE), $(Z64)))
		    CFLAGS += -m31
		    LDFLAGS += -m31
	    else
		    ifneq (,$(findstring $(MACHINE), $(X86_64)))
			    CFLAGS += -m32 -malign-double
			    LDFLAGS += -m32
		    else
			    CFLAGS += -m32
			    LDFLAGS += -m32
		    endif
	    endif
    endif
    ifeq ($(MODE), 64)
	    CFLAGS += -m64
	    LDFLAGS += -m64
    endif
endif
RELEASE = $(wildcard /etc/*-release)
ifeq (SuSE, $(findstring SuSE, $(RELEASE)))
CFLAGS +=-DSUSE
export DISTRO=SUSE
else ifeq (fedora, $(findstring fedora, $(RELEASE)))
CFLAGS +=-DFEDORA -DLSM_SELINUX
export DISTRO=FEDORA
export LSM_SELINUX=1
else ifeq (redhat, $(findstring redhat, $(RELEASE)))
CFLAGS +=-DRHEL -DLSM_SELINUX
export DISTRO=RHEL
export LSM_SELINUX=1
endif

ifeq (s390x, $(findstring s390x, $(MACHINE)))
CFLAGS +=-DS390X
endif
ifeq (ppc64, $(findstring ppc64, $(MACHINE)))
CFLAGS +=-DPPC64
endif
ifeq (i686, $(findstring i686, $(MACHINE)))
CFLAGS +=-DI686
endif

##########################################################################
# Common rules
##########################################################################

.PHONY: all run \
	clean distclean verify _clean _distclean _verify

all: deps subdirs $(ALL_AR) $(ALL_EXE) $(ALL_SO)

run:

rerun:

# Re-used in toplevel Makefile
check_set_PPROFILE = \
	if [[ ! -x /usr/sbin/getenforce ]]; then \
	  export PPROFILE=capp ; \
        elif [[ $$PPROFILE != capp && $$PPROFILE != lspp ]]; then \
	  export PPROFILE=capp ; \
	  if [[ "$$(getenforce)" == "Enforcing" ]] &&  \
	        (/usr/sbin/sestatus | grep -q mls); then \
	    if [[ "$$(secon -r)" != "lspp_test_r" ]]; then \
	      echo "SELinux MLS policy is enabled but you are not in lspp_test_r" ; \
	      exit 1; \
	    else \
	      export PPROFILE=lspp ; \
	    fi \
	  fi \
	fi

check_set_PASSWD = \
	while [[ -z $$PASSWD ]]; do \
	    trap 'stty echo; exit' 1 2; \
	    read -sp "Login user password: " PASSWD; echo; export PASSWD; \
	    trap - 1 2; \
	done

ifeq (, $(findstring network, $(RUN_DIRS)))
check_set_LBLNET_SVR_IPV4 = true
else
check_set_LBLNET_SVR_IPV4 = \
	while [[ -z $$LBLNET_SVR_IPV4 ]]; do \
	    trap 'stty echo; exit' 1 2; \
	    read -p "Remote test server IPv4 address: " LBLNET_SVR_IPV4; \
		echo; export LBLNET_SVR_IPV4; \
	    trap - 1 2; \
	done
endif

ifeq (, $(findstring network, $(RUN_DIRS)))
check_set_LBLNET_SVR_IPV6 = true
else
check_set_LBLNET_SVR_IPV6 = \
	while [[ -z $$LBLNET_SVR_IPV6 ]]; do \
	    trap 'stty echo; exit' 1 2; \
	    read -p "Remote test server IPv6 address: " LBLNET_SVR_IPV6; \
		echo; export LBLNET_SVR_IPV6; \
	    trap - 1 2; \
	done
endif

check_TTY = \
	if [[ -f /etc/selinux/mls/contexts/securetty_types ]]; then \
	    tty=`/usr/bin/tty`; \
	    tty_type=`ls -lZ $$tty | awk -F: '{print $$3}' | awk '{print $$1}'`; \
	    grep -q $$tty_type /etc/selinux/mls/contexts/securetty_types /dev/null && { \
	        echo -n "You are connected to the test machine through "; \
	        echo "a device ($$tty) that"; \
	        echo -n "will prevent one or more tests from functioning "; \
	        echo "as intended.  Connect to"; \
	        echo -n "the machine remotely through a pty device, such "; \
	        echo "as logging in as the "; \
	        echo "test-user directly using ssh."; \
	        echo ; \
	        exit 1; \
	    } \
	fi

ifneq ($(if $(filter-out .,$(TOPDIR)),$(wildcard run.conf)),)
all: run.bash

run.bash:
	[[ -f run.bash ]] || ln -sfn $(TOPDIR)/utils/run.bash run.bash

run: all
	@$(check_set_PPROFILE); \
	$(check_set_PASSWD); \
	./run.bash --header; \
	./run.bash

rerun: all
	@$(check_set_PPROFILE); \
	$(check_set_PASSWD); \
	./run.bash --rerun
endif

_clean:
	@if [[ "$(MAKECMDGOALS)" == clean ]]; then \
	    for x in $(SUB_DIRS); do \
		make -C $$x clean; \
	    done; \
	fi
	$(RM) -r .deps
	$(RM) $(ALL_OBJ)
	$(RM) $(ALL_EXE) $(ALL_AR) $(ALL_SO)

clean: _clean

ALL_LOGS += run.log rollup.log logs
_distclean: clean
	@if [[ "$(MAKECMDGOALS)" == distclean ]]; then \
	    for x in $(SUB_DIRS); do \
		make -C $$x distclean; \
	    done; \
	fi
	$(RM) -r $(ALL_LOGS)
	if [[ -L run.bash ]]; then $(RM) run.bash; fi

distclean: _distclean

_verify:

verify: _verify

##########################################################################
# Dependency rules
##########################################################################

DEP_FILES = $(addprefix .deps/, $(ALL_OBJ:.o=.d))

.PHONY: deps

deps: $(DEP_FILES)

# See http://www.gnu.org/software/make/manual/html_node/make_47.html#SEC51
# "4.14 Generating Prerequisites Automatically"
.deps/%.d: %.c
	# @mkdir -p .deps
	@echo NOT Creating dependencies for $<
	# @$(SHELL) -ec '$(CC) $(CFLAGS) $(CPPFLAGS) -MM $< \
	#	| sed '\''s@\($*\)\.o[ :]*@\1.o $@: @g'\'' > $@; \
	#	[ -s $@ ] || $(RM) $@'

ifneq ($(DEP_FILES),)
-include $(DEP_FILES)
endif

# How to build missing things like libraries
../%:
	$(MAKE) -C $(dir $@) $(notdir $@)

##########################################################################
# Sub-directory processing rules
##########################################################################

.PHONY: subdirs subdirs_quiet

subdirs:
	@for x in $(SUB_DIRS); do \
	    $(MAKE) -C $$x $(MAKECMDGOALS) || exit $$?; \
	done

subdirs_quiet:
	@for x in $(SUB_DIRS); do \
	    $(MAKE) --no-print-directory -C $$x $(MAKECMDGOALS) || exit $$?; \
	done

##########################################################################
# Various helper rules
##########################################################################

export-%:
	@[ '$($*)' ] && echo 'export $*=$($*)' || true
