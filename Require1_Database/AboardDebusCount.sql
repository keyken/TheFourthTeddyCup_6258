select * from test

;with cte as(
	select ���ִ�ʱ��=CONVERT(varchar(4),ArriveTime,108)+'0',
	վ��=Station,
	�³�����=sum(DebusCount)
	from stationRecord with(nolock)
	where Station in (select Station from stationInfo where InPipe = '��')and (TrainNum like 'D%')
	group by CONVERT(varchar(4),ArriveTime,108)+'0',Station
)select * from cte
where ���ִ�ʱ�� is not NULL 
order by վ��,���ִ�ʱ��
go

;with cte as(
	select ���뿪ʱ��=CONVERT(varchar(3),DepartsTime,108)+'00',
	վ��=Station,
	�ϳ�����=sum(AboardCount)
	from stationRecord with(nolock)
	where Station in (select Station from stationInfo where InPipe = '��') and (TrainNum like 'D%')
	group by CONVERT(varchar(3),DepartsTime,108)+'00',Station
)select * from cte
where ���뿪ʱ�� is not NULL 
order by վ��,���뿪ʱ��
go

select * from stationRecord
where TrainNum like 'D%'