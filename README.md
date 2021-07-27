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
# Guía paso a paso
En una máquina Linux con KVM instalado, ejecutamos los siguientes comandos para  configurar el puente de KVM, haciendo uso del archivo nat-net.xml:
 virsh net-define nat-net.xml 
 virsh net-start NAT_mgmt 
 virsh net-autostart NAT_mgmt
Configuramos tambien el almacenamiento, es decir, la fuente de donde KVM obtendrá la imagen del sistema operativo que vamos a usar:
 mkdir /var/lib/libvirt/isos
 virsh pool-define-as kvmpool --type dir --target /var/lib/libvirt/isos
 virsh pool-autostart kvmpool 
 virsh pool-start kvmpool

A continuación, creamos las 4 máquinas de las que se compone el despliegue: Controller, Compute, Block, OSM:

 sudo virt-install --name controller --memory 8192 --vcpus 2 --cdrom ubuntu-20.04.2-live-server-amd64.iso --disk pool=kvmpool,size=150 --boot cdrom,fd,hd,network --network bridge=virbr_vm --virt-type kvm --graphics vnc,port=5901,listen=0.0.0.0 --os-type linux --os-variant ubuntu20.04


 sudo virt-install --name compute --memory 8192 --vcpus 2 --cdrom ubuntu-20.04.2-live-server-amd64.iso --disk pool=kvmpool,size=150 --boot cdrom,fd,hd,network --network bridge=virbr_vm --virt-type kvm --graphics vnc,port=5902,listen=0.0.0.0 --os-type linux --os-variant ubuntu20.04


 sudo virt-install --name block --memory 4096 --vcpus 1 --cdrom ubuntu-20.04.2-live-server-amd64.iso --disk pool=kvmpool,size=100 --boot cdrom,fd,hd,network --network bridge=virbr_vm --virt-type kvm --graphics vnc,port=5903,listen=0.0.0.0 --os-type linux --os-variant ubuntu20.04


 sudo virt-install --name OSM --memory 6144 --vcpus 2 --cdrom ubuntu-20.04.2-live-server-amd64.iso --disk pool=kvmpool,size=200 --boot cdrom,fd,hd,network --network bridge=virbr_vm --virt-type kvm --graphics vnc,port=5904,listen=0.0.0.0 --os-type linux --os-variant ubuntu20.04


En el proceso de instalación de las máquinas se les asignará una IP estática siguiendo la siguiente tabla:


Controller	10.0.0.2

Compute	10.0.0.3

Block Storage	10.0.0.4

OSM	10.0.0.5


Llegados a este punto y una vez desplegadas las máquinas, copiaremos el archivo que corresponde a cada una de ellas en la siguiente dirección de las mismas /etc/network/interfaces.

Reiniciamos los servicios de red: 

 systemctl restart networking
 
Procedemos a clonar el repositorio de Openstack:

 git clone -b master https://github.com/openstack/openstack-ansible.git /opt/openstack-ansible
 
Nos desplazamos a ese nuevo directorio y ejecutamos:

 scripts/bootstrap-ansible.sh
 
Copiamos el contenido del directorio /opt/openstack-ansible/etc/openstack_deploy al directorio /etc/openstack_deploy.

Ahora copiamos el archivo openstack_user_config.yml a este último directorio.

Creamos el archivo de credenciales:
 
 cd /opt/openstack-ansible
 
 ./scripts/pw-token-gen.py --file /etc/openstack_deploy/user_secrets.yml
 
Y ya estamos listos para ejecutar los playbooks uno a uno:

 openstack-ansible setup-hosts.yml
 
 openstack-ansible setup-infrastructure.yml
 
 openstack-ansible setup-openstack.yml

Una vez finalizada la ejecución del último Playbook, podremos acceder a Openstack a través de la IP 172.29.236.10

A continuación, en la máquina OSM, procederemos a instalar Open Spurce MANO mediante los siguientes comandos:

wget https://osm-download.etsi.org/ftp/osm-10.0-ten/install_osm.sh

chmod +x install_osm.sh

./install_osm.sh

Una  vez finalizado podremos acceder a la interfaz de OSM a traves del navegador introduciendo la dirección 10.0.0.5

Llegados a este punto procedemos a vincular OSM y Openstack por medio del siguiente comando en una terminal de la máquina controller:

ssh controller@10.0.0.2

osm vim-create --name openstack-site --user admin --password 7d952e2c37d6d586edeebb7cd4487935e --auth_url https://172.29.236.10:5000/v3/ --tenant admin --account_type openstack --config '{insecure: True}'

Con este último paso completado, llegamos al punto de probar la infraestructura ordenando la creación de una instancia desde Open Source MANO.
