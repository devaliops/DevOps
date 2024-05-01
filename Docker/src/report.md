# DOCKER

## Оглавление

[Часть 1. Готовый Docker ](#Часть1)\
[Часть 2. Операции с контейнером ](#Часть2)\
[Часть 3. Мини веб-сервер ](#Часть3)\
[Часть 4. Свой докер ](#Часть3)

## <div id = "Часть1"></div> Часть 1. Готовый Docker

- Взял официальный докер образ с `nginx` и выкачал его при помощи `docker pull` 

![linux_network](images/1.png)

- Проверил наличие `Docker` образа через `docker images`

![linux_network](images/2.png)

- Запустил докер образ через `docker run -d 021283c8eb95`

![linux_network](images/3.png)

- Проверил, что образ запустился через `docker ps`

![linux_network](images/4.png)

- Посмотрел информацию о контейнере через `docker inspect 05354d4af5f3`

![linux_network](images/5.png)

- По выводу команды определил и поместил в отчёт размер контейнера, список замапленных портов и `ip` контейнера

![linux_network](images/6.png)
![linux_network](images/7.png)
![linux_network](images/8.png)

- Остановил докер образ через ` docker stop `

![linux_network](images/9.png)

- Проверил, что образ остановился через `docker ps`

![linux_network](images/10.png)

- Запустил докер с портами `80` и `443` в контейнере, замапленными на такие же порты на локальной машине, через команду run

![linux_network](images/11.png)

- Проверил, что в браузере по адресу `localhost:80` доступна стартовая страница nginx

![linux_network](images/12.png)

- Перезапустил докер контейнер через `docker restart`

![linux_network](images/13.png)

- Проверил любым способом, что контейнер запустился

![linux_network](images/14.png)

![linux_network](images/15.png)

## <div id = "Часть2"></div> Часть 2. Операции с контейнером 

- Прочитал конфигурационный файл `nginx.conf` внутри докер контейнера через команду `exec`

![linux_network](images/21.png)

- Создал на локальной машине файл `nginx.conf`
- Настроил в нем по пути `/status` отдачу страницы статуса сервера `nginx`

![linux_network](images/22.png)

- Скопировал созданный файл `nginx.conf` внутрь докер образа через команду `docker cp`

![linux_network](images/23.png)

- Перезапустил `nginx` внутри докер образа через команду exec

![linux_network](images/24.png)

- Проверил, что по адресу `localhost:80/status` отдается страничка со статусом сервера `nginx`

![linux_network](images/25.png)

- Экспортировал контейнер в файл `container.tar` через команду export
- Остановил контейнер

![linux_network](images/26.png)

- Удалил образ через `docker rmi`, не удаляя перед этим контейнеры

![linux_network](images/27.png)

- Удалил остановленный контейнер

![linux_network](images/28.png)

- Импортировал контейнер обратно через команду `import`
- Запустил импортированный контейнер

![linux_network](images/29.png)

- Проверил, что по адресу `localhost:80/status` отдается страничка со статусом сервера nginx

![linux_network](images/30.png)

## <div id = "Часть3"></div> Часть 3. Мини веб-сервер

- Запустил доекр с портами 81, с помощью команды `run`

![linux_network](images/31.png)

- Написал мини сервер на **C** и **FastCgi** и свой **nginx.conf** 

![linux_network](images/36.png)\
![linux_network](images/37.png)

- Скопировал в docker

![linux_network](images/32.png)

- Зашёл в контейнер 

![linux_network](images/33.png)

- Запустил 

![linux_network](images/34.png)

- Проверил, что в браузере по *localhost:81* отдается написанная вами страничка

![linux_network](images/35.png)

- Положил файл `nginx.conf` по пути `04/nginx/nginx.conf`(это понадобится позже)

## <div id = "Часть4"></div> Часть 4. Свой докер

- Написал `DOCKERFILE`

![linux_network](images/46.png)

![linux_network](images/47.png)

- Собрал написанный докер образ через `docker build` при этом указав имя и проверил через `docker images`

![linux_network](images/48.png)\
![linux_network](images/49.png)

- Запустил собранный докер образ с маппингом `81` порта на `80` на локальной машине и маппингом папки `./nginx` внутрь контейнера по адресу, где лежат конфигурационные файлы `nginx'а`

![linux_network](images/410.png)

- Проверил, что по `localhost:80` доступна страничка написанного мини сервера

![linux_network](images/411.png)

- Дописал в `./nginx/nginx.conf` проксирование странички `/status`, по которой надо отдавать статус сервера `nginx`

- Перезапустил докер образ
![linux_network](images/412.png)

- Проверил, что теперь по `localhost:80/status` отдается страничка со статусом nginx

![linux_network](images/413.png)


## <div id = "Часть5"></div> Часть 5. Dockle

- Просканировал образ из предыдущего задания через `dockle [image_id|repository]`

![linux_network](images/51.png)

- Исправил образ так, чтобы при проверке через `dockle` не было ошибок и предупреждений

![linux_network](images/50.png)

## <div id = "Часть6"></div> Часть 6. Базовый Docker Compose

- Написал файл docker-compose.yml

![linux_network](images/61.png)

- Внёс изменения 

![linux_network](images/63.png)\
![linux_network](images/65.png)

- Собрал и запустил проект с помощью команд `docker-compose build` и `docker-compose up`

![linux_network](images/62.png)\
![linux_network](images/64.png)

- Проверил, что в браузере по localhost:80 отдается написанная вами страничка, как и ранее

![linux_network](images/411.png)