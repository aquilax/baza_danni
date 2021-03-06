% Практическо ръководство по управление на бази данни
% http://plus.google.com/103587746021296602888
% 2011-08-07

Свободно ръководство с отворен код. Оригиналът можете да откриете на адрес: <https://github.com/aquilax/baza_danni>

Автор [aquilax+](https://plus.google.com/103587746021296602888?rel=author)

# Лицензна информация

<a rel="license" href="http://creativecommons.org/licenses/by-nc-sa/2.5/bg/"><img alt="Криейтив Комънс договор" style="border-width:0" src="http://i.creativecommons.org/l/by-nc-sa/2.5/bg/88x31.png" /></a><br />Произведението <span xmlns:dct="http://purl.org/dc/terms/" href="http://purl.org/dc/dcmitype/Text" property="dct:title" rel="dct:type">Практическо ръководство по управление на бази данни</span> създадено от <a xmlns:cc="http://creativecommons.org/ns#" href="http://bazadanni.com/" property="cc:attributionName" rel="cc:attributionURL">aquilax</a> ползва <a rel="license" href="http://creativecommons.org/licenses/by-nc-sa/2.5/bg/">Криейтив Комънс Признание-Некомерсиално-Споделяне на споделеното 2.5 България договор</a>.<br />Базирано на следната творба:<a xmlns:dct="http://purl.org/dc/terms/" href="http://bazadanni.com/book/" rel="dct:source">bazadanni.com</a>.


# Увод

През последните десетина години ми се е налагало да използвам няколко системи за управление на бази от данни (Paradox, dBase, MS Access, Excel, MS SQL, MySQL, Memcache, App Engine datastore, SQLite, PostreSQL дори малко Oracle). Всяка система си има своите особености и приложение но общото между тях е че улесняват работата с данни.

Една от основните задачи на програмирането е именно обработката на данни. Затова реших да събера кратко практическо ръководство за работа с база данни. По голямата част от проектите, върху които работя, са интерфейс към някакви данни.

# Общо за релационните бази данни

Релационните бази данни носят това име заради връзките между елементите им, които ги правят истински полезни.

## Атом

Атомът е най-малката неделима единица данни с която можем да работи. Примери за атоми са: 1, 123, А, София, Иван Петров.

## Поле

Поле е мястото, където се съхраняват атомите. Полето обикновено има тип, който определя какви данни могат да се съхраняват в него. Основните типове данни на полета са:

**INTEGER** - цели числа;

Целите числа могат да са със знак или без знак. Числата без знак могат да са само положителни но затова пък горната им граница е 2 пъти по висока от аналогичните числа със знак; Примери за цели числа: 1, 100, -23, 33222;

  **FLOAT** - числа с плаваща запетая (или дробни числа);

Числата със плаваща запетая са удобни за представяне на десетични дроби. **ВНИМАНИЕ!**: Въпреки че числата с плаваща запетая изглеждат удобни за работа с пари, избягвайте тази употреба. Точността на операциите с числа с плаваща запетая не е гарантирана а това може да ви докара много главоболия. Практиката е за пари да се използват цели числа (които да се интерпретират като такива с фиксирана точка), иначе казано вместо да записвате 2.15 за сумата от 2 лева и 15 стотинки, използвайте цяло число и запишете 215 стотинки.

Примери за числа с плаваща запетая са: 1.00, 3.145, 8.22 (забележете че десетичната запетая се изписва като точка, въпреки че по БДС десетичният разделител в България е символа за запетая);

  **CHAR** - текст с фиксирана дължина

Текста с фиксирана широчина е такъв на който знаете предварително дължината. 

Примери за такива полета са MD5 сумите, Единния граждански номер, данъчния номер;

Принципно полетата с фиксирана широчина се управляват по-ефективно от СУБД, отколкото тези с променлива дължина. Все пак не прекалявайте. Приложението на фиксираната дължина е ограничено.
 
  **VARCHAR** - текст с променлива дължина;
  
Най-често използвания тип за съхранение на текстови данни. Полето с променлива дължина има размер, който указва максималния размер на текста, който може да се събере в него. Ще се запитате тогава какво му е променливото на това поле. Променлива е дължината, която СУБД заделя за данните при физическия запис.

  **TEXT** - дълъг текст;

Текстовото поле се използва за съхранение на голямо количество текст. Казвам голямо а не неограничено количество, защото обикновено има ограничение за максималния размер на текста и то зависи от конкретната база. Текстовото поле често се нарича текстов блоб (blob = BLOB binary large object). Разликата с CHAR и VARCHAR полетата е че текстовите полета обикновено се съхраняват във физически отделни файлове и не поддържат всички функции за обработка т.е. най-често се извличат и съхраняват като цели обекти.
  
  **DATE** - дата;
  
Поле за дата. Различните СУБД го интерпретират по различен начин (примерно MS SQL и MS Access според регионалните настройки, докато PostgreSQL използва японския запис YYYY-MM-DD).

  **TIMESTAMP** - дата и час;

Поле за време час (включително и милисекунди понякога). Много полезен тип, обикновено се използва за означаване на момент на добавяне или промяна на запис. Обикновено се преобразува лесно до Unix timestamp, който е удобен за програмна обработка.

>  Различните СУБД (Система за управление на база данни) поддържат много повече типове данни. Някой от тях екзотични но безспорно полезни. Примерно масиви, координати, IP адреси и.т.н. Тези допълнителни типове и прилежащите функции за работа с тях могат да се окажат решаващ фактор при избора на система.

## Колона

Колона в теорията на БД е поредица поредица от един тип поле. Можете да си го представите като колона в Excel. Колоната съдържа един тип данни, като типа се определя от типа на полето.

## Ред

Ред или също така запис е поредица от различни типове полета със стойностите им. Например "Иван Петров, София, 02 222 222 22" е ред за лицето Иван Пертов, живущ в София с телефонен номер, 02 222 222 22. Този ред се състои от три полета: име, град, телефонен номер.

## Таблица

Таблица е списък от редове с една и съща структура обединени в таблица. Ако използваме аналогията с Excel, таблицата е един лист от електронната таблица. Таблицата е основна функционална единица в релационните бази данни.

## База данни

Логическата съвкупност от таблици се организира в база данни. Обикновено таблиците в една БД имат пряка или косвена връзка помежду си макар че това не е задължително. Базата данни е пясъчникът, където строите замъците си и се борите за чисти и точни данни. Базата може да е изолирана или да ви позволява достъп и до други бази в зависимост от СУБД.


# SQL

SQL е един от най-широко използваните езици. Това не е толкова учудващо, тъй като SQL е сравнително лесен. Основната му функционалност се реализира от четири команди, като в болшинството от случаите се използва една от тях: SELECT. Синтаксиса на SQL варира в различните БД но основата му е стандартизирана, при това цели седем пъти досега. SQL командите завършват със символа ";".

## CREATE

CREATE е командата за създаване на обекти в SQL. Обектите най-често са таблици но могат да бъдат сторнати процедури (stored procedure), вюта (view), тригери, генератори и.т.н. Създаване на таблица:

~~~ {.sql}
CREATE TABLE table_name (
  field1_name field1_type,
  field2_name field2_type
);
~~~

Този израз създава таблица **table_name** със две колони: **field1_name** от тип **field1_type** и **field2_name** от тип **field2_type**.

Малко по-реален пример:


~~~ {.sql}
CREATE TABLE user (
  id integer,
  username varchar(30),
);
~~~


## DROP

DROP унищожава обект а синтаксисът му е обезпокоително прост:

~~~ {.sql}
DROP TABLE user;
~~~

Командата унищожава таблица **user** и ви дава пълно право да започнете да се тревожите за архивиране не данните.

## INSERT

INSERT е командата с най-лошият синтаксис в SQL а той е:

~~~ {.sql}
INSERT INTO user (id, name) VALUES (1, "aquilax");
~~~

Виждате ли къде е проблема? имената на колоните и техните стойности са в различни списъци. Това не е такъв проблем в "тесни" таблици но ако имате над 5 колони и някой от тях са текстови, ще усетите неудобството в пълната му сила. Разбира се това се проявява само когато, пишете заявките си сами. 

MySQL предлага следния удобен синтаксис за INSERT:

~~~ {.sql}
INSERT INTO user SET id = 1, name = "aquilax";
~~~~

За съжаление този синтаксис не е стандартен и доколкото знам другите СУБД не го поддържат.

# NoSQL
