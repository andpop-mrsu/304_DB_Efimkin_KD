#!/bin/bash
chcp 65001

sqlite3 movies_rating.db < db_init.sql

echo "1. Найти все пары пользователей, оценивших один и тот же фильм. Устранить дубликаты, проверить отсутствие пар с самим собой. Для каждой пары должны быть указаны имена пользователей и название фильма, который они оценили. В списке оставить первые 100 записей."
sqlite3 movies_rating.db -box -echo "SELECT DISTINCT u1.name AS first_user, u2.name AS second_user, m.title AS movie_title FROM ratings r1 JOIN ratings r2 ON r1.movie_id = r2.movie_id AND r1.user_id < r2.user_id JOIN users u1 ON r1.user_id = u1.id JOIN users u2 ON r2.user_id = u2.id JOIN movies m ON r1.movie_id = m.id ORDER BY first_user, second_user, movie_title LIMIT 100;"
echo " "

echo "2. Найти 10 самых свежих оценок от разных пользователей, вывести названия фильмов, имена пользователей, оценку, дату отзыва в формате ГГГГ-ММ-ДД."
sqlite3 movies_rating.db -box -echo "SELECT movie_title, user_name, rating, review_date FROM (SELECT m.title AS movie_title, u.name AS user_name, r.rating, date(r.timestamp, 'unixepoch') AS review_date, ROW_NUMBER() OVER (PARTITION BY r.user_id ORDER BY r.timestamp DESC) AS row_num, r.timestamp FROM ratings r JOIN users u ON r.user_id = u.id JOIN movies m ON r.movie_id = m.id) sub WHERE row_num = 1 ORDER BY timestamp DESC LIMIT 10;"
echo " "

echo "3. Вывести в одном списке все фильмы с максимальным средним рейтингом и все фильмы с минимальным средним рейтингом. Общий список отсортировать по году выпуска и названию фильма. В зависимости от рейтинга в колонке \"Рекомендуем\" для фильмов должно быть написано \"Да\" или \"Нет\"."
sqlite3 movies_rating.db -box -echo "WITH avg_scores AS (SELECT movie_id, AVG(rating) AS score FROM ratings GROUP BY movie_id) SELECT m.title, m.year, s.score AS avg_rating, CASE WHEN s.score = (SELECT MAX(score) FROM avg_scores) THEN 'Да' ELSE 'Нет' END AS 'Рекомендуем' FROM movies m JOIN avg_scores s ON m.id = s.movie_id WHERE s.score = (SELECT MAX(score) FROM avg_scores) OR s.score = (SELECT MIN(score) FROM avg_scores) ORDER BY m.year ASC, m.title ASC;"
echo " "

echo "4. Вычислить количество оценок и среднюю оценку, которую дали фильмам пользователи-женщины в период с 2010 по 2012 год."
sqlite3 movies_rating.db -box -echo "SELECT COUNT(r.id) AS ratings_count, ROUND(AVG(r.rating), 4) AS average_rating FROM ratings r JOIN users u ON r.user_id = u.id WHERE u.gender = 'female' AND date(r.timestamp, 'unixepoch') >= '2010-01-01' AND date(r.timestamp, 'unixepoch') <= '2012-12-31';"
echo " "

echo "5. Составить список фильмов с указанием их средней оценки и места в рейтинге по средней оценке. Полученный список отсортировать по году выпуска и названиям фильмов. В списке оставить первые 20 записей."
sqlite3 movies_rating.db -box -echo "WITH ratings_summary AS (SELECT m.id, m.title, m.year, AVG(r.rating) AS avg_rating FROM movies m JOIN ratings r ON m.id = r.movie_id GROUP BY m.id, m.title, m.year) SELECT title, year, avg_rating, RANK() OVER (ORDER BY avg_rating DESC) AS rating_place FROM ratings_summary ORDER BY year ASC, title ASC LIMIT 20;"
echo " "

echo "6. Вывести список из 10 последних зарегистрированных пользователей в формате \"Фамилия Имя|Дата регистрации\" (сначала фамилия, потом имя)."
sqlite3 movies_rating.db -box -echo "SELECT SUBSTR(name, INSTR(name, ' ') + 1) || ' ' || SUBSTR(name, 1, INSTR(name, ' ') - 1) || '|' || register_date AS user_entry FROM users ORDER BY register_date DESC LIMIT 10;"
echo " "

echo "7. С помощью рекурсивного CTE составить таблицу умножения для чисел от 1 до 10."
sqlite3 movies_rating.db -box -echo "WITH RECURSIVE times_table(x, y) AS (SELECT 1, 1 UNION ALL SELECT CASE WHEN y = 10 THEN x + 1 ELSE x END, CASE WHEN y = 10 THEN 1 ELSE y + 1 END FROM times_table WHERE x < 10 OR (x = 10 AND y < 10)) SELECT x || 'x' || y || '=' || (x * y) AS multiplication_table FROM times_table;"
echo " "

echo "8. С помощью рекурсивного CTE выделить все жанры фильмов, имеющиеся в таблице movies (каждый жанр в отдельной строке)."
sqlite3 movies_rating.db -box -echo "WITH RECURSIVE genre_split(movie_id, genre_name, remaining) AS (SELECT id, '', genres || '|' FROM movies UNION ALL SELECT movie_id, SUBSTR(remaining, 1, INSTR(remaining, '|') - 1), SUBSTR(remaining, INSTR(remaining, '|') + 1) FROM genre_split WHERE remaining <> '') SELECT DISTINCT genre_name AS genre FROM genre_split WHERE genre_name <> '' ORDER BY genre;"
echo " "
