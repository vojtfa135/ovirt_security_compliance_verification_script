#!/usr/bin/python3


class FIPSFilters:

    def extract_versions(self, hosts, binaries):
        binary_versions = {host: [] for host in hosts}

        for host in hosts:
            for binary in binaries:
                if host == binary['item'][0]:
                    binary_versions[host].append(binary['stdout'])

        return binary_versions

    def match_versions(self, hosts, actual_versions, desired_versions):

        flat_desired_versions = [
            '{}-{}'.format(pkg['name'], pkg['version'])
            for desired_version in desired_versions.values()
            for pkg in desired_version
        ]

        if len(flat_desired_versions) != len(actual_versions[hosts[0]]):
            raise Exception('Lengths of the lists do not equal')

        matched_versions = sum([
            sum(list(map(
                lambda x, y: x in y, flat_desired_versions, actual_version
            ))) == len(flat_desired_versions)
            for actual_version in actual_versions.values()
        ]) == len(hosts)

        return matched_versions


class FilterModule(object):

    fips_filters = FIPSFilters()

    filter_map = {
        'fips_extract_versions': fips_filters.extract_versions,
        'fips_match_versions': fips_filters.match_versions
    }

    def filters(self):
        return self.filter_map
