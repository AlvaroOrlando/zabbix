#!/bin/bash

# Função para exibir mensagens de erro
erro_exit() {
    echo "Erro: $1"
    exit 1
}

# Detecta a versão do sistema operacional a partir de /etc/os-release

versao_debian=debian12
#if [[ -z "$versao_debian" ]]; then
#    erro_exit "Não foi possível detectar a versão do sistema operacional."
#fi

# Exibe a versão do sistema operacional detectada
echo "Versão do sistema operacional detectada: $versao_debian"

# Monta o link do pacote de repositório do Zabbix baseado na versão do sistema
url_repositorio="https://repo.zabbix.com/zabbix/6.0/debian/pool/main/z/zabbix-release/zabbix-release_latest+${versao_debian}_all.deb"
echo $url_repositorio

# Baixa o pacote do repositório Zabbix
echo "Baixando pacote do repositório Zabbix..."
wget "$url_repositorio" -O zabbix-release.deb || erro_exit "Falha ao baixar o pacote do repositório Zabbix."

# Instala o pacote do repositório Zabbix
echo "Instalando pacote do repositório Zabbix..."
sudo dpkg -i zabbix-release.deb || erro_exit "Falha ao instalar o pacote do repositório Zabbix."

# Atualiza os repositórios e pacotes
echo "Atualizando pacotes do sistema..."
sudo apt update || erro_exit "Falha ao atualizar os pacotes do sistema."

# Instala o Zabbix Agent
echo "Instalando o Zabbix Agent..."
sudo apt install -y zabbix-agent || erro_exit "Falha ao instalar o Zabbix Agent."

# Reinicia o serviço do Zabbix Agent
echo "Reiniciando o serviço do Zabbix Agent..."
sudo systemctl restart zabbix-agent || erro_exit "Falha ao reiniciar o serviço do Zabbix Agent."

# Habilita o Zabbix Agent para iniciar automaticamente
echo "Habilitando o serviço do Zabbix Agent para iniciar no boot..."
sudo systemctl enable zabbix-agent || erro_exit "Falha ao habilitar o serviço do Zabbix Agent."

echo "Instalação do Zabbix Agent concluída com sucesso!"



