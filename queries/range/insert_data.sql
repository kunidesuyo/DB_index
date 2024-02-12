INSERT INTO RANGE_TABLE (NUM1, NUM2)
SELECT gen.n + 1,
gen.n + 1
FROM generator_64k gen;
