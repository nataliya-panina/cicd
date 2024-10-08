# Домашнее задание к занятию «Подъём инфраструктуры в Yandex Cloud» - Панина Наталия

## Задание 1

  Выполните действия, приложите скриншот скриптов, скриншот выполненного проекта.  
  От заказчика получено задание: при помощи Terraform и Ansible собрать виртуальную инфраструктуру и развернуть на ней веб-ресурс.  
 - В инфраструктуре нужна одна машина с ПО ОС Linux, двумя ядрами и двумя гигабайтами оперативной памяти.  
 - Требуется установить nginx, залить при помощи Ansible конфигурационные файлы nginx и веб-ресурса.  
 - Секретный токен от yandex cloud должен вводится в консоли при каждом запуске terraform.

   ![Этапы выполнения](https://github.com/nataliya-panina/cicd/blob/main/infra-cloud/etapes.md)
   
Провести тестирование.

## Решение

В файле ![main.tf](https://github.com/nataliya-panina/cicd/blob/main/infra-cloud/main.tf) описываю заданную конфигурацию виртуальной машины:  

 

В файле ![variables.tf](https://github.com/nataliya-panina/cicd/blob/main/infra-cloud/variables.tf) описываются переменные и их значения по умолчанию. В том числе токен, который вводится вручную при запуске terraform на выполнение.

В файле ![meta.txt](https://github.com/nataliya-panina/cicd/blob/main/infra-cloud/meta.txt) указываю параметры соединения: имя пользователя, группу sudo, в которую он должен входить, его командную оболочку, ключ ssh.  

В файле ![outputs.tf](https://github.com/nataliya-panina/cicd/blob/main/infra-cloud/outputs.tf) описываются переменные, которые нужно вывести после успешного создания инфраструктуры.  


Инициализация terraform:  

    terraform init

После инициализации можно посмотреть конфигурацию, которая будет создана после применения команды ``` terraform apply ``` : 

    terraform plan

Создание инфраструктуры, описанной в файлах конфигурации:  

    terraform apply

После создания инфраструктуры ```terraform output``` и полученный IP указываю в качестве хоста в файле hosts.  

```
#hosts
[yc:vars]
ansible_connection=ssh
ansible_user=user
ansible_ssh_private_key_file=/home/moi/.ssh/id_ed25519

[yc]
<Внешний IP ВМ>
```

Плейбук для установки, конфигурации и запуска nginx:  

```
#Playbook install nginx
---
- name: "Install Nginx"
  hosts: "all"
  become: yes
  become_method: "sudo"
  become_user: "root"
  remote_user: "user"

  tasks:
    - name: "Install Nginx"
      ansible.builtin.apt:
        name: "nginx"
        state: "latest"
        update_cache: true

    - name: "Copy config file"
      copy:
        src: /var/www/html/index.nginx-debian.html
        dest: /var/www/html/index.nginx-debian.html
        remote_src: no

    - name: "nginx systemd"
      systemd:
        name: "nginx"
        enabled: yes
        state: "started"
...
```

Запуск плейбука на выполнение:

    ansible-playbook install_nginx.yml -i hosts

Результат:

![image](https://github.com/user-attachments/assets/96eafdfd-9d59-47f4-b81b-882d2c6bcf94)


![image](https://github.com/user-attachments/assets/157fa885-6820-44b2-94e3-0f5095d70f7a)

ЗЫ: Для того, чтобы сработал ansible-playbook без ввода пароля - изменила  image_id = "fd8o6khjbdv3f1suqf69". (В дискорде посоветовали).


## Задание 2*

Выполните действия, приложите скриншот скриптов, скриншот выполненного проекта.

    Перестроить инфраструктуру и добавить в неё вторую виртуальную машину.
    Установить на вторую виртуальную машину базу данных.
    Выполнить проверку состояния запущенных служб через Ansible.
    
## Решение

Для создания двух одинаковых ВМ нужно добавить строчку ``` count = 2 ``` в файл с ресурсами.  
Изменения в файле main.tf:

```
...
resource "yandex_compute_instance" "vm" {
  count = 2

  resources {
    cores  = 2
    memory = 2
    core_fraction = 20
  }

  boot_disk {
    initialize_params {
      image_id = "fd8o6khjbdv3f1suqf69"
    }
  }
...
```
Изменения в файле outputs.tf:
```
  GNU nano 6.2                                                      outputs.tf                                                                
output "internal_ip_address_vm" {
  value = yandex_compute_instance.vm[*].network_interface.0.ip_address
}

output "external_ip_address_vm" {
  value = yandex_compute_instance.vm[*].network_interface.0.nat_ip_address
}
```

Применение изменений:

```
terraform apply
```

Создание двух одинаковых ВМ:  

![image](https://github.com/user-attachments/assets/19e4e64a-3d19-4ef8-ae90-85f2a82c3042)

Плейбук для установки базы данных на одну из виртуальных машин:  

```
#Playbook Install MySQL
---
- hosts: db
  become: yes
  become_method: "sudo"
  become_user: "root"
  remote_user: "user"

- tasks:
  - name: "install mysql"
    apt:
      name: "mysql"
      update_cache: yes
      cache_valid_time: 3600
      state: "present"

  - name: "start up the mysql service"
    shell: "service mysql start"

  - name: "ensure mysql is enabled to run on startup"
    service:
      name: "mysql"
      state: "started"
      enabled: true

  - name: "update mysql root password for all root accounts"
    mysql_user:
      name: "user"
      host: "{{ item }}"
      password: "password"
#      login_user: "root"
#      login_password: "{{ mysql_root_password }}"
      check_implicit_admin: yes
      priv: "*.*:ALL,GRANT"
      with_items:
        - "{{ ansible_hostname }}"
        - 127.0.0.1
        - localhost
        - 89.169.156.109

  - name: "create a new database"
    mysql_db:
      name: "testdb"
      state: "present"
      login_user: "user"
      login_password: "password"
```
... Ищу ошибки...

## Задание 3*

Изучите инструкцию yandex для terraform. Добейтесь работы паплайна с безопасной передачей токена от облака в terraform через переменные окружения. Для этого:

    Настройте профиль для yc tools по инструкции.
    Удалите из кода строчку "token = var.yandex_cloud_token". Terraform будет считывать значение ENV переменной YC_TOKEN.
    Выполните команду export YC_TOKEN=$(yc iam create-token) и в том же shell запустите terraform.
    Для того чтобы вам не нужно было каждый раз выполнять export - добавьте данную команду в самый конец файла ~/.bashrc
## Решение

![image](https://github.com/user-attachments/assets/78a4aae1-6a79-4029-bed6-0a413c8646eb)

```
export YC_TOKEN=$(yc iam create-token)
```
![image](https://github.com/user-attachments/assets/c3ed85c6-f694-4819-a706-0639f67ff8dd)


Дополнительные материалы:

![Nginx. Руководство для начинающих.](https://nginx.org/ru/docs/beginners_guide.html)  
![Руководство по Terraform.](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/doc)  
![Ansible User Guide.](https://docs.ansible.com/ansible/latest/user_guide/index.html)  
![Terraform Documentation.](https://www.terraform.io/docs/index.html)  
