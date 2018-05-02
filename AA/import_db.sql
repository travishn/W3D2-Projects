-- PRAGMA foreign_keys = ON;
-- DROP TABLE IF EXISTS

CREATE TABLE users (
  id INTEGER PRIMARY KEY,
  fname VARCHAR(255) NOT NULL,
  lname VARCHAR(255) NOT NULL
);

CREATE TABLE questions (
  id INTEGER PRIMARY KEY,
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  author_id INTEGER NOT NULL,
  
  FOREIGN KEY (author_id) REFERENCES users(id)
);

CREATE TABLE question_follows (
  id INTEGER PRIMARY KEY,
  user_id INTEGER,
  question_id INTEGER,
  follows INTEGER,
  
  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (question_id) REFERENCES questions(id)
);

CREATE TABLE replies (
  id INTEGER PRIMARY KEY,
  question_id INTEGER,
  parent_id INTEGER NULL, 
  user_id INTEGER, 
  body TEXT NOT NULL,
  
  FOREIGN KEY (parent_id) REFERENCES replies(id),
  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (question_id) REFERENCES questions(id)
  
);

CREATE TABLE question_likes (
  id INTEGER PRIMARY KEY,
  user_id INTEGER,
  question_id INTEGER,
  
  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (question_id) REFERENCES questions(id)
);



INSERT INTO 
  question_follows(user_id, question_id)
VALUES
  (2, 1);




INSERT INTO 
  users(fname, lname)
VALUES
  ('Melissa', 'Ho'),
  ('Travis', 'Nguyen');
  
INSERT INTO
  questions(title, body, author_id)
VALUES 
  ('How to SQL101', 'What are the correct keys', 1);

INSERT INTO 
  question_follows(user_id, question_id)
VALUES 
  (1, 1);
  

INSERT INTO 
replies(question_id, parent_id, user_id, body)
VALUES
(1, 3, 1, "the keys are green");

INSERT INTO
  question_likes(question_id, user_id)
VALUES
  (1, 1),
  (1, 2);








