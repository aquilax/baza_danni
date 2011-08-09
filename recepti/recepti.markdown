## Приоритизиране на резултатите от UNION

Има случаи в които трябва да използваме UNION за да обединим резултатите от няколко заявки. Подобен пример е търсене на текст в няколко таблици примерно:

~~~ {.sql}
SELECT id, name FROM table1 WHERE name LIKE "%search%"
UNION
SELECT id, name FROM table2 WHERE name LIKE "%search%"
UNION
SELECT id, name FROM table3 WHERE name LIKE "%search%"
~~~

В общия случай данните, които ще получим ще са подредени в реда, в който сме подредили заявките но това не е гарантирано. Ако искаме да върнем резултатите в ред според таблицата, от която са, можем да използваме следния трик:

~~~ {.sql}
SELECT id, name FROM (
  SELECT id, name, 1 AS ordr FROM table1 WHERE name LIKE "%search%"
  UNION
  SELECT id, name, 3 AS ordr FROM table2 WHERE name LIKE "%search%"
  UNION
  SELECT id, name, 2 AS ordr FROM table3 WHERE name LIKE "%search%"
) AS t 
ORDER BY ordr;
~~~

Добавяме една "фалшива" колона в резултата, която използваме във външната заявка за сортиране. В случая резултатите ще се подредят в реда първа, трета, втора таблица.

## Частично възстановяване на данни от архив

Понякога се случва да напишем заявка от рода на:

~~~ {.sql}
UPDATE posts 
SET user_id=1;
~~~

докато всъщност искаме да кажем:

~~~ {.sql}
UPDATE posts 
SET user_id=1
WHERE id = 155633;
~~~

В такива случаи се налага да възстановим данните от архив но докато се ровим из архивите на базата в таблицата продължават да се трупат записи, които са верни. Целта ни е да възстановим колоната **user_id** в таблица **user** от архивно копие.

Първо възстановяваме таблицата от архива с ново име, примерно **user_bak** и наливаме архивните данни.
Остава само да обновим колоната със следната заявка:

~~~ {.sql}
UPDATE 
user u, user_bak ub
SET u.user_id = ub.user_id
WHERE u.id = ub.id
~~~

Накрая изтриваме архивната таблица:

~~~ {.sql}
DROP TABLE user_bak;
~~~

и отиваме да си премерим пулса.


## Тагове

Класификацията с тагове е удобна в случаите, когато един елемент се определя от повече от една характеристики. Реализацията (обикновено) е следната:

~~~ {.sql}
CREATE TABLE entry(
  id integer NOT NULL AUTO_INCREMENT,
  entry_name VARCHAR(15),
  PRIMARY KEY (id)
);

CREATE TABLE tag(
  id integer NOT NULL AUTO_INCREMENT,
  tag_name VARCHAR(10),
  PRIMARY KEY (id)
);

CREATE TABLE entry_tag(
  entry_id INTEGER NOT NULL,
  tag_id INTEGER NOT NULL
);
~~~

Да добавим и уникален индекс за entry_tag за да няма дублиране на думи за един и същ елемент както и на tag.name за да не се дублират самите ключови думи:

~~~ {.sql}
CREATE UNIQUE INDEX entry_tag_uniq
  ON entry_tag (entry_id, tag_id);
CREATE UNIQUE INDEX tag_uniq
  ON tag (tag_name);
~~~


Малко тестови данни:

~~~ {.sql}
INSERT INTO entry VALUES (NULL, "круша"), (NULL, "ябълка"), (NULL, "репичка"), (NULL, "зеле");
INSERT INTO tag  VALUES (NULL, "плод"), (NULL, "зеленчук"), (NULL, "червено"), (NULL, "зелено"), (NULL, "жълто");
~~~

И резултатът:

    SELECT * FROM tag;
    +----+------------------+
    | id | tag_name         |
    +----+------------------+
    |  1 | плод             |
    |  2 | зеленчук         |
    |  3 | червено          |
    |  4 | зелено           |
    |  5 | жълто            |
    +----+------------------+

    SELECT * FROM entry;
    +----+----------------+
    | id | entry_name     |
    +----+----------------+
    |  1 | круша          |
    |  2 | ябълка         |
    |  3 | репичка        |
    |  4 | зеле           |
    +----+----------------+

### Закачане на елемент към ключова дума

Примерно искаме да изкажем следните твърдения:

~~~ {.sql}
INSERT INTO entry_tag VALUES (2, 1), (2, 3); /* ябълката е червена */
INSERT INTO entry_tag VALUES (1, 1), (1, 5); /* крушата е плод и е жълта */
INSERT INTO entry_tag VALUES (3, 2), (3, 3); /* репичката е зеленчук и е червена */
INSERT INTO entry_tag VALUES (4, 2), (4, 4); /* зелето е зеленчук и е зелено*/
~~~

И изпълненият с числа резултат:

    SELECT * FROM entry_tag;
    +----------+--------+
    | entry_id | tag_id |
    +----------+--------+
    |        1 |      1 |
    |        1 |      5 |
    |        2 |      1 |
    |        2 |      3 |
    |        3 |      2 |
    |        3 |      3 |
    |        4 |      2 |
    |        4 |      4 |
    +----------+--------+

Всичко това е много хубаво но не казва нищо за зелето и крушите на случайните минувачи.

### Ключови думи към елемент

Да видим какво знаем за крушата (entry.id = 1)

~~~ {.sql}
SELECT tag_name 
FROM entry_tag et 
JOIN tag t ON t.id = et.tag_id 
WHERE et.entry_id = 1;
~~~

+------------+
| tag_name   |
+------------+
| плод       |
| жълто      |
+------------+

### Елементи и ключови думи към тях

В случая за MySQL заявката изглежда така:

~~~ {.sql}
SELECT e.entry_name, GROUP_CONCAT(t.tag_name) AS tags
FROM entry e
JOIN entry_tag et ON e.id = et.entry_id
JOIN tag t ON t.id = et.tag_id
GROUP BY e.entry_name
ORDER BY e.entry_name
~~~

и резултатът е:

    +----------------+---------------------------------+
    | entry_name     | tags                            |
    +----------------+---------------------------------+
    | зеле           | зеленчук,зелено                 |
    | круша          | плод,жълто                      |
    | репичка        | зеленчук,червено                |
    | ябълка         | плод,червено                    |
    +----------------+---------------------------------+

В PostgreSQL **GROUP_CONCAT** може да се замести с **array_to_string(array_agg(arr), ',')** или да си напишете собствена версия на функцията;

### Елементи по ключова дума

Това е лесно. Примерно всичко червено:

~~~ {.sql}
SELECT e.entry_name 
FROM entry_tag et
JOIN entry e ON e.id = et.entry_id
WHERE et.tag_id = 3;
~~~

    +----------------+
    | entry_name     |
    +----------------+
    | ябълка         |
    | репичка        |
    +----------------+

### Брой елементи за ключова дума

~~~ {.sql}
SELECT t.tag_name, count(*) AS cntr
FROM tag t
JOIN entry_tag et ON et.tag_id = t.id
GROUP BY t.tag_name
ORDER BY t.tag_name;
~~~

    +------------------+------+
    | tag_name         | cntr |
    +------------------+------+
    | жълто            |    1 |
    | зелено           |    1 |
    | зеленчук         |    2 |
    | плод             |    2 |
    | червено          |    2 |
    +------------------+------+

### Несвързани ключови думи

Да добавим несвързана ключова дума:

~~~ {.sql}
INSERT INTO tag VALUES (NULL, "локомотив");
~~~

Случва се ключови думи да останат несвързани към елементи. Ако искаме да разберем кои са те можем да използваме следната заявка:

~~~ {.sql}
SELECT tag_name
FROM tag t
LEFT JOIN entry_tag et ON t.id = et.tag_id
WHERE et.tag_id IS NULL
~~~

    +--------------------+
    | tag_name           |
    +--------------------+
    | локомотив          |
    +--------------------+


