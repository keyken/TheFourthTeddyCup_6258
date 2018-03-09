--���������Ϣ������ʱ������ڳ�վ��¼����û�ж�Ӧ���ڵĳ��κ�վ�㣬����Ҫ��Ӧ���
--�����վ��¼�����Ѿ��ж�Ӧ���ݣ�����������Ӧվ���ϳ��������³��������ۼ�
USE Railway
GO

if (object_id('tgr_flowInfo_insert','tr') is not null)
	drop trigger tgr_flowInfo_insert
go
create trigger tgr_flowInfo_insert
on flowInfo 
	instead of insert
as
begin
	declare @_TrainNum varchar(20),@_RecordDate date,@_AboardStation varchar(20),@_DebusStation varchar(20),@_FlowCount int
	--��inserted��ʱ���л�ȡ��¼ֵ
	select @_TrainNum = TrainNum,
	@_RecordDate = RecordDate,
	@_AboardStation = AboardStation,
	@_DebusStation = DebusStation,
	@_FlowCount = FlowCount
	from inserted
	
	if @_AboardStation not in (select Station from stationRecord) or 
	@_TrainNum not in (select TrainNum from stationRecord) or
	@_RecordDate not in (select RecordDate from stationRecord)
	begin
		insert into stationRecord values(@_TrainNum,@_RecordDate,@_AboardStation, NULL, NULL,@_FlowCount,default)
	end
	else
	begin
		update stationRecord set AboardCount = AboardCount+@_FlowCount
		where Station=@_AboardStation and TrainNum=@_TrainNum and RecordDate=@_RecordDate;
	end
	
	if @_TrainNum not in (select TrainNum from stationRecord) or 
	@_DebusStation not in (select Station from stationRecord) or
	@_RecordDate not in (select RecordDate from stationRecord)
	begin
		insert into stationRecord values(@_TrainNum,@_RecordDate,@_DebusStation, NULL, NULL,default,@_FlowCount)
	end
	else
	begin
		update stationRecord set DebusCount = DebusCount+@_FlowCount
		where Station=@_DebusStation and TrainNum=@_TrainNum and RecordDate=@_RecordDate;
	end
	
	insert into flowInfo select * from inserted
end
go
--��������
--insert into flowInfo values('k1',getdate(),'a','b',5)
--insert into flowInfo values('k1',getdate(),'b','a',13)


--������Ϣ��ɾ�����ݣ���վ��Ϣ�����Ÿı�����
if (object_id('tgr_flowInfo_delete', 'TR') is not null)
    drop trigger tgr_flowInfo_delete
go
create trigger tgr_flowInfo_delete
on flowInfo
    after delete --ɾ������
as
	declare @pre_TrainNum varchar(20),@pre_RecordDate date,
	@pre_AboardStation varchar(20),@pre_DebusStation varchar(20),@pre_FlowCount int
	
	select @pre_TrainNum = TrainNum,
	@pre_RecordDate = RecordDate,
	@pre_AboardStation = AboardStation,
	@pre_DebusStation = DebusStation,
	@pre_FlowCount = FlowCount
	from deleted;

	update stationRecord set AboardCount = AboardCount-@pre_FlowCount
	where Station=@pre_AboardStation and TrainNum=@pre_TrainNum and RecordDate=@pre_RecordDate;

	update stationRecord set DebusCount = DebusCount-@pre_FlowCount
	where Station=@pre_AboardStation and TrainNum=@pre_TrainNum and RecordDate=@pre_RecordDate;
go


--������Ϣ��������ݣ���վ��¼�����Ÿı�����
--update���������ڸ������ݺ󣬽�����ǰ�����ݱ�����deleted���У����º�����ݱ�����inserted����
if (object_id('tgr_FlowInfo_update', 'TR') is not null)
    drop trigger tgr_flowInfo_update
go
create trigger tgr_flowInfo_update
on flowInfo
    after update
as
/*
	declare  @pre_TrainNum varchar(20),@pre_RecordDate date,
	@pre_AboardStation varchar(20),@pre_DebusStation varchar(20),@pre_FlowCount int,
	@after_TrainNum varchar(20),@after_RecordDate date,
	@after_AboardStation varchar(20),@after_DebusStation varchar(20),@after_FlowCount int
	
	--����ǰ������
	select 
	@pre_TrainNum = TrainNum,
	@pre_RecordDate = RecordDate,
	@pre_AboardStation = AboardStation,
	@pre_DebusStation = DebusStation,
	@pre_FlowCount = FlowCount
	from deleted;
	
	--���º������
	select @after_FlowCount = FlowCount,
	@after_TrainNum = TrainNum,
	@after_RecordDate = RecordDate,
	@after_AboardStation = AboardStation,
	@after_DebusStation = DebusStation
	from inserted;
*/
	begin
		delete from flowInfo select * from deleted;
		insert into flowInfo select * from inserted;
		/*
		--�����޸ĵļ�¼��stationRecord���н��ж�Ӧɾ��
		update stationRecord set AboardCount = AboardCount-@pre_FlowCount
		where Station=@pre_AboardStation and TrainNum=@pre_TrainNum and RecordDate=@pre_RecordDate;
		update stationRecord set DebusCount = DebusCount-@pre_FlowCount
		where Station=@pre_DebusStation and TrainNum=@pre_TrainNum and RecordDate=@pre_RecordDate;
		
		--���޸ĺõ�������stationRecord���н��ж�Ӧ���
		if @after_AboardStation not in (select Station from stationRecord) or 
			@after_TrainNum not in (select TrainNum from stationRecord) or
			@after_RecordDate not in (select RecordDate from stationRecord))
		begin
			insert into stationRecord values(@after_TrainNum,@after_RecordDate,@after_AboardStation, NULL, NULL,@after_FlowCount,default)
		end
		else
		begin
			update stationRecord set AboardCount = AboardCount+@after_FlowCount
			where Station=@after_AboardStation and TrainNum=@after_TrainNum and RecordDate=@after_RecordDate;
		end
		
		if @after_TrainNum not in (select TrainNum from stationRecord) or 
			@after_DebusStation not in (select Station from stationRecord) or
			@after_RecordDate not in (select RecordDate from stationRecord)
		begin
			insert into stationRecord values(@after_TrainNum,@after_RecordDate,@after_DebusStation, NULL, NULL,default,@after_FlowCount)
		end
		else
		begin
			update stationRecord set DebusCount = DebusCount+@after_FlowCount
			where Station=@after_DebusStation and TrainNum=@after_TrainNum and RecordDate=@after_RecordDate;
		end
		*/
	end
go



--��վ��Ϣ��������ݣ��жϳ��μ�¼���Ƿ������Ӧ��¼��û������Ӽ�¼
CREATE trigger [dbo].[tgr_stationRecord_insert]  
on [dbo].[stationRecord]   
	instead of insert  
as  
begin
	declare @_TrainNum varchar(20),@_RecordDate date,@_Station varchar(20),@_AboardCount int  
	select @_TrainNum = TrainNum,  
	@_RecordDate = RecordDate,  
	@_Station = Station,  
	@_AboardCount = AboardCount  
	from inserted  
   
	if @_Station not in (select Station from stationInfo)  
	begin  
	insert into stationInfo values('����',@_Station,'��',0)  
	end  
   
	if @_TrainNum not in (select TrainNum from trainRecord) or  
	@_RecordDate not in (select RecordDate from trainRecord)  
	begin  
		insert into trainRecord values(@_TrainNum,@_RecordDate,NULL,NULL,NULL,@_AboardCount,NULL)  
	end
	else
	begin
		update trainRecord set RealCount = RealCount+@_AboardCount  
		where TrainNum=@_TrainNum and RecordDate=@_RecordDate;  
	end

	insert into stationRecord select * from inserted  

end
/*if (object_id('tgr_stationRecord_insert','tr') is not null)
	drop trigger tgr_stationRecord_insert
go
create trigger tgr_stationRecord_insert
on stationRecord 
	for insert
as
begin
	declare @_TrainNum varchar(20),@_RecordDate date,@_Station varchar(20),@_AboardCount int
	select @_TrainNum = TrainNum,
	@_RecordDate = RecordDate,
	@_Station = Station,
	@_AboardCount = AboardCount
	from inserted
	
	if @_Station not in (select Station from stationInfo))
	begin
		insert into stationInfo values('����',@_Station,'��',0)
	end
	
	if @_TrainNum not in (select TrainNum from trainRecord) or
		@_RecordDate not in (select RecordDate from trainRecord)
	begin
		insert into trainRecord values(@_TrainNum,@_RecordDate,NULL,NULL,NULL,@_AboardCount,NULL)
	end
	else
	begin
		update trainRecord set RealCount = RealCount+@_AboardCount
		where TrainNum=@_TrainNum and RecordDate=@_RecordDate;
	end
end
go*/


--��վ��Ϣ��ɾ������
if (object_id('tgr_stationRecord_delete','tr') is not null)
	drop trigger tgr_stationRecord_delete
go
create trigger tgr_stationRecord_delete
on stationRecord 
	for delete
as
begin
	declare @_TrainNum varchar(20),@_RecordDate date,@_Station varchar(20),@_AboardCount int
	select @_TrainNum = TrainNum,
	@_RecordDate = RecordDate,
	@_AboardCount = AboardCount
	from deleted
	
	update trainRecord set RealCount = RealCount-@_AboardCount
	where TrainNum=@_TrainNum and RecordDate=@_RecordDate;
	
	if(exists (select * from flowInfo where AboardStation = @_Station))
		delete from flowInfo where AboardStation=@_Station;
	
	if(exists (select * from flowInfo where DebusStation = @_Station))
		delete from flowInfo where DebusStation=@_Station;
end
go

/*
--��վ��Ϣ���������
if (object_id('tgr_stationRecord_update','tr') is not null)
	drop trigger tgr_stationRecord_update
go
create trigger tgr_stationRecord_update
on stationRecord 
	for update
as
begin
	declare @pre_TrainNum varchar(20),@pre_RecordDate date,@pre_Station varchar(20),@pre_AboardCount int,@pre_DebusCount int,
	@after_TrainNum varchar(20),@after_RecordDate date,@after_Station varchar(20),@after_AboardCount int,@after_DebusCount int
	select @pre_TrainNum = TrainNum,
	@pre_RecordDate = RecordDate,
	@pre_Station = Station,
	@pre_AboardCount = AboardCount,
	@pre_DebusCount = DebusCount
	from deleted
	select @after_TrainNum = TrainNum,
	@after_RecordDate = RecordDate,
	@after_Station = Station,
	@after_AboardCount = AboardCount,
	@after_DebusCount = DebusCount
	from inserted
	
	if(@pre_TrainNum!=@after_TrainNum or @pre_RecordDate!=@after_RecordDate or @pre_Station!=@after_Station or
	@pre_AboardCount!=@after_AboardCount or @pre_DebusCount!=@after_DebusCount)
	begin
		raisError('ֻ���޸ĵ�վʱ��ͷ���ʱ��', 16, 10);
		rollback tran;
	end
end
go


--���μ�¼���������
if (object_id('tgr_trainRecord_update','tr') is not null)
	drop trigger tgr_trainRecord_update
go
create trigger tgr_trainRecord_update
on trainRecord 
	for update
as
begin
	declare @pre_TrainNum varchar(20),@pre_RecordDate date,@pre_RealCount int,
	@after_TrainNum varchar(20),@after_RecordDate date,@after_RealCount int
	select @pre_TrainNum = TrainNum,
	@pre_RecordDate = RecordDate,
	@pre_RealCount = RealCount
	from deleted
	select @after_TrainNum = TrainNum,
	@after_RecordDate = RecordDate,
	@after_RealCount = RealCount
	from inserted
	
	if(@pre_TrainNum!=@after_TrainNum or @pre_RecordDate!=@after_RecordDate or @pre_RealCount!=@after_RealCount)
	begin
		raisError('�����޸ĳ��Ρ����ں�ʵ������', 16, 10);
		rollback tran;
	end
end
go
*/
--���μ�¼��ɾ������
if (object_id('tgr_trainRecord_delete','tr') is not null)
	drop trigger tgr_trainRecord_delete
go
create trigger tgr_trainRecord_delete
on trainRecord
	for delete
as
begin
	declare @pre_TrainNum varchar(20),@pre_RecordDate date,@pre_RealCount int
	select @pre_TrainNum = TrainNum,
	@pre_RecordDate = RecordDate,
	@pre_RealCount = RealCount
	from deleted

	delete from stationRecord where TrainNum=@pre_TrainNum and RecordDate=@pre_RecordDate;
end
go


--��վ��Ϣ��ɾ������
if (object_id('tgr_stationInfo_delete','tr') is not null)
	drop trigger tgr_stationInfo_delete
go
create trigger tgr_stationInfo_delete
on stationInfo
	for delete
as
begin
	declare @pre_Region varchar(20),@pre_Station varchar(20)
	select @pre_Region = Region,
	@pre_Station = Station
	from deleted
	
	if(exists (select * from trainRecord where OriginStation = @pre_Station))
		delete from trainRecord where OriginStation=@pre_Station;
	if(exists (select * from trainRecord where TerminalStation = @pre_Station))
		delete from trainRecord where TerminalStation=@pre_Station;
end
go

/*
--���μ�¼���������
if (object_id('tgr_trainRecord_insert','tr') is not null)
	drop trigger tgr_trainRecord_insert
go
create trigger tgr_trainRecord_insert
on trainRecord 
	instead of insert
as
begin
	declare @_TrainNum varchar(20),@_RecordDate date,@_OriginStation varchar(20),@_TerminalStation varchar(20)
	select @_TrainNum = TrainNum,
	@_RecordDate = RecordDate,
	@_OriginStation = OriginStation,
	@_TerminalStation = TerminalStation
	from inserted
	
	if exists(select * from trainRecord where trainRecord.OriginStation not in (select Station from stationInfo))
	begin
		insert into stationInfo values('����',@_OriginStation,'��',0)
	end
	if exists(select * from trainRecord where trainRecord.TerminalStation not in (select Station from stationInfo))
	begin
		insert into stationInfo values('����',@_TerminalStation,'��',0)
	end
	insert into trainRecord select * from inserted
end
go*/

--���μ�¼���������
CREATE trigger [dbo].[tgr_trainRecord_insert]  
on [dbo].[trainRecord]   
 instead of insert  
as  
begin  
 declare @_TrainNum varchar(20),@_RecordDate date,@_OriginStation varchar(20),@_TerminalStation varchar(20)  
 select @_TrainNum = TrainNum,  
 @_RecordDate = RecordDate,  
 @_OriginStation = OriginStation,  
 @_TerminalStation = TerminalStation  
 from inserted  
   
 if @_OriginStation not in (select Station from stationInfo)  
 begin  
  insert into stationInfo values('����',@_OriginStation,'��',0)  
 end  
 if @_TerminalStation not in (select Station from stationInfo)  
 begin  
  insert into stationInfo values('����',@_TerminalStation,'��',0)  
 end  
  
 insert into trainRecord select * from inserted  
  
end



/*
��ɾ����delete�����ݵ�ʱ�򣬿��Լٶ����ݿ⽫Ҫɾ�������ݷŵ�һ��deleted��ʱ���У�
���ǿ������ȡ��ͨ�ı�һ����select �ֶ� from deleted��insert��ʱ�����һ����
ֻ�����ǰ�Ҫ��������ݷ���inserted���С����²���������Ϊ��ִ��������������
�Ȱ���һ�м�¼delete����Ȼ����insert������update����ʵ���ϾͶ�deleted���inserted��Ĳ�����
���Բ�����updated���ˣ��е�ʱ�����������������ϵ����ɾ���������ݵ�ͬʱ���ӱ���ص�����Ҳɾ����
���ʱ������ô�������û��Ч���ˣ���Ϊ���������������ɾ�����Ŵ����ģ�
���ʱ��ֱ����ֹ����ʾ�����������ϵ������ɾ���ȡ�������������ɾ����������û��Ч����
*/





/*
select * from sys.triggers
--��ѯ�Ѵ��ڵĴ�����
select * from sys.triggers;
select * from sys.objects where type = 'TR';
--�鿴����������
exec sp_helptext '��������'
--ɾ��������
drop trigger trigger_name
--����������
create trigger trigger_name 
on  {table_name|view_name} 
{After|Instead of} {insert|update|delete}
as ��ӦT-SQL���
--�޸Ĵ�����
alter trigger trigger_name 
on  {table_name|view_name} 
{After|Instead of} {insert|update|delete}
as ��ӦT-SQL���
--�鿴�����������¼�
select te.* from sys.trigger_events te join sys.triggers t
on t.object_id = te.object_id
where t.parent_class = 0 and t.name = 'tgr_valid_data';
--�鿴�������������
exec sp_helptext 'tgr_message';
*/
