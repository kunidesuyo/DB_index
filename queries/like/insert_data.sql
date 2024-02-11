INSERT INTO like_table (id, str)
SELECT gen.n + 1,
GROUP_CONCAT(CHAR((RAND() * 25)+97) SEPARATOR '')
FROM generator_64k gen, generator_16 rand
GROUP BY gen.n;


UPDATE like_table 
   SET str = 'abcdef'
 WHERE id=1;
