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
#### [六、PL/SQL块结构](#6)
#### [另：某些上机示例](#7)

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

2. 多表查询<a id="3.2"></a>
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
 ```


### 六、PL/SQL块结构<a id="6"></a>[🔝](#top)



### 一些上机示例<a id="7"></a>[🔝](#top)
基础设施是经济社会发展的重要支撑，基础设施建设是国民经济基础性、先导性、战略性、引领性产业。现在需要我们设计一个小型的基建项目管理系统，通过把工程项目、供应商和原材料信息有机的结合起来（每个供应商只供应一种原材料），从而提高项目的实施效率。系统至少应该包含几个核心模块：项目管理模块、供应商管理模块、原材料管理模块、供需管理模块。  
（1）	项目管理模块：用于记录项目的基本信息，包括项目编号、名称、地址、起始时间、项目状态等等；
（2）	供应商管理模块：用于记录供应商的基本信息，包括供应商代码、名称、供应原材料代码等等；
（3）	原材料管理模块：用于记录原材料的基本信息，包括原材料代码、名称、类别、单价、存放地、库存数等等；
（4）	供需管理模块：用于记录项目供需的基本信息，包括项目编号、供应商代码、原材料代码、供应数量等等。  
1.用SQL语句创建表格，包括主外键；其中项目编号必须是12个字符长度，并且以’PJNO’开始。例如，‘PJNO00000001’。
```sql
CREATE TABLE 项目管理(
  项目编号  VARCHAR(12) PRIMARY KEY CHECK(项目编号 LIKE 'PJNO%'),
  项目名称  VARCHAR(50),
  地址      VARCHAR(50),
  开始时间  DATE,
  项目状态  VARCHAR(5) CHECK(项目状态 IN ("未开始","施工中","已交付")))；
CREATE TABLE 供应商管理(
  供应商代码  VARCHAR(10),
  名称       VARCHAR(100),
  供应原材料代码  NUMERIC(20),
  PRIMARY KRY (供应商代码));
CREATE TABLE 原材料管理(
  原材料代码  NUMERIC(20) PRIMARY KEY,
  原材料名称  VARCHAR(40) NOT NULL,
  原材料类别  VARCHAR(40),
  单价       DECIMAL(5,2),
  存放地     VARCHAR(100),
  库存数     INT);
CREATE TABLE 供需管理(
  供需记录编号  NUMERIC(20),
  项目编号      VARCHAR(13),
  供应商代码    VARCHAR(10),
  原材料代码    NUMERIC(20),
  供应数量      INT NOT NULL,
  FOREIGN KEY (项目编号) REFERENCES 项目管理(项目编号),
  FOREIGN KEY (供应商代码) REFERENCES 供应商管理(供应商代码),
  FOREIGN KEY (原材料代码) REFERENCES 原材料管理(原材料代码));
```
2.查询各种状态下的项目数量，项目状态为：未开始、施工中、已交付
```sql

```  
3.创建一个视图，显示供应数量最多的原材料信息  
```sql
CREATE VIEW 最多供应数 AS
SELECT 原材料管理.原材料代码,原材料管理.原材料名称,原材料管理.原材料类别,原材料管理.单价,原材料管理.存放地,SUM(供应数量) AS 总供给数
FROM 供需管理
JOIN 原材料管理 ON 供需管理.原材料代码=原材料管理.原材料代码
GROUP BY 原材料管理.原材料代码,原材料管理.原材料名称,原材料管理.原材料类别,原材料管理.单价,原材料管理.存放地
ORDER BY 总供给数 DESC;
```
4.查询项目名包含“南京”的项目所有供需信息  
```sql
SELECT 项目管理.项目编号,项目管理.项目名称,供需管理.供应商代码,供需管理.原材料代码,供需管理.供应数量
FROM 项目管理
JOIN 供需管理 ON 项目管理.项目编号=供需管理.项目编号
WHERE 项目管理.项目名称 LIKE '%南京'；
```
5.查询至少需要3种不同原材料且每种原材料的供应数量不低于10的项目编号与名称  
```sql
SELECT 项目管理.项目编号,项目管理.项目名称
FROM 项目管理
JOIN 供需管理 ON 项目管理.项目编号=供需管理.项目编号
WHERE 供需管理.供应数量>=10
GROUP BY 项目管理.项目编号,项目管理.项目名称
HAVING COUNT(DISTINCT 供需管理.原材料代码)>=3;
```
6.查询使用了“原材料A”但没有使用“原材料B”的项目编号和名称  
```sql
SELECT 项目管理.项目编号,项目管理.项目名称
FROM 项目管理
JOIN 供需管理 ON 项目管理.项目编号=供需管理.项目编号
JOIN 原材料管理 ON 供需管理.原材料代码=原材料管理.原材料代码
WHERE 原材料管理.原材料名称='原材料A'
AND 项目管理.项目编号 NOT IN(
  SELECT 项目编号
  FROM 供需管理
  WHERE 原材料名称='原材料B');
```
