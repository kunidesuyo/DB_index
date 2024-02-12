INSERT INTO order_by_table (id1, id2)
SELECT (gen.n + 1) / 1000,
(gen.n + 1) % 1000
FROM generator_64k gen;
