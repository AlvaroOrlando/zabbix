#!/bin/bash

# Função para exibir mensagens de erro
erro_exit() {
    echo "Erro: $1"
    exit 1
}


# Extrai o nome e a versão da distribuição
os_name=$(lsb_release -i | awk -F'\t' '{print $2}' | tr '[:upper:]' '[:lower:]')
os_version=$(lsb_release -r | awk -F'\t' '{print $2}')

echo -e "\n"
# Monta a string 
os_model="${os_name}${os_version}"

echo "Nome do sistema operacional: " $os_name
echo "Versão do sistema operacional: " $os_version
echo -e "\n"

# Exibe o resultado echo ": $os_model"

if [[ -z "${os_model}" ]]; then
    echo -e "\n"  
    erro_exit "Não foi possível detectar a versão do sistema operacional."
fi

# Exibe a versão do sistema operacional detectada
echo "Versão do sistema operacional detectada: $os_model"

######################################################################################################
# Para formar o link na versão Ubuntu Arm64 é necessário trocar "os_name" por ubuntu-arm64 no código #  
######################################################################################################

# Monta o link do pacote de repositório do Zabbix baseado na versão do sistema
url_repositorio="https://repo.zabbix.com/zabbix/6.0/${os_name}/pool/main/z/zabbix-release/zabbix-release_latest+${os_model}_all.deb"

echo $url_repositorio

# Baixa o pacote do repositório Zabbix
echo "Baixando pacote do repositório Zabbix..."

wget "$url_repositorio" -O zabbix-release.deb || erro_exit "Falha ao baixar o pacote do repositório Zabbix."

echo -e "\n"

# Instala o pacote do repositório Zabbix
echo "Instalando pacote do repositório Zabbix..."

sudo dpkg -i zabbix-release.deb || erro_exit "Falha ao instalar o pacote do repositório Zabbix."

echo -e "\n"

# Atualiza os repositórios e pacotes
echo "Atualizando pacotes do sistema..."
sudo apt update || erro_exit "Falha ao atualizar os pacotes do sistema."

# Instala o Zabbix Agent
echo "Instalando o Zabbix Agent..."
sudo apt install -y zabbix-agent || erro_exit "Falha ao instalar o Zabbix Agent."

echo -e "\n"

# Reinicia o serviço do Zabbix Agent
echo "Reiniciando o serviço do Zabbix Agent..."
sudo systemctl restart zabbix-agent || erro_exit "Falha ao reiniciar o serviço do Zabbix Agent."

echo -e "\n"

# Habilita o Zabbix Agent para iniciar automaticamente
echo "Habilitando o serviço do Zabbix Agent para iniciar no boot..."
sudo systemctl enable zabbix-agent || erro_exit "Falha ao habilitar o serviço do Zabbix Agent."

echo -e "\n"

echo "Instalação do Zabbix Agent concluída com sucesso!"


read -p "Informe o IP do servidor Zabbix: " servidor_zabbix 
if [[ -z "$servidor_zabbix" ]]; then
	erro_exit "O IP do servidor Zabbix não foi informado."
fi

read -p "Informe o nome do host (hostname) : " hostname

if [[ -z "$hostname" ]]; then
	erro_exit "O nome do host não foi informado."
fi	

sudo sed -i "s/^Server=127.0.0.1/Server=${servidor_zabbix}/" /etc/zabbix/zabbix_agentd.conf

sudo sed -i "s/^ServerActive=127.0.0.1/ServerActive=${servidor_zabbix}/" /etc/zabbix/zabbix_agentd.conf

sudo sed -i "s/^Hostname=Zabbix server/Hostname=${hostname}/" /etc/zabbix/zabbix_agentd.conf

echo "Reiniciando o serviço do Zabbix Agent..."
sudo systemctl restart zabbix-agent || erro_exit "Falha ao reiniciar o serviço do Zabbix Agent."

echo "Habilitando o serviço do Zabbix Agent..."
sudo systemctl enable zabbix-agent || erro_exit "Falha ao habilitar o serviço do Zabbix Agent..."

echo "Instalação e configuração do Zabbix Agent concluídas com sucesso!"
