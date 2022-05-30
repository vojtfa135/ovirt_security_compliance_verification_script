#!/usr/bin/python
from ansible.module_utils.basic import AnsibleModule

BASIC_MODULE_CONFIG = {
    'NIST_URL': 'csrc.nist.gov',
    'CMVP': 'cryptographic-module-validation-program',
    'SEARCH_MODE_VAL': 'Advanced',
    'SEARCH_MODE': 'SearchMode',
    'VENDOR': 'Vendor',
    'STANDARD': 'Standard',
    'CERT_STATUS': 'CertificateStatus'
}
CMVP_SEARCH_URL = (
    f'https://{BASIC_MODULE_CONFIG.NIST_URL}/'
    f'{BASIC_MODULE_CONFIG.CMVP}/validated-modules/search?'
)


def run_module():
    """
    https://csrc.nist.gov/projects/cryptographic-module-validation-program/
    validated-modules/search?SearchMode=Advanced&Vendor=Red+Hat&
    Standard=140-2&CertificateStatus=Active&ValidationYear=2021
    """
    module_args = dict(
        vendor=dict(type='str', required=False),
        standard=dict(type='str', required=False),
        cert_status=dict(type='str', required=False)
    )

    result = dict(
        changed=False,
        request_url=''
    )

    module = AnsibleModule(
        argument_spec=module_args,
        supports_check_mode=True
    )

    if module.check_mode:
        module.exit_json(**result)

    vendor = module.params['vendor']
    standard = module.params['standard']
    cert_status = module.params['cert_status']
    request_url = '{CMVP_SEARCH_URL}{SEARCH_MODE}={SEARCH_MODE_VAL}'.format(
        CMVP_SEARCH_URL=CMVP_SEARCH_URL,
        SEARCH_MODE=BASIC_MODULE_CONFIG['SEARCH_MODE'],
        SEARCH_MODE_VAL=BASIC_MODULE_CONFIG['SEARCH_MODE_VAL']
    )

    if vendor:
        request_url += '&{vendor}'.format(vendor=BASIC_MODULE_CONFIG['VENDOR'])

    if standard:
        request_url += '&{standard}'.format(standard=BASIC_MODULE_CONFIG['STANDARD'])
    
    if cert_status:
        request_url += '&{cert_status}'.format(cert_status=BASIC_MODULE_CONFIG['CERT_STATUS'])

    result['request_url'] = request_url
    result['changed'] = True

    module.exit_json(**result)


def main():
    run_module()


if __name__ == '__main__':
    main()
