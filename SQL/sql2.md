### 六、PL/SQL[⏪](./sql.md)<a id="here"></a>
- #### [1. 相关概念](#6.1)
- #### [2. PL/SQL控制语句](#6.2)
- #### [3. 游标的使用](#6.3)
- #### [4. 存储过程与存储函数](#6.4)
- #### [5. 数据库触发器](#6.5)

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
1）简单循环
```sql
loop
  循环语句;
  exit when 结束条件;
end loop;
```
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
  2）while循环
```sql
while 循环条件 loop
    循环语句;
end loop;
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
  3）for循环
```sql
for 循环变量 in [reverse] 最小值..最大值 loop
  sequence_of_statement;
end loop;
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
游标：是系统开设的一个**数据缓冲区**，存放SQL语句的执行结果。  
作用：用户可通过游标获取记录，并赋给变量。  
当对数据库的查询操作返回一组结果集时，存入游标，以后通过对游标的操作来获取结果集中的数据信息。  
游标分显式游标和隐式游标。当查询语句返回多条记录时，必须显式地定义游标以处理每一行。其他的SQL语句(更新操作或查询操作只返回一条记录)都使用隐式游标。
```sql
--游标的定义：
--CURSOR <游标名> IS <SQL语句>;
--例：
CURSOR c_emp IS SELECT * FROM emp WHERE dno=3; 
 
--当需要操作结果集时，须完成：打开游标、使用FETCH语句将游标里的数据取出以及关闭游标操作。
--游标声明：
	CURSOR  游标名 IS 查询语句;
--游标的打开：
	OPEN 游标名;
--游标的取值：
	FETCH 游标名 INTO 变量列表;
--游标的关闭：
	CLOSE 游标名;
```
```sql
--使用游标查询emp表中所有员工的姓名和工资，并将其依次打印出来
DECLARE
  CURSOR c_emp IS 	--声明游标
  SELECT ename, sal FROM emp;	 --声明变量用来接受游标中的元素
  v_ename emp.ename%TYPE;
  v_sal emp.sal%TYPE;
BEGIN
  OPEN c_emp;	 --打开游标
  LOOP	--遍历游标中的值
    FETCH c_emp into v_ename, v_sal ; 	 --通过FETCH语句获取游标中的值并赋值                      
    EXIT WHEN c_emp%NOTFOUND; 	--判断是否有值,有值打印,没有则退出循环
    DBMS_OUTPUT.PUT_LINE('姓名:' || v_ename || ',薪水:' || v_sal)
  END LOOP;
  CLOSE c_emp;	 --关闭游标
END;
 
--使用游标查询并打印某部门的员工的姓名和薪资，部门编号为运行时手动输入。
DECLARE
  CURSOR c_emp(v_empno emp.empno%TYPE) IS
    SELECT ename, sal FROM emp WHERE empno = v_empno;
  v_ename emp.ename%TYPE;
  v_sal emp.sal%TYPE;
BEGIN
  OPEN c_emp(10);	 --打开游标
  LOOP	--遍历游标中的值
  FETCH c_emp INTO v_ename, v_sal ; 	 --通过FETCH语句获取游标中的值并赋值            
  EXIT  WHEN c_emp%NOTFOUND; 	--判断是否有值,有值打印,没有则退出循环
  DBMS_OUTPUT.PUT_LINE('姓名:' || v_ename || ',薪水:' || v_sal)
  END LOOP;
  CLOSE c_emp;	 --关闭游标
END;
```
```sql
--带参游标在声明的时候定义形式参数，打开游标的时候指定实际参数
DECLARE
  -- 定义带参数的游标，查询薪水大于给定值的员工
  CURSOR emp_cursor (min_salary IN NUMBER) IS
    SELECT employee_id, first_name, last_name, salary
    FROM employees
    WHERE salary > min_salary;
  -- 定义变量来保存游标返回的结果
  v_employee_id employees.employee_id%TYPE;
  v_first_name employees.first_name%TYPE;
  v_last_name employees.last_name%TYPE;
  v_salary employees.salary%TYPE;
BEGIN
  -- 打开游标并传入参数
  OPEN emp_cursor(5000);  -- 查询薪水大于5000的员工
  LOOP
    FETCH emp_cursor INTO v_employee_id, v_first_name, v_last_name, v_salary;
    EXIT WHEN emp_cursor%NOTFOUND;
    -- 输出员工信息
    DBMS_OUTPUT.PUT_LINE('Employee ID: ' || v_employee_id ||
                         ', Name: ' || v_first_name || ' ' || v_last_name ||
                         ', Salary: ' || v_salary);
  END LOOP;
  CLOSE emp_cursor;
END;
```

#### 4. 存储过程与存储函数<a id="6.4"></a>[🔝](#here)
存储过程无返回值，存储函数必须有一个返回值
- 存储过程的创建与使用  
```sql
CREATE OR REPLACE PROCEDURE procedure_name (
    parameter1 [IN | OUT | IN OUT] datatype,
    parameter2 [IN | OUT | IN OUT] datatype
) AS
    -- 声明部分
BEGIN
    -- 执行部分
EXCEPTION
    -- 异常处理部分
END procedure_name;
```
1）无参存储过程  
```sql
CREATE OR REPLACE PROCEDURE add_sal
  AS BEGIN
    UPDATE emp
    SET sal = sal * 1.1
    WHERE sal<3000;
END;
```

2）有参存储过程
```sql
--根据输入的员工ID输出员工的工资
CREATE OR REPLACE PROCEDURE get_employee_salary (p_emp_id IN NUMBER) 
AS
    v_salary NUMBER;
BEGIN
    SELECT salary INTO v_salary
    FROM employees
    WHERE employee_id = p_emp_id;

    DBMS_OUTPUT.PUT_LINE('员工ID ' || p_emp_id || ' 的工资是：' || v_salary);
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('未找到该员工的记录。');
END;
```
```sql
--根据员工ID获取员工姓名，并返回工资。
CREATE OR REPLACE PROCEDURE get_employee_details (
    p_emp_id IN NUMBER,
    p_emp_name OUT VARCHAR2,
    p_salary OUT NUMBER
) AS
BEGIN
    SELECT first_name, salary INTO p_emp_name, p_salary
    FROM employees
    WHERE employee_id = p_emp_id;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        p_emp_name := '未找到';
        p_salary := 0;
END;
--调用：
DECLARE
    v_name VARCHAR2(50);
    v_salary NUMBER;
BEGIN
    get_employee_details(101, v_name, v_salary);
    DBMS_OUTPUT.PUT_LINE('姓名: ' || v_name || ', 工资: ' || v_salary);
END;
```
```sql
--根据员工ID更新工资，同时返回更新前的工资。
CREATE OR REPLACE PROCEDURE update_salary (
    p_emp_id IN NUMBER,
    p_new_salary IN NUMBER,
    p_old_salary OUT NUMBER
) AS
BEGIN
    -- 查询更新前的工资
    SELECT salary INTO p_old_salary
    FROM employees
    WHERE employee_id = p_emp_id;

    -- 更新工资
    UPDATE employees
    SET salary = p_new_salary
    WHERE employee_id = p_emp_id;

    DBMS_OUTPUT.PUT_LINE('员工ID ' || p_emp_id || ' 的工资已更新为：' || p_new_salary);
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('未找到该员工的记录，无法更新工资。');
END;
--调用
DECLARE
    v_old_salary NUMBER;
BEGIN
    update_salary(101, 8000, v_old_salary);
    DBMS_OUTPUT.PUT_LINE('更新前的工资为：' || v_old_salary);
END;
```

- 存储函数的创建与使用
```sql
CREATE OR REPLACE FUNCTION function_name (
    parameter1 datatype,
    parameter2 datatype
) RETURN return_datatype IS
    -- 声明部分
BEGIN
    -- 执行部分
    RETURN value; -- 必须返回一个值
EXCEPTION
    -- 异常处理部分（可选）
END function_name;
```
1）无参数存储函数
```sql
CREATE OR REPLACE FUNCTION say_hello
RETURN VARCHAR2 IS
BEGIN
    RETURN '欢迎使用Oracle存储函数！';
END;
--调用：
BEGIN
    DBMS_OUTPUT.PUT_LINE(say_hello);
END;
```
2）带参数存储函数
```sql
/*创建一个存储函数，用于获取员工的详细信息：
输入员工ID（可选），默认查询公司中薪资最高的员工。
返回包含员工姓名、职位、工资和员工等级的字符串。
根据工资确定员工等级：
工资 > 20000：高级
工资在 10000 和 20000 之间：中级
工资 < 10000：初级
如果输入的员工ID不存在，返回提示“未找到员工”。*/
CREATE OR REPLACE FUNCTION get_employee_info (p_emp_id NUMBER DEFAULT NULL) 
RETURN VARCHAR2 IS
    -- 声明部分
    v_emp_name VARCHAR2(100);
    v_job_title VARCHAR2(100);
    v_salary NUMBER;
    v_level VARCHAR2(20);
    v_result VARCHAR2(400);
BEGIN
    -- 执行部分
    IF p_emp_id IS NULL THEN
        -- 如果未传递员工ID，查询公司工资最高的员工
        SELECT first_name || ' ' || last_name, job_title, salary
        INTO v_emp_name, v_job_title, v_salary
        FROM employees
        WHERE salary = (SELECT MAX(salary) FROM employees);
    ELSE
        -- 查询指定员工ID的信息
        SELECT first_name || ' ' || last_name, job_title, salary
        INTO v_emp_name, v_job_title, v_salary
        FROM employees
        WHERE employee_id = p_emp_id;
    END IF;

    -- 根据工资确定员工等级
    IF v_salary > 20000 THEN
        v_level := '高级';
    ELSIF v_salary BETWEEN 10000 AND 20000 THEN
        v_level := '中级';
    ELSE
        v_level := '初级';
    END IF;

    -- 生成结果字符串
    v_result := '姓名: ' || v_emp_name || ', 职位: ' || v_job_title ||
                ', 工资: ' || v_salary || ', 等级: ' || v_level;

    RETURN v_result;

EXCEPTION
    -- 异常处理：如果未找到记录
    WHEN NO_DATA_FOUND THEN
        RETURN '未找到员工信息，请检查员工ID。';
    -- 其他异常
    WHEN OTHERS THEN
        RETURN '发生未知错误，请联系管理员。';
END;
```

#### 5. 数据库触发器<a id="6.5"></a>[🔝](#here)
```sql
CREATE [OR REPLACE] TRIGGER trigger_name
{BEFORE | AFTER | INSTEAD OF}
{INSERT [OR] | UPDATE [OR] | DELETE}
ON table_name
[FOR EACH ROW]
[WHEN (condition)]
DECLARE
    -- 可选的变量或游标声明
BEGIN
    -- 触发器的逻辑代码
EXCEPTION
    -- 可选的异常处理
END;
```
```sql
CREATE OR REPLACE TRIGGER trg_after_insert_update_employee
AFTER INSERT OR UPDATE ON employees
FOR EACH ROW
BEGIN
    IF INSERTING THEN
        INSERT INTO employee_actions (action_id, employee_id, action_type, action_date)
        VALUES (employee_actions_seq.NEXTVAL, :NEW.employee_id, 'INSERT', SYSDATE);
    ELSIF UPDATING THEN
        INSERT INTO employee_actions (action_id, employee_id, action_type, action_date)
        VALUES (employee_actions_seq.NEXTVAL, :NEW.employee_id, 'UPDATE', SYSDATE);
    END IF;
END;
--调用：
INSERT INTO employees (employee_id, first_name, last_name, salary)
VALUES (102, 'Alice', 'Smith', 6000);

UPDATE employees
SET salary = 6500
WHERE employee_id = 102;

SELECT * FROM employee_actions;
```