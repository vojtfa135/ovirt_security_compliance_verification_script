###############################################################################
# Copyright (C) International Business Machines  Corp., 2003
# (c) Copyright Hewlett-Packard Development Company, L.P., 2005
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
###############################################################################

TOPDIR		= .

include $(TOPDIR)/rules.mk

RUN_DIRS	= audit-tools \
		 audit-trail-protection \
		 kvm \
#		 kvm-cgroups \
#		 kvm-iommu \
		 libpam \
		 misc \
		 trustedprograms

#ifeq ($(MODE), $(NATIVE))
#RUN_DIRS       += fail-safe \
#		  filter \
#		  audit-trail-protection \
#		  audit-tools \
#		  libpam
#ifneq ($(DISTRO), SUSE)
#RUN_DIRS       += trustedprograms \
#		  netfilter \
#		  crypto \
#		  audit-remote \
#		  misc
#ifneq ($(MACHINE), ppc64)
#ifneq ($(MACHINE), s390x)
#RUN_DIRS       += netfilebt
#ifneq ($(MACHINE), i686)
#ifeq ($(VIRT_TYPE),)
#RUN_DIRS       += kvm \
#		  kvm-cgroups \
#		  kvm-iommu
#endif
#endif
#endif
#endif
#endif
#endif

SUB_DIRS	= $(RUN_DIRS) \
		  utils

run:
	@for l in run rollup; do \
	    echo "audit.$$l.log will be collected from subdirectories when the test completes" >audit.$$l.log; \
	done
	@$(check_set_PPROFILE); \
	$(check_set_PASSWD); \
	$(check_set_LBLNET_SVR_IPV4); \
	$(check_set_LBLNET_SVR_IPV6); \
	$(check_TTY); \
	$(MAKE) all && \
	for x in $(RUN_DIRS); do make -C $$x $(MAKECMDGOALS); done
	$(MAKE) report

.PHONY: rerun
rerun: run

.PHONY: dist
dist:
	deps="audit libcap-devel" && \
	rev=$$(git log | head -n 1| awk '/^commit/{print $$2}' | cut -b 1-6 ) && \
	tmpdir=$$(mktemp -d) && \
	into=$${PWD%/*} && \
	sed -i "/^Version:/s/[0-9].*/$$rev/; \
		s/^\(Requires:[         ]*\).*/\1$$deps/" \
		    audit-test.spec && \
	mkdir "$$tmpdir/audit-test" && \
	rsync -a --exclude=.git . "$$tmpdir/audit-test" && \
	$(MAKE) distclean -C "$$tmpdir/audit-test" && \
	cd "$$tmpdir" && \
	chmod -R a+rX audit-test && \
	tar czf "$$into/audit-test-$$rev.tar.gz" audit-test && \
	cd "$$into" && \
	rm -rf "$$tmpdir" && \
	echo && \
	ls -l audit-test-$$rev.tar.gz

.PHONY: report
ALL_LOGS	+= audit.run.log audit.rollup.log
report:
	@# tty output has color, generated logs don't, so collect them
	@# instead of redirecting output of the above loop.
	@for l in run rollup; do \
	  for x in $(RUN_DIRS); do \
	    echo; \
	    echo "::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::"; \
	    printf "::: %-52s :::\n" "$$x"; \
	    echo "::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::"; \
	    echo; \
	    cat $$x/$$l.log; \
	  done &> audit.$$l.log; \
	done
	utils/tally-results.awk < audit.rollup.log \
	    | tee -a audit.run.log | tee -a audit.rollup.log

.PHONY: rpm
rpm: dist
	rev=$$(git log | head -n 1| awk '/^commit/{print $$2}' | cut -b 1-6 ) && \
	cd .. && \
	rpmbuild -ta audit-test-$$rev.tar.gz && \
	mv ~/rpmbuild/RPMS/noarch/audit-test-$$rev-1.* . && \
	mv ~/rpmbuild/SRPMS/audit-test-$$rev-1.* . && \
	echo && \
	ls -l audit-test-$$rev-1.*

.PHONY: policy
policy:
	cd utils/selinux-policy && \
	$(MAKE) clean && \
	$(MAKE) && \
	$(MAKE) install && \
	$(MAKE) relabel

.PHONY: netconfig
netconfig:
	cd network/system && $(MAKE) install
	cd utils/network-server && $(MAKE) install

.PHONY: envcheck
envcheck:
	@$(check_set_PPROFILE); \
	$(check_set_PASSWD);
	@utils/envcheck
