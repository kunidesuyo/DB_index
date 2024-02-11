INSERT INTO multi_column_index (id1, id2, id3)
SELECT gen.n + 1,
gen.n + 2,
gen.n + 3
FROM generator_1m gen;
