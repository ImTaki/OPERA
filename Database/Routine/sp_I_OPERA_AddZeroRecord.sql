-- ***********************************************************************************************************************
-- Module Name			-   sp_I_OPERA_AddZeroRecord
-- Description			-	Add Zero Record
-- Author				-	Taki Guan
-- Date Created			-	2019/3/29
-- Version				-   0.0.0
--
-- Copyright (C) 2019 Colgate Sanxiao Inc.  All rights reserved.
--
-- THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY
-- KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
-- IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
-- PARTICULAR PURPOSE.
----------------------------------------------------------------------------------------------------------------------------
-- Date_Modified	Modified_By		Ver			Changes
-- 2019/3/29		Taki Guan		0.0.0		Initial Creation
-- 2019/4/29		Taki Guan		0.0.1		Modify the shift end check logic to avoid null
-- 
----------------------------------------------------------------------------------------------------------------------------
-- *************************************************************************************************************************

ALTER PROCEDURE [dbo].[sp_I_OPERA_AddZeroRecord]
(
	@userID AS nvarchar(40),
	@shiftTime AS datetime,
	@lineEntName AS nvarchar(40),
	@equEntName AS nvarchar(40),
	@woID AS nvarchar(40)
)
AS

BEGIN
	
	BEGIN TRANSACTION;

	declare @sessID int,@lineEntID int,@eqEntId int,@itemID nvarchar(40),@seqNO int,@qty float,@operID nvarchar(20),@shiftID int

	select top 1 @sessID=session_id from sessn where std_time=0

	-- set @userID='MF\Taki Guan'

	-- set @lineEntID=187
	-- set @eqEntId=190

	-- select top 1 @lineEntID=ent_id from ent where ent_name='H2FCS904'
	-- select top 1 @eqEntId=ent_id from ent where ent_name='H2FCS904_FCS'

	select top 1 @lineEntID=ent_id from ent where ent_name=@lineEntName
	select top 1 @eqEntId=ent_id from ent where ent_name= @equEntName

	-- select top 1 @lineEntID=ent_id from ent where ent_name='P2HA6015'
	-- select top 1 @eqEntId=ent_id from ent where ent_name='P2HA6015_HoongA'

	-- set @woID='000' + '102094897'
	-- set @woID= '000102087677'
	-- set @shiftTime='2019-03-26 16:00:00'
	set @qty=0

	select top 1 @itemID=item_id from wo where wo_id=@woID

	if @itemID is not null
	begin
		select top 1 @seqNO=seq_no,@operID=oper_id
		from job where wo_id=@woID and target_sched_ent_id=@eqEntId order by seq_no desc
		--
		declare @lineProdRate float,@eqProdRate float
		declare @varQtyReqd float,@varBatchSize float,@varProdUom int
		set @lineProdRate=dbo.fn_GetProdRate(@lineEntID,@itemID)
		set @eqProdRate=dbo.fn_GetProdRate(@eqEntId,@itemID)
		select top 1 @varQtyReqd=qty_reqd,@varProdUom=prod_uom from job where  wo_id=@woID and seq_no=0
		update job set batch_size=@lineProdRate where  wo_id=@woID and seq_no=0
		--
		if @seqNO is null
		begin
			select top 1 @seqNO=max(seq_no) from job where wo_id=@woID
			if @seqNO is not null
			begin
				set @seqNO=@seqNO+1
				set @operID='10'
			
				set @varQtyReqd=round(@varQtyReqd*@eqProdRate*1.0/@lineProdRate,2)
				set @varBatchSize=round(@eqProdRate,2)
				exec sp_i_job @woID,@operID,@seqNO,@operID,@itemID,2,1,null,null,@eqEntId,@eqEntId,@eqEntId,@varQtyReqd,0,0,0,0,@varQtyReqd,-0.01,1,@varBatchSize,0,0,0,0,null,null,null,null,1,@varProdUom,null,null,null,null,null,null,null,null,null,null,null,0,null,0,0,null,null,null,null,@seqNO,null,0,null,null,null,null,null,null,null,null,1,null
			
			end
		end

		if @seqNO is not null and @seqNO>0
		begin
			select top 1 @shiftID=shift_id
			from shift_history where shift_start_local<=@shiftTime and isnull(shift_end_local, DATEADD(hour, 8, shift_start_local)) > @shiftTime
			update job set act_start_time_local=isnull(act_start_time_local,getdate()),
				state_cd =case when state_cd<4 then 4 else state_cd end,
				run_ent_id=ISNULL(run_ent_id,target_sched_ent_id)
			where wo_id=@woID

			exec sp_I_Item_Prod_AddProdPostExecExt @sessID,@userID,@eqEntId,@qty,@woID,@operID,@seqNO,@shiftTime,@shiftTime,@shiftID,@itemID,2
			exec sp_I_Item_Prod_AddProdPostExecExt @sessID,@userID,@lineEntID,@qty,@woID,@operID,0,@shiftTime,@shiftTime,@shiftID,@itemID,2
		end
	
	end

COMMIT TRANSACTION;

END;
