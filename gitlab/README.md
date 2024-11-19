# Домашнее задание к занятию «GitLab» - Панина Наталия
Инструкция по выполнению домашнего задания

    Сделайте fork репозитория c шаблоном решения к себе в GitHub и переименуйте его по названию или номеру занятия, например, https://github.com/имя-вашего-репозитория/gitlab-hw или https://github.com/имя-вашего-репозитория/8-03-hw.
    Выполните клонирование этого репозитория к себе на ПК с помощью команды git clone.
    Выполните домашнее задание и заполните у себя локально этот файл README.md:
        впишите сверху название занятия, ваши фамилию и имя;
        в каждом задании добавьте решение в требуемом виде — текст, код, скриншоты, ссылка.
        для корректного добавления скриншотов используйте инструкцию «Как вставить скриншот в шаблон с решением»;
        при оформлении используйте возможности языка разметки md. Коротко об этом можно посмотреть в инструкции по MarkDown.
    После завершения работы над домашним заданием сделайте коммит git commit -m "comment" и отправьте его на GitHub git push origin.
    Для проверки домашнего задания в личном кабинете прикрепите и отправьте ссылку на решение в виде md-файла в вашем GitHub.
    Любые вопросы по выполнению заданий задавайте в чате учебной группы или в разделе «Вопросы по заданию» в личном кабинете.

Желаем успехов в выполнении домашнего задания!

------
## Задание 1

Что нужно сделать:

    Разверните GitLab локально, используя Vagrantfile и инструкцию, описанные в этом репозитории.
    Создайте новый проект и пустой репозиторий в нём.
    Зарегистрируйте gitlab-runner для этого проекта и запустите его в режиме Docker. Раннер можно регистрировать и запускать на той же виртуальной машине, на которой запущен GitLab.
В качестве ответа в репозиторий шаблона с решением добавьте скриншоты с настройками раннера в проекте.

---
## Решение
```
git clone https://github.com/netology-code/sdvps-materials.git
```
Установка Vitrualbox:
```
echo "deb http://download.virtualbox.org/virtualbox/debian $(lsb_release -sc) contrib" | sudo tee -a /etc/apt/sources.list
wget -q https://www.virtualbox.org/download/oracle_vbox_2016.asc -O- | sudo apt-key add -
wget -q https://www.virtualbox.org/download/oracle_vbox.asc -O- | sudo apt-key add -
sudo apt update
sudo apt install virtualbox -y
```
Установка Vagrant:
```
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install vagrant
vagrant --version
```
![image](https://github.com/user-attachments/assets/bfe891f3-559b-41a4-bbe5-debe060bec81)

  Работа с Gitlab:  
- В Gitlab создаю новый пустой проект "my_project"  
- Добавляю этот репозиторий в список удаленных репозиториев и заливаю в него клон:
  
```
git remote add my_gitlab http://89.169.151.188/root/my_project.git
git push my_gitlab
```
Запуск раннера в режиме docker:
```
moi@ubu:~/gitlab/git_clone$    docker run -ti --rm --name gitlab-runner \
     --network host \
     -v /srv/gitlab-runner/config:/etc/gitlab-runner \
     -v /var/run/docker.sock:/var/run/docker.sock \
     gitlab/gitlab-runner:latest register
Unable to find image 'gitlab/gitlab-runner:latest' locally
latest: Pulling from gitlab/gitlab-runner
d9802f032d67: Pull complete 
5e97f4029c0b: Pull complete 
d55be237d1a8: Pull complete 
Digest: sha256:d7776fd6b38f5d985832a6fde36062fb74ff38f5000d25d7843a2e3486b6d277
Status: Downloaded newer image for gitlab/gitlab-runner:latest
Runtime platform                                    arch=amd64 os=linux pid=7 revision=12030cf4 version=17.5.3
Running in system-mode.                            
                                                   
Created missing unique system ID                    system_id=r_y9xujOZtiCKr
Enter the GitLab instance URL (for example, https://gitlab.com/):
http://51.250.15.253/
Enter the registration token:
GR1348941_6JyPvw6x4ruHucs_gFu
Enter a description for the runner:
[ubu]:               
Enter tags for the runner (comma-separated):

Enter optional maintenance note for the runner:

WARNING: Support for registration tokens and runner parameters in the 'register' command has been deprecated in GitLab Runner 15.6 and will be replaced with support for authentication tokens. For more information, see https://docs.gitlab.com/ee/ci/runners/new_creation_workflow 
Registering runner... succeeded                     runner=GR1348941_6JyPvw6
Enter an executor: ssh, docker, kubernetes, docker-autoscaler, instance, custom, shell, parallels, virtualbox, docker-windows, docker+machine:
docker
Enter the default Docker image (for example, ruby:2.7):
golang:1.20
Runner registered successfully. Feel free to start it, but if it's running already the config should be automatically reloaded!
 
Configuration (with the authentication token) was saved in "/etc/gitlab-runner/config.toml"
```
![image](https://github.com/user-attachments/assets/e3e0cd8a-400e-4e95-bc80-16798767724a)

---
## Задание 2

Что нужно сделать:

    Запушьте репозиторий на GitLab, изменив origin. Это изучалось на занятии по Git.
    Создайте .gitlab-ci.yml, описав в нём все необходимые, на ваш взгляд, этапы.

В качестве ответа в шаблон с решением добавьте:

    файл gitlab-ci.yml для своего проекта или вставьте код в соответствующее поле в шаблоне;
    скриншоты с успешно собранными сборками.
----
# Дополнительные задания* (со звёздочкой)

Их выполнение необязательное и не влияет на получение зачёта по домашнему заданию. Можете их решить, если хотите лучше разобраться в материале.
## Задание 3*

Измените CI так, чтобы:

    этап сборки запускался сразу, не дожидаясь результатов тестов;
    тесты запускались только при изменении файлов с расширением *.go.

В качестве ответа добавьте в шаблон с решением файл gitlab-ci.yml своего проекта или вставьте код в соответсвующее поле в шаблоне.
