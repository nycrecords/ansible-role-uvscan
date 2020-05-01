import os

import pytest
import testinfra.utils.ansible_runner

testinfra_hosts = testinfra.utils.ansible_runner.AnsibleRunner(
    os.environ["MOLECULE_INVENTORY_FILE"]
).get_hosts("all")


def test_mcafee_vscl_installed(host):
    uvscan = host.run("/usr/local/bin/uvscan --version")

    assert uvscan.rc == 0


@pytest.mark.parametrize(
    "dat_file_path",
    [
        ("/usr/local/uvscan/avvscan.dat"),
        ("/usr/local/uvscan/avvnames.dat"),
        ("/usr/local/uvscan/avvclean.dat"),
    ],
)
def test_mcafee_vscl_dat_files_exist(host, dat_file_path):
    dat_file = host.file(dat_file_path)

    assert dat_file.exists
    assert oct(dat_file.mode) == '0o444'