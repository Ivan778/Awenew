# Требования к проекту

# 1 Введение

Цель разработки - приложение для мобильных устройств под управлением операционной системы iOS, которое предоставляет следующие возможности:
- Определение вашего местоположения и реверс геокодинг (вывод вашего адреса по долготе и широте);
- Вывод погоды в соответствие с вашим местоположением;
- Поиск погоды в других городах;
- Просмотр прогноза погоды;
- Подборка новостей в соответствии с вашим городом/страной, а также всего мира;
- Сохранение информации о погоде в тот момент, когда вы открыли приложение и возможность её просмотра.

# 2 Требования пользователя
### 2.1 Программные интерфейсы

Приложение будет написано на языке Swift в Xcode 8 с использованием Google API (для реверс-геокодинга, т.к. нативный геокодинг работает не для всех стран), OpenWeatherMap API (получение данных о погоде) и BBC News API (получение новостей).

### 2.2 Интерфейс пользователя

Данный проект является продолжением уже существующей версии. Ниже представлен интерфейс на данный момент:

![Alt text](AppScreenShots/MainScreen.png "Главный экран")
![Alt text](AppScreenShots/HistoryScreen.png "История погоды")
![Alt text](AppScreenShots/OpenedHistory.png "Просмотр истории")

Ниже представлены скетчи обновлённого приложения:

![Alt text](AppScreenShots/WeatherSearch.png "Поиск погоды")
![Alt text](AppScreenShots/News.png "Новости")

### 2.3 Характеристика пользователей

Целевая аудитория приложения - любые пользователи, интересующиеся погодой и новостями.
Минимальный необходимый навык - умение использовать устройство под управлением iOS.

### 2.4 Предположения и зависимости

Для использования приложения необходимо соединение с интернетом. В случае его отсутствия будет доступна только ваша история погоды.

# 3 Системные требования

Любое устройство под управлением iOS 9.3.x и выше.

### 3.1 Функциональные требования

1. Возможность просмотра своего местоположения и погоды исходя из координат этого места;
2. Возможность просмотра истории с погодой и местоположением;
3. Возможность поиска погоды для любой страны и города (ограничение накладывается только самим OpenWeatherMap API);
4. Возможность просмотра последних новостей вашей страны и мира (до 10).

### 3.2 Нефункциональные требования
#### 3.2.1 Атрибуты качества
1. Последние новости. Приложение должно предоставлять доступ только к актуальным новостям;
2. Экономия заряда устройства. Т.к. GPS-навигация отнимает много энергии, необходимо обеспечить её использование только в том случае, если происходит определение местоположения.
