/*
设计一个小型的网上商城管理系统，系统至少应该包含几个核心模块：商品管理模块、供应商管理模块、用户管理模块和订单管理模块。
（1）	商品管理模块：用于记录销售的商品信息，包括商品名称、商品编号、商品类别、商品产地、库存数和供货商编号等等；
（2）	供应商管理模块：用于记录供应商的基本信息，包括供应商代码、供应商名称、供应的商品编号、联系电话等等；
（3）	用户管理模块：用于记录用户的基本信息，包括用户编号、名称、密码、地址、联系电话等等；
（4）	订单管理模块：用于记录平台订单的基本信息，包括用户编号、商品编号、订单状态、配送地址、联系电话等等；
1. 用SQL语句创建表格，包括主外键；其中用户编号必须是8个字符长度，并且以’2023’开始。例如，‘20230001’。
2. 查询各种状态下的订单数量，订单状态为：已下单、已发货、已签收和已退单。
3. 创建一个视图，显示销售数量最多的商品的详细信息。
4. 查询商品名包含“手机”的商品的所有订单信息。
5. 查询用户名为“用户A”的用户的所有已购买商品的平均价格、最高价格、最低价格。
6. 查询购买了“商品A”但没有购买“商品B”的用户编号和名称。
*/

CREATE TABLE 用户管理 (
    用户编号 NVARCHAR2(8) PRIMARY KEY CHECK (用户编号 LIKE '2023%'),
    用户名称 NVARCHAR2(50) NOT NULL,
    密码 NVARCHAR2(50) NOT NULL,
    地址 NVARCHAR2(100),
    联系电话 NVARCHAR2(15)
);

CREATE TABLE 商品管理 (
    商品编号 NUMBER PRIMARY KEY,
    商品名称 NVARCHAR2(50) NOT NULL,
    商品类别 NVARCHAR2(50),
    商品产地 NVARCHAR2(50),
    库存数 NUMBER,
    供货商编号 NUMBER
);

CREATE TABLE 供应商管理 (
    供应商代码 NUMBER PRIMARY KEY,
    供应商名称 NVARCHAR2(50) NOT NULL,
    供应的商品编号 NUMBER,
    联系电话 NVARCHAR2(15),
    FOREIGN KEY (供应的商品编号) REFERENCES 商品管理(商品编号)
);

CREATE TABLE 订单管理 (
    订单编号 NUMBER PRIMARY KEY,
    用户编号 NVARCHAR2(8),
    商品编号 NUMBER,
    订单状态 NVARCHAR2(10) CHECK (订单状态 IN ('已下单', '已发货', '已签收', '已退单')),
    配送地址 NVARCHAR2(100),
    联系电话 NVARCHAR2(15),
    FOREIGN KEY (用户编号) REFERENCES 用户管理(用户编号),
    FOREIGN KEY (商品编号) REFERENCES 商品管理(商品编号)
);

ALTER TABLE 商品管理 ADD CONSTRAINT 商品管理_供应商管理_FK FOREIGN KEY (供货商编号) REFERENCES 供应商管理(供应商代码);
ALTER TABLE 商品管理 ADD(价格 NUMBER);

SELECT 订单状态, COUNT(*) AS 订单数量
FROM 订单管理
GROUP BY 订单状态;

CREATE OR REPLACE VIEW 视图 AS
SELECT 商品管理.*
FROM 商品管理
JOIN (
    SELECT 商品编号, COUNT(*) AS 销售数量
    FROM 订单管理
    GROUP BY 商品编号
    ORDER BY COUNT(*) DESC
    FETCH FIRST 1 ROWS ONLY
) 热销商品 ON 商品管理.商品编号 = 热销商品.商品编号;

SELECT 订单管理.*
FROM 订单管理
JOIN 商品管理 ON 订单管理.商品编号 = 商品管理.商品编号
WHERE 商品管理.商品名称 LIKE '%手机%';

SELECT 
    AVG(商品管理.价格) AS 平均价格,
    MAX(商品管理.价格) AS 最高价格,
    MIN(商品管理.价格) AS 最低价格
FROM 订单管理
JOIN 商品管理 ON 订单管理.商品编号 = 商品管理.商品编号
JOIN 用户管理 ON 订单管理.用户编号 = 用户管理.用户编号
WHERE 用户管理.用户名称 = '用户A';

SELECT DISTINCT 用户管理.用户编号, 用户管理.用户名称
FROM 用户管理
WHERE 用户管理.用户编号 IN (
    SELECT 用户编号
    FROM 订单管理
    WHERE 商品编号 = (
        SELECT 商品编号 FROM 商品管理 WHERE 商品名称 = '商品A'
    )
)
AND 用户管理.用户编号 NOT IN (
    SELECT 用户编号
    FROM 订单管理
    WHERE 商品编号 = (
        SELECT 商品编号 FROM 商品管理 WHERE 商品名称 = '商品B'
    )
);
