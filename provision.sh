# config.vm.provision :shell, :path => "provision.sh"

# install java
sudo add-apt-repository -y ppa:webupd8team/java
sudo apt-get update
echo debconf shared/accepted-oracle-license-v1-1 select true | \
  sudo debconf-set-selections
echo debconf shared/accepted-oracle-license-v1-1 seen true | \
  sudo debconf-set-selections
sudo apt-get -y install oracle-java8-installer

# install elasticsearch
wget -qO - https://packages.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
echo "deb http://packages.elastic.co/elasticsearch/2.x/debian stable main" | sudo tee -a /etc/apt/sources.list.d/elasticsearch-2.x.list
sudo apt-get update && sudo apt-get install elasticsearch

sudo echo "node.name: HSants" >> /etc/elasticsearch/elasticsearch.yml
sudo echo "cluster.name: HSants" >> /etc/elasticsearch/elasticsearch.yml
# either of the next two lines is needed to be able to access "localhost:9200" from the host os
sudo echo "network.bind_host: 0" >> /etc/elasticsearch/elasticsearch.yml
sudo echo "network.host: 0.0.0.0" >> /etc/elasticsearch/elasticsearch.yml
# enable dynamic scripting
sudo echo "script.inline: on" >> /etc/elasticsearch/elasticsearch.yml
sudo echo "script.indexed: on" >> /etc/elasticsearch/elasticsearch.yml
# enable cors (to be able to use Sense)
sudo echo "http.cors.enabled: true" >> /etc/elasticsearch/elasticsearch.yml
sudo echo "http.cors.allow-origin: /https?:\/\/.*/" >> /etc/elasticsearch/elasticsearch.yml

sudo iptables -I INPUT -p tcp --dport 9200 -j ACCEPT
sudo iptables-save

update-rc.d elasticsearch defaults 95 10
/etc/init.d/elasticsearch start

# install head
cd /usr/share/elasticsearch/bin/ 
sudo su
./plugin install mobz/elasticsearch-head
exit
cd

# install kibana
wget https://download.elastic.co/kibana/kibana/kibana-4.3.1-linux-x64.tar.gz
gunzip kibana-4.3.1-linux-x64.tar.gz
tar -xvf kibana-4.3.1-linux-x64.tar
mkdir /opt/kibana
cp -Rrvf kibana-4.3.1-linux-x64/* /opt/kibana/
cd /etc/init.d/
wget https://gist.githubusercontent.com/thisismitch/8b15ac909aed214ad04a/raw/bce61d85643c2dcdfbc2728c55a41dab444dca20/kibana4
chmod +x /etc/init.d/kibana4

sudo iptables -I INPUT -p tcp --dport 5601 -j ACCEPT
sudo iptables-save

update-rc.d kibana4 defaults 96 9
/etc/init.d/kibana4 restart

# install sense
cd /opt/kibana
sudo ./bin/kibana plugin --install elastic/sense
sudo ./bin/kibana
/etc/init.d/kibana4 restart

# install logstash
echo 'deb http://packages.elasticsearch.org/logstash/2.0/debian stable main' | sudo tee /etc/apt/sources.list.d/logstash.list
sudo apt-get update
sudo apt-get install logstash

# intall odbc
sudo apt-get -y install unixodbc unixodbc-dev freetds-dev freetds-bin tdsodbc
