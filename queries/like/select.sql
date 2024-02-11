EXPLAIN SELECT * FROM like_table WHERE str LIKE 'abc%';
EXPLAIN SELECT * FROM like_table WHERE str LIKE '%abc';
EXPLAIN SELECT * FROM like_table WHERE str LIKE '%abc%';
