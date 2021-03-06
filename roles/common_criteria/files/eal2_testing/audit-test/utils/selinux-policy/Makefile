###############################################################################
# (c) Copyright Hewlett-Packard Development Company, L.P., 2007
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

#######
#
# LSPP test Makefile
#
#

SELINUX_POLICY_TYPE := mls
SELINUX_POLICY_RPM := selinux-policy-$(SELINUX_POLICY_TYPE)
SELINUX_DEV_RPM := selinux-policy

SELINUX_POLICY_DEFTYPEFILE := /etc/selinux/$(SELINUX_POLICY_TYPE)/contexts/default_type
SELINUX_POLICY_STAFFUCONTEXTS := /etc/selinux/$(SELINUX_POLICY_TYPE)/contexts/users/staff_u
TEST_STAFFUCONTEXTS := "lspp_test_r:local_login_t:s0       staff_r:staff_t:s0 sysadm_r:sysadm_t:s0"

SELINUX_DEV_BASEDIR := /usr/share/selinux/devel


TEST_BASEDIR := /usr/local/eal2_testing

SELINUX_USER := staff_u

MODULE_NAME := lspp_test
MODULE_ROLE := lspp_test_r:lspp_harness_t

###
#
# targets
#

.PHONY: verify install uninstall relabel distclean

# base SELinux module targets
include $(SELINUX_DEV_BASEDIR)/Makefile

verify:
	@echo "Checking system for basic requirements"
	@echo -n " SELinux policy RPM version ($(SELINUX_POLICY_RPM)): "; \
	if rpm -q $(SELINUX_POLICY_RPM) > /dev/null; then \
		rpm -q $(SELINUX_POLICY_RPM) --qf "%{VERSION}-%{RELEASE}"; \
		echo ""; \
	else \
		echo "not installed"; \
	fi;
	@echo -n " SELinux policy development RPM version: "; \
	if rpm -q $(SELINUX_DEV_RPM) > /dev/null; then \
		rpm -q $(SELINUX_DEV_RPM) --qf "%{VERSION}-%{RELEASE}"; \
		echo ""; \
	else \
		echo "not installed"; \
	fi;
	@echo -n " LSPP test policy module version: "; \
	if semodule -l | grep -q $(MODULE_NAME); then \
		semodule -l | grep $(MODULE_NAME) | cut -f 2; \
	else \
		echo "not installed"; \
	fi;
	@echo -n " Checking test login context: "; \
	role=$$(echo $(MODULE_ROLE) | cut -d':' -f 1); \
	if grep -q $$role $(SELINUX_POLICY_STAFFUCONTEXTS); then \
		echo "installed"; \
	else \
		echo "not installed"; \
	fi;
	@echo -n " Number of LSPP test files labeled incorrectly: "; \
	restorecon -Frvn $(TEST_BASEDIR) | wc -l;

# During this install a role is added to an SELinux user which we use 
# as a positive test of semanage.  If this did not work correctly the 
# testing infrastructure would not run.

install: $(MODULE_NAME).pp
	@if semodule -l | grep -q $(MODULE_NAME); then \
		echo -n "Upgrading $(MODULE_NAME) module ... "; \
		semodule -u $(MODULE_NAME).pp &> /dev/null && echo "ok" || \
			echo "failed (check the policy version number)"; \
	else \
		echo -n "Loading $(MODULE_NAME) module ... "; \
		semodule -i $(MODULE_NAME).pp &> /dev/null && echo "ok" || \
			echo "failed"; \
		role=$$(echo $(MODULE_ROLE) | cut -d':' -f 1); \
		if [ -n "$$role" ]; then \
			echo -n "Adding role \"$$role\" to user \"$(SELINUX_USER)\" ... "; \
			semanage user -m -R $$role $(SELINUX_USER) &> /dev/null && \
				echo "ok" || \
				echo "failed (check the SELinux user)"; \
			echo "Adding role/type to the default_types file"; \
			echo $(MODULE_ROLE) >> $(SELINUX_POLICY_DEFTYPEFILE); \
		fi; \
	fi; \
	echo -n "Adding test login context ..."; \
	role=$$(echo $(MODULE_ROLE) | cut -d':' -f 1); \
        if grep -q $$role $(SELINUX_POLICY_STAFFUCONTEXTS); then \
                echo "already installed"; \
        else \
		echo $(TEST_STAFFUCONTEXTS) >> $(SELINUX_POLICY_STAFFUCONTEXTS);\
                echo "added"; \
        fi;

uninstall:
	@role=$$(echo $(MODULE_ROLE) | cut -d':' -f 1); \
	if [ -n "$$role" ]; then \
		echo "Removing role/type from the default_types file"; \
		sed -i -e '/$(MODULE_ROLE)/d' $(SELINUX_POLICY_DEFTYPEFILE); \
		echo -n "Removing local customizations from user \"$(SELINUX_USER)\" ... "; \
		semanage user -d $(SELINUX_USER) &> /dev/null && \
			echo "ok" || echo "failed"; \
	fi; \
	echo -n "Unloading $(MODULE_NAME) module ... "; \
	semodule -r $(MODULE_NAME) &> /dev/null && echo "ok" || echo "failed"; \
	echo -n "Removing test login context ...";  \
	if grep -q $$role $(SELINUX_POLICY_STAFFUCONTEXTS); then \
		sed -i -e /$$role/d $(SELINUX_POLICY_STAFFUCONTEXTS); \
		echo "removed"; \
	else \
		echo "not installed"; \
	fi;

relabel:
	@echo "Resetting file ownership in $(TEST_BASEDIR)"
	@chown -R root:root $(TEST_BASEDIR)
	@echo "Relabeling LSPP tests in $(TEST_BASEDIR)"
	@restorecon -Fr $(TEST_BASEDIR)

# remove only generated files
distclean:
	$(MAKE) clean
	@ shopt -s nullglob; \
	for file in *.fc; do \
		[ -z "$$(cat $$file)" ] && rm -vf "$$file"; \
	done; \
	for file in *.if; do \
		[ -z "$$(grep -v '<summary></summary>' < $$file)" ] && rm -vf "$$file"; \
	done;
