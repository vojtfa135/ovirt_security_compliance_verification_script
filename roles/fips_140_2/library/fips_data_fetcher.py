#!/usr/bin/python
from ansible.module_utils.basic import AnsibleModule
from bs4 import BeautifulSoup
from requests import get
from requests.exceptions import HTTPError

BASIC_MODULE_CONFIG = {
    'FIPS_BINARIES': [
        'OpenSSL',
        'Libgcrypt',
        'Kernel Cryptographic API',
        'GnuTLS',
        'NSS',
    ]
}


def run_module():
    module_args = dict(
        url_to_scrape=dict(type='str', required=True),
        rhel_version=dict(type='str', required=False),
        validation_status=dict(type='str', required=False)
    )

    result = dict(
        changed=False,
        fips_binaries_versions=list
    )

    module = AnsibleModule(
        argument_spec=module_args,
        supports_check_mode=True
    )

    if module.check_mode:
        module.exit_json(**result)

    url_to_scrape = module.params['url_to_scrape']
    try:
        scraped = get(url_to_scrape)
        scraped.raise_for_status()
    except HTTPError:
        module.fail_json(msg='Failed to scrape Red Hat Gov website')

    html_to_parse = scraped.text
    val_stat = module.params['validation_status']
    rhelv = module.params['rhel_version']

    soup = BeautifulSoup(html_to_parse, "html.parser")
    tables = soup.find_all("table")

    fips_tables = []
    for table in tables:
        for th in table.findChildren('th'):
            if th.text == 'Cryptographic Module':
                fips_table = th.parent.parent.parent
                rhel_version = fips_table.previous_sibling.previous_sibling
                fips_entry = {'rhel_version': rhel_version.text, 'table': fips_table}
                fips_tables.append(fips_entry)

    fips_binaries_versions = []
    for table in fips_tables:
        for td in table['table'].findChildren('td'):
            if td.text in BASIC_MODULE_CONFIG['FIPS_BINARIES']:
                fips_binary_version = {
                    'cryptographic_module': td.text,
                    'module_version': td.next_sibling.next_sibling.text,
                    'associated_packages': td.next_sibling.next_sibling.next_sibling.next_sibling.text,
                    'validation_status': td.next_sibling.next_sibling.next_sibling.next_sibling.next_sibling.next_sibling.text,
                    'certificate': td.next_sibling.next_sibling.next_sibling.next_sibling.next_sibling.next_sibling.next_sibling.next_sibling.href,
                    'rhel_version': table['rhel_version']
                }
                fips_binaries_versions.append(fips_binary_version)

    specified_fips_binaries_versions = []
    if rhelv:
        for fips_data in fips_binaries_versions:
            if rhelv in fips_data['rhel_version']:
                specified_fips_binaries_versions.append(fips_data)
    elif val_stat:
        for fips_data in fips_binaries_versions:
            if fips_data['validation_status'] == val_stat:
                specified_fips_binaries_versions.append(fips_data)
    elif val_stat and rhelv:
        for fips_data in fips_binaries_versions:
            if fips_data['validation_status'] == val_stat and rhelv in fips_data['rhel_version']:
                specified_fips_binaries_versions.append(fips_data)

    if specified_fips_binaries_versions:
        result['fips_binaries_versions'] = specified_fips_binaries_versions
    elif not specified_fips_binaries_versions and rhelv:
        specified_fips_binaries_versions.append({"rhel_version_found": False})
        result['fips_binaries_versions'] = specified_fips_binaries_versions
    else:
        result['fips_binaries_versions'] = fips_binaries_versions
    result['changed'] = True

    module.exit_json(**result)


def main():
    run_module()


if __name__ == '__main__':
    main()
