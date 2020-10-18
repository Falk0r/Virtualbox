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
sudo apt-get install apache2 php7.0 libapache2-mod-php7.0 mysql-server php7.0-mysql php-xml php7.0-mbstring -y
sudo sed -i '462c\display_errors = On' /etc/php/7.0/apache2/php.ini
sudo sed -i '473c\display_startup_errors = On' /etc/php/7.0/apache2/php.ini
wget https://raw.githubusercontent.com/composer/getcomposer.org/76a7060ccb93902cd7576b67264ad91c8a2700e2/web/installer -O - -q | php -- --quietphp composer-setup.php
sudo mv composer.phar /usr/local/bin/composer
wget https://get.symfony.com/cli/installer -O - | bash
sudo mv /root/.symfony/bin/symfony /usr/local/bin/symfony
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
        config.vm.provider 'virtualbox' do |vb|
            vb.memory = '2048'
        end
        config.vm.provision 'shell', inline: <<-SHELL
            bash /var/www/html/install-packages.sh
            symfony check:requirements
        SHELL
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
        config.vm.provider 'virtualbox' do |vb|
            vb.memory = '2048'
        end
        config.vm.provision 'shell', inline: <<-SHELL
            bash /var/www/html/install-packages.sh
            symfony check:requirements
        SHELL
    end
    ">Vagrantfile
fi

vagrant up
vagrant ssh

# Une fois en ssh, il faudra lancer la commande :
# bash /var/www/html/install-packages.sh
# afin de lancer ce 2nd script