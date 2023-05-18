/*  #1 SHOW PERCENTAGE CHANGE IN OPENING AND CLOSING STOCK PRICE ON THAT	 DAY
ROUND UP TO TWO DECIMAL PLACE */ 
SELECT * , concat(round(((close - open) / open)*100,2),'%')  as
percent_change_in_stockprice
FROM twitter.twitter  ;


-- #2 Show me the month in which positive  percentage change in opening and closeing  stock are maximum
with ct1 as (SELECT  date_format(date,'%Y  %M') month , avg(open) open ,avg(close) close   from twitter
group by date_format(date, '%Y  %M')
order by  	month  ) ,
ct2 as (select *,   concat(round(((close - open) / open)*100,2),'%')  as percent_change_in_stockprice 
from ct1) 
select * from ct2
where percent_change_in_stockprice =(select  max(percent_change_in_stockprice) from ct2) ;




--  #3 SHOW ME THE TOP 5 DATE WHERE POSIIVE VOLUME CHANGE IS MAXIMUM 
 with cte as (select *, dense_rank() over(order by Volm_change_prev_date desc ) rankk from ( select * , volume -lag(volume) over(order by date asc) Volm_change_prev_date from twitter  ) b )
 select * from cte 
 where rankk<6 ;

-- #4  FIND 50 DAY MOVING AVERAGE OF AVERAGE STOCK PRICE OF EACH DAY

select  *,  avg((close+open)/2) over(order by date asc rows   between  50 preceding and current row) 
50_day_opening_moving_avg  from twitter 
 ;
 /* #5   SQL JOIN 
 SHOW ME THE DATE AT WHICH AVG STOCK PRICE OF THAT DATE IS
 GREATER THAN 
 AVERAGE STOCK PRICE OF THAT MONTH */ 
 
 with cte as (select date_format(date,'%Y  %M') datte ,  avg((close+open)/2) month_avg from twitter
 group by Date_FORMAT(date,'%Y  %M') 
 order by datte )
 select tt.date , tt.open, tt.close , cte.month_avg   
,  (tt.open+tt.close)/2 avgg  , cte.datte  from  twitter tt
 join cte on cte.datte=date_format(tt.date,'%Y  %M') 
 where  ((tt.open+tt.close)/2) > cte.month_avg ;

-- #6 PERCENTAGE CHANGE IN STOCK PRICE BETWEEN YEAR 2014 TO 2015 FOR EACH MONTH --

 select * from (select  substring(date,5) month , avg_month 'stock_price in 2014',
 lead(avg_month) over(partition by substring(date,5) order by date asc )  'stock_price_in_2015', concat(round(lead(avg_month) over(partition by substring(date,5)  order by date
 asc )/avg_month,4),'%') 'percent-change_from 2014_to_2015'
 from (  select date_format(date,'%Y%M') date , avg((open+close)/2) avg_month  from  twitter
 where year(date) between 2014 and 2015  
 group by date_format(date,'%Y%M') ) b) n 
 where stock_price_in_2015 is not null ;
 
-- SHOW ME  FOR EACH MONTH CHANGE IN VOLUMNE WHEN PRICE PERCENTAGE CHANGE IS MAX & MIN FOR THAT MONTH   
 with cte as (select * , ((close-open)/open)* 100   Percentage_change,volume - lead(volume) over(partition by date_format(date,'%Y  %M') order by date asc) volume_chang  from twitter)
   , cte2 as (select  *, max(percentage_change) over(partition by date_format(date,'%Y  %M') ) ma_x , min(percentage_change) over(partition by date_format(date,'%Y  %M') ) m_in from cte
where volume_chang is not null  )
select date month ,max(Volume_when_price_percent_change_is_max) "change_in_volume_when_price percent_change_is MAX" , min(Volumn_when_price_percent_change_is_min)  "change_in_volume_when_price percent_change_is MIN" from (  select date_format(date,'%Y  %M') date , case when percentage_change=ma_x   then volume_chang  end  Volume_when_price_percent_change_is_max  ,
case when percentage_change=m_in  then volume_chang  end Volumn_when_price_percent_change_is_min  from cte2  ) a 
group by date
;

