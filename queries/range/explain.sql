EXPLAIN SELECT * FROM RANGE_TABLE WHERE NUM1 <= 100;
EXPLAIN SELECT * FROM RANGE_TABLE WHERE NUM1 >= 65500;
EXPLAIN SELECT * FROM RANGE_TABLE WHERE NUM1 BETWEEN 100 AND 200;

EXPLAIN SELECT * FROM RANGE_TABLE WHERE NUM2 <= 100;
EXPLAIN SELECT * FROM RANGE_TABLE WHERE NUM2 >= 65500;
EXPLAIN SELECT * FROM RANGE_TABLE WHERE NUM2 BETWEEN 100 AND 200;
