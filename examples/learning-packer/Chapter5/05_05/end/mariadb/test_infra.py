def test_mariadb_is_installed(host):
    mariadb = host.package("mariadb-server")
    assert mariadb.is_installed

def test_mariadb_running_and_enabled(host):
    mariadb = host.service("mariadb")
    assert mariadb.is_running
    assert mariadb.is_enabled

