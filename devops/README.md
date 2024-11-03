# Домашнее задание к занятию «Что такое DevOps. СI/СD» - Панина Наталия

## Задание 1

Что нужно сделать:

    Установите себе jenkins по инструкции из лекции или любым другим способом из официальной документации. Использовать Docker в этом задании нежелательно.
    Установите на машину с jenkins golang.
    Используя свой аккаунт на GitHub, сделайте себе форк репозитория. В этом же репозитории находится дополнительный материал для выполнения ДЗ.
    Создайте в jenkins Freestyle Project, подключите получившийся репозиторий к нему и произведите запуск тестов и сборку проекта go test . и docker build ..

В качестве ответа пришлите скриншоты с настройками проекта и результатами выполнения сборки.
## Решение
Установка Java
```
sudo apt update
sudo apt install default-jre -y
```  
Проверка версии java:
```
java -version

openjdk version "11.0.24" 2024-07-16  
OpenJDK Runtime Environment (build 11.0.24+8-post-Ubuntu-1ubuntu322.04)  
OpenJDK 64-Bit Server VM (build 11.0.24+8-post-Ubuntu-1ubuntu322.04, mixed mode, sharing)  
```

Установка Jenkins
```
sudo wget -O /usr/share/keyrings/jenkins-keyring.asc https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc]" https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt update
sudo apt install jenkins -y

```
https://www.jenkins.io/doc/book/installing/linux/#debianubuntu
![image](https://github.com/user-attachments/assets/500cc0c4-3efe-464c-857c-0c12688934b2)
![image](https://github.com/user-attachments/assets/7a940722-4f10-4782-9eef-141cacf7b2a6)
Создаю новый item: netology_homework1 тип: freestyle
![image](https://github.com/user-attachments/assets/5241b761-500f-4fe5-8d8a-274b7b9b505d)

script shell:
```
/usr/local/go/bin/go test .
docker build . -t ubuntu-bionic:8082/hello-world:v$BUILD_NUMBER
docker login ubuntu-bionic:8082 -u admin -p admin && docker push ubuntu-bionic:8082/hello-world:v$BUILD_NUMBER && docker logout
```

![image](https://github.com/user-attachments/assets/91071c86-2266-4f1e-8aa5-688cc5eeb435)

Install Go
```
wget https://go.dev/dl/go1.17.5.linux-amd64.tar.gz
rm -rf /usr/local/go && tar -C /usr/local -xzf go1.17.5.linux-amd64.tar.gz
echo 'export PATH=$PATH:/usr/local/go/bin' >> /etc/profile
```


---
## Задание 2

Что нужно сделать:

    Создайте новый проект pipeline.
    Перепишите сборку из задания 1 на declarative в виде кода.

В качестве ответа пришлите скриншоты с настройками проекта и результатами выполнения сборки.
## Решение

## Задание 3

Что нужно сделать:

    Установите на машину Nexus.
    Создайте raw-hosted репозиторий.
    Измените pipeline так, чтобы вместо Docker-образа собирался бинарный go-файл. Команду можно скопировать из Dockerfile.
    Загрузите файл в репозиторий с помощью jenkins.

В качестве ответа пришлите скриншоты с настройками проекта и результатами выполнения сборки.
## Решение


# Дополнительные задания* (со звёздочкой)
е и не влияет на получение зачёта по домашнему заданию. Можете их решить, если хотите лучше разобраться в материале.
## Задание 4*

Придумайте способ версионировать приложение, чтобы каждый следующий запуск сборки присваивал имени файла новую версию. Таким образом, в репозитории Nexus будет храниться история релизов.

Подсказка: используйте переменную BUILD_NUMBER.

В качестве ответа пришлите скриншоты с настройками проекта и результатами выполнения сборки.
## Решение

