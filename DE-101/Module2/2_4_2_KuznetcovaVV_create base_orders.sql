-- создание базы для таблицы orders

-- CALENDAR "dim_calendar"
--create
CREATE TABLE "dim_calendar"
(
 "calendar_id" serial NOT NULL,
 "order_date"  date NOT NULL,
  "ship_date"   date NOT NULL,
  "order_id"    varchar(50) NOT NULL,
 CONSTRAINT "PK_calendar" PRIMARY KEY ( "calendar_id" )
);

COMMENT ON TABLE "dim_calendar" IS 'заказ происходит
 в определенный день,
 доставка тоже';

--clean rows
truncate table dim_calendar;

--insert data
insert into dim_calendar 
select 100+row_number() over () as calendar_id, order_date , ship_date, order_id from (select distinct order_date, ship_date, order_id from orders) a;

--check data in calendar
select * from dim_calendar;

-- CUSTOMER
--create table "dim_customer"


CREATE TABLE "dim_customer"
(
 "customer_id"   serial NOT NULL,
 "customer_name" varchar(150) NOT NULL,
 "segment"       varchar(50) NOT NULL,
 "customerid_o"  varchar(50) NOT NULL,
 CONSTRAINT "PK_customer" PRIMARY KEY ( "customer_id" )
);

COMMENT ON TABLE "dim_customer" IS 'заказ делает
 потребитель';

--clean rows
truncate table dim_customer;

--insert data
insert into dim_customer 
select 100+row_number() over () as customer_id, customer_name, segment, customer_id as customerid_o
from (select distinct customer_name, segment, customer_id from orders) a;

--check data in customer
select * from dim_customer;

--CREATE MANAGERS
--create table "dim_managers"
CREATE TABLE "dim_managers"
(
 "region_id" serial NOT NULL,
 "manager"   varchar(150) NOT NULL,
 "region"    varchar(50) NOT NULL,
 CONSTRAINT "PK_managers" PRIMARY KEY ( "region_id" )
);

COMMENT ON TABLE "dim_managers" IS 'каждая территория
 закреплена
 за определенным 
менеджером';
--clean rows
truncate table dim_managers;

--insert data
insert into dim_managers 
select 100+row_number() over () as region_id, person as manager,region  from (select distinct person,region from people) a;

--check data in managers
select * from dim_managers;

-- CREATE Geografy
--create table "dim_geo"
drop table dim_geo cascade;
CREATE TABLE "dim_geo"
(
 "geo_id"    serial NOT NULL,
 "country"   varchar(50) NOT NULL,
 "city"      varchar(50) NOT NULL,
 "state"     varchar(50) NOT NULL,
  "postal"    integer NOT NULL,
  "region_id" integer NOT NULL,
 CONSTRAINT "PK_geografy" PRIMARY KEY ( "geo_id" ),
 CONSTRAINT "FK_138" FOREIGN KEY ( "region_id" ) REFERENCES "dim_managers" ( "region_id" )
);

CREATE INDEX "fkIdx_138" ON "dim_geo"
(
 "region_id"
);

COMMENT ON TABLE "dim_geo" IS 'доставка заказа
 по определенному
 адресу';
--clean rows
truncate table dim_geo;

--insert data
insert into dim_geo 
select 100+row_number() over () as geo_id, country,city,state,  postal_code as postal, region_id
from (select distinct country,city,state, postal_code, region_id from orders o 
 inner join dim_managers m on o.region=m.region) a;

--check data in geo
select * from dim_geo;

-- City Burlington, Vermont doesn't have postal code
update dim_geo
set postal = '05401'
where city = 'Burlington'  and postal is null;

--also update source file
update orders
set postal_code = '05401'
where city = 'Burlington'  and postal_code is null;

-- PRODUCT
--create table "dim_product"
drop table dim_product cascade;
CREATE TABLE "dim_product"
(
 "product_id"   serial NOT NULL,
 "product_name" varchar(200) NOT NULL,
 "category"     varchar(50) NOT NULL,
 "sub_category" varchar(50) NOT NULL,
 "productid_o"  varchar(50) NOT NULL,
 CONSTRAINT "PK_product" PRIMARY KEY ( "product_id" )
);

COMMENT ON TABLE "dim_product" IS 'заказ состоит 
из конкретных продуктов, 
продукты классифицированы
 по категориям и подкатегориям';
--clean rows
truncate table dim_product;

--insert data
insert into dim_product
select 100+row_number() over () as product_id, product_name,category, subcategory as sub_category, product_id as productid_o
from (select distinct product_name,category, subcategory,product_id from orders) a;

--check data in product
select * from dim_product;

-- SHIPPING
--create table "dim_shipping"

CREATE TABLE "dim_shipping"
(
 "ship_id"   serial NOT NULL,
 "ship_mode" varchar(50) NOT NULL,
 CONSTRAINT "PK_ship_mode" PRIMARY KEY ( "ship_id" )
);

COMMENT ON TABLE "dim_shipping" IS 'доставка может быть
 разными способами';

--clean rows
truncate table dim_shipping;

--insert data
insert into dim_shipping
select 100+row_number() over () as ship_id, ship_mode
from (select distinct ship_mode from orders) o;

--check data in shipping
select * from dim_shipping;


-- RETURNS
--CREATE TABLE "dim_returns"
drop table "dim_returns";
drop table fact_sales ;
drop table retu ;
CREATE TABLE "dim_returns"
(
 "return_id" serial NOT NULL,
 "returned"  varchar(50) NOT NULL,
 "order_id"  varchar(50) NOT NULL,
 CONSTRAINT "PK_returns" PRIMARY KEY ( "return_id" )
);

COMMENT ON TABLE "dim_returns" IS 'по некоторым заказам 
бывают возвраты';


truncate table dim_returns;

--insert data
insert into dim_returns
select 100+row_number() over () as return_id, return_mode as returned,order_id
from (select distinct return_mode,  order_id from returns) a;

--check data in returns
select * from dim_returns dr ;
select count(*) from dim_returns dr ;
-- SALES
-- create table "fact_sales"

CREATE TABLE "fact_sales"
(
 "row_id"      serial NOT NULL,
 "order_id"    varchar(50) NOT NULL,
 "sales"       numeric NOT NULL,
 "quantity"    int NOT NULL,
 "discount"    numeric NOT NULL,
 "profit"      numeric NOT NULL,
 "product_id"  integer NOT NULL,
 "geo_id"      integer NOT NULL,
 "ship_id"     integer NOT NULL,
 "calendar_id" integer NOT NULL,
 "customer_id" integer NOT NULL,
 "return_id"   integer NOT NULL,
 CONSTRAINT "PK_sales_fact" PRIMARY KEY ( "row_id" ),
 CONSTRAINT "FK_124" FOREIGN KEY ( "product_id" ) REFERENCES "dim_product" ( "product_id" ),
 CONSTRAINT "FK_127" FOREIGN KEY ( "geo_id" ) REFERENCES "dim_geo" ( "geo_id" ),
 CONSTRAINT "FK_163" FOREIGN KEY ( "ship_id" ) REFERENCES "dim_shipping" ( "ship_id" ),
 CONSTRAINT "FK_172" FOREIGN KEY ( "calendar_id" ) REFERENCES "dim_calendar" ( "calendar_id" ),
 CONSTRAINT "FK_207" FOREIGN KEY ( "customer_id" ) REFERENCES "dim_customer" ( "customer_id" ),
 CONSTRAINT "FK_227" FOREIGN KEY ( "return_id" ) REFERENCES "dim_returns" ( "return_id" )
);

CREATE INDEX "fkIdx_124" ON "fact_sales"
(
 "product_id"
);

CREATE INDEX "fkIdx_127" ON "fact_sales"
(
 "geo_id"
);

CREATE INDEX "fkIdx_163" ON "fact_sales"
(
 "ship_id"
);

CREATE INDEX "fkIdx_172" ON "fact_sales"
(
 "calendar_id"
);

CREATE INDEX "fkIdx_207" ON "fact_sales"
(
 "customer_id"
);

CREATE INDEX "fkIdx_227" ON "fact_sales"
(
 "return_id"
);

COMMENT ON TABLE "fact_sales" IS 'основная таблица
 с данными по заказам
 и кодами для связей 
со справочниками';


--clean rows
truncate table fact_sales;

--insert data
insert into fact_sales
select 100+row_number() over () as row_id, o.order_id, sales, quantity, discount, profit, p.product_id, g.geo_id,
s.ship_id, c.calendar_id, cu.customer_id, return_id
from orders o inner join dim_product p on o.product_id=p.productid_o and  o.product_name=p.product_name
inner join dim_geo g on o.postal_code=g.postal and o.city=g.city 
inner join dim_shipping s on o.ship_mode=s.ship_mode inner join dim_calendar c on o.order_id=c.order_id inner join 
dim_customer cu on o.customer_name=cu.customer_name left join dim_returns dr on o.order_id = dr.order_id ;

--check data in sales

select * from fact_sales; 
select count(*) from fact_sales;
select category, sum(sales) from fact_sales sf inner join dim_product dp on sf.product_id = dp.product_id group by category ;
select segment, sum(sales) from fact_sales sf inner join dim_customer dc  on sf.customer_id = dc.customer_id group by segment ;
select region, sum(sales) from fact_sales sf inner join dim_geo dg on sf.geo_id = dg.geo_id 
inner join dim_managers dm on dg.region_id=dm.region_id group by region;

select region, count(dg.postal) from fact_sales sf inner join dim_geo dg on sf.geo_id = dg.geo_id 
inner join dim_managers dm on dg.region_id=dm.region_id group by region ;




--check data in dim_returns
select count(returned) from dim_returns;
select count(calendar_id) from dim_calendar dc;
select count(customer_id) from dim_customer dc;
select count(geo_id) from dim_geo dg;
select count(region_id) from dim_managers dm;
select count(product_id) from dim_product dp;
select count(ship_id) from dim_shipping ds;
--check data in fact-sales
select count(order_id) from fact_sales sf;
select order_id, product_name, segment, customer_name, order_date, sales from fact_sales fs2 inner join dim_customer dc on fs2.customer_id=dc.customer_id
inner join dim_calendar dc2 on fs2.calendar_id=dc2.calendar_id inner join dim_product dp on fs2.product_id=dp.product_id;
--inner join dim_shipping ds ON  sf.ship_id=ds.ship_id 
--inner join dim_geo dg on sf.geo_id=dg.geo_id
--inner join dim_product dp on sf.product_id=dp.product_id
--inner join dim_customer dc on sf.customer_id=dc.customer_id;


 