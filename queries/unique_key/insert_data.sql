INSERT INTO unique_key_table (id)
SELECT gen.n + 1
FROM generator_64k gen;
