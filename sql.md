### 表的建立与删改
- 建立student表、定义完整性约束条件，设置sno为主键
```sql
create table student(
sno     NUMERIC(6),
sname   VARCHAR(8) NOT NULL,
sex     VARCHAR(2) NOT NULL,
dept    VARCHAR(20),
place   VARCHAR(20),
PRIMARY KEY (sno));
```

- 删除student表
```sql
--CASCADE（直接将数据、表、索引、视图全部删除）
drop table student CASCADE 
```
```sql
--RESTRICT（先删除数据、表、索引、视图等才能删除空表）
drop table student RESTRICT 
```

- 在student表中增加列
```sql
alter table student
add(subject VARCHAR(20),addr VARCHAR(20));
```

- student表修改列名
```sql
alter table student
rename column addr to 地址
--rename column 旧列名 to 新列名
```

- 将student表“place”的长度改为15
```sql
alter table student
MODIFY place VARCHAR(15);
```

- 删除student表中的subject、addr
```sql
alter table student drop column addr;
alter table student drop column subject;
```


### 完整性约束的三个子句形式
1. 主键子句：primary key (<列名>)
```sql
create table worker(
worker_id   NUMERIC(10),
worker_name VARCHAR(6),
skill_type  VARCHAR(8),
PRIMARY KEY (sno)); 
```
```sql
create table worker(
worker_id   NUMERIC(10) primary key,
worker_name VARCHAR(6),
skill_type  VARCHAR(8));
```

2. 外键子句：foreign key (<列名>) references [<表名>][<约束选项>]
```sql
create table assignment(
worker_id   NUMERIC(10),
start_date  DATE,
FOREIGN KEY (worker_id) REFERENCES worker(woker_id));
--一个表可以有多个外键
```

3. 检验子句：check(<约束条件>)
```sql
--性别只能为男或女
create table student(
sno     NUMERIC(8) PRIMARY KEY,
sex     VARCHAR(2) check(sex='男' or sex='女'))；
```
```sql
--三选一
create table building(
bldg_id     NUMERIC(10) primary key,
type VARCHAR(9) DEFAULT 'office'
check (type IN ('office','warehouse','residence')))；
```
```sql
--在一个范围中间
create table student(
sno     NUMERIC(8) PRIMARY KEY,
sage    NUMERIC(2) check(sage between 12 and 18))；
--或者也可以写成 ...check(sage>12 and sage<18)
```
```sql
--长度大于等于某个值
create table student(
sno     NUMERIC(8) PRIMARY KEY,
id      NUMERIC(18) check(length(id)=18))；
```
```sql
--前几位以固定格式开头
create table project_manage(
pno     VARCHAR(12) PRIMARY KEY CHECK(pno LIKE 'PJNO%'),
pname   VARCHAR(20));
```
```sql
--只能是8位字符，前两位是0，3~4位是数字，第5位是下划线，6~8位为字母
create table info(
id          NUMERIC(10) primary key,
password    VARCHAR(10) check(regexp_like(password,'^00[0-9]{2}[_][a-z,A-Z]{3}$')) and lenth(password)=8);
```


### 数据更新
- 插入数据
```sql
--将学生的信息加入到学生表中
insert into student
values(200508,'yj',19,'男','人工智能','江苏省')
```

- 删改数据
```sql

```