**setup control node**

    sudo vim /etc/hostname -> ansible-control-node

    sudo hostname ansible-control-node

    sudo su -

    sudo useradd ansadmin

    sudo passwd ansadmin -> ansadmin

    sudo vim /etc/sudoers -> 
        below
            ## Allow root to run any commands anywhere 
            root    ALL=(ALL)       ALL
        add
            ansadmin ALL=(ALL) NOPASSWD: ALL

    sudo yum install -y python python-pip

    sudo pip install ansible

    sudo mkdir /etc/ansible/

    ansible --version

    if config file = None, then:
        ansible-config init --disabled > ~/ansible.cfg
        sudo mv -v ~/ansible.cfg /etc/ansible/ansible.cfg
    fi

    sudo touch /etc/ansible/hosts

    sudo su - ansadmin

    ssh-keygen

    cat ~/.ssh/id_rsa.pub -> copy key for later

    sudo su -

    sudo vim /etc/ssh/sshd_config -> change PasswordAuthentication value from "no" to "yes"

    sudo service sshd restart

**done**

**setup managed node**

    sudo vim /etc/hostname -> <distro>-managed-node

    sudo hostname <distro>-managed-node

    sudo su -

    sudo useradd ansadmin

    sudo passwd ansadmin -> ansadmin

    sudo vim /etc/sudoers -> 
        below
            ## Allow root to run any commands anywhere 
            root    ALL=(ALL)       ALL
        add
            ansadmin ALL=(ALL) NOPASSWD: ALL

    sudo vim /etc/ssh/sshd_config.d/50-cloud-init.conf -> change PasswordAuthentication value from "no" to "yes"

    sudo service sshd reload

    ip addr -> copy value from inet under eth0

    connect to control node

        sudo vim /etc/ansible/hosts -> paste private ip address from managed node

        ssh-copy-id <addr>

        ansible all -m ping -> should return SUCCESS

**done**