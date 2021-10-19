def test_jenkins_is_installed(host):
    jenkins = host.package("jenkins")
    assert jenkins.is_installed
    assert jenkins.version.startswith("2.1")

def test_jenkins_running_and_enabled(host):
    jenkins = host.service("jenkins")
    assert jenkins.is_running
    assert jenkins.is_enabled

def test_ansible_is_installed(host):
    ansible = host.package("ansible")
    assert ansible.is_installed
    assert ansible.version.startswith("2.6")

def test_packer_in_path(host):
    packer = host.exists('packer')
    assert packer == True
