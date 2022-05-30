SECRET = "secret"
USERNAME = "username"

# ansible-playbook -i inventory -u root main.yml --extra-vars -k "check_fips=true"
test-fips:
	ansible-playbook -i inventory -u root main.yml --extra-vars "check_fips=true check_base_info=true ansible_password=${SECRET} ansible_user=${USERNAME} ansible_sudo_pass=${SECRET}"


test-stig:
	ansible-playbook -i inventory -u root main.yml --extra-vars "check_disa_stig=true check_base_info=true ansible_password=${SECRET} ansible_sudo_pass=${SECRET}"


test-cc:
	ansible-playbook -i inventory -u root main.yml --extra-vars "check_common_criteria=true check_base_info=true ansible_password=${SECRET} ansible_sudo_pass=${SECRET}"


test-all:
	ansible-playbook -i inventory -u root main.yml --extra-vars "check_fips=true check_disa_stig=true check_common_criteria=true check_base_info=true ansible_password=${SECRET} ansible_sudo_pass=${SECRET}"
