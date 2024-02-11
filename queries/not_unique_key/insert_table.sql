INSERT INTO not_unique_key_table (id)
SELECT (gen.n + 1) % 10000
FROM generator_64k gen;
