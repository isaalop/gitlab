#!/bin/bash

# Leer variables requeridas para la configuración del servicio
. ./VALORES

# Actualizar Sistema Operativo e instalar prerequisitos
echo "[TAREA 1] Actualizar SO e instalar prerequisitos"
sudo dnf update -y >/dev/null 2>&1
sudo dnf install -y curl policycoreutils python3-policycoreutils nano net-tools >/dev/null 2>&1

# Instalar servicio Gitlab
echo "[TAREA 2] Instalar servicio Gitlab"
curl -sS https://packages.gitlab.com/install/repositories/gitlab/gitlab-ce/script.rpm.sh | sudo bash >/dev/null 2>&1
sudo dnf install -y gitlab-ce >/dev/null 2>&1

# Configurar servicio Gitlab
echo "[TAREA 3] Configurar servicio Gitlab"
sudo cp /etc/gitlab/gitlab.rb /etc/gitlab/gitlab.rb.bck
sudo sed -i "s/external_url 'http/#external_url 'http/g" /etc/gitlab/gitlab.rb
cat << EOF | sudo tee -a /etc/gitlab/gitlab.rb
external_url 'https://gitlab.dominio.com'

# Configuracion certificado SSL
letsencrypt['enable'] = true
letsencrypt['contact_emails'] = ['user@midominio.com']  
letsencrypt['auto_renew'] = true
letsencrypt['auto_renew_hour'] = 12
letsencrypt['auto_renew_minute'] = 15
letsencrypt['auto_renew_day_of_month'] = "*/4"

# Configuracion para envio de notificaciones
gitlab_rails['smtp_enable'] = true
gitlab_rails['smtp_address'] = "smtp.gmail.com"
gitlab_rails['smtp_port'] = 587
gitlab_rails['smtp_user_name'] = "user@midominio.com"
gitlab_rails['smtp_password'] = "PASSWORD"
gitlab_rails['smtp_domain'] = "smtp.gmail.com"
gitlab_rails['smtp_authentication'] = "login"
gitlab_rails['smtp_enable_starttls_auto'] = true
gitlab_rails['smtp_tls'] = false
gitlab_rails['smtp_openssl_verify_mode'] = 'peer'
gitlab_rails['gitlab_email_from'] = 'gitlab@midominio.com'
gitlab_rails['gitlab_email_reply_to'] = 'noreply@midominio.com'
EOF

# Reemplazar valores desde archivo de variables
sudo sed -i "s/gitlab.dominio.com/$URL/g" /etc/gitlab/gitlab.rb
sudo sed -i "s/user@midominio.com/$EMAIL/g" /etc/gitlab/gitlab.rb
sudo sed -i "s/PASSWORD/$PASSWORD/g" /etc/gitlab/gitlab.rb
sudo sed -i "s/midominio.com/$DOMINIO/g" /etc/gitlab/gitlab.rb

# Reconfigurar el servicio
sudo gitlab-ctl reconfigure >/dev/null 2>&1

echo "[FIN] La instalacion se llevo a cabo con exito"
echo "Ir a la URL https://$URL"
