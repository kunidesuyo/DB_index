EXPLAIN SELECT * FROM multi_column_index WHERE id1 = 1;
EXPLAIN SELECT * FROM multi_column_index WHERE id1 = 1 AND id2 = 1;
EXPLAIN SELECT * FROM multi_column_index WHERE id1 = 1 AND id2 = 1 AND id3 = 1;
EXPLAIN SELECT * FROM multi_column_index WHERE id2 = 1;
EXPLAIN SELECT * FROM multi_column_index WHERE id3 = 1;