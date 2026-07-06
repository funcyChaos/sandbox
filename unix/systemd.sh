sudo vim /etc/systemd/system/filebrowser.service
sudo systemctl daemon-reload
sudo systemctl enable filebrowser
sudo systemctl start filebrowser
sudo systemctl status filebrowser
journalctl -u filebrowser -f