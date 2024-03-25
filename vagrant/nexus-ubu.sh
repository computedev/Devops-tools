#!/bin/bash
sudo -i
sleep 2
sudo apt update -y

sleep 5
# sudo apt-get update -y

#apt-get install java-1.8.0-openjdk.x86_64 wget -y   
sudo apt install openjdk-8-jdk -y   
mkdir -p /opt/nexus/   
mkdir -p /tmp/nexus/                           
cd /tmp/nexus/
NEXUSURL="https://download.sonatype.com/nexus/3/latest-unix.tar.gz"
wget $NEXUSURL -O nexus.tar.gz
sleep 10
EXTOUT=`tar xzvf nexus.tar.gz`
NEXUSDIR=`echo $EXTOUT | cut -d '/' -f1`
sleep 5
rm -rf /tmp/nexus/nexus.tar.gz
cp -r /tmp/nexus/* /opt/nexus/
sleep 5
useradd nexus
chown -R nexus:nexus /opt/nexus 
cat <<EOT>> /etc/systemd/system/nexus.service
[Unit]                                                                          
Description=nexus service                                                       
After=network.target                                                            
                                                                  
[Service]                                                                       
Type=forking                                                                    
LimitNOFILE=65536                                                               
ExecStart=/opt/nexus/$NEXUSDIR/bin/nexus start                                  
ExecStop=/opt/nexus/$NEXUSDIR/bin/nexus stop                                    
User=nexus                                                                      
Restart=on-abort                                                                
                                                                  
[Install]                                                                       
WantedBy=multi-user.target                                                      

EOT

echo 'run_as_user="nexus"' > /opt/nexus/$NEXUSDIR/bin/nexus.rc
echo application-host=127.0.0.1 >> /opt/nexus/sonatype-work/nexus3/etc/nexus.properties
echo application-port=8081>> /opt/nexus/sonatype-work/nexus3/etc/nexus.properties
systemctl daemon-reload
systemctl start nexus
systemctl enable nexus


sudo -i 
sleep 2
sudo apt install nginx -y
sudo systemctl is-enabled nginx
sudo systemctl status nginx

mkdir /etc/nginx/sites-available/nexus

cat <<EOT>> /etc/nginx/sites-available/nexus
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
