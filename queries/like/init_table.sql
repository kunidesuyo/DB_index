create table generator_char(str varchar(10));
insert into generator_char values('A');
insert into generator_char values('B');
insert into generator_char values('C');
insert into generator_char values('D');
insert into generator_char values('E');
insert into generator_char values('F');
insert into generator_char values('G');
insert into generator_char values('H');
insert into generator_char values('I');
insert into generator_char values('J');

CREATE TABLE IF NOT EXISTS LIKE_TABLE (
   ID INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
   STR VARCHAR(10) NOT NULL,
   COL INT NOT NULL
);

CREATE INDEX LIKE_INDEX on LIKE_TABLE(STR);

DELETE FROM LIKE_TABLE;

INSERT INTO LIKE_TABLE(STR, COL)
SELECT CONCAT(t1.STR, t2.STR, t3.STR, t4.STR, t5.STR) 'STR',
1
FROM generator_char t1, generator_char t2, generator_char t3, generator_char t4, generator_char t5;