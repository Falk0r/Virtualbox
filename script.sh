#!/usr/bin/env bash

# Fonction rappelant l'entête à afficher
title() {
clear
echo "          *************************"
echo "          *                       *"
echo "          *  Configuration de VM  *"
echo "          *                       *"
echo "          *************************"
echo ""
}

# Choix de l'ip, nécessite une réponse
title
read -p 'Choisir une ip pour la Box : 192.168.33.' ip
while [ -z $ip ]; do
    read -p 'Choisir une ip pour la Box : 192.168.33.' ip
done

# Choix du nom que portera la VM dans Virtualbox. 
# Si laissé vide, nom par défaut
title
read -p 'Choisir un nom pour votre VM : ' name

# Choix du nom du dossier synchronisé.
# Si laissé vide, sera automatiquement 'data'
title
read -p 'Choisir un nom de dossier synchronisé : ' repo
if [ -z $repo ]; then
    repo='data'
fi

mkdir $repo

# Création du fichier install-packages.sh qui servira 
# à mettre à jour et installer les paquets de sous VM.
# Il confifugre mysql avec un mot de passe de '0000' par défaut
# (à ne laisser que pour les VM pédagogiques)
echo "#!/bin/bash
sudo apt-get update
export UBUNTU_FRONTEND='noninteractive'
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password password 0000'
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password 0000'
sudo apt-get install apache2 php7.0 libapache2-mod-php7.0 mysql-server php7.0-mysql -y
sudo sed -i '462c\display_errors = On' /etc/php/7.0/apache2/php.ini
sudo sed -i '473c\display_startup_errors = On' /etc/php/7.0/apache2/php.ini
sudo service apache2 restart
rm /var/www/html/index.html
rm /var/www/html/install-packages.sh
">$repo/install-packages.sh


# Création du fichier Vagrantfile
if [ -z $name ]; then
    echo "Vagrant.configure('2') do |config|
        config.vm.box = 'ubuntu/xenial64'
        config.vm.network 'private_network', ip: '192.168.33.$ip'
        config.vm.synced_folder './$repo', '/var/www/html'
    end
    ">Vagrantfile
else
    echo "Vagrant.configure('2') do |config|
        config.vm.box = 'ubuntu/xenial64'
        config.vm.network 'private_network', ip: '192.168.33.$ip'
        config.vm.synced_folder './$repo', '/var/www/html'
        config.vm.provider 'virtualbox' do |v|
            v.name = '$name'
        end
    end
    ">Vagrantfile
fi

vagrant up
vagrant ssh

# Une fois en ssh, il faudra lancer la commande :
# bash /var/www/html/install-packages.sh
# afin de lancer ce 2nd script