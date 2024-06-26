# Case-study оптимизации

## Актуальная проблема

В нашем проекте возникла серьёзная проблема.

Необходимо было обработать файл с данными, чуть больше ста мегабайт.

У нас уже была программа на `ruby`, которая умела делать нужную обработку.

Она успешно работала на файлах размером пару мегабайт, но для большого файла она работала слишком долго, и не было понятно, закончит ли она вообще работу за какое-то разумное время.

Я решил исправить эту проблему, оптимизировав эту программу.

## Формирование метрики

Для того, чтобы понимать, дают ли мои изменения положительный эффект на быстродействие программы я придумал использовать такую метрику: скорость исполнения программы на 4000 тысячах строк должна укладываться в заданный временной интервал.

## Гарантия корректности работы оптимизированной программы

Программа поставлялась с тестом. Выполнение этого теста в фидбек-лупе позволяет не допустить изменения логики программы при оптимизации.

## Feedback-Loop

Для того, чтобы иметь возможность быстро проверять гипотезы я выстроил эффективный `feedback-loop`, который позволил мне получать обратную связь по эффективности сделанных изменений за _время, которое у вас получилось_

Вот как я построил `feedback_loop`:
Изначальный код отметил как начальный и определил перфоманс для 4000 строк
Последующие итерации помещены в версии и для каждой из версий определен прирост производительности на основе тестовю

## Вникаем в детали системы, чтобы найти главные точки роста

Для того, чтобы найти "точки роста" для оптимизации я воспользовался профилированием программы

Вот какие проблемы удалось найти и решить

### Ваша находка №1

- флейм граф показал, что Array#select занимает значительное время исполнения
- Array#select происводит поиск по всему массиву сессий и это занимает много времени. Для ускорения поиска, я изменил структуру оранизации сессий и в реализации V1 сессии сгруппированы по user_id в хеш. Таким образом, используются оптимизированный механизмы поиска ruby и достигается прирост происховодительности
- Скрость выполнения увеличина в 4 раза для 4000 строк
- исправленная проблема перестала быть точкой роста

### Ваша находка №2

- флейм граф показал, что Array#+ занимает значительное время исполнения
- На основе https://github.com/fastruby/fast-ruby?tab=readme-ov-file#arrayconcat-vs-array-code Array#+ можно заменить на Array#concat
- Замена Array#+ на Array#concat дала прирост как минимум 10% на 4000 строк
- исправленная проблема перестала быть точкой роста и следует увеличить количство строк

### Ваша находка №3

- флейм граф показал, что метод String#split и Date#parse занимает значительное время
- Заменил String#split на String#match и убрал Date#parse
- Указанные изменения повысили производительность на 40% на файле 30 000 строк

### Ваша находка №4

- флейм граф показал, что поиск уникальных браузеров занимает значительное время
- Рефакторинг вычисления сессий как в находке 1
- Указанные изменения повысили производительность на 50% на файле 30 000 строк

### Ваша находка №5

- общий рефакторинг кода 
- Вызов upcase во время парсинга(а не несколько раз), эмуляция метода any? c break и др 
- Указанные изменения не повлияли значительно на производительность

## Результаты

В результате проделанной оптимизации наконец удалось обработать файл с данными.
Удалось улучшить метрику системы с того, что нельзя дождать окончания результата обработки, до того, что получилось уложиться в выполнению программы в заданный бюджет 30 секунд.
Измеренный прирост производительности составил 33 раз для обработки файла в 10 000 строк

Заданный бюджет выполнения программы в 30 секунд был достигнут на M1


## Защита от регрессии производительности

Для защиты от потери достигнутого прогресса при дальнейших изменениях программы написаны тесты производительности.
