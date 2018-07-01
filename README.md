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
