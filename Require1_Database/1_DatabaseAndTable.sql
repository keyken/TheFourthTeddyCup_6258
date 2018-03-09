--�������ݿ�RailWay
Use master
IF EXISTS(SELECT * FROM sysdatabases WHERE name='Railway')
DROP DATABASE Railway
CREATE DATABASE Railway
ON PRIMARY                 --���ļ���
(
	NAME='Railway_data',
	FILENAME='F:\SQL\project\E_Market_data.mdf',
	SIZE=10MB,
	MAXSIZE=500MB,
	FILEGROWTH=10% 
)--��һ���ļ������

Use Railway
--����3
--������region
IF EXISTS(SELECT * FROM sysobjects WHERE name='region')
DROP TABLE region
GO
CREATE TABLE region
(
	Region varchar(20) NOT NULL
)
GO
ALTER TABLE region
ADD CONSTRAINT PK_Region PRIMARY KEY (Region)
GO

--����4
--������վ������������״����weather
IF EXISTS(SELECT * FROM sysobjects WHERE name='weather')
DROP TABLE weather
GO
CREATE TABLE weather
(
	Region varchar(20) NOT NULL,    --����
	RecordDate date NOT NULL,		--����
	WeatherStart varchar(10),		--��ʼ����״��
	WeatherChange varchar(10),		--ת��������״��
	TemperatureLowest int,			--�������
	TemperatureHighest int,			--�������
	WindDirectStart varchar(20),	--��ʼ����
	WindPowerStart varchar(20),		--��ʼ����
	WindDirectChange varchar(20),	--ת�������
	WindPowerChange varchar(20)		--ת�������
)
GO
ALTER TABLE weather WITH NOCHECK ADD 
CONSTRAINT [PK_weather] PRIMARY KEY  NONCLUSTERED 
(
  [Region],
  [RecordDate]
)
ALTER TABLE weather
	ADD CONSTRAINT FK_Region1 FOREIGN KEY(Region) REFERENCES region(Region)	--������Լ��
GO
-- --ɾ��������������
-- truncate table weather
-- SELECT * FROM dbo.weather

--����3
--�����������γ�վ��Ϣ��stationInfo
IF EXISTS(SELECT * FROM sysobjects WHERE name='stationInfo')
DROP TABLE stationInfo
GO
CREATE TABLE stationInfo
(
	Region varchar(20) NOT NULL,
	Station varchar(20) NOT NULL,
	InPipe varchar(3) NOT NULL,
	Mileage int
)
GO
ALTER TABLE stationInfo	--��station��������Լ��
ADD CONSTRAINT PK_Station PRIMARY KEY (Station),
	CONSTRAINT CK_InPipe CHECK(InPipe='��' OR InPipe='��'),
	CONSTRAINT FK_Region2 FOREIGN KEY(Region) REFERENCES  Region(Region)
	GO
-- --ȡ������
-- ALTER TABLE stationInfo
-- DROP CONSTRAINT PK_Station
-- GO
-- --�޸���������
-- alter table stationInfo alter column Station varchar(20) not null
-- SELECT * FROM stationInfo

--����1
--����������Ϣ��trainRecord
IF EXISTS(SELECT * FROM sysobjects WHERE name='trainRecord')
DROP TABLE trainRecord
GO
CREATE TABLE trainRecord
(
	TrainNum varchar(20) NOT NULL,		--����
	RecordDate date NOT NULL,			--ʼ������
	OriginStation varchar(20),			--ʼ����վ
	TerminalStation varchar(20),		--�ִﳵվ
	MaxCount int,						--�վ���Ա
	RealCount int NOT NULL,				--��ʵ������
	LoadFactors decimal(4,1)			--������
)
GO
ALTER TABLE trainRecord WITH NOCHECK ADD --������������
CONSTRAINT [PK_trainRecord] PRIMARY KEY  NONCLUSTERED 
(
  [TrainNum],
  [RecordDate]
)
GO
ALTER TABLE trainRecord
ADD CONSTRAINT FK_OriginStation FOREIGN KEY(OriginStation) REFERENCES  stationInfo(Station),
	CONSTRAINT FK_TerminalStation FOREIGN KEY(TerminalStation) REFERENCES  stationInfo(Station),
	CONSTRAINT DF_RecordCount DEFAULT(0) FOR RealCount
GO

--����1
--������վ��¼��
IF EXISTS(SELECT * FROM sysobjects WHERE name='stationRecord')
DROP TABLE stationRecord
GO
CREATE TABLE stationRecord
(
	TrainNum varchar(20) NOT NULL,	--����
	RecordDate date NOT NULL,		--����
	Station varchar(20) NOT NULL,	--��ǰվ��
	ArriveTime datetime,			--��վʱ��
	DepartsTime  datetime,			--����ʱ��
	AboardCount int,				--�ϳ�����
	DebusCount int					--�³�����
)
GO
ALTER TABLE stationRecord WITH NOCHECK ADD 
CONSTRAINT [PK_stationRecord] PRIMARY KEY  NONCLUSTERED 
(
  [TrainNum],
  [RecordDate],
  [Station]
)
ALTER TABLE stationRecord
ADD CONSTRAINT FK_RecordDate_TrainNum FOREIGN KEY(TrainNum,RecordDate) REFERENCES  trainRecord(TrainNum,RecordDate),
	CONSTRAINT FK_Station FOREIGN KEY(Station) REFERENCES  stationInfo(Station),
	CONSTRAINT DF_AboardCount DEFAULT(0) FOR AboardCount,
	CONSTRAINT DF_DebusCount DEFAULT(0) FOR DebusCount
GO
	
--����1
--����������Ϣ��
IF EXISTS(SELECT * FROM sysobjects WHERE name='flowInfo')
DROP TABLE flowInfo
GO
CREATE TABLE flowInfo
(
	TrainNum varchar(20) NOT NULL,				--����
	RecordDate date NOT NULL,					--����
	AboardStation varchar(20) NOT NULL,			--�ϳ�վ
	DebusStation varchar(20) NOT NULL,			--�³�վ
	FlowCount int								--������
)
GO
ALTER TABLE flowInfo WITH NOCHECK ADD 
CONSTRAINT [PK_flowInfo] PRIMARY KEY  NONCLUSTERED 
(
  [TrainNum],
  [RecordDate],
  [AboardStation],
  [DebusStation]
)
ALTER TABLE flowInfo
ADD CONSTRAINT FK_RecordDate_TrainNum1 FOREIGN KEY(TrainNum,RecordDate) REFERENCES  trainRecord(TrainNum,RecordDate),
	CONSTRAINT FK_AboardStation FOREIGN KEY(AboardStation) REFERENCES  stationInfo(Station),
	CONSTRAINT FK_DebusStation FOREIGN KEY(DebusStation) REFERENCES  stationInfo(Station),
	CONSTRAINT DF_FlowCount DEFAULT(0) FOR FlowCount
GO

--���ݹ�ϵ��������