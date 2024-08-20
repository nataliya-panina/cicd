# Домашнее задание к занятию «Ansible. Часть 1» - Панина Наталия

## Задание 1
Ответьте на вопрос в свободной форме.  
Какие преимущества даёт подход IAC?

## Решение

    Скорость настройки инфраструктуры увеличивается
    Количесво ошибок уменьшается, и при их нахождении исправляются все сразу
    Поднимаемая инфраструктура всега идентична
    Масштабирование структуры занимает меньше времени
    Полезная статья: https://habr.com/ru/companies/otus/articles/574278/
    
## Задание 2
Выполните действия и приложите скриншоты действий.

    Установите Ansible.
    Настройте управляемые виртуальные машины, не меньше двух.
    Создайте файл inventory с созданными вами ВМ.
    Проверьте доступность хостов с помощью модуля ping.

## Решение

Я использую виртуальные машины в Яндекс облаке.

![Инструкция по установке](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html)
 
    sudo apt update  
    sudo apt install python3-pip python3-venv -y
    python3 --version
    python3 -m venv ansible_venv
    source ansible_venv/bin/activate
    pip3 install ansible
    ansible --version
    ansible-config init --disabled -t all > ansible.cfg

На ansible генерирую пару ключей  для управляемых хостов:  

    ssh-keygen -t ed25519
    

Файлы конфигурации:
1. ![hosts.yml](https://github.com/nataliya-panina/cicd/blob/main/hosts.yml)
2. ![ansible.cfg](https://github.com/nataliya-panina/cicd/blob/main/ansible.cfg)

Снимки с экрана:

![Ошибка](https://github.com/nataliya-panina/cicd/blob/main/img/failure_ping.png)
![Ошибка](https://github.com/nataliya-panina/cicd/blob/main/img/failure_venv.png)    

## Задание 3

Ответьте на вопрос в свободной форме.

Какая разница между параметрами forks и serial?

## Решение
    Параметр forks определяет максимальное количество хостов, на которых текущая задача выполняется одновременно.
    Параметр serial определяет количество нод, на которых плейбук запускается одновременно

## Задание 4

В этом задании вы будете работать с Ad-hoc коммандами.

Выполните действия и приложите скриншоты запуска команд.

    Установите на управляемых хостах любой пакет, которого нет.
    Проверьте статус любого, присутствующего на управляемой машине, сервиса.
    Создайте файл с содержимым «I like Linux» по пути /tmp/netology.txt.
    
## Решение

