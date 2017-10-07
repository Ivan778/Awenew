# Требования к проекту

# 1 Введение

Цель разработки - приложение для мобильных устройств под управлением операционной системы iOS, которое предоставляет следующие возможности:
- определение вашего местоположения и реверс геокодинг (вывод вашего адреса по долготе и широте);
- вывод погоды в соответствие с вашим местоположением;
- поиск погоды в других городах;
- просмотр прогноза погоды;
- подборка новостей в соответствии с вашим городом/страной;
- сохранение информации о погоде в тот момент, когда вы открыли приложение и возможность её просмотра.

# 2 Требования пользователя
### 2.1 Программные интерфейсы

Приложение будет написано на языке Swift в Xcode 8 с использованием Google API (для реверс-геокодинга, т.к. нативный геокодинг работает не для всех стран), OpenWeatherMap API (получение данных о погоде) и BBC News API (получение новостей).

### 2.2 Интерфейс пользователя

Данный проект является продолжением уже существующей версии. Ниже представлен интерфейс на данный момент:

Главный экран
![Alt text](AppScreenShots/MainScreen.png "Главный экран")

Экран с историей просмотра погоды
![Alt text](AppScreenShots/HistoryScreen.png "История использования приложения")

Открытая история просмотра
![Alt text](AppScreenShots/OpenedHistory.png "Просмотр истории")



### 2.3 Характеристика пользователей

Целевая аудитория приложения - любые пользователи, интересующиеся погодой и новостями.
Минимальный необходимый навык - умение использовать устройство под управлением iOS.

### 2.4 Предположения и зависимости

Для использования приложения необходимо соединение с интернетом. В случае его отсутствия будет доступна только ваша история погоды.

# 3 Системные требования

Любое устройство под управлением iOS 9.3.x и выше.

### 3.1 Функциональные требования
