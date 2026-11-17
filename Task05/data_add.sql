PRAGMA foreign_keys = ON;

BEGIN TRANSACTION;

INSERT INTO users (first_name, last_name, email, gender, occupation_id) VALUES
    ('Кирилл', 'Ефимкин',  'kirill.efimkin@mrsu.ru', 'male', (SELECT id FROM occupations WHERE name = 'student')),
    ('Егор',   'Тужилкин', 'egor.tuzhilkin@mrsu.ru', 'male', (SELECT id FROM occupations WHERE name = 'student')),
    ('Илья',   'Куликов',  'ilya.kulikov@mrsu.ru',   'male', (SELECT id FROM occupations WHERE name = 'student')),
    ('Иван',   'Кряжев',   'ivan.kryazhev@mrsu.ru',  'male', (SELECT id FROM occupations WHERE name = 'student')),
    ('Илья',   'Арискин',  'ilya.ariskin@mrsu.ru',   'male', (SELECT id FROM occupations WHERE name = 'student'));

INSERT INTO movies (title, year) VALUES
    ('Knives Out', 2019),
    ('Green Book', 2018),
    ('Spider-Man: Into the Spider-Verse', 2018);

INSERT INTO movie_genres (movie_id, genre_id) VALUES
    ((SELECT id FROM movies WHERE title = 'Knives Out'), (SELECT id FROM genres WHERE name = 'Crime')),
    ((SELECT id FROM movies WHERE title = 'Green Book'), (SELECT id FROM genres WHERE name = 'Comedy')),
    ((SELECT id FROM movies WHERE title = 'Spider-Man: Into the Spider-Verse'), (SELECT id FROM genres WHERE name = 'Animation'));

INSERT INTO ratings (user_id, movie_id, rating) VALUES
    ((SELECT id FROM users WHERE email = 'kirill.efimkin@mrsu.ru'), (SELECT id FROM movies WHERE title = 'Knives Out'), 4.0),
    ((SELECT id FROM users WHERE email = 'kirill.efimkin@mrsu.ru'), (SELECT id FROM movies WHERE title = 'Green Book'), 5.0),
    ((SELECT id FROM users WHERE email = 'kirill.efimkin@mrsu.ru'), (SELECT id FROM movies WHERE title = 'Spider-Man: Into the Spider-Verse'), 4.5);

COMMIT;
