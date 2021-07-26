# OpenStack y Ansible.
En este repositorio se recogen los principales archivos de configuración para el despliegue del TFG.
# Descripción de los archivos del repositorio
  - Los archivos con el prefijo "git-" son una automatización de los principales comandos git.
  - Los archivos dentro la carpeta /interfaces son la configuración de red (archivo /etc/network/interfaces) de cada máquina.
  - El archivo nat-net.xml es la configuración de red de KVM para el despliegue.
  - El archivo openstack-ansible-master.zip son todos los archivos necesarios para la ejecución de los playbooks, así como scripts y archivos python generados por Openstack.
  - El archivo openstack_user_config.yml es la configuración que se ha usado para este despliegue. Este archivo especifica la arquitectura que va a tener el sistema a ansible (redes disponibles, máquinas totales y en qué máquina se va a desplegar cada servicio)

· Documentation: https://docs.openstack.org/openstack-ansible/latest/
· Source: https://opendev.org/openstack/openstack-ansible
· Bugs: https://bugs.launchpad.net/openstack-ansible
· Release notes: https://docs.openstack.org/releasenotes/openstack-ansible/
