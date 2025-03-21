# Домашнее задание к занятию «Terraform» - Панина Наталия

## Задание 1

Ответьте на вопрос в свободной форме.

Опишите виды подхода к IaC:

    функциональный;
    процедурный;
    интеллектуальный.

## Решение

- **Функциональный (декларативный) подход.** Инфраструктура описывается в виде конфигурационных файлов, которые указывают желаемое состояние системы, а инструменты IaC берут на себя всю остальную работу: развертывание виртуальной машины или контейнера, установка и настройка необходимого программного обеспечения, управление версиями и т.д. Главный недостаток декларативного подхода заключается в том, что для его настройки и управления обычно требуется опытный администратор. Terraform и CloudFormation являются примерами популярных инструментов, использующих декларативный подход.
- **Процедурный (императивный) подход.** Инфраструктура определяется путем применения команд и скриптов для создания и управления ресурсами. Несмотря на то, что по мере масштабирования инфраструктуры при использовании такого подхода может потребоваться проделать больше работы, системным администраторам может быть проще с ним разобраться, поскольку они могут использовать уже имеющиеся сценарии настройки. Примерами таких инструментов являются Ansible и Chef.
- **Интеллектуальный (гибридный) подход.** Комбинация декларативного и императивного подходов, где описание инфраструктуры может включать в себя и декларативные файлы, а также императивные команды для настройки определенных частей инфраструктуры.

## Задание 2

Ответьте на вопрос в свободной форме.

Как вы считаете, в чём преимущество применения Terraform?

## Решение

Преимущества Terraform:  

- Масштабируемость и гибкость - позволяет описывать и управлять инфраструктурой любого размера и сложности
- Декларативная конфигурация - нет необходимости описывать шаг за шагом то, что нужно получить в итоге
- Универсальность - работает со многими облачными провайдерами
- Сообщество и экосистема

## Задание 3

Ответьте на вопрос в свободной форме.

Какие минусы можно выделить при использовании IaC?

## Решение

- Нужны дополнительные инструменты
- Необходимость ведения документации и регистрация всех изменений

## Задание 4

Выполните действия и приложите скриншоты запуска команд.

Установите Terraform на компьютерную систему (виртуальную или хостовую), используя лекцию или инструкцию.

В связи с недоступностью ресурсов для загрузки Terraform на территории РФ, вы можете воспользоваться VPN или использовать зеркало из репозитория по ссылке.

## Решение

    cd /usr/local/src && git clone https://github.com/hashicorp/terraform.git

![Installed](https://github.com/nataliya-panina/cicd/blob/main/Terraform/Terraform_installed.png)

# Дополнительные задания* (со звёздочкой)

## Задание 5*

Ответьте на вопрос в свободной форме.

Перечислите основные функции, которые могут использоваться в Terraform.

## Решение

---
# Установка nginx и wordpress локально в контейнерах


## providers.tf
  - в этом файле описываются провайдеры, с которыми будет работать terraform. В этом случае запускаются контейнеры docker, поэтому в качестве провайдера описываем docker.
```hcl
terraform {
  required_providers {
    docker = {
      source = "kreuzwerker/docker"
      version = "3.0.2"
    }
  }
}
```

## variables.tf
  - в качестве переменной сначала описывается её структура (объект), который включает в себя наименование (строка), образ (строка), и порты (объект), состоящий из внешнего и внутреннего портов (числа). Блок "default" включает в себя 2 контейнера - nginx и wordpress, каждый со своими параметрами.
```hcl
variable "containers" {
  type=map(object({
    name=string
    image=string
    ports=object({
      external=number
      internal=number
    })
  }))
default={
  nginx={
    name="reverse-proxy-nginx"
    image="nginx:1.21.1"
    ports={
      internal=80
      external=1080
    }
  }
  wordpress={
    name="web-wordpress"
    image="wordpress:latest"
    ports={
      internal=80
      external=2080
    }
  }
}
}
```
## main.tf
  - это инструкция для создания ресурсов, имена указаны в виде переменных (var.containers.nginx.image), которые были ранее описаны в файле variables.tf
```hcl
resource "docker_image" "nginx" {
    name = var.containers.nginx.image
    keep_locally = true
}
resource "docker_image" "wordpress" {
    name = var.containers.wordpress.image
    keep_locally = true
}
```
## Команды terraform
```hcl
terraform validate # проверка кода
terraform plan # план структуры
terraform apply # применение описанной структуры
terraform refresh # проверяет соответствие своего файла и структуры облака
terraform output  # просмотр выходных переменных
terraform taint # помечает ресурс на пересоздание
terraform destroy # удаление всей созданной структуры
terraform console # терминал для тренировок
```

## terraform console
![image](https://github.com/user-attachments/assets/cc558432-ded2-4b0b-876b-2603f7af66c0)
![image](https://github.com/user-attachments/assets/4c755931-c709-40cf-a851-10d7917d1143)
![image](https://github.com/user-attachments/assets/7b980b77-51a9-4ef1-bc6c-22d06bed0657)
![image](https://github.com/user-attachments/assets/919789bb-24be-40d9-a86e-48914bf41123)
## backend
Файл terraform.tfstate нужно хранить в надёжном месте, например, в S3, в Yandex cloud https://console.yandex.cloud/folders/b1ghpsbumf7efm6d0s33/storage/buckets,  https://yandex.cloud/ru/docs/storage/quickstart?from=int-console-empty-state. Для получения доступа к бакету нужен сервисный аккаунт с правами доступа (создать ключ для доступа в хранилище). Далее в файле **providers.tf** описывается бэкенд:
```hcl
terraform {
  required_version = ">=1.8.4"
  backend "s3" {
    region = "ru-central1"
    bucket = "bucket_name"
    key = "terraform.tfstate"

    #access_key = !!! nano 
    #secret_key = !!!

    skip_region_validation = true
    skip_credentials_validation = true
    skip_requesting_account_id = true
    skip_s3_checksum = true
  }
  endpoints = {
    s3 = "https://storage.yandexcloud.net"
  }
}
```
