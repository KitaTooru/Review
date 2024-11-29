/*
电子商务是指以信息网络技术为手段，以商品交换为中心的商务活动；买卖双方不谋面地进行各种商贸活动，实现消费者的网上购物、商户之间的网上交易和在线电子支付以及各种商务活动、交易活动、金融活动和相关的综合服务活动的一种新型的商业运营模式。现在需要我们设计一个小型的电子商务系统。系统至少应该包含几个核心模块：用户管理模块、商品管理模块、订单管理模块、购物车管理模块、供应商管理模块。
（1）	用户管理模块：用于记录用户的基本信息，包括用户名、密码、电话等等；
（2）	商品管理模块：用于记录销售的商品信息，包括商品名称、商品描述、商品分类、供货商等等；
（3）	订单管理模块：用于记录用户订购商品的信息，包括用户姓名、电话、地址、商品名、订单状态等等；
（4）	购物车管理模块：用于记录用户购物已选但未支付的商品；
（5）	供应商管理模块：用于记录供应商信息，包括供应商名称、联系人、电话、营业执照等等。

1. 创建一个存储过程，输入商品名称（模糊）能打印“共找到XXX个供应商提供XXX商品!”，如果未找到，那么打印“没有供应商提供XXX商品”。
2. 创建一个存储过程，查询用户购物车商品信息，并按商品添加时间降序排列。
3. 在用户表上建立一个触发器，当删除用户信息时，删除用户所有订单信息和购物车信息。
*/

CREATE TABLE 用户管理(
    用户编号 VARCHAR(20) PRIMARY KEY,
    用户名   VARCHAR(10) NOT NULL,
    密码     VARCHAR(20),
    电话     NUMBER(11)
);

CREATE TABLE 供应商管理(
    供应商编号  VARCHAR(20) PRIMARY KEY,
    供应商名称  VARCHAR(10) NOT NULL,
    联系人      VARCHAR(10),
    电话        NUMBER(11),
    营业执照    VARCHAR(50)
);

CREATE TABLE 商品管理(
    商品编号    VARCHAR(20) PRIMARY KEY,
    商品名称    VARCHAR(20),
    商品描述    VARCHAR(50),
    商品分类    VARCHAR(20),
    供应商编号  VARCHAR(10) REFERENCES 供应商管理(供应商编号)
);

CREATE TABLE 订单管理(
    订单编号    VARCHAR(20) PRIMARY KEY,
    用户编号    VARCHAR(20) REFERENCES 用户管理(用户编号),
    商品编号    VARCHAR(20) REFERENCES 商品管理(商品编号),
    地址        VARCHAR(50),
    订单状态    VARCHAR(20)
);

CREATE TABLE 购物车管理(
    购物车编号  VARCHAR(20),
    用户编号    VARCHAR(20) REFERENCES 用户管理(用户编号),
    商品编号    VARCHAR(20) REFERENCES 商品管理(商品编号),
    商品添加时间    DATE
);

CREATE OR REPLACE PROCEDURE 供应商供应商品信息(s_商品名 IN VARCHAR)
AS
    s_number INT;
BEGIN
    SELECT COUNT(DISTINCT 商品管理.供应商编号)
    INTO s_number
    FROM 供应商管理
    JOIN 商品管理 ON 供应商管理.供应商编号=商品管理.供应商编号
    WHERE 商品管理.商品名称=s_商品名;
    IF s_number>0 THEN
        DBMS_OUTPUT.PUT_LINE('共找到'||s_number||'个供应商提供'||s_商品名||'商品!');
    ELSE
        DBMS_OUTPUT.PUT_LINE('没有供应商提供'||s_商品名||'商品。');
    END IF;
END;
/


-- 2.方法一：用游标
CREATE OR REPLACE PROCEDURE 用户购物车商品信息(u_用户编号 IN VARCHAR)
AS 
CURSOR c_购物车商品 IS
        SELECT 
            商品管理.商品编号,
            商品管理.商品名称,
            商品管理.商品描述,
            商品管理.商品分类,
            购物车管理.商品添加时间
        FROM 购物车管理
        JOIN 商品管理 ON 购物车管理.商品编号 = 商品管理.商品编号
        WHERE 购物车管理.用户编号 = u_用户编号
        ORDER BY 购物车管理.商品添加时间 DESC;
    r_购物车商品 c_购物车商品%ROWTYPE;
BEGIN
    OPEN c_购物车商品;
    LOOP
        FETCH c_购物车商品 INTO r_购物车商品;
        EXIT WHEN c_购物车商品%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('商品编号: '||r_购物车商品.商品编号||', 商品名称: '||r_购物车商品.商品名称||', 商品描述: '||r_购物车商品.商品描述||', 商品分类: '||r_购物车商品.商品分类||',添加时间:'||TO_CHAR(r_购物车商品.商品添加时间, 'YYYY-MM-DD HH24:MI:SS'));
    END LOOP;
    CLOSE c_购物车商品;
END;
/

-- 2.方法二：FOR循环
CREATE OR REPLACE PROCEDURE 查询购物车商品信息(p_用户编号 IN VARCHAR)
AS
BEGIN
    FOR r IN (
        SELECT 
            g.商品编号,
            g.商品名称,
            g.商品描述,
            g.商品分类,
            c.商品添加时间
        FROM 购物车管理 c
        JOIN 商品管理 g ON c.商品编号 = g.商品编号
        WHERE c.用户编号 = p_用户编号
        ORDER BY c.商品添加时间 DESC
    ) LOOP
        DBMS_OUTPUT.PUT_LINE('商品编号: ' || r.商品编号 || 
                             ', 商品名称: ' || r.商品名称 || 
                             ', 商品描述: ' || r.商品描述 || 
                             ', 商品分类: ' || r.商品分类 || 
                             ', 添加时间: ' || TO_CHAR(r.商品添加时间, 'YYYY-MM-DD HH24:MI:SS'));
    END LOOP;
END;
/

CREATE OR REPLACE TRIGGER 删除信息
AFTER DELETE ON 用户管理
FOR EACH ROW
BEGIN
    DELETE FROM 订单管理 WHERE 用户编号=:OLD.用户编号;
    DELETE FROM 购物车管理 WHERE 用户编号=:OLD.用户编号;
END;
/