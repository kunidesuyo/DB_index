insert into like_table(str)
select concat(t1.str, t2.str, t3.str, t4.str, t5.str) 'str' 
from generator_char t1, generator_char t2, generator_char t3, generator_char t4, generator_char t5;
