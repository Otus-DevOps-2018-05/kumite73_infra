# kumite73_infra
kumite73 Infra repository

----

## Запуск 1 командой

----

1. Запуск ssh-agent `eval $(ssh-agent -s)`
2. Добавление приватного ключа в агент авторизации `ssh-add ~/.ssh/appuser`
3. Добавляем команды 1 и 2 в `.bashrc`
4. Команда для запуска `ssh -A appuser@35.233.104.183 ssh -tt 10.132.0.3`

----

## Запуск через alias

----

1. Создаем файл `~/.ssh/config`
2. Выставляем права `600`
3. Изменяем `config`

       Host someinternalhost
           HostName 10.132.0.3
           User appuser
           ProxyCommand ssh -W %h:%p appuser@35.233.104.183
       Host 35.233.104.183
           IdentityFile ~/.ssh/appuser
       Host 10.132.0.3
           IdentityFile ~/.ssh/appuser

4. Команда для запуска `ssh someinternalhost`

----

## OpenVPN

bastion_IP = 35.233.104.183

someinternalhost_IP = 10.132.0.3

## TestApp

testapp_IP = 35.195.200.0

testapp_port = 9292

## Packer

1. Устанловлен packer
2. Скопированы скрипты `install_ruby.sh install_mongodb.sh`
3. Удален запуск MongoDB
4. Создан файл настроек для packer `ubuntu16.json`
5. Проверен на корректность `packer validate ./ubuntu16.json`
6. Зваущен build `packer build ubuntu16.json`
7. На основе образа создан инстанс `reddit-app`
8. Задеплоено приложение
9. Добавлены переменные в файл `ubuntu16.json`
10. Создан файл `variables.json` с переменными
11. Проверена конфигурация `packer validate -var-file=variables.json ubuntu16.json`
12. Создан образ `packer build -var-file=variables.json ubuntu16.json`

## Terraform-1
Определяем секцию провайдер

    provider "google" {
	version = "1.4.0"
	project = "steam-strategy-174408"
	region = "europe-west1"
    }

Инициализируем `terraform init`
Добавляем ресурс для создания инстанса VM в GCP
Устанавливаем семейство образов `image = "reddit-base"`
Планируем изменения `terraform plan`
Применяем изменения `terraform apply`
Ищем нужный атрибут `terraform show | grep assigned_nat_ip`
Попытка подключения `ssh appuser@<внешний_IP>`
Не смогли подключиться, так-как удалили SSH ключ в начале задания.
Добавляем SSH ключ `ssh-keys = "appuser:${file("~/.ssh/appuser.pub")}"`
Создаем файл `outputs.tf` с описанием выходной переменной `output "app_external_ip" {value = "${google_compute_instance.app.network_interface.0.access_config.0.assigned_nat_ip}"}`
Смотрим значение `terraform output app_external_ip 104.155.68.69`
Создаем правило для firewall `resource "google_compute_firewall" "firewall_puma`
Добавляем тег инстансу `tags = ["reddit-app"]`
Добавляем секцию провижинеров
Задаем параметры подключения провиженеров к VM
Определяем переменные в файле `variables.tf`
Используем input переменные

Добавляем переменную для приватного ключа

    variable "private_key_path" {
	description = "Private key path for provisiners to connect via ssh"
    }

Определяем input переменную для задания зоны

    variable "zone" {
	description = "Zone"
	default     = "europe-west1-b"
    }

Форматируем конфигурацию `terraform fmt`
Создаем файл `terraform.tfvars.example`

### Задание со *
Добавляем ключи для 2 пользователей 

    resource "google_compute_project_metadata" "default" {
	metadata {
	    ssh-keys = "appuser1:${file(var.public_key_path)} appuser2:${file(var.public_key_path)}"
	}
    }

Добавляем в веб-интерфейсе ключ для `appuser_web`
Выпролняем `terraform apply` и наш ключ добавленный в веб интерфейсе затирается. Осиаются только ключи описанные в terraform,

### Задание с **

Создан aайл для балансировщика lb.tf
Ресурс для проверки состояния `resource "google_compute_http_health_check" "health-check"`
Ресурс для пула инстансов `resource "google_compute_target_pool" "target-pool"
Ресурс для правила прoброса `resource "google_compute_forwarding_rule" "forwarding-rule"`
Задана output переменная для внешнего адреса балансировщика 

    output "forwarding_rule_ip" {
	value = "${google_compute_forwarding_rule.forwarding-rule.ip_address}"
    }

Задана переменная для кол-ва VM

    variable "count" {
	description = "number of VM instance"
	default = 1
    }

Изменение имени VM от переменной `count` `name = "reddit-app${count.index}"

Главная проблема данной конфигурации: MongoDB создается для каждой VM внутри. Чтобы решить данную проблему, нужен отдельный инстанс с MongoDB, чтобы фронты имели одинаковую информацию из БД.

## Terraform-2
Определяем ресур файервал

    resource "google_compute_firewall" "firewall_ssh" {
	name = "default-allow-ssh"
	network = "default"
	
	allow {
	    protocol = "tcp"
	    ports = ["22"]
	}
    source_ranges = ["0.0.0.0/0"]
    }

Импортируем существующую инфраструктуру `terraform import google_compute_firewall.firewall_ssh default-allow-ssh`
Зададим IP для инстанса с приложением в виде внешнего ресурса

    resource "google_compute_address" "app_ip" {
	name = "reddit-app-ip"
    }
Ссылаемся на атрибуты другого ресурса

    network_interface {
	network = "default"
	access_config = {
	    nat_ip = "${google_compute_address.app_ip.address}"
	}
    }

Создаем две VM `app.tf db.tf`
Создаем правила для FW `vpc.tf`
В папке `modules/` создаем модули `app db vcs`
Меняем `main.tf` на использование модулей
Вызываем `terraform get` для загрузки модулей 
Получаем `output` переменные из модуля

    output "app_external_ip" {
	value = "${module.app.app_external_ip}"
    }

Создаем `Stage & Prod` и меняем пути к модулям на `../modules/xxx`
Создаем `storage-bucket.tf`

    provider "google" {
	version = "1.4.0"
	project = "${var.project}"
	region = "${var.region}"
    }
    module "storage-bucket" {
	source = "SweetOps/storage-bucket/google"
	version = "0.1.1"
	name = ["storage-bucket-test", "storage-bucket-test2"]
    }
    output storage-bucket_url {
	value = "${module.storage-bucket.url}"
    }

Создаем  `variables.tf terraform.tfvars`

### Параметризуем конфигурацию модулей

В модули добавляем переменные, чтобы была возможность создания не перескающихся IS (оставлены только новые или измененыее переменные)

    module "app" {
	app_name                   = "reddit-app-stage"
	tags                       = ["reddit-app-stage"]
	reddit_app_ip_name         = "reddit-app-stage-ip"
	firewall_puma_name         = "firefall-puma-stage"
	firewall_puma_source_range = ["0.0.0.0/0"]
	firewall_puma_target_tags  = ["reddit-app-stage"]
    }

    module "db" {
	db_name                    = "reddit-db-stage"
	tags                       = ["reddit-db-stage"]
	firewall_mongo_name        = "firefall-mongo-stage"
	firewall_mongo_source_tags = ["reddit-app-stage"]
	firewall_mongo_target_tags = ["reddit-db-stage"]
    }

    module "vpc" {
	name_ssh      = "ssh-for-stage"
    }

## Ansible-1

Устанавливаем ansible `easy_install `cat requirements.txt``
Прверяем версию `ansible --version` результат `ansible 2.6.0`
Добавляем `output` переменную для терраформа в модуль `db`

    output "db_external_ip" {
	value = "${google_compute_instance.db.network_interface.0.access_config.0.assigned_nat_ip}"
    }

Добавляем `output` переменную для терраформа в `stage and production`

    output "db_external_ip" {
	value = "${module.db.db_external_ip}"
    }

Создаем `inventory`

    appserver ansible_host=35.195.178.52 ansible_user=appuser ansible_private_key_file=~/.ssh/appuser

Добавляем в `inventory`

    dbserver ansible_host=35.240.108.228 ansible_user=appuser ansible_private_key_file=~/.ssh/appuser

Вызоваем модуль ping `ansible dbserver -i ./inventory -m ping`
Создаем `ansible.cfg`

    [defaults]
    inventory = ./inventory
    remote_user = appuser
    private_key_file = ~/.ssh/appuser
    host_key_checking = False
    retry_files_enabled = False

Удаляем избыточную информацию в `inventory`
Создаем группы хостов в `inventory`

    [app]
	appserver ansible_host=35.195.178.52
    [db]
	dbserver ansible_host=35.240.108.228

Создаем `inventory.yml`

    app:
      hosts:
	appserver:
	  ansible_host: 35.195.178.52
    db:
      hosts:
	dbserver:
	  ansible_host: 35.240.108.228

Проверияем, что на app сервере установлены компоненты для работы

    ansible app -m command -a 'ruby -v'
    ansible app -m command -a 'bundler -v'

А вот здесь ошибка

    ansible app -m command -a 'ruby -v; bundler -v'

Меняем модуль на `shell`

    ansible app -m shell -a 'ruby -v; bundler -v'

Проверяем `MongoDB`

    ansible db -m command -a 'systemctl status mongod'

Или с помощью `systemd`

    ansible db -m systemd -a name=mongod

Или с `service`

    ansible db -m service -a name=mongod

Клонируем репо 

    ansible app -m git -a 'repo=https://github.com/express42/reddit.git dest=/home/appuser/reddit'

Создаем playbook `clone.yml`

    ---
    - name: Clone
      hosts: app
      tasks:
	- name: Clone repo
	    git:
            repo: https://github.com/express42/reddit.git
            dest: /home/appuser/reddit

Выполняем: `ansible-playbook clone.yml`
Выполняем: `ansible app -m command -a 'rm -rf ~/reddit'`
Выполняем: `ansible-playbook clone.yml`
Если задача ансибла ничего не меняет - то выводится статус Ok. Так-как мы удалили данные, то задача вернула статус Changed так-как произошло клонирование репозитория, который раньше был уже скопирован.

### Ansible-1 *
Создан файл `inventory.json`
Создан файл `inventory.rb`

    #!/usr/bin/env ruby
    # encoding: UTF-8

    require 'open3'
    require 'json'

    $VERBOSE=nil

    begin
	app_ip, status = Open3.capture3("cd ../terraform/stage; terraform output app_external_ip;")
	db_ip, status = Open3.capture3("cd ../terraform/stage; terraform output db_external_ip;")
	if ARGV[0] == '--list'
	    j = {app: {hosts: [app_ip.strip]}, db: {hosts: [db_ip.strip]},'_meta' => {'hostvars': {}}}
	else
	    j = {app: {hosts: {appserver: {ansible_host: app_ip.strip}}}, db: {hosts: {dbserver: {ansible_host: db_ip.strip}}},'_meta' => {'hostvars': {}}}
	end
	puts JSON.pretty_generate(j)
    rescue
	puts 'Error'
    end

Выдаем права на запуск `chmod +x inventory.rb`
Резудьтат работы `ansible all -i ./inventory.rb -m ping`

    35.240.108.228 | SUCCESS => {
	"changed": false,
	"ping": "pong"
    }
    35.195.178.52 | SUCCESS => {
	"changed": false,
	"ping": "pong"
    }

Результат генерации полного `inventory` запуск  `./inventory.rb`

    {
	"app": {
	    "hosts": {
    		"appserver": {
    		    "ansible_host": "35.195.178.52"
    		}
	    }
	},
	"db": {
	    "hosts": {
    		"dbserver": {
    		    "ansible_host": "35.240.108.228"
    		}
	    }
	},
	"_meta": {
	    "hostvars": {
	    }
	}
    }

Меняем строчку в `ansible.cfg`

    inventory = ./inventory

На

    inventory = ./inventory.rb

Запускаем `ansible all -m ping`
Результат

    35.240.108.228 | SUCCESS => {
	"changed": false,
	"ping": "pong"
    }
    35.195.178.52 | SUCCESS => {
	"changed": false,
	"ping": "pong"
    }

