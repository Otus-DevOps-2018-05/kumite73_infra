# kumite73_infra
kumite73 Infra repository

----

## Запуск 1 командой

----

1. Запуск ssh-agent `eval $(ssh-agent -s)`
2. Добавление приватного ключа в агент авторизации `ssh-add ~/.ssh/appuser`
3. Добавляем команды 1 и 2 в `.bashrc`
4. Команда для запуска `ssh -A appuser@130.211.51.235 ssh -tt 10.132.0.3`

----

## Запуск через alias

----

1. Создаем файл `~/.ssh/config`
2. Выставляем права `600`
3. Изменяем `config`

       Host someinternalhost
           HostName 10.132.0.3
           User appuser
           ProxyCommand ssh -W %h:%p appuser@130.211.51.235
       Host 130.211.51.235
           IdentityFile ~/.ssh/appuser
       Host 10.132.0.3
           IdentityFile ~/.ssh/appuser

4. Команда для запуска `ssh someinternalhost`

----

## OpenVPN

bastion_IP = 130.211.51.235

someinternalhost_IP = 10.132.0.3
