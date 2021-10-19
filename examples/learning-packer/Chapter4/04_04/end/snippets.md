# Snippets

```yml

---
- hosts: all
  become: true

  vars:
    mysql_packages:
      - mariadb-client
      - mariadb-server
      - python-mysqldb

  roles:
    - geerlingguy.mysql

```