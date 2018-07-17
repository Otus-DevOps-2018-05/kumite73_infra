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

Устанавливаем ansible 

    easy_install `cat requirements.txt`

Проверяем версию `ansible --version` результат `ansible 2.6.0`
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
Результат работы `ansible all -i ./inventory.rb -m ping`

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



## Ansible-2

Добавляем в модуль terraform db output переменную 

    output "db_internal_ip" {
	value = "${google_compute_instance.db.network_interface.0.address}"
    }

Добавляем в stage output переменную 

    output "db_internal_ip" {
	value = "${module.db.db_internal_ip}"
    }

Создаем файл reddit_app.yml

Делаем сценарий для Монго

    ---
    - name: Configure hosts & deploy application
      hosts: all
      tasks:
        - name: Change mongo config file
          become: true
	  template:
            src: templates/mongod.conf.j2
            dest: /etc/mongod.conf
            mode: 0644

Добавялем тег в задачу, чтобы была возможность запускать по тегу `tags: db-tag`
Создаем директорию `templates`
Создаем шаблон `mongod.conf.j2`
Работа с переменными в шаблоне

    # network interfaces
    net:
      port: {{ mongo_port | default('27017') }}
      bindIp: {{ mongo_bind_ip }}

Проверка конфигурации для хостов из группы DB `ansible-playbook reddit_app.yml --check --limit db`
Задаем переменную IP адрес для монго

    - name: Configure hosts & deploy application
      hosts: all
      vars:
        mongo_bind_ip: 0.0.0.0

Работа с handler. Добаввялем в task оповещение `notify: restart mongod`
Описываем handler

    handlers:
      - name: restart mongod
        become: true
        service: name=mongod state=restarted

Применим плейбук `ansible-playbook reddit_app.yml --limit db`

Создаем директорию `files`
Создаем файл `puma.service`

    [Unit]
    Description=Puma HTTP Server
    After=network.target

    [Service]
    Type=simple
    EnvironmentFile=/home/appuser/db_config
    User=appuser
    WorkingDirectory=/home/appuser/reddit
    ExecStart=/bin/bash -lc 'puma'
    Restart=always

    [Install]
    WantedBy=multi-user.target

Создаем таск для копирования unit файла на хост приложения. Используем модуль `copy` и модуль `systemd` для перезапуска пумы.

    - name: Add unit file for Puma
      become: true
      copy:
	src: files/puma.service
	dest: /etc/systemd/system/puma.service
      tags: app-tag
      notify: reload puma

    - name: enable puma
      become: true
      systemd: name=puma enabled=yes
      tags: app-tag

Создаем шаблон `db_config.j2`

    DATABASE_URL={{ db_host }}

Добавляем таск для копирования созданного шаблона:

    - name: Add config for DB connection
      template:
	src: templates/db_config.j2
	dest: /home/appuser/db_config
      tags: app-tag

Задаем переменную `db_host: 10.132.0.2`
Адрем берем из output переменной
Применяем таски `ansible-playbook reddit_app.yml --limit app --tags app-tag`
Создаем таски для деплоя кода

    - name: Fetch the latest version of application code
      git:
	repo: 'https://github.com/express42/reddit.git'
	dest: /home/appuser/reddit
	version: monolith
      tags: deploy-tag
      notify: reload puma

    - name: Bundle install
      bundler:
	state: present
	chdir: /home/appuser/reddit
      tags: deploy-tag

Выполняем деплой `ansible-playbook reddit_app.yml --limit app --tags deploy-tag`
Создаем новый файл `reddit_app2.yml`

Копируем определение сценария из `reddit_app.yml` и всю информацию, относящуюся к настройке MongoDB, которая будет включать в себя таски, хендлеры и переменные
Выносим `become: true` на уровень сценария для того, чтобы все команды вызывались из под `root`
Аналогично делаем для `reddit_app2.yml`
Пересоздаем инфраструктуру. Для этого я создал 2 альяса ta и td. Чтобы упростить работу с терраформ.
Применяем сценарий `ansible-playbook reddit_app2.yml --tags db-tag`
Применяем сценарий `ansible-playbook reddit_app2.yml --tags app-tag`
Создаем сценарий для деплоя в `reddit_app2.yml`
Выполянем `ansible-playbook reddit_app2.yml --tags deploy-tag`
Переименуем предыдущие плейбуки:

    reddit_app.yml -> reddit_app_one_play.yml
    reddit_app2.yml-> reddit_app_multiple_plays.yml

Создаем файлы `app.yml, db.yml, deploy.yml`
Заполняем файлы из `Из файла reddit_app_multiple_plays.yml`
Убираем теги
Создаем файл `site.yml`

    ---
    - include: db.yml
    - include: app.yml
    - include: deploy.yml

P.S. Начиная с версии 2.4 инструкцию `include` можно заменить на `import_playbook`
Пересоздаем инфраструктуру `td ta`
Выполняем `ansible-playbook site.yml`
Создаем на основе плейбуки `ansible/packer_app.yml` и `ansible/packer_db.yml`
Интегрируем Ansible в Packer
Заменим секцию Provision в образе `packer/app.json` на Ansible

    "provisioners": [
	{
	    "type": "ansible",
	    "playbook_file": "ansible/packer_app.yml"
	}
    ]

Такие же изменения выполним и для `packer/db.json`

    "provisioners": [
	{
	    "type": "ansible",
	    "playbook_file": "ansible/packer_db.yml"
	}
    ]

Запускаем проверку app паркер `packer validate -var-file=packer/variables.json packer/app.json`
Запускаем build app паркер `packer build -var-file=packer/variables.json packer/app.json`
Запускаем проверку adb паркер `packer validate -var-file=packer/variables.json packer/db.json`
Запускаем build app паркер `packer build -var-file=packer/variables.json packer/db.json`
Проверяем образы через `stage`

### Ansible-3

Создаем директорию `roles`
Создаем роли

    ansible-galaxy init app
    ansible-galaxy init db

Переносим таски из db.yml в `db/tasks/main.yml` убираем путь в  src и копируем шаблон `mongod.conf.j2` в `db/templates`

    ---
    # tasks file for db
      - name: Change mongo config file
	template:
          src: mongod.conf.j2
          dest: /etc/mongod.conf
	mode: 0644
	notify: restart mongod

Копируем данные их хендлера в `db/handlers/main.yml`

    - name: restart mongod
      service: name=mongod state=restarted

Определяем используемые в шаблоне переменные в секции переменных по умолчанию `db/defaults/main.yml`

    ---
    # defaults file for db
    mongo_port: 27017
    mongo_bind_ip: 127.0.0.1


Переносим таски из app.yml в `app/tasks/main.yml` убираем путь в src и копируем шаблон `db_conf.j2` в `app/templates`  `puma.service` в `app/files`

    - name: Add unit file for Puma
      copy:
	src: puma.service
	dest: /etc/systemd/system/puma.service
      notify: reload puma

    - name: Add config for DB connection
      template:
	src: db_config.j2
	dest: /home/appuser/db_config
	owner: appuser
	group: appuser

    - name: enable puma
      systemd: name=puma enabled=yes

Копируем данные их хендлера в `app/handlers/main.yml`

    - name: reload puma
      systemd: name=puma state=restarted


Определяем используемые в шаблоне переменные в секции переменных по умолчанию `app/defaults/main.yml`

    ---
    # defaults file for app
    db_host: 127.0.0.1

Меняем `ansible/app.yml` для вызова ролей

    ---
    - name: Configure App
      hosts: app
      become: true
      vars:
	db_host: 10.132.0.2
      roles:
	- app

Меняем `ansible/db.yml` для вызова ролей

    ---
    - name: Configure MongoDB
      hosts: db
      become: true
      vars:
	mongo_bind_ip: 0.0.0.0
      roles:
	- db

Пересоздадим инфраструктуру окружения `stage`
Проверяем и применяем роли

    ansible-playbook site.yml --check
    ansible-playbook site.yml

Создаем директорию `environments` внтури 2 директории stage и prod
Копируем инвентори файл `ansible/inventory` в каждую из директорий окружения `environtents/prod` и `environments/stage` удаляем `inventory`
Изменяем окружение по умолчанию в `ansible.cfg`

    inventory = ./environments/stage/inventory

Создаем директорию `group_vars` в директориях окружений `environments/prod` и `environments/stage`
Создаем файл `stage/group_vars/app` для определения переменных для группы хостов `app`, описанных в инвентори файле `stage/inventory`

    db_host: 10.132.0.2

Удаляем `ansible/app.yml`
Создаем файл `stage/group_vars/db` для определения переменных для группы хостов `db`, описанных в инвентори файле `stage/inventory`

    mongo_bind_ip: 0.0.0.0

Удаляем `ansible/db.yml`
Создаем файл `stage/group_vars/all`

    env: stage

Настраиваем `prod` копируем файлы `app, db, all` из директории `stage/group_vars` в директорию `prod/group_vars`
Меняем файл `all`

    env: prod

Определияем переменную по умолчанию `env` в используемых ролях `ansible/roles/app/defaults/main.yml`  и  `ansible/roles/db/defaults/main.yml`

    env: local

Вывод названия окружения. Добавляем в `tasks/main.yml` в начало для ролей `app и db`

    - name: Show info about the env this host belongs to
      debug:
      msg: "This host is in {{ env }} environment!!!"

Организуем плейбуки
Улучшим `ansible.cfg`

    [defaults]
    inventory = ./environments/stage/inventory
    remote_user = appuser
    private_key_file = ~/.ssh/appuser
    host_key_checking = False
    retry_files_enabled = False
    roles_path = ./roles
    [diff]
    always = True
    context = 5

Пересоздаем `stage`
Изменяем внешние IP адреса инстансов в инвентори файле `ansible/environments/stage/inventory` и переменную `db_host` в `stage/group_vars/app`

Проверяем и применяем роли

    ansible-playbook playbooks/site.yml --check
    ansible-playbook playbooks/site.yml


Удаляем `stage`
СОздаем `prod`
Изменяем внешние IP адреса инстансов в инвентори файле `ansible/environments/prod/inventory` и переменную `db_host` в `prod/group_vars/app`

Проверяем и применяем роли

    ansible-playbook -i environments/prod/inventory playbooks/site.yml --check
    ansible-playbook -i environments/prod/inventory playbooks/site.yml

Создадим файлы `environments/stage/requirements.yml` и `environments/prod/requirements.yml`

    ---
    - src: jdauphant.nginx
      version: v2.18.1

Установим роль: `ansible-galaxy install -r environments/stage/requirements.yml`

Поучили ошибку:

    Failed to get data from the API server (https://galaxy.ansible.com/api/): Failed to validate the SSL certificate for galaxy.ansible.com:443. Make sure your managed systems have a valid CA certificate installed

Решаем проблему:

    sudo python -m pip install pip==9.0.1
    sudo pip install -U urllib3[secure]

Изменим `.gitignore` добавимм строку `jdauphant.nginx`
Открываем 80 порт `terraform\satge\main.yml` и `terraform\prod\main.yml` добавляем тег `http-server`

    module "app" {
	...
	tags                       = ["reddit-app-stage", "http-server"]
	...
    }

Применяем инфрраструктуру
Добавляем переменные для `jdauphant.nginx` в `stage/group_vars/app и prod/group_vars/app`

    jdauphant_nginx_listen_port: 80
    jdauphant_nginx_server_name: reddit
    jdauphant_nginx_proxy_pass_port: 9292

Добавляем запуск роли в `playbooks/app.yml`

    roles:
      - app
      - jdauphant.nginx
        nginx_sites:
          default:
            - listen {{ jdauphant_nginx_listen_port }}
            - server_name {{ jdauphant_nginx_server_name }}
            - |
              location / {
                proxy_pass http://127.0.0.1:{{ jdauphant_nginx_proxy_pass_port }};
              }

При проверке выдает ошибку

    failed: [appserver] (item={'value': [u'listen 80', u'server_name reddit', u'location / {\n  proxy_pass http://127.0.0.1:9292;\n}\n'], 'key': u'default'}) => {"changed": false, "item": {"key": "default", "value": ["listen 80", "server_name reddit", "location / {\n  proxy_pass http://127.0.0.1:9292;\n}\n"]}, "msg": "src file does not exist, use \"force=yes\" if you really want to create the link: /etc/nginx/sites-available/default.conf", "path": "/etc/nginx/sites-enabled/default.conf", "src": "/etc/nginx/sites-available/default.conf", "state": "absent"}

При прямом запуске все проходит успешно

### Работа с Ansible Vault
Создаем `vault.key`
Добавляем в `ansible.cfg`

    [defailt]
    ...
    vault_password_file = vault.key

Создаем плейбук для создания пользователей `ansible/playbooks/users.yml`

    ---
    - name: Create users
      hosts: all
      become: true

      vars_files:
	- "{{ inventory_dir }}/credentials.yml"

      tasks:
	- name: create users
          user:
    	    name: "{{ item.key }}"
    	    password: "{{ item.value.password|password_hash('sha512', 65534|random(seed=inventory_hostname)|string) }}"
    	    groups: "{{ item.value.groups | default(omit) }}"
    	  with_dict: "{{ credentials.users }}"

Создаем файл `ansible/environments/prod/credentials.yml`

    ---
    credentials:
	users:
	    admin:
    	    password: admin123
    	    groups: sudo

Создаем файл `ansible/environments/stage/credentials.yml`

    ---
    credentials:
	users:
	    admin:
    	    password: qwerty123
    	    groups: sudo

    qauser:
      password: test123

Шифруем файлы

    ansible-vault encrypt environments/prod/credentials.yml
    ansible-vault encrypt environments/stage/credentials.yml

Применяем конфигурацию

    ansible-playbook playbooks/site.yml

### Задание *

Изменен скрипт `inventory.rb` сделана проверка в каком окружении он запущен и исходя из этого, берутся нужные переменны из терраформ.
Скрипт помещен в `environments/stage/` и `environments/prod/`
Запуск

    ansible-playbook -i ./environments/stage/inventory.rb playbooks/site.yml
    ansible-playbook -i ./environments/prod/inventory.rb playbooks/site.yml
