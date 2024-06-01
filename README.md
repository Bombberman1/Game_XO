# Курсова робота з дисципліни "Мікроконтролери частина 1"

## Виконав: Павлюк Олег Ігорович (Група ІР-23)

### Гра "Хрестики - Нулики"

Гра на мікроконтролері використовуючи 1 чи 2 клавіатури, блютуз модуль HC-05 та екран 20*4 для налаштувань гри.
При режимі гри "Bluetooth" потрібно відкрити Android додаток на телефоні, дані передаються з телефона на МК через Bluetooth, у інших режимах працює виключно МК.
Мобільний додаток зроблений на Flutter, та вимагає доступу до Bluetooth та GPS для взаємодії з МК.
Дані з МК передаються через COM Port на Java Spring back-end.
Використовуючи мій стиль, дані прочитуються та обробляються, далі передаються до MySQL бази даних, чи залишаються для фронт-енду.
Фронт-енд реалізовано за допомогою React, з інтервалом 0,5 секунд відправляються GET запити на бек-енд, для перевірки, чи є запущена зараз якась гра, також є і запити для перевірки історії ігор, вичитаної з БД.
На МК доступні 2 режими гри: з ботом, чи з іншим гравцем, чи з іншим гравцем по блютузу, усі налаштування виконуються виключно лівою клавіатурою, і виключно в режимі "Settings"

[Android App](https://drive.google.com/file/d/1xK3PM92s7sBCr5x4YHtImpbkebPvNYoZ/view?usp=sharing)
