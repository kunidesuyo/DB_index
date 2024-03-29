CREATE TABLE IF NOT EXISTS UNIQUE_KEY_TABLE (
   ID INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
   NUM INT NOT NULL UNIQUE,
   COL INT NOT NULL
);

DELETE FROM UNIQUE_KEY_TABLE;

INSERT INTO UNIQUE_KEY_TABLE (NUM, COL)
SELECT gen.n + 1,
gen.n + 1
FROM generator_64k gen;
