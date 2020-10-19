# Virtualbox

## Développement Web sur base PHP/MySQL/Apache2/Linux

Lancement du script pour la création de la Machine Virtuel :

```
bash script.sh
```

Une fois connecté à la VM, entrer la commande :

```
bash /var/www/html/install-packages.sh
```

Le serveur est à écouter sur l'adresse :
```
192.168.33. + IP ENTREE AU MOMENT DE LA CREATION
```

Fichier à configurer :

```bash
sudo nano /etc/apache2/sites-available/000-default.conf
```
ajouter les lignes suivantes :
```
<Directory /var/www/project/public>
	AllowOverride All
	Order Allow,Deny
	Allow from All
</Directory>
```
Pensez également à modifier l'adresse de __DocumentRoot__ par /var/www/html/[mon projet]/public.

Puis éditer le fichier envvars en modifiant le USER et USER-GROUP par vagrant. Lien du fichier :
```
sudo nano /etc/apache2/envvars
```


