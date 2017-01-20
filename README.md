# ElasticSearch, Logstash and Kibana

A simple Ubuntu box with ELK stack installed

## Requirements

* VirtualBox
* Vagrant


## Installation

clone the repo

```
git clone https://github.com/helverton/start_elasticsearch.git
```
provision the box
```
cd vagrant-elk-box
vagrant up
```

This might take a while as it downloads stuffs and install them.(dont worry about the red-caption things, it will run to completion, I promise)

## Usage
* [http://localhost:9200/](http://localhost:9200/) - ElasticSearch
* [http://localhost:9200/_plugin/head](http://localhost:9200/_plugin/head) - Head
* [http://localhost:5601/app/kibana](http://localhost:5601/app/kibana) - Kibana
* [http://localhost:5601/app/sense](http://localhost:5601/app/sense) - Sense

To use logstash, you need to login to the VM itself

```
vagrant ssh
/opt/logstash/bin/logstash
```

