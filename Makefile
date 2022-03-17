SECRET = ""

# ansible-playbook -i inventory -u root main.yml --extra-vars -k "check_fips=true"
test-fips:
	ansible-playbook -i inventory -u root main.yml --extra-vars "check_fips=true ansible_password=${SECRET}"


test-stig:
	ansible-playbook -i inventory -u root main.yml --extra-vars "check_disa_stig=true ansible_password=${SECRET}"


test-cc:
	ansible-playbook -i inventory -u root main.yml --extra-vars "check_common_criteria=true ansible_password=${SECRET}"


test-all:
	ansible-playbook -i inventory -u root main.yml --extra-vars "check_fips=true check_disa_stig=true check_common_criteria=true ansible_password=${SECRET}"
