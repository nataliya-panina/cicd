# Домашнее задание к занятию «Ansible.Часть 2» - Панина Наталия

## Задание 1

Выполните действия, приложите файлы с плейбуками и вывод выполнения.

Напишите три плейбука. При написании рекомендуем использовать текстовый редактор с подсветкой синтаксиса YAML.

Плейбуки должны:

-  Скачать какой-либо архив, создать папку для распаковки и распаковать скаченный архив. Например, можете использовать официальный сайт и зеркало Apache Kafka. При этом можно скачать как исходный код, так и бинарные файлы, запакованные в архив — в нашем задании не принципиально.  
-  Установить пакет tuned из стандартного репозитория вашей ОС. Запустить его, как демон — конфигурационный файл systemd появится автоматически при установке. Добавить tuned в автозагрузку.  
-  Изменить приветствие системы (motd) при входе на любое другое. Пожалуйста, в этом задании используйте переменную для задания приветствия. Переменную можно задавать любым удобным способом.  

## Решение
Файл ansible.cfg:
```
[defaults]
remote_user = moi
ansible_ssh_private_key_file: /home/moi/.ssh/id_ed25519
inventory = "./hosts"

[privilege_escalation]
become = True
become_user = root
become_method = sudo
```

1. Плейбук, который создаёт директорию в /tmp и распаковывает туда скачанный архивный файл
```
---
- name: download and unarchive kafka
  hosts: yc
  tasks:
  - name: create_directory_kafka
    file:
      path: /tmp/kafka
      state: directory
      mode: 0755
  - name: download_unarchive_kafka
    unarchive:
      src: https://downloads.apache.org/kafka/3.8.0/kafka_2.13-3.8.0.tgz
      dest: /tmp/kafka
      remote_src: yes

  - name: list_destination_directory
    shell: ls /tmp/kafka
    register: results

  - debug:
      var: results.stdout
...
```

![image](https://github.com/user-attachments/assets/8e9e30b9-7b1f-4291-87a0-86d10c13ed98)


2. Плейбук для сервиса tuned:

```
---
- name: Install and start service tuned
  hosts: yc
  tasks:
    - name: install_tuned
      apt:
        name: tuned
        state: latest
        update_cache: yes
    - name: start_service_tuned
      service:
        name: tuned
        state: started
        enabled: true
...
```
![image](https://github.com/user-attachments/assets/a9fc6ce8-96a7-4f2d-8e75-397fd26115ec)


3. Плейбук, который изменяет приветствие (motd)

```
- name: change_motd
  hosts: yc
  tasks:
  - name: disable default motd
    file:
      path: /etc/update-motd.d/
      state: directory
      recurse: yes
      mode: 644

  - name: new message
    shell: echo Hello $USER > /etc/motd
```

![image](https://github.com/user-attachments/assets/a96e90e3-71a8-47f1-8f11-69ce511f13fa)


## Задание 2

Выполните действия, приложите файлы с модифицированным плейбуком и вывод выполнения.

Модифицируйте плейбук из пункта 3, задания 1. В качестве приветствия он должен установить IP-адрес и hostname управляемого хоста, пожелание хорошего дня системному администратору.  

## Решение

```
---
- name: Hello from cloud
  hosts: yc
  tasks:
  - name: disable default motd
    file:
      path: /etc/update-motd.d/
      state: directory
      recurse: yes
      mode: 644

  - name: generate new motd
    copy:
      content: "\n Hello from {{ ansible_hostname }} \n
               \n my IP address is {{ ansible_host }} \n
               \n Have a nice day! \n " 
      dest: /etc/motd
```

![image](https://github.com/user-attachments/assets/f92461dc-9baa-461f-9bdb-8d7425fa5c45)


## Задание 3

Выполните действия, приложите архив с ролью и вывод выполнения.

Ознакомьтесь со статьёй «Ansible - это вам не bash», сделайте соответствующие выводы и не используйте модули shell или command при выполнении задания.

Создайте плейбук, который будет включать в себя одну, созданную вами роль. Роль должна:

- Установить веб-сервер Apache на управляемые хосты.
- Сконфигурировать файл index.html c выводом характеристик каждого компьютера как веб-страницу по умолчанию для Apache. Необходимо включить CPU, RAM, величину первого HDD, IP-адрес. Используйте Ansible facts и jinja2-template. Необходимо реализовать handler: перезапуск Apache только в случае изменения файла конфигурации Apache.
- Открыть порт 80, если необходимо, запустить сервер и добавить его в автозагрузку.
- Сделать проверку доступности веб-сайта (ответ 200, модуль uri).

В качестве решения:

- предоставьте плейбук, использующий роль;
- разместите архив созданной роли у себя на Google диске и приложите ссылку на роль в своём решении;
- предоставьте скриншоты выполнения плейбука;
- предоставьте скриншот браузера, отображающего сконфигурированный index.html в качестве сайта.
## Решение



![image](https://github.com/user-attachments/assets/d1f412c1-2baa-4114-97ce-2bf6a5d92993)

