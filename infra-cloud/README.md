# Домашнее задание к занятию «Подъём инфраструктуры в Yandex Cloud» - Панина Наталия

## Задание 1

  Выполните действия, приложите скриншот скриптов, скриншот выполненного проекта.  
  От заказчика получено задание: при помощи Terraform и Ansible собрать виртуальную инфраструктуру и развернуть на ней веб-ресурс.  
 - В инфраструктуре нужна одна машина с ПО ОС Linux, двумя ядрами и двумя гигабайтами оперативной памяти.  
 - Требуется установить nginx, залить при помощи Ansible конфигурационные файлы nginx и веб-ресурса.  
 - Секретный токен от yandex cloud должен вводится в консоли при каждом запуске terraform.  

Для выполнения этого задания нужно сгенирировать SSH-ключ командой ssh-keygen. Добавить в конфигурацию Terraform ключ в поле:
```
 metadata = {
    user-data = "${file("./meta.txt")}"
  }
```

В файле meta прописать:
```
 users:
  - name: user
    groups: sudo
    shell: /bin/bash
    sudo: ['ALL=(ALL) NOPASSWD:ALL']
    ssh-authorized-keys:
      - ssh-rsa  xxx
```

Где xxx — это ключ из файла /home/"name_ user"/.ssh/id_rsa.pub. Примерная конфигурация Terraform:
```
terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
}

variable "yandex_cloud_token" {
  type = string
  description = "Данная переменная потребует ввести секретный токен в консоли при запуске terraform plan/apply"
}

provider "yandex" {
  token     = var.yandex_cloud_token #секретные данные должны быть в сохранности!! Никогда не выкладывайте токен в публичный доступ.
  cloud_id  = "xxx"
  folder_id = "xxx"
  zone      = "ru-central1-a"
}

resource "yandex_compute_instance" "vm-1" {
  name = "terraform1"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = "fd87kbts7j40q5b9rpjr"
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-1.id
    nat       = true
  }
  
  metadata = {
    user-data = "${file("./meta.txt")}"
  }

}
resource "yandex_vpc_network" "network-1" {
  name = "network1"
}

resource "yandex_vpc_subnet" "subnet-1" {
  name           = "subnet1"
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.network-1.id
  v4_cidr_blocks = ["192.168.10.0/24"]
}

output "internal_ip_address_vm_1" {
  value = yandex_compute_instance.vm-1.network_interface.0.ip_address
}
output "external_ip_address_vm_1" {
  value = yandex_compute_instance.vm-1.network_interface.0.nat_ip_address
}
```

В конфигурации Ansible указать:

    внешний IP-адрес машины, полученный из output external_ ip_ address_ vm_1, в файле hosts;
    доступ в файле plabook *yml поля hosts.
```
- hosts: 138.68.85.196
  remote_user: user
  tasks:
    - service:
        name: nginx
        state: started
      become: yes
      become_method: sudo
```
Провести тестирование.
## Решение

В файле main.tf описываю заданную конфигурацию виртуальной машины:  

![main.tf](https://github.com/nataliya-panina/cicd/blob/main/infra-cloud/main.tf) 

В файле ![variables.tf](https://github.com/nataliya-panina/cicd/blob/main/infra-cloud/variables.tf) описываются переменные и их значения по умолчанию.

В файле ![meta.txt](https://github.com/nataliya-panina/cicd/blob/main/infra-cloud/meta.txt) указываю параметры соединения: имя пользователя, группу sudo, в которую он должен входить, его командную оболочку, ключ ssh.  

В файле ![outputs.tf](https://github.com/nataliya-panina/cicd/blob/main/infra-cloud/outputs.tf) описываются переменные, которые нужно вывести после успешного создания инфраструктуры.  


Инициализация terraform:  

    terraform init

После инициализации можно посмотреть конфигурацию, которая будет создана после применения команды ``` terraform apply ``` : 

    terraform plan

Создание инфраструктуры, описанной в файлах конфигурации:  

    terraform apply

После создания инфраструктуры ```terraform output``` и полученний IP указываю в качестве хоста в файле hosts.

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
        src: '{/var/www/html/index.nginx-debian.html}'
        dest: '{/var/www/html/index.nginx-debian.html}'

    - name: "nginx systemd"
      systemd:
        name: "nginx"
        enabled: yes
        state: "started"
...
```

    ansible-playbook install_nginx.yml -i hosts

![image](https://github.com/user-attachments/assets/7250f7de-367c-40c2-88bf-1af0dbe3fb90)

```
terraform show:
```

```
...
    metadata                  = {
        "user-data" = <<-EOT
            #cloud-config
            users:
              - name: user
                groups: sudo
                shell: /bin/bash
                sudo: ['ALL=(ALL:ALL) NOPASSWD:ALL']
                ssh-authorized-keys:
                  - ssh-rsa ***
                  - ssh-ed25519 ***
        EOT
    }
...
```
    Я правильно понимаю, что в файле мета создается пользователь в группе судо и для повышения его привилегий пароль не нужен?. Я могу подключится по ssh, пользователь находится в группе sudo, но при попытке установить что-нибудь - запрашивается пароль рута.
Где и что нужно изменить чтобы пароль не запрашивался?

## Задание 2*

Выполните действия, приложите скриншот скриптов, скриншот выполненного проекта.

    Перестроить инфраструктуру и добавить в неё вторую виртуальную машину.
    Установить на вторую виртуальную машину базу данных.
    Выполнить проверку состояния запущенных служб через Ansible.
## Решение


## Задание 3*

Изучите инструкцию yandex для terraform. Добейтесь работы паплайна с безопасной передачей токена от облака в terraform через переменные окружения. Для этого:

    Настройте профиль для yc tools по инструкции.
    Удалите из кода строчку "token = var.yandex_cloud_token". Terraform будет считывать значение ENV переменной YC_TOKEN.
    Выполните команду export YC_TOKEN=$(yc iam create-token) и в том же shell запустите terraform.
    Для того чтобы вам не нужно было каждый раз выполнять export - добавьте данную команду в самый конец файла ~/.bashrc
## Решение


Дополнительные материалы:

![Nginx. Руководство для начинающих.](https://nginx.org/ru/docs/beginners_guide.html)  
![Руководство по Terraform.](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/doc)  
![Ansible User Guide.](https://docs.ansible.com/ansible/latest/user_guide/index.html)  
![Terraform Documentation.](https://www.terraform.io/docs/index.html)  
