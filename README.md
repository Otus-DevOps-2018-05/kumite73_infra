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
