#!/usr/bin/python3

class GeneralFilters:

    def final_evaluation(self, rules_dict):
        return sum([
            rules_dict[rule]['pass'] == "True" for rule in rules_dict
        ]) == len(rules_dict)


class FIPSFilters:

    def extract_versions(self, binaries):
        return [
            binary['stdout'] for binary in binaries
        ]

    def match_versions(
        self, actual_versions, desired_versions,
        required_validation_status
    ):
        return sum(list(map(
            lambda x, y: x['associated_packages'] in y and
            x['validation_status'] == required_validation_status and
            x['certificate'] is not None,
            desired_versions,
            actual_versions
        ))) == len(desired_versions)


class STIGFIlters:

    def get_oscap_reports_paths(
        self, pwd_result, stig_hosts, local_path, remote_path, report_name
    ):
        return [
            (f'{pwd_result}/{local_path}/{host}{remote_path}/{report_name}',
                host)
            for host in stig_hosts
        ]


class CCFilters():
    pass


class FilterModule(object):

    fips_filters = FIPSFilters()
    stig_filters = STIGFIlters()
    general_filters = GeneralFilters()

    filter_map = {
        'fips_extract_versions': fips_filters.extract_versions,
        'fips_match_versions': fips_filters.match_versions,
        'fips_final_evaluation': general_filters.final_evaluation,
        'stig_get_oscap_reports_paths': stig_filters.get_oscap_reports_paths,
        'stig_final_evaluation': general_filters.final_evaluation,
        'cc_final_evaluation': general_filters.final_evaluation
    }

    def filters(self):
        return self.filter_map
