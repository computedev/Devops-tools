sudo -i
sudo apt update
sudo apt install openjdk-8-jdk
java -version
sudo useradd -d /opt/nexus -s /bin/bash nexus
ulimit -n 65536

mkdir -p /opt/nexus
cd /tmp
wget https://download.sonatype.com/nexus/3/nexus-3.41.1-01-unix.tar.gz
tar xzf nexus-3.41.1-01-unix.tar.gz

mv nexus-3.41.1-01 /opt/nexus
mv sonatype-work /opt/sonatype-work
chown -R nexus:nexus /opt/nexus /opt/sonatype-work
echo run_as_user="nexus" >> /opt/nexus/bin/nexus.rc
echo application-host=127.0.0.1 >>/opt/sonatype-work/nexus3/etc/nexus.properties
cat <<EOT>> /etc/systemd/system/nexus.service
[Unit]
Description=nexus service
After=network.target

[Service]
Type=forking
LimitNOFILE=65536
ExecStart=/opt/nexus/bin/nexus start
ExecStop=/opt/nexus/bin/nexus stop
User=nexus
Restart=on-abort

[Install]
WantedBy=multi-user.target
EOT
sudo systemctl daemon-reload
sudo systemctl enable nexus.service
sudo systemctl start nexus.service
sudo systemctl status nexus.service
sudo apt install nginx
sudo systemctl is-enabled nginx
sudo systemctl status nginx

cat<<EOT>>/etc/nginx/sites-available/nexus
upstream nexus3 {
server 127.0.0.1:8081;
}

server {
listen 80;
server_name domain_name;

location / {
proxy_pass http://nexus3/;
proxy_http_version 1.1;
proxy_set_header Upgrade $http_upgrade;
proxy_set_header Connection "upgrade";
proxy_set_header Host $http_host;
proxy_set_header X-Real-IP $remote_addr;
proxy_set_header X-Forward-For $proxy_add_x_forwarded_for;
proxy_set_header X-Forward-Proto http;
proxy_set_header X-Nginx-Proxy true;
proxy_redirect off;
}
}
EOT

sudo ln -s /etc/nginx/sites-available/nexus /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx
