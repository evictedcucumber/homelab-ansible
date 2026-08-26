.PHONY: ping-tcyclops
ping-tcyclops:
	ansible -i inventories/test/hosts.yml tcyclops.homelab.zezura.cc -m ping

.PHONY: debian-tcyclops
debian-tcyclops:
	ansible-playbook -i inventories/test/hosts.yml -l tcyclops.homelab.zezura.cc playbooks/os-debian-13.yml
