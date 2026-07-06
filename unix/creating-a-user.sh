sudo useradd --system --home /var/lib/filebrowser --shell /usr/sbin/nologin filebrowser
sudo mkdir -p /var/lib/filebrowser
sudo mkdir -p /srv/files
sudo chown -R filebrowser:filebrowaser /var/lib/filebrowser
sudo chown -R filebrowser:filebrowser /srv/files

