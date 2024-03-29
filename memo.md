# DB index
- SQL: mysql 8.0.27
- Engine: InnoDB
- INDEX: B+Tree
## インデックスの内部構造
### BTree
- Balanced Tree
  - 木構造の計算量は木の深さ(ルートノードからリーフノードまでの距離)に依存する
  - 各リーフノードに対する木の深さを同じに保ってくれる構造
  - 構造
    - ルートノード
    - ブランチノード
    - リーフノード
      - 実際の値が入っている
```mermaid
graph TB;
  subgraph root node
    a[ ];
  end
  a-->b;
  a-->c;
  subgraph branch node
    direction LR;
    b[ ];
    c[ ];
  end
  b-->d & e;
  c-->f & g;
  subgraph leaf node
    direction LR;
    d[1];
    e[2];
    f[3];
    g[4];
  end
```
- 計算量
  - 検索`log(n)`
    - ツリーの走査という
    - 例
      - 1~12の値が入ったBTreeから6を検索([B+Treeシミュレーター](https://www.cs.usfca.edu/~galles/visualization/BPlusTree.html))
![image](https://github.com/kunidesuyo/DB_index/assets/81606310/2e785dee-d90b-4dc6-8bee-62ca994778c6)
![image](https://github.com/kunidesuyo/DB_index/assets/81606310/13e99de1-0e0a-4582-89e0-1003b65025fe)
![image](https://github.com/kunidesuyo/DB_index/assets/81606310/f34aeab0-6ed0-4133-9d56-21650ddb8919)
![image](https://github.com/kunidesuyo/DB_index/assets/81606310/ec0a63b9-f1f6-48ca-abaf-fc51c3dd1240)
![image](https://github.com/kunidesuyo/DB_index/assets/81606310/83ccb374-c1f0-407c-9880-cda9033e8bb0)
![image](https://github.com/kunidesuyo/DB_index/assets/81606310/f674e926-5d98-48b0-8215-842fac48f263)


  - 挿入`log(n)`
  - 更新`log(n)`
  - 削除`log(n)`
### B+Tree
- BTreeのリーフノードを双方向連結リストにしたもの
```mermaid
graph LR;
  subgraph leaf node
    direction LR;
    a[1]<-->b[2];
    b<-->c[3];
    c<-->d[4];
  end
```
- リーフノードを辿るのをリーフノードの走査という

## MySQLでのインデックス
### クラスタインデックスとセカンダリインデックス
#### クラスタインデックス
- 主キーに作られるインデックス
- 自動的に作成される
- 例

|ID(PK)|NUM1|NUM2|
|----|----|----|
|1|1|1|
|2|2|2|
|3|3|3|
|4|4|4|

```mermaid
graph TB;
  subgraph clustered index
    direction TB;
    a[ ]-->b[ ];
    a-->c[ ];
    b-->d[PK: 1<br>NUM1: 1<br>NUM2: 1] & e[PK: 2<br>NUM1: 2<br>NUM2: 2];
    c-->f[PK: 3<br>NUM1: 3<br>NUM2: 3] & g[PK: 4<br>NUM1: 4<br>NUM2: 4];
  end
```

#### セカンダリインデックス
- ユーザーが定義するインデックス
  - `CREATE INDEX (INDEX NAME) ON (TABLE NAME)(COL1, COL2, ...)`
  - 指定したカラムの値でソートされて、リーフノードに格納される
    - 複数指定の場合、左から順番に優先順位がつく
      - COL1でソート、COL1が同じならCOL2でソート、COL2が同じなら...
- リーフノードには設定したカラムの値とPKの値が入っている
- 実データにアクセスするときはPKの値を使ってクラスタインデックスを探索する
- 例

|ID(PK)|NUM1|NUM2|NUM3|
|----|----|----|----|
|1|1|1|1|
|2|1|2|1|
|3|1|2|2|
|4|2|1|1|
|5|3|2|1|

`INDEX (NUM1, NUM2, NUM3)`

```mermaid
graph TB;
  subgraph secondary index tree
  direction TB;
  a[ ];
  b[ ];
  c[ ];
  z[ ];
  a-->b;
  a-->c;
  a-->z;
  z-->h;
  b-->d & e;
  c-->f & g;
  subgraph leaf node
    direction LR;
    h[NUM1: 1<br>NUM2: 1<br>NUM3: 1<br> PK: 1];
    d[NUM1: 1<br>NUM2: 2<br>NUM3: 1<br> PK: 2];
    e[NUM1: 1<br>NUM2: 2<br>NUM3: 2<br> PK: 3];
    f[NUM1: 2<br>NUM2: 1<br>NUM3: 1<br> PK: 4];
    g[NUM1: 3<br>NUM2: 2<br>NUM3: 1<br> PK: 5];
  end
  end
```

### 実行計画
- クエリの先頭に`explain`をつけると見ることができる
- インデックスがどのように使われたか分かる

## WHERE句
### 等価演算子
#### 単一
##### プライマリーキーでの検索(/queries/primary_key)
- クラスタインデックスツリーの走査のみ
- 一意に決まることが保証されているのでリーフノードの走査は行われない
- 実行計画では{type: const}となる。
###### 例

- DB

|ID(PK)|NUM|
|----|----|
|1|1|
|2|2|
|3|3|
|4|4|

- query

`(SELECT) WHERE ID = 2`

- index tree

```mermaid
graph TB;
  subgraph clustered index
    direction TB;
    a[ ]-->b[ ];
    a-->c[ ];
    b-->d[1] & e[2];
    c-->f[3] & g[4];
    style e fill:red
  end
```

- 実行計画

|type|key|Extra|
|----|----|----|
|const|PRIMARY|NULL|

- type: const
  - 一行のみを見つけるためにBツリーを走査するときに表示される

##### プライマリーキー以外の検索
- 一意(/queries/unique_key)
  - UNIQUE制約設定されたカラムには自動的にインデックスが作成される(インデックスの名前はカラム名)
###### 例
- DB

|ID(PK)|NUM(UNIQUE)|COL|
|----|----|----|
|1|1|1|
|2|2|1|
|3|3|1|
|4|4|1|

- INDEX定義

`INDEX NUM`

- query

`(SELECT) WHERE NUM = 2`

- INDEX TREE

```mermaid
graph TB;
  subgraph secondary index NUM
    direction TB;
    a[ ]-->b[ ];
    a-->c[ ];
    b-->d[1] & e[2];
    c-->f[3] & g[4];
    style e fill:red
  end
```

- 実行計画

|type|key|Extra|
|----|----|----|
|const|NUM|NULL|

##### 一意ではない(queries/not_unique_key)
  - インデックスツリーの走査とリーフノードの走査が行われる
  - 実行計画では{type: ref}
###### 例
- DB

|ID(PK)|NUM|COL|
|----|----|----|
|1|1|1|
|2|2|1|
|3|2|1|
|4|3|1|

- INDEX

`INDEX NUM`

- クエリ

`(SELECT) WHERE NUM = 2`

- INDEX TREE
  - ツリーの走査
```mermaid
graph TB;
  subgraph secondary index NUM
  direction TB;
  a[ ];
  b[ ];
  c[ ];
  a-->b;
  a-->c;
  b-->d & e;
  c-->f & g;
  subgraph leaf node
    direction LR;
    d[1];
    e[2];
    f[2];
    g[3];
  end
  end
  style e fill:red
```
  - リーフノードの走査
```mermaid
graph TB;
  subgraph leaf node
    direction LR;
    a[1];
    b[2];
    c[2];
    d[3];
    a<-->b;
    b<-->c;
    c<-->d;
    style b fill:red
    style c fill:red
  end
```

- PKを使ってクラスタインデックスから行データを取り出す

- 実行計画

|type|key|Extra
|----|----|----|
|ref|(index_name)|NULL|

- type: ref
  - リーフノードの走査している場合に表示される


#### 複合インデックス(queries/multi_column_index)
- id1, id2, id3で作成した場合
  - id1, id1&id2, id1&id2&id3を指定した検索は効く
    - 実行計画: {type: ref}
  - それ以外を指定した検索は効かない
    - ~~フルテーブルスキャンになる~~
    - フルインデックススキャンになる
    - 実行計画: {type: index}
    - インデックスコンディションプッシュダウンというもので使われることもある[参考14:30~](https://youtu.be/4Zj7Qgvt7RE?si=AIpn9un92sSdm1ta)
##### 例
- DB

|ID(PK)|NUM1|NUM2|NUM3|COL|
|----|----|----|----|----|
|1|1|1|1|1|
|2|1|2|1|1|
|3|1|2|2|1|
|4|2|1|1|1|
|5|3|2|1|1|

- INDEX

`INDEX NUM1, NUM2, NUM3`

- クエリ

`(SELECT) WHERE NUM1 = 1`

- INDEX TREE
  - ツリーの走査
```mermaid
graph TB;
  subgraph secondary index NUM
  direction TB;
  a[ ];
  b[ ];
  c[ ];
  z[ ];
  a-->b;
  a-->c;
  a-->z;
  z-->h;
  b-->d & e;
  c-->f & g;
  subgraph leaf node
    direction LR;
    h[1<br>1<br>1];
    d[1<br>2<br>1];
    e[1<br>2<br>2];
    f[2<br>1<br>1];
    g[3<br>2<br>1];
  end
  end
  style h fill:red
```
  - リーフノードの走査
```mermaid
graph TB;
  subgraph leaf node
    direction LR;
    a[1<br>1<br>1];
    b[1<br>2<br>1];
    c[1<br>2<br>2];
    d[2<br>1<br>1];
    e[3<br>2<br>1];
    a<-->b;
    b<-->c;
    c<-->d;
    d<-->e;
    style a fill:red
    style b fill:red
    style c fill:red
  end
```

- PKを使ってクラスタインデックスから行データを取り出す

- 実行計画

|type|key|Extra
|----|----|----|
|ref|(index_name)|NULL|

- クエリ

`(SELECT) WHERE NUM1 = 1 AND NUM2 = 2`

- INDEX TREE
  - ツリーの走査
```mermaid
graph TB;
  subgraph secondary index NUM
  direction TB;
  a[ ];
  b[ ];
  c[ ];
  z[ ];
  a-->b;
  a-->c;
  a-->z;
  z-->h;
  b-->d & e;
  c-->f & g;
  subgraph leaf node
    direction LR;
    h[1<br>1<br>1];
    d[1<br>2<br>1];
    e[1<br>2<br>2];
    f[2<br>1<br>1];
    g[3<br>2<br>1];
  end
  end
  style d fill:red
```
  - リーフノードの走査
```mermaid
graph TB;
  subgraph leaf node
    direction LR;
    a[1<br>1<br>1];
    b[1<br>2<br>1];
    c[1<br>2<br>2];
    d[2<br>1<br>1];
    e[3<br>2<br>1];
    a<-->b;
    b<-->c;
    c<-->d;
    d<-->e;
    style b fill:red
    style c fill:red
  end
```

- PKを使ってクラスタインデックスから行データを取り出す

- 実行計画

|type|key|Extra
|----|----|----|
|ref|(index_name)|NULL|

- クエリ

`(SELECT) WHERE NUM1 = 1 AND NUM2 = 2 AND NUM3 = 1`

- INDEX TREE
  - ツリーの走査
```mermaid
graph TB;
  subgraph secondary index NUM
  direction TB;
  a[ ];
  b[ ];
  c[ ];
  z[ ];
  a-->b;
  a-->c;
  a-->z;
  z-->h;
  b-->d & e;
  c-->f & g;
  subgraph leaf node
    direction LR;
    h[1<br>1<br>1];
    d[1<br>2<br>1];
    e[1<br>2<br>2];
    f[2<br>1<br>1];
    g[3<br>2<br>1];
  end
  end
  style d fill:red
```
  - リーフノードの走査
```mermaid
graph TB;
  subgraph leaf node
    direction LR;
    a[1<br>1<br>1];
    b[1<br>2<br>1];
    c[1<br>2<br>2];
    d[2<br>1<br>1];
    e[3<br>2<br>1];
    a<-->b;
    b<-->c;
    c<-->d;
    d<-->e;
    style b fill:red
  end
```

- PKを使ってクラスタインデックスから行データを取り出す

- 実行計画

|type|key|Extra
|----|----|----|
|ref|(index_name)|NULL|

- クエリ

`(SELECT) WHERE NUM2 = 2`

`(SELECT) WHERE NUM3 = 1`

- リーフノード
```mermaid
graph TB;
  subgraph leaf node
    direction LR;
    a[1<br>1<br>1];
    b[1<br>2<br>1];
    c[1<br>2<br>2];
    d[2<br>1<br>1];
    e[3<br>2<br>1];
    a<-->b;
    b<-->c;
    c<-->d;
    d<-->e;
  end
```

- 実行計画

|type|key|Extra|
|----|----|----|
|index|(index_name)|Using where|

- type: index
  - フルインデックススキャン
  - インデックスの全行をインデックスの順番に沿って読む
  - あまり効率が良くない
- Extra: Using where
  - indexに含まれない列に対してWHEREに指定した条件を評価する
  - 行データを取り出した後のフィルター

- 説明
  - NUM2が同じリーフノードが固まって配置されるとは限らないので、このインデックスを使って絞り込みは行えない
  - NUM3も同様

### カバリングインデックス(/queries/covering_index)
- selectで指定するカラムと使われるインデックスのカラムが一致すると、クラスタインデックスを辿らなくて済む

#### 例
- DB

|ID(PK)|NUM1|NUM2|
|----|----|----|
|1|1|1|
|2|2|2|
|3|3|3|
|4|4|4|

- INDEX

`INDEX NUM1, NUM2`

- クエリ

`SELECT NUM1, NUM2 WHERE NUM1 = 2 AND NUM2 = 2`

- INDEX TREE
  - ツリーの走査
```mermaid
graph TB;
  subgraph secondary index NUM
  direction TB;
  a[ ];
  b[ ];
  c[ ];
  a-->b;
  a-->c;
  b-->d & e;
  c-->f & g;
  subgraph leaf node
    direction LR;
    d[NUM1: 1<br>NUM2: 1];
    e[NUM1: 2<br>NUM2: 2];
    f[NUM1: 3<br>NUM2: 3];
    g[NUM1: 4<br>NUM2: 4];
  end
  end
  style e fill:red
```
  - リーフノードの走査
```mermaid
graph TB;
  subgraph leaf node
    direction LR;
    a[NUM1: 1<br>NUM2: 1];
    b[NUM1: 2<br>NUM2: 2];
    c[NUM1: 3<br>NUM2: 3];
    d[NUM1: 4<br>NUM2: 4];
    a<-->b;
    b<-->c;
    c<-->d;
    style b fill:red
  end
```

- 実行計画

|type|key|Extra
|----|----|----|
|ref|(index_name)|Using index|

#### インデックスにあるカラムとないカラムを条件に指定(/queries/index_no_index)
- インデックスを使って検索
- そのデータを取り出してインデックスにないカラムの条件でフィルターする
- mysqlで`2^20`のデータにフィルターをかける処理を書いたがフルテーブルスキャンを使わなかった(?)

##### 例
- DB

|ID(PK)|NUM1|NUM2|
|----|----|----|
|1|1|1|
|2|1|2|
|3|2|1|
|4|2|2|

- INDEX

`INDEX NUM1`

- クエリ

`(SELECT) WHERE NUM1 = 1 AND NUM2 = 2`

- INDEX TREE
  - ツリーの走査
```mermaid
graph TB;
  subgraph secondary index NUM1
  direction TB;
  a[ ];
  b[ ];
  c[ ];
  a-->b;
  a-->c;
  b-->d & e;
  c-->f & g;
  subgraph leaf node
    direction LR;
    d[1];
    e[1];
    f[2];
    g[2];
  end
  end
  style e fill:red
```
  - リーフノードの走査
```mermaid
graph TB;
  subgraph leaf node
    direction LR;
    a[1<br>PK: 1];
    b[1<br>PK: 2];
    c[2];
    d[2];
    a<-->b;
    b<-->c;
    c<-->d;
    style a fill:red
    style b fill:red
  end
```
- PKを使って、クラスタインデックスから行データを取り出して、条件でフィルタ
```mermaid
graph TB;
  a[PK: 1<br>NUM: 1<br>NUM2: 1]
  b[PK: 2<br>NUM: 1<br>NUM2: 2]
  style b fill:red
```
- 実行計画

|type|key|Extra
|----|----|----|
|ref|(index_name)|Using where|

- Extra: Using where
  - indexに含まれない列に対してWHEREに指定した条件を評価する
  - 行データを取り出した後のフィルター

### 関数インデックス(今回はスキップ)
mysql8.0.13以降は使える[参考](https://dev.mysql.com/doc/refman/8.0/en/create-index.html)
- WHERE句で関数値を指定するとき(ex. where f(num) = 1)にインデックスを効かせることができる
  - create index f(num);
  - index numは効かない
- 関数インデックスは確定的でないといけない(同じ条件でも実行する環境によって値が変わるものには使えない)
  - ex. 現在時刻を関数値の計算に使う場合など

### 範囲検索
[参考](https://use-the-index-luke.com/ja/sql/where-clause/searching-for-ranges)
#### 大なり小なりBETWEEN(のみ)(範囲検索)(queries/range)
- リーフノードの走査が行われる
- {type: range}
- TODO: NUM2を追加

##### 例
- DB

|ID(PK)|NUM|COL|
|----|----|----|
|1|1|1|
|2|2|1|
|3|3|1|
|4|4|1|

- INDEX

`INDEX NUM`

- クエリ

`(SELECT) WHERE NUM >= 2`

- INDEX TREE
  - ツリーの走査
```mermaid
graph TB;
  subgraph secondary index NUM
  direction TB;
  a[ ];
  b[ ];
  c[ ];
  a-->b;
  a-->c;
  b-->d & e;
  c-->f & g;
  subgraph leaf node
    direction LR;
    d[1];
    e[2];
    f[3];
    g[4];
  end
  end
  style e fill:red
```
  - リーフノードの走査
```mermaid
graph TB;
  subgraph leaf node
    direction LR;
    a[1];
    b[2];
    c[3];
    d[4];
    a<-->b;
    b<-->c;
    c<-->d;
    style b fill:red
    style c fill:red
    style d fill:red
  end
```

- PKを使ってクラスタインデックスから行データを取り出す

- クエリ

`(SELECT) WHERE NUM <= 3`

- INDEX TREE
  - ツリーの走査
```mermaid
graph TB;
  subgraph secondary index NUM
  direction TB;
  a[ ];
  b[ ];
  c[ ];
  a-->b;
  a-->c;
  b-->d & e;
  c-->f & g;
  subgraph leaf node
    direction LR;
    d[1];
    e[2];
    f[3];
    g[4];
  end
  end
  style f fill:red
```
  - リーフノードの走査
```mermaid
graph TB;
  subgraph leaf node
    direction LR;
    a[1];
    b[2];
    c[3];
    d[4];
    a<-->b;
    b<-->c;
    c<-->d;
    style a fill:red
    style b fill:red
    style c fill:red
  end
```

- PKを使ってクラスタインデックスから行データを取り出す

- クエリ

`(SELECT) WHERE NUM BETWEEN 2 AND 3`

- INDEX TREE
  - ツリーの走査
```mermaid
graph TB;
  subgraph secondary index NUM
  direction TB;
  a[ ];
  b[ ];
  c[ ];
  a-->b;
  a-->c;
  b-->d & e;
  c-->f & g;
  subgraph leaf node
    direction LR;
    d[1];
    e[2];
    f[3];
    g[4];
  end
  end
  style e fill:red
```
  - リーフノードの走査
```mermaid
graph TB;
  subgraph leaf node
    direction LR;
    a[1];
    b[2];
    c[3];
    d[4];
    a<-->b;
    b<-->c;
    c<-->d;
    style b fill:red
    style c fill:red
  end
```

- PKを使ってクラスタインデックスから行データを取り出す

- 実行計画(>=, <=, BETWEEN全て一緒)

|type|key|Extra|
|----|----|----|
|range|(index_name)|(Using index condition)|

- Extra: Using index condition(調べる)


#### 範囲条件と等価条件の複合(*)?
- 等価条件に使われるカラムをより最初にしてインデックスを作るとよい
- インデックスは等価性(ツリーの走査)を調べた後に、範囲(リーフノードの走査)を調べるために使われる
- 等価カラムと範囲カラムの順番による違い
  - 等価カラム、範囲カラムの場合
    - 等価カラムを使って、リーフノードまで辿り着く
    - リーフノードを走査して、範囲カラム（等価カラム）の条件に当てはまるものを取得
      - 走査範囲で範囲カラムがソートされていることが保証されるので、余計な走査が行われない（途中で打ち切りができる）
  - 範囲カラム、等価カラムの場合
    - 範囲カラムを使って、リーフノードまで辿り着く
    - リーフノードを走査して、等価カラム（範囲カラム）の条件に当てはまるものを取得
      - 走査範囲で等価カラムがソートされていることが保証されていないので、必ず範囲全体を走査しないといけない（途中で打ち切りができない）


#### LIKE演算子(/queries/like)
- 前方一致のみにインデックスが効く
  - LIKE 'hoge%', LIKE 'hoge%hoge'
  - 選択性が高くないとパフォーマンスが出ない
- 後方一致には効かない
  - LIKE '%hoge'
- 部分一致検索ではインデックスを効かせられない
  - LIKE '%hoge%'
  - 全文検索には他の方法を用いる(時間があったら調査)
    - FULLTEXT INDEX
      - [参考](https://dev.mysql.com/doc/refman/8.0/en/fulltext-search.html);

##### 例
- DB

|ID(PK)|STR|COL|
|----|----|----|
|1|AA|1|
|2|AB|1|
|3|BB|1|
|4|CA|1|

- INDEX

`INDEX STR`

- クエリ

`(SELECT) WHERE STR LIKE 'A%'`

- INDEX TREE
  - ツリーの走査
```mermaid
graph TB;
  subgraph secondary index NUM
  direction TB;
  a[ ];
  b[ ];
  c[ ];
  a-->b;
  a-->c;
  b-->d & e;
  c-->f & g;
  subgraph leaf node
    direction LR;
    d[AA];
    e[AB];
    f[BB];
    g[CA];
  end
  end
  style d fill:red
```
  - リーフノードの走査
```mermaid
graph TB;
  subgraph leaf node
    direction LR;
    a[AA];
    b[AB];
    c[BB];
    d[CA];
    a<-->b;
    b<-->c;
    c<-->d;
    style a fill:red
    style b fill:red
  end
```

- PKを使ってクラスタインデックスから行データを取り出す

- 実行計画

|type|key|Extra|
|----|----|----|
|range|(index_name)|Using index condition|

- Extraについて

- クエリ

`(SELECT) WHERE STR LIKE '%A'`

`(SELECT) WHERE STR LIKE '%A%'`

  - リーフノードの走査
```mermaid
graph TB;
  subgraph leaf node
    direction LR;
    a[AA];
    b[AB];
    c[BB];
    d[CA];
    a<-->b;
    b<-->c;
    c<-->d;
  end
```

- 実行計画

|type|key|Extra|
|----|----|----|
|ALL|(index_name)|Using where|

- 条件に当てはまるリーフノードが固まって配置されるとは限らないので、インデックスは使えない



#### インデックスの結合(x)
[参考](https://use-the-index-luke.com/ja/sql/where-clause/searching-for-ranges/index-merge-performance)
- 別々のカラムを範囲検索
  - 2つのカラムに対する複合インデックス
    - 選択性の高いカラムを先に置く
  - 各々のカラムのインデックスを作成
    - 各々のインデックスをつかって対象のデータを検索
    - 各々の検索結果の積集合を返す
    - using intersect

## ORDER BY(/queries/order_by)
- order by句がインデックスによる順序付けと一致している場合、ソート処理を省略できる
  - index id1, id2: where id1= order by id1, id2
  - index id1, id2: where id1= id2(range) orderby id2
- 一致していない場合はソートをしないといけない
  - クイックソート(nlogn)

##### 例
- DB

|ID(PK)|NUM1|NUM2|
|----|----|----|
|1|1|1|
|2|2|2|
|3|2|1|
|4|2|3|

- INDEX

`INDEX NUM1`

- クエリ

`(SELECT) WHERE NUM1 = 2 ORDER BY NUM1, NUM2`

- INDEX TREE
  - ツリーの走査
```mermaid
graph TB;
  subgraph secondary index NUM
  direction TB;
  a[ ];
  b[ ];
  c[ ];
  a-->b;
  a-->c;
  b-->d & e;
  c-->f & g;
  subgraph leaf node
    direction LR;
    d[1];
    e[2];
    f[2];
    g[2];
  end
  end
  style e fill:red
```
  - リーフノードの走査
```mermaid
graph TB;
  subgraph leaf node
    direction LR;
    a[1];
    b[2<br>PK: 1];
    c[2<br>PK: 2];
    d[2<br>PK: 3];
    a<-->b;
    b<-->c;
    c<-->d;
    style b fill:red
    style c fill:red
    style d fill:red
  end
```
- PKを用いて、クラスタインデックスから行データを取得

|ID|NUM1|NUM2|
|----|----|----|
|2|2|2|
|3|2|1|
|4|2|3|

- ソート

|ID|NUM1|NUM2|
|----|----|----|
|3|2|1|
|2|2|2|
|4|2|3|

- 実行計画

|type|key|Extra
|----|----|----|
|ref|(index_name)|Using filesort|


- INDEX

`INDEX NUM1, NUM2`

- クエリ

`(SELECT) WHERE NUM1 = 2 ORDER BY NUM1, NUM2`

- INDEX TREE
  - ツリーの走査
```mermaid
graph TB;
  subgraph secondary index NUM
  direction TB;
  a[ ];
  b[ ];
  c[ ];
  a-->b;
  a-->c;
  b-->d & e;
  c-->f & g;
  subgraph leaf node
    direction LR;
    d[NUM1: 1<br>NUM2: 1];
    e[NUM1: 2<br>NUM2: 1];
    f[NUM1: 2<br>NUM2: 2];
    g[NUM1: 2<br>NUM2: 3];
  end
  end
  style e fill:red
```
  - リーフノードの走査`NUM1 = 2`
```mermaid
graph TB;
  subgraph leaf node
    direction LR;
    a[NUM1: 1<br>NUM2: 1];
    b[NUM1: 2<br>NUM2: 1];
    c[NUM1: 2<br>NUM2: 2];
    d[NUM1: 2<br>NUM2: 3];
    a<-->b;
    b<-->c;
    c<-->d;
    style b fill:red
    style c fill:red
    style d fill:red
  end
```
順番に並んでいるのでそのまま値を返す

- 実行計画

|type|key|Extra
|----|----|----|
|ref|(index_name)|Using index|


### ASC, DESC(*)?
- 指定するカラムが単一
  - ASC, DESCどちらでもインデックスが使える
- 複数
  - ASC, DESCが一致していれば良い
  - indexにASC, DESCを指定できる

## update, delete, insert(*)
- update, deleteのターゲットの絞り込みで使える
- 各操作後に存在するインデックスを更新することになるので、インデックスが多いほど処理が遅くなる

## DBコンテナの扱い
- DBデータ永続化削除
  - `docker volume rm db_index_test_index_db_data`
- DBコンテナに入る
  - `docker exec -it mysql /bin/bash`
- SQLファイルの実行
  - `mysql -uuser -ppassword db < .sql`

## 参考URL
[USE THE INDEX LUKE](https://use-the-index-luke.com/ja)
[参考14:30~](https://youtu.be/4Zj7Qgvt7RE?si=AIpn9un92sSdm1ta)
