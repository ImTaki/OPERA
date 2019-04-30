USE MESDB

-- ***********************************************************************************************************************
-- Module Name			-   SQL Server @ SQL1
-- Description			-	Some useful statement can quick solve issues
-- Author				-	Taki Guan
-- Date Created			-	2019-4-28
-- Version				-   1.0.0
--
-- Copyright (C) 2019 Colgate Sanxiao Inc.  All rights reserved.
--
-- THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY
-- KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
-- IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
-- PARTICULAR PURPOSE.
----------------------------------------------------------------------------------------------------------------------------
-- Date_Modified	Modified_By		Ver			Changes
-- 2019-4-28		Taki Guan		1.0.0		Script created.

----------------------------------------------------------------------------------------------------------------------------
-- *************************************************************************************************************************

-- Material and BOM Section

-- UPDATE ngsfr_subr_bom SET intf_process_status = 0 WHERE intf_process_status = -1

SELECT * FROM item WHERE item_id = 'C0000007162' -- BETWEEN 'C0000007312' AND 'C0000007315'

SELECT * FROM ngsfr_subr_material_master WHERE matl_number BETWEEN 'C0000007312' AND 'C0000007315'

SELECT * FROM ngsfr_subr_material_master WHERE intf_process_status = 0

SELECT * FROM bom_item WHERE parent_item_id = 'C0000007242'

SELECT DISTINCT item_id FROM bom_item bi WHERE bi.item_id LIKE 'C%' and bi.item_id NOT IN (SELECT DISTINCT parent_item_id FROM bom_item)

SELECT * FROM ngsfr_subr_bom WHERE bom_parent_item = 'C0000007242'

-- Get All SKUs don't have BOM item
SELECT DISTINCT bom_item FROM ngsfr_subr_bom sb WHERE sb.bom_item LIKE 'C%' and sb.bom_item NOT IN (SELECT DISTINCT bom_parent_item FROM ngsfr_subr_bom)

SELECT bom_parent_item, bom_item,start_eff, * FROM ngsfr_subr_bom WHERE start_eff > GETDATE()

SELECT * FROM bom_ver WHERE parent_item_id = 'C0000006602'

-- UPDATE ngsfr_subr_bom SET intf_process_status = 0 WHERE intf_process_status = 1

SELECT * FROM NGSFR_MII_MATERIAL_LIST WHERE MATNR = 'C0000007312'

-- UPDATE ngsfr_subr_material_master SET intf_process_status = 0 WHERE intf_process_status = 1 AND matl_number = 'C0000007242'

-- ===============================================================================================================================================================================

-- Work Order Section

-- UPDATE wo SET state_cd = 3 WHERE process_id LIKE '[T,H]2[BH,FCS]%' AND state_cd = 1 AND req_finish_time_local < '2019-04-19 00:00:00'

SELECT * FROM wo WHERE process_id LIKE '[T,H]2[BH,FCS]%' AND state_cd = 1 AND req_finish_time_local < '2019-04-19 00:00:00' ORDER BY wo_id-- OR last_edit_at < '2019-04-15 00:00:00'

SELECT * FROM wo WHERE wo_id IN ('000102148412')

SELECT * FROM wo WHERE wo_id LIKE '%4446' AND item_id LIKE '%6611'

SELECT * FROM wo WHERE item_id = 'C0000006606' AND last_edit_at >= '2018-05-15'

SELECT * FROM wo WHERE item_id = 'C0000007314'

SELECT * FROM ngsfr_subr_production_order WHERE order_number = '000102103715'

-- ===============================================================================================================================================================================

-- Job Selection

SELECT * FROM  job_state;

SELECT * FROM job WHERE wo_id IN ('000102148514')

SELECT * FROM job WHERE act_start_time_local >= '2019-4-22 00:00:00' AND act_start_time_local <= '2019-4-22 08:00:00' AND run_ent_id = (SELECT ent_id FROM ent WHERE ent_name = 'T2BH0204')

-- Check if any Job running during specific time period
SELECT * FROM job WHERE run_ent_id = 128 AND act_start_time_local > '2019-3-11 16:00:00' AND act_start_time_local < '2019-3-7 0:00:00'

SELECT * FROM job WHERE item_id = 'C0000006606' AND job_desc = 'HSL Tufting Machine 09'

SELECT * FROM job WHERE item_id LIKE '%183902038'

-- Item Produced, Job Event and TPM Stat Section

SELECT * FROM item_prod WHERE wo_id = '000102148602'

SELECT * FROM item_prod WHERE item_id = 'C0000007314'

SELECT * FROM item_prod WHERE ent_id IN ( SELECT ent_id FROM ent WHERE ent_name IN ('T2BH0208_END', 'T2BH0208')) AND good_prod = 1 AND wo_id = '000102143695' AND shift_start_local = '2019-04-24 08:00:00' ORDER BY  row_id DESC

SELECT * FROM item_prod WHERE ent_id IN (140) AND good_prod = 1 AND shift_start_local = '2019-04-24 08:00:00' AND wo_id = '000102143913' ORDER BY  row_id DESC

-- SELECT * FROM item_prod WHERE ent_id = ( SELECT top 1 ent_id FROM ent WHERE ent_name='T2BH0210_END' ) AND shift_start_local = '2019-03-13 08:00:00' AND wo_id = '000102070210' ORDER BY  last_edit_at DESC

SELECT * FROM item_prod WHERE ent_id = 161 AND shift_start_local = '2019-04-24 00:00:00.000' AND good_prod = 1 AND wo_id = '000102142082' ORDER BY row_id DESC

SELECT * FROM job_event WHERE wo_id = '000102109761' AND event_type = 'JobStateChanged' AND ent_id = 162 ORDER BY row_id;

SELECT * FROM job_event WHERE wo_id = '000102143695' AND ent_id IN (171, 174) AND event_time_local >= '2019-4-24 14:00:00' AND event_time_local < '2019-4-24 15:00:00' ORDER BY row_id DESC-- AND event_type = 'JobStateChanged'

SELECT event_time_local, seq_no, event_type, value1, quantity FROM job_event WHERE wo_id = '000102148685' ORDER BY row_id

SELECT * FROM tpm_stat WHERE wo_id = '000101721575'

SELECT * FROM tpm_stat WHERE ent_id IN ( SELECT ent_id FROM ent WHERE ent_name IN ('T2BH0210_END', 'T2BH0210')) AND wo_id = '000102143913' AND shift_start_local = '2019-04-24 08:00:00' ORDER BY last_edit_at DESC

-- SELECT * FROM tpm_stat WHERE item_id LIKE '%183902038'

-- Insert Job
-- exec sp_I_OPERA_InsertJobOnEquip 133, 0, '000101878005', '10', 2, 'C0000006801', 8581, 52.63, 1, 4, 'MF\Taki Guan'

-- ===============================================================================================================================================================================

SELECT ent_id, cur_wo_id, cur_oper_id, cur_seq_no FROM job_exec WHERE ent_id IN (128, 129)

SELECT ent_id, ent_name FROM ent WHERE ent_id BETWEEN 175 AND  179

SELECT A.ent_name, A.ent_id, B.attr_id, C.attr_desc, B.attr_value
FROM ent A,
     ent_attr B,
     attr C
WHERE A.ent_id = B.ent_id
  AND B.attr_id = C.attr_id
  AND C.attr_desc LIKE 'Equipment_Eff_Date'

SELECT * FROM ent_attr WHERE attr_value LIKE '19%-01-01%'

SELECT * FROM attr WHERE attr_desc LIKE '%Prod_Rate_FCS%'

-- Select Entity Attribute
SELECT ent.ent_name, attr.attr_desc, ent_attr.attr_value
FROM ent,
     ent_attr,
     attr
WHERE ent.ent_id = ent_attr.ent_id
  AND ent.ent_id IN (SELECT ent_id FROM ent_attr WHERE attr_value = 'Line')
  AND ent_attr.attr_id = attr.attr_id
--  AND ent_attr.attr_value = 'Line'
  AND ent_attr.attr_id IN (SELECT attr.attr_id FROM attr WHERE attr_desc LIKE '%Prod_Rate_FCS%')
ORDER BY ent.ent_name

-- ===============================================================================================================================================================================

-- User and Password Section

SELECT
  user_id     ID,
  user_desc   Description,
  def_dept_id Department
FROM user_name
WHERE def_dept_id = 'Technician' or def_dept_id = 'Technician Leader';

-- View Password

SELECT
  BadgeNum, Username,
  CONVERT(
        nvarchar(MAX),
        DecryptByPassPhrase(CONCAT(Username, BadgeNum), Password)) AS Password, LastEditedAt
FROM
  OPERA_badge_credentials
WHERE
  ACTIVE = 1  -- AND Username = 'Cuicui Gen'

SELECT * FROM user_name WHERE spare1 IN (SELECT spare1 FROM user_name GROUP BY spare1 HAVING COUNT(spare1) > 1)

SELECT * FROM user_name WHERE user_id LIKE '%Yilan Zhang%'

SELECT  * FROM user_name WHERE spare1 = '32868534' -- user_id LIKE '%Jinzhu Che'

SELECT user_desc FROM user_name GROUP BY user_desc HAVING COUNT(user_desc) > 2

SELECT * FROM labor_usage WHERE user_id LIKE '%Yilan Zhang%' AND wo_id = '000102077385'

SELECT * FROM user_grp_link WHERE grp_id > 20

-- ===============================================================================================================================================================================

-- Utilization Log and Data Log Section

SELECT * FROM util_reas_grp

SELECT b.reas_grp_desc,reas_desc, category2 FROM util_reas a, util_reas_grp b WHERE a.reas_grp_id IN (337, 338, 339, 340, 341) AND a.reas_grp_id = b.reas_grp_id

SELECT  * FROM util_reas WHERE state_cd = 0

-- Badge Reader Configuration
SELECT * FROM OPERA_node_alias

SELECT * FROM data_log_16 WHERE grp_id = 67 AND ent_id = (SELECT ent_id FROM ent WHERE ent_name = 'T2BH0201') ORDER BY sample_time_local DESC

SELECT * FROM data_log_grp

SELECT * FROM data_log_value WHERE grp_id = 67

SELECT shift_start_local [Shift], raw_reas_cd [Reason], duration/3600.00 [Hour], category2 [DESC]FROM util_log WHERE ent_id = (SELECT ent_id FROM ent WHERE ent_name = 'H2FCS952') AND shift_start_local = '2019-03-28 08:00:00' ORDER BY event_time_local

SELECT * FROM util_log WHERE ent_id = (SELECT ent_id FROM ent WHERE ent_name = 'T2BH0202_END') AND shift_start_local = '2019-04-24 08:00:00' ORDER BY event_time_local

-- SELECT * FROM job_util_log_link;

-- ===============================================================================================================================================================================
