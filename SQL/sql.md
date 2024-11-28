## 目录<a id="top"></a>
#### [一、表的建立与删改](#1)  
#### [二、完整性约束的三个子句形式](#2)  
- #### [1. 主键子句](#2.1)
- #### [2. 外键子句](#2.2)
- #### [3. 检验子句](#2.3)
#### [三、数据查询](#3)  
- #### [1. 单表查询](#3.1)
- #### [2. 多表查询](#3.2)
- #### [3. 连接查询](#3.3)
- #### [4. 递归查询](#3.4)
#### [四、数据更新](#4)  
#### [五、视图创建与使用](#5)
#### [六、PL/SQL](./sql2.md)

## 笔记

### 一、表的建立与删改<a id="1"></a>[🔝](#top)
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


### 二、完整性约束的三个子句形式<a id="2"></a>[🔝](#top)
1. 主键子句：primary key (<列名>)<a id="2.1"></a>
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

2. 外键子句：foreign key (<列名>) references [<表名>][<约束选项>]<a id="2.2"></a>
```sql
create table assignment(
worker_id   NUMERIC(10),
start_date  DATE,
FOREIGN KEY (worker_id) REFERENCES worker(woker_id));
--一个表可以有多个外键
```

3. 检验子句：check(<约束条件>)<a id="2.3"></a>
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
--regexp_like:确认字符串是否匹配正则表达式
```


### 三、数据查询<a id="3"></a>[🔝](#top)
1. 单表查询 <a id="3.1"></a>  
SELECT语句的含义：  
1）根据WHERE子句的条件表达式，从FROM子句指定的基本表或视图中找出满足条件的元组；  
2）再按SELECT子句中的目标列表表达式选出元组中的列值形成结果表；  
3）如果有GROUP子句，将行选择的结果按<列名1>的值进行分组，列值相等的元组为一个组，每个组产生结果表中的一条记录，如果GROUP子句带HAVING短语，则只有满足指定条件的组才会输出；  
4）如果有ORDER子句，最后的结果按照<列名2>值的升序或降序排序。
```sql
--查询员工人数大于5的部门中，薪水平均值大于6000的部门，按平均薪水降序排列
SELECT DEPARTMENT_ID, COUNT(*) AS EMPLOYEE_COUNT, AVG(SALARY) AS AVG_SALARY
FROM EMPLOYEES
WHERE SALARY > 5000  --只考虑薪水大于5000的员工
GROUP BY DEPARTMENT_ID  --按部门分组
HAVING AVG(SALARY) > 6000  --过滤平均薪水大于6000的部门
ORDER BY AVG_SALARY DESC;  --按平均薪水降序排列
```
- WHERE子句（在SELECT语句中最先执行）
```sql
--查询员工表 EMPLOYEES 中薪水大于5000的员工
SELECT EMPLOYEE_ID, FIRST_NAME, LAST_NAME, SALARY
FROM EMPLOYEES
WHERE SALARY > 5000;
```
- GROUP BY子句（常与聚合函数（如COUNT、SUM、AVG、MAX、MIN）一起使用）
```sql
--查询每个部门的员工总数,按照DEPARTMENT_ID分组
SELECT DEPARTMENT_ID, COUNT(*) AS EMPLOYEE_COUNT
FROM EMPLOYEES
GROUP BY DEPARTMENT_ID;
```
- HAVING子句（用于聚合后的条件过滤，不能在WHERE中直接使用聚合函数）
```sql
--查询员工人数大于5的部门，并显示部门ID和员工数量
SELECT DEPARTMENT_ID, COUNT(*) AS EMPLOYEE_COUNT
FROM EMPLOYEES
GROUP BY DEPARTMENT_ID
HAVING COUNT(*) > 5;
```
- ORDER BY子句（用于排序，升序ASC，降序DESC，可以按多个字段排序）
```sql
-- 查询员工表中薪水大于5000的员工信息，按薪水降序排列
SELECT EMPLOYEE_ID, FIRST_NAME, LAST_NAME, SALARY
FROM EMPLOYEES
WHERE SALARY > 5000
ORDER BY SALARY DESC;
```
- DISTINCT的用法
```sql
-- 去除单列中的重复值,返回唯一的记录行。
-- DISTINCT可以统计多列，必须放在开头
SELECT DISTINCT column1, column2, ... 
FROM table_name;
```
- 聚合函数  
   <font color=red>WHERE子句中不能用聚集函数作为条件表达式。聚集函数只能用于SELECT子句和GROUP BY中的HAVING子句。</font>
```sql
--COUNT用于计算行数，可以统计非空值的个数，或者直接计算总行数。
SELECT COUNT(*) AS TOTAL_EMPLOYEES
FROM EMPLOYEES;
--统计表EMPLOYEES中的总员工数
```
```sql
--AVG用于计算数值列的平均值。
SELECT DEPARTMENT_ID, AVG(SALARY) AS DEPARTMENT_AVG_SALARY
FROM EMPLOYEES
GROUP BY DEPARTMENT_ID;
--按DEPARTMENT_ID分组，计算每个部门的平均薪水
```
```sql
--SUM用于计算数值列的总和
SELECT DEPARTMENT_ID, SUM(SALARY) AS DEPARTMENT_TOTAL_SALARY
FROM EMPLOYEES
GROUP BY DEPARTMENT_ID;
--按DEPARTMENT_ID分组，计算每个部门的总薪水。
```
```sql
--MAX用于计算列的最大值
SELECT DEPARTMENT_ID, MAX(SALARY) AS DEPARTMENT_MAX_SALARY
FROM EMPLOYEES
GROUP BY DEPARTMENT_ID;
--分组、然后查询每个部门的最高薪水
```
```sql
--MIN用于计算列的最大值
SELECT DEPARTMENT_ID, MIN(SALARY) AS DEPARTMENT_MIN_SALARY
FROM EMPLOYEES
GROUP BY DEPARTMENT_ID;
--分组、然后查询每个部门的最低薪水
```

1. 多表查询<a id="3.2"></a>
- 嵌套查询（子查询嵌套在父查询的WHERE条件中，不能使用ORDER子句，因为ORDER BY子句只能对最终查询结果排序）
```sql
--找出年龄超过平均年龄的学生姓名
SELECT name
FROM student
WHERE age>
(SELECT AVG(age)
 FROM student);
```
- 条件连接查询
```sql
--用嵌套查询查询选修了数据库课程的学生学号、成绩
SELECT sno,grade
FROM s_c
WHERE cno IN
(SELECT cno
 FROM course
 WHERE cname="数据库");
 --以上语句用条件连接查询表示为：
 SELECT sno,grade
 FROM s_c,course
 WHERE s_c.cno=course.cno AND cname="数据库";
```
- 相关子查询  
EXISTS或NOT EXISTS的执行顺序是先执行外查询再执行内查询。
```sql
select * from A where not exists(select * from B where A.id = B.id);
select * from A where exists(select * from B where A.id = B.id);
--1、首先执行外查询select * from A，然后从外查询的数据取出一条数据传给内查询。
--2、内查询执行select * from B，外查询传入的数据和内查询获得的数据根据where后面的条件做匹对，如果存在数据满足A.id=B.id则返回true，如果一条都不满足则返回false。
--3、内查询返回true，则外查询的这行数据保留，反之内查询返回false，则外查询的这行数据不显示。外查询的所有数据逐行查询匹对。
```
```sql
--查询没有选修001号课程的学生学号及姓名
SELECT sno,sname
  FROM student
  WHERE NOT EXISTS
    (SELECT *
    FROM s_c
    WHERE s_c.sno=student.sno AND cno='001');

SELECT sno,sname
  FROM student
  WHERE sno <> ALL
    (SELECT sno
    FROM s_c
    WHERE cno='001');
```

3. 连接查询<a id="3.3"></a>  
  用JOIN...ON...，其中JOIN指定要连接的表，而ON子句指定连接的条件（即连接键）
```sql
--查询员工表和部门表中的员工信息以及对应的部门名称
--默认情况下，JOIN...ON...就是内连接（INNER JOIN...ON...）
SELECT E.EMPLOYEE_ID, E.FIRST_NAME, E.LAST_NAME, E.SALARY, D.DEPARTMENT_NAME
FROM EMPLOYEES E
JOIN DEPARTMENTS D ON E.DEPARTMENT_ID = D.DEPARTMENT_ID;
```

4. 递归查询（好像不常用）<a id="3.4"></a>


### 四、数据更新<a id="4"></a>[🔝](#top)
- 插入数据
```sql
--将学生的信息加入到学生表中
insert into student
values(200508,'yj',19,'男','人工智能','江苏省');
```

- 修改数据
```sql
--用子句修改表中数据
--假设有一个员工表EMPLOYEES，包含字段EMPLOYEE_ID, FIRST_NAME, LAST_NAME, SALARY
--将员工编号为101的员工工资增加10%
UPDATE EMPLOYEES
SET SALARY = SALARY * 1.1
WHERE EMPLOYEE_ID = 101;
```
```sql
--用子查询修改表中数据（适用于复杂场景）
--假设有另一个表DEPARTMENTS，包含字段DEPARTMENT_ID, DEPARTMENT_NAME
--目标：将所有在销售部门工作的员工工资增加15%
UPDATE EMPLOYEES
SET SALARY = SALARY * 1.15
WHERE DEPARTMENT_ID = (
    SELECT DEPARTMENT_ID
    FROM DEPARTMENTS
    WHERE DEPARTMENT_NAME = 'Sales');
```

- 删除数据（子句和子查询两种）
```sql
--从员工表中删除所有薪水小于3000的员工记录
DELETE FROM EMPLOYEES
WHERE SALARY < 3000;
```
```sql
--假设要删除所有在某一特定部门内工作，并且薪水低于该部门平均薪水的员工
DELETE FROM EMPLOYEES
WHERE SALARY < (
    SELECT AVG(SALARY)
    FROM EMPLOYEES
    WHERE DEPARTMENT_ID = EMPLOYEES.DEPARTMENT_ID);
```


### 五、视图创建与使用<a id="5"></a>[🔝](#top)
 创建视图的过程实际上就是在一个数据查询（即SELECT语句）前加上了CREATE VIEW关键字，视图本质上是一个查询的封装。
 ```sql
--假设有以下查询
SELECT EMPLOYEE_ID, FIRST_NAME, LAST_NAME, SALARY, DEPARTMENT_ID
FROM EMPLOYEES
WHERE SALARY > 5000;
--将这个查询封装成视图，可以使用：
CREATE VIEW high_salary_employees AS
SELECT EMPLOYEE_ID, FIRST_NAME, LAST_NAME, SALARY, DEPARTMENT_ID
FROM EMPLOYEES
WHERE SALARY > 5000;
--子查询可以是任意复杂的SELECT语句
```