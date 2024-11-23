### 六、PL/SQL[⏪](./sql.md)<a id="here"></a>
- #### [1. 相关概念](#6.1)
- #### [2. PL/SQL控制语句](#6.2)
- #### [3. 游标的使用](#6.3)

#### 1. 相关概念<a id="6.1"></a>[🔝](#here)
- 一个完整的PL/SQL语句块由3个部分组成。  
1）声明部分：**以关键字DECLARE开始**，以BEGIN结束。主要用于声明变量，常量，数据类型，游标，异常处理名称和本地子程序定义等。  
2）执行部分：是PL/SQL语句块的**功能实现**部分，以关键字begin开始，以exception或end结束（如果语句中没有异常处理部分，则以关键字end结束）。该部分通过变量赋值，流程控制，数据查询，数据操纵，数据定义，事务控制，游标处理等操作实现语句块的功能。  
3）异常处理部分：以关键字exception开始，以end结束。该部分用于处理该语句块**执行过程中产生的异常**。  
```sql
DECLARE <说明的变量、常量、游标等>       --可选的声明部分
BEGIN <SQL语句、PL\SQL的流程控制语句>    --可执行的部分
[ EXCEPTION <异常处理部分> ]             --可选的异常处理部分
END;
```

- 声明与赋值（可以在声明时为其赋值，也可在执行部分为其赋值）
%type：定义一个变量，其数据类型与已经定义的某个数据变量的类型相同，或者与数据库表的某个列的数据类型相同，这时可以用%TYPE为变量赋值  
1）使用赋值运算符(:=)；  
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
--赋值运算符赋值
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

#### 2. PL/SQL控制语句<a id="6.2"></a>[🔝](#here)
- 条件控制语句
```sql
--从员工表（假设表名为 employees）中查询某个员工的工资，并根据工资范围判断等级。
DECLARE
    v_salary NUMBER; --用于存储工资
    v_emp_id NUMBER := 101; --假设查询员工ID为101
BEGIN
    -- 查询员工工资
    SELECT salary INTO v_salary 
    FROM employees 
    WHERE employee_id = v_emp_id;

    -- 判断工资等级
    IF v_salary > 10000 THEN
        DBMS_OUTPUT.PUT_LINE('高薪');
    ELSIF v_salary BETWEEN 5000 AND 10000 THEN
        DBMS_OUTPUT.PUT_LINE('中等收入');
    ELSE
        DBMS_OUTPUT.PUT_LINE('低收入');
    END IF;
END;
```
```sql
--从部门表（假设表名为 departments）中查询某个部门的名称，并根据部门名进行分类。
DECLARE
    v_department_name VARCHAR2(50);
    v_dept_id NUMBER := 10; -- 假设查询部门ID为10
    v_result VARCHAR2(50); -- 存储结果
BEGIN
    -- 查询部门名称
    SELECT department_name INTO v_department_name 
    FROM departments 
    WHERE department_id = v_dept_id;

    -- 使用CASE语句进行分类
    CASE v_department_name
        WHEN 'Sales' THEN v_result := '销售部门';
        WHEN 'HR' THEN v_result := '人力资源部门';
        WHEN 'IT' THEN v_result := '信息技术部门';
        ELSE v_result := '其他部门';
    END CASE;

    -- 输出结果
    DBMS_OUTPUT.PUT_LINE('部门分类: ' || v_result);
END;
```
```sql
--CASE嵌套IF-THEN
DECLARE
    v_salary NUMBER;
    v_department_name VARCHAR2(50);
    v_emp_id NUMBER := 101; -- 假设员工ID为101
BEGIN
    -- 查询员工工资和部门名称
    SELECT e.salary, d.department_name
    INTO v_salary, v_department_name
    FROM employees e
    JOIN departments d
    ON e.department_id = d.department_id
    WHERE e.employee_id = v_emp_id;

    -- 综合判断
    IF v_salary > 10000 AND v_department_name = 'Sales' THEN
        DBMS_OUTPUT.PUT_LINE('高薪销售人员');
    ELSIF v_salary > 10000 THEN
        DBMS_OUTPUT.PUT_LINE('高薪非销售人员');
    ELSE
        DBMS_OUTPUT.PUT_LINE('普通员工');
    END IF;
END;
```
- 循环控制语句
```sql
--简单循环求1-100之间偶数的和。(在循环体中一定要包含exit语句，否则程序会进入死循环。)
declare
  count binary_integer:=1;  --BINARY_INTENER用来描述不存储在数据库中，但是需要用来计算的带符号的整数值。它以2的补码二进制形式表述。循环计数器经常使用这种类型。
  sum number:=0;
begin
  loop
    if mod(count,2)=0 then
      sum:=sum+count;
    end if
    count:=count+1;
    exit when count>100;
  end loop;
  dbms_output.put_line(sum);
end;
```
```sql
--while循环求1-100之间偶数的和。
declare 
  count binary_integer:=1;
  sum number:=0;
begin
  while count<=100 loop
    if mod(count,2)=0 then 
      sum:=sum+count;
    end if;
    count:=count+1;
   end loop;
   dbms_output.put_line(sum);
end;
```
```sql
--for循环求1-100的偶数之和
declare
  sum number:=0;
begin
  for count in 1..100 loop
    if mod(count,2)=0 then 
      sum:=sum+count;
    end if;
    count:=count+1;
    end loop;
   dbms_output.put_line(sum);
end;
```

#### 3. 游标的使用<a id="6.3"></a>[🔝](#here)


#### 4. 存储过程与存储函数

#### 5. 数据库触发器