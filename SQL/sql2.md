### 六、PL/SQL[🔝](./sql.md)

#### 1. 相关概念
- 一个完整的PL/SQL语句块由3个部分组成。  
1）声明部分：**以关键字DECLARE开始**，以BEGIN结束。主要用于声明变量，常量，数据类型，游标，异常处理名称和本地子程序定义等。  
2）执行部分：是PL/SQL语句块的**功能实现**部分，以关键字begin开始，以exception或end结束（如果语句中没有异常处理部分，则以关键字end结束）。该部分通过变量赋值，流程控制，数据查询，数据操纵，数据定义，事务控制，游标处理等操作实现语句块的功能。  
3）异常处理部分：以关键字exception开始，以end结束。该部分用于处理该语句块**执行过程中产生的异常**。
```sql
DECLARE <说明的变量、常量、游标等>       --可选的声明部分
BEGIN <SQL语句、PL\SQL的流程控制语句>    --可执行的部分
[ EXCEPTION <异常处理部分>]             --可选的异常处理部分
END;
```

- 声明与赋值
为变量赋值（可以在声明时为其赋值，也可在执行部分为其赋值）  
1）使用赋值运算符(：=)；  
2）使用语句
```sql
DECLARE
--声明变量
    emp_name    VARCHAR(20);
    emp_no      NUMBER(4);
    active_emp  BOOLEAN;
--声明常量并赋值
    days_worked_month CONSTANT NUMBER(2):=20;
......
```
```sql
DECLARE
    wages           NUMBER(6,2);
    hours_worked    NUMBER :=40;
    hourly_salary   NUMBER :=50.50;
    country         VARCHAR2(128);
    active_emp      BOOLEAN NOT NULL := TRUE; --NOT NULL 约束后必须加一个初始化子句
    valid_id        BOOLEAN;
BEGIN
    wages := (hours_worked * hourky_sakary) + bonus;
    country := 'China';
    valid_id := TRUE;
END;
```
```sql
--使用语句为变量赋值，使用SELECT INTO语句将查询结果赋给变量
DECLARE
    bonus_rate  CONSTANT NUMBER(2,2) := 0.15;
    bonus                NUMBER(7,2);
    emp_id               NUMBER(4) := 7788;
BEGIN
    SELECT sal * bonus_rate INTO bonus FROM emp
      WHERE empno = emp_id;
      DBMS_OUTPUT.PUT_LINE('Employee:'||TO_CHAR(emp_id)||'Bonus:'||TO_CHAR(bonus)||'Bonus Rate:'||TO_CHAR(bonus_rate));
END;
```

#### 2. PL/SQL控制语句