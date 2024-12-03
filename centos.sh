#!/bin/bash

# Ler o conteúdo do /etc/os-release 
source /etc/os-release

 # Obter a versão do sistema operacional
    so_version=$VERSION_ID
    complete_name=$NAME
    name=$(echo $NAME | awk '{print tolower($1)}')	
    id_like=$(echo $ID_LIKE | awk '{print $1}')

    # Exibir a versão do sistema operacional detectada
    echo "Versão do sistema operacional detectada: CentOS/RHEL $so_version"

# Função para instalação do Zabbix Agent no CentOS/RHEL

instalar_zabbix_agent_rhel() {
   
rpm -Uvh https://repo.zabbix.com/zabbix/${so_version}/rhel/${so_version}/x86_64/zabbix-release-latest-6.0.el${so_version}.noarch.rpm

    # Verificando a versão do sistema e instalando o Zabbix Agent de acordo
    if [ "$so_version" -eq 8 ] || [ "$so_version" -eq 9 ]; then
        echo "Instalando o Zabbix Agent para CentOS/RHEL 8 ou 9..."
        dnf clean all
        dnf install -y zabbix-agent
        systemctl restart zabbix-agent
        systemctl enable zabbix-agent
    elif [ "$so_version" -eq 7 ]; then
        echo "Instalando o Zabbix Agent para CentOS/RHEL 7..."
        yum clean all
        yum install -y zabbix-agent
        systemctl restart zabbix-agent
        systemctl enable zabbix-agent
    elif [ "$so_version" -eq 6 ]; then
        echo "Instalando o Zabbix Agent para CentOS/RHEL 6..."
        yum clean all
        yum install -y zabbix-agent
        service zabbix-agent restart
        chkconfig --level 35 zabbix-agent on
    else
        echo "Erro: Versão não suportada pelo Zabbix Agent (versão $so_version)"
        exit 1
    fi
}

 # Condição para verificar se o ID_LIKE é "rhel" 
if [ "$id_like" == "rhel" ]; then 
echo "Versão do sistema operacional detectada: $NAME" 
instalar_zabbix_agent_rhel 
fi


