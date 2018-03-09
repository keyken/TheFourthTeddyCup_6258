use RailWay
select * from region
select * from stationInfo
select * from trainRecord
select * from stationRecord
select * from weather
select * from flowInfo
--truncate table trainRecord
--delete from trainRecord
SELECT  Region AS ����,SUM(Mileage) AS ���
FROM stationInfo
GROUP BY Region
ORDER BY SUM(Mileage) DESC

--IF EXISTS(SELECT * FROM sysobjects WHERE name='test')
--DROP TABLE test
--GO
--CREATE TABLE test
--(
--	Region varchar(20) NOT NULL,
--	Mileage int
--)
--GO
--insert into test(Region,Mileage) 
--select Region, SUM(Mileage) FROM stationInfo
--GROUP BY Region
--ORDER BY SUM(Mileage) DESC
IF EXISTS(SELECT * FROM sysobjects WHERE name='test')
DROP TABLE test
GO
create table test
(
	RecordDate date NOT NULL,		--����
	Station varchar(20) NOT NULL,	--��ǰվ��
--	ArriveTime datetime,			--��վʱ��
--	DepartsTime  datetime,			--����ʱ��
	AboardCount int,				--�ϳ�����
	DebusCount int					--�³�����
)
insert into test(RecordDate,Station,AboardCount,DebusCount) 
select RecordDate AS ����,Station AS վ��,
SUM(AboardCount) AS �ϳ�����,SUM(DebusCount) AS �³����� FROM stationRecord
GROUP BY RecordDate,Station
ORDER BY RecordDate,Station DESC
select * from test where Station='ZD159' and RecordDate='2015-01-01'
--delete from test

select * from stationRecord where Station='�³������ϼ�'

;with cte as(
	select ����ʱ��=convert(char(15),ArriveTime,108)+'0',
	����ʱ��=convert(char(15),DepartsTime,108)+'0',
	�ϳ�����=sum(AboardCount),
	�³�����=sum(DebusCount)
	from stationRecord with(nolock)
	group by convert(char(15),ArriveTime,108)+'0',convert(char(15),DepartsTime,108)+'0'
)
--select *,AboardCount+DebusCount as ������ from cte
select * from cte
go