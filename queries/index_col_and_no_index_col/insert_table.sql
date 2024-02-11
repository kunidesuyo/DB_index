INSERT INTO index_col_and_no_index_col (id, num)
SELECT 1,
gen.n + 1
FROM generator_1m gen;
