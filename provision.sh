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
sudo apt-get update && sudo apt-get install logstash

# install head
cd /usr/share/elasticsearch/bin/ 
sudo su
./plugin install mobz/elasticsearch-head
exit
cd

# intall odbc
sudo apt-get -y install unixodbc unixodbc-dev freetds-dev freetds-bin tdsodbc




#==============================

# # install grafana
# echo "Installing Grafana repository..."
# wget -qO - https://packagecloud.io/gpg.key | sudo apt-key add -
# echo "deb https://packagecloud.io/grafana/stable/debian/ jessie main" | sudo tee -a /etc/apt/sources.list.d/grafana.list
# sudo apt-get update && sudo apt-get install grafana

# sudo iptables -I INPUT -p tcp --dport 3000 -j ACCEPT
# sudo iptables-save

# sudo update-rc.d grafana-server defaults 95 10
# sudo chmod +x /etc/init.d/grafana-server
# sudo /etc/init.d/grafana-server start



# # config integration between logstash and sql server
# cd /opt/logstash
# sudo ./bin/plugin install logstash-input-jdbc
# cd
# sudo wget https://download.microsoft.com/download/0/2/A/02AAE597-3865-456C-AE7F-613F99F850A8/enu/sqljdbc_6.0.7728.100_enu.tar.gz

# gunzip sqljdbc_6.0.7728.100_enu.tar.gz
# rm -rf sqljdbc_6.0.7728.100_enu.tar.gz

# tar -xvf sqljdbc_6.0.7728.100_enu.tar
# rm -rf sqljdbc_6.0.7728.100_enu.tar

# sudo mkdir /opt/logstash/lib/jdbc
# sudo cp sqljdbc_6.0/enu/sqljdbc42.jar /opt/logstash/lib/jdbc/

# cd /opt/logstash
# sudo su
# > sql.conf
# echo "input {
#   jdbc {
#     jdbc_driver_library => "/opt/logstash/lib/jdbc/sqljdbc42.jar"
#     jdbc_driver_class => "com.microsoft.sqlserver.jdbc.SQLServerDriver"
#     jdbc_connection_string => "jdbc:sqlserver://ip_sql_server;user=***;password=*****;"
#     jdbc_user => "***"
#     jdbc_password => "*****"
#     schedule => "*/5 * * * * *"
#     statement => "select * from [db].[schema].[table]"
#   }
# }
# filter {
# }
# output {
#   elasticsearch {
#     hosts => "ip_elasticsearch"
#     index => "index_name"
#     document_type => "type_name"
#     document_id => "%{id}"
#     manage_template => true
#   }
#   stdout { codec => rubydebug }
# }" >> sql.conf
