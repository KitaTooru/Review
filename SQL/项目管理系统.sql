/*
基础设施是经济社会发展的重要支撑，基础设施建设是国民经济基础性、先导性、战略性、引领性产业。现在需要我们设计一个小型的基建项目管理系统，通过把工程项目、供应商和原材料信息有机的结合起来（每个供应商只供应一种原材料），从而提高项目的实施效率。系统至少应该包含几个核心模块：项目管理模块、供应商管理模块、原材料管理模块、供需管理模块。
（1）	项目管理模块：用于记录项目的基本信息，包括项目编号、名称、地址、起始时间、项目状态等等；
（2）	供应商管理模块：用于记录供应商的基本信息，包括供应商代码、名称、供应原材料代码等等；
（3）	原材料管理模块：用于记录原材料的基本信息，包括原材料代码、名称、类别、单价、存放地、库存数等等；
（4）	供需管理模块：用于记录项目供需的基本信息，包括项目编号、供应商代码、原材料代码、供应数量等等；
1.创建一个游标，查询所有原料的库存，如果库存数小于等于2，则输出“XXX（原料名）需要补充库存！”。
2.创建一个存储过程，输入项目名称ZZZ能打印“ZZZ项目共需要X种原材料”；如果未找到，那么打印“ZZZ项目还没有记录”。
3.创建一个存储函数，查询“南京甲”项目所需要的“原材料A”的所有信息，至少需要显示项目名、原材料名、原材料单价、供应数量。
4.在项目表上建立一个触发器，当删除项目信息时，删除该项目的所有供需信息。
*/

CREATE TABLE 项目管理 (
    项目编号  VARCHAR(12) PRIMARY KEY CHECK(项目编号 LIKE 'PJNO%'),
    项目名称  VARCHAR(50),
    地址      VARCHAR(50),
    开始时间  DATE,
    项目状态  VARCHAR(6),
    CONSTRAINT 项目状态检查 CHECK (项目状态 IN ('未开始', '施工中', '已交付'))
);

CREATE TABLE 供应商管理(
    供应商代码  VARCHAR(10) PRIMARY KEY,
    名称       VARCHAR(100),
    供应原材料代码  NUMBER(20)
);

CREATE TABLE 原材料管理(
    原材料代码  NUMERIC(20) PRIMARY KEY,
    原材料名称  VARCHAR(40) NOT NULL,
    原材料类别  VARCHAR(40),
    单价       DECIMAL(5,2),
    存放地     VARCHAR(100),
    库存数     INT
);

CREATE TABLE 供需管理(
    供需记录编号  NUMERIC(20),
    项目编号      VARCHAR(12),
    供应商代码    VARCHAR(10),
    原材料代码    NUMERIC(20),
    供应数量      INT NOT NULL,
    FOREIGN KEY (项目编号) REFERENCES 项目管理(项目编号),
    FOREIGN KEY (供应商代码) REFERENCES 供应商管理(供应商代码),
    FOREIGN KEY (原材料代码) REFERENCES 原材料管理(原材料代码)
);

DECLARE
CURSOR 查询原材料库存(最小库存数 IN NUMBER) IS
SELECT 原材料名称,库存数 
FROM 原材料管理
WHERE 库存数 <= 最小库存数;
v_原材料名称 原材料管理.原材料名称%TYPE;
v_库存数 原材料管理.库存数%TYPE;
BEGIN
    OPEN 查询原材料库存(2);
    LOOP
        FETCH 查询原材料库存 INTO v_原材料名称, v_库存数;
        EXIT WHEN 查询原材料库存%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('原材料'||v_原材料名称||'需要补充库存！');
    END LOOP;
    CLOSE 查询原材料库存;
END;
/

CREATE OR REPLACE PROCEDURE 查询所需原材料数量(项目名称 IN VARCHAR)
AS
    原材料种类数量 INT;
BEGIN
    SELECT COUNT(DISTINCT 原材料代码)
    INTO 原材料种类数量
    FROM 供需管理
    JOIN 项目管理 ON 供需管理.项目编号 = 项目管理.项目编号
    WHERE 项目管理.项目名称 = 项目名称;
    IF 原材料种类数量 > 0 THEN
        DBMS_OUTPUT.PUT_LINE(项目名称||'项目共需要'||原材料种类数量||'种原材料');
    ELSE
        DBMS_OUTPUT.PUT_LINE(项目名称||'项目还没有记录');
    END IF;
END;
/

CREATE OR REPLACE FUNCTION 所需信息(项目名称 IN VARCHAR,原材料名称 IN VARCHAR)
RETURN VARCHAR IS 
查询结果 VARCHAR(200);
BEGIN
    SELECT 项目管理.项目名称||' '||原材料管理.原材料名称||' '||原材料管理.单价||' '||供需管理.供应数量
    INTO 查询结果
    FROM 供需管理
    JOIN 项目管理 ON 供需管理.项目编号=项目管理.项目编号
    JOIN 原材料管理 ON 供需管理.原材料代码=原材料管理.原材料代码
    WHERE 项目管理.项目名称=项目名称 AND 原材料管理.原材料名称=原材料名称;
    RETURN 查询结果;
END;
/

CREATE OR REPLACE TRIGGER 删除供需记录
AFTER DELETE ON 项目管理
FOR EACH ROW
BEGIN
    DELETE FROM 供需管理 WHERE 项目编号 = :OLD.项目编号;
END;
/
