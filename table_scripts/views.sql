--------------------------------------------------------
--  File created - Tuesday-October-10-2017   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for View STP_AREA_FORESTERS_V
--------------------------------------------------------

  CREATE OR REPLACE FORCE EDITIONABLE VIEW "BSMART_DATA"."STP_AREA_FORESTERS_V" ("AREA_FORESTER", "AREA") AS 
  SELECT AREA_FORESTER,
          trim(COLUMN_VALUE) AREA
   FROM BSMART_DATA.STP_AREA_FORESTERS,
     xmltable(('"'
      || REPLACE(AREA, ':', '","')
     || '"'))
;
--------------------------------------------------------
--  DDL for View STP_CONTRACT_DETAIL_V
--------------------------------------------------------

  CREATE OR REPLACE FORCE EDITIONABLE VIEW "BSMART_DATA"."STP_CONTRACT_DETAIL_V" ("ID", "CONTRACT_ITEM_ID", "TYPE_ID", "TYPE", "STOCK_TYPE_ID", "STOCK_TYPE", "PLANT_TYPE_ID", "PLANT_TYPE", "SPECIES_ID", "SPECIES", "TOP_PERFORMER", "STUMPING_SIZE_ID", "STUMPING_SIZE", "TRANSP_DIS_ID", "TRANSP_DIS", "DESCRIPTION", "MEASUREMENT", "QUANTITY", "YEAR", "PROGRAM", "CREATED_BY", "CREATED_ON", "MODIFIED_BY", "MODIFIED_ON") AS 
  select SCD.ID,
SCD.CONTRACT_ITEM_ID,
SCD.TYPE_ID,
stp_activities.activity as TYPE,
SCD.STOCK_TYPE_ID,
TO_CHAR(stp_stocktype_lk.CODE_NAME) AS STOCK_TYPE,
SCD.PLANT_TYPE_ID,
TO_CHAR(PLANT_TYPE.CODE_NAME) AS PLANT_TYPE,
SCD.SPECIES_ID,
TO_CHAR(STP_SPECIES_LK.SPECIES) AS SPECIES,
NVL(TPFMR.TOP_PERFORMER, 'N') AS TOP_PERFORMER,
SCD.STUMPING_SIZE_ID,
TO_CHAR(stp_stumping_lk.CODE_NAME) AS STUMPING_SIZE,
SCD.TRANSP_DIS_ID,
TO_CHAR(TRANSP_DIS.CODE_NAME) AS TRANSP_DIS,
SCD.DESCRIPTION,
SCD.MEASUREMENT,
SCD.QUANTITY,
SCI.YEAR,
SCI.PROGRAM,
SCD.CREATED_BY,
SCD.CREATED_ON,
SCD.MODIFIED_BY,
SCD.MODIFIED_ON
from STP_CONTRACT_DETAIL SCD
left join STP_CONTRACT_ITEM SCI
ON SCI.ID = SCD.CONTRACT_ITEM_ID
left join stp_activities
on stp_activities.id= SCD.TYPE_ID
left join stp_stocktype_lk
on stp_stocktype_lk.CODE_VALUE = SCD.STOCK_TYPE_ID
left join stp_plantsize_lk PLANT_TYPE
on PLANT_TYPE.CODE_VALUE = SCD.PLANT_TYPE_ID
left join STP_SPECIES_LK
on STP_SPECIES_LK.SPECIESID = SCD.SPECIES_ID
left join stp_stumping_lk
on stp_stumping_lk.CODE_VALUE = SCD.STUMPING_SIZE_ID
left join stp_plantsize_lk TRANSP_DIS
on TRANSP_DIS.CODE_VALUE = SCD.TRANSP_DIS_ID
left join stp_top_performer TPFMR
on TPFMR.speciesid=SCD.SPECIES_ID
WHERE SCI.STATUS_ID <> 3
;
--------------------------------------------------------
--  DDL for View STP_DEFICIENCY_V
--------------------------------------------------------

  CREATE OR REPLACE FORCE EDITIONABLE VIEW "BSMART_DATA"."STP_DEFICIENCY_V" ("OBJECTID", "TREEID", "CREATEDATE", "CONTRACTYEAR", "CONTRACTNUMBER", "CONTRACTOPERATION", "ACTIVITY_TYPE_ID", "MISSINGTREE", "INCORRECTLOCATION", "EXTRATREE", "UNAPPROVEDSPECIES", "CORRECTSPECIES", "INCORRECTSIZE", "TAGNUMBER", "TAG_COLOR_ID", "TAG_COLOR", "CROWNDIEBACK", "CROWNINSECTDISEASE", "EPICORMICBRANCHING", "BRANCHINGSTRUCTURE", "ROOTBALLSIZE", "ROOTBALLLOOSE", "GIRDLINGROOTS", "STEMINSECTDISEASE", "STEMTISSUENECROSIS", "STEMSCARS", "GIRDLEDSTEM", "DETAILEDINSPECTION", "PLANTINGHOLESIZE", "BACKFILL", "PLANTINGLOW", "PLANTINGHIGH", "SOILRETENTIONRING", "BURLAPWIREROPE", "BEDPREPARATIONDIAMETER", "BEDPREPARATIONSOD", "BEDPREPARATIONCULTIVATION", "BEDPREPARATIONCULTIVATIONDEPTH", "MULCHDEPTH", "MULCHDIAMETER", "MULCHRING", "MULCHSTEM", "STEMCROWNROPE", "TREEGATORBAG", "TREEGUARD", "PRUNING", "STAKING", "STOCK_TYPE_ID", "STOCK_TYPE", "PLANT_TYPE_ID", "PLANT_TYPE", "STUMPING_ID", "STUMPING_SIZE", "ROOTBALLDAMAGE", "INSPECTIONID", "SEQUENCEID", "CORRECT_STOCK_TYPE_ID", "CORRECT_STOCK_TYPE", "CORRECT_PLANT_TYPE_ID", "CORRECT_PLANT_TYPE", "COMMLOCATIONSPECIES", "COMMCROWN", "COMMROOTBALL", "COMMSTEM", "COMMPLANTINGHOLE", "COMMBEDPREPARATION", "COMMMULCH", "COMMOTHER", "CREATEUSER", "CONTRACTITEM", "READY_STATUS") AS 
  SELECT OBJECTID,
      TREEID,
      CREATEDATE,
      CONTRACTYEAR,
      CONTRACTNUMBER,
      CONTRACTOPERATION,
      (CASE WHEN CONTRACTOPERATION = 1 AND (STUMPING IS NULL OR STUMPING NOT IN (2,3)) THEN 1
            WHEN CONTRACTOPERATION IN (5, 6, 7) AND (STUMPING IS NULL OR STUMPING NOT IN (2,3)) THEN 3
            WHEN CONTRACTOPERATION IN (1, 5, 6, 7) AND (STUMPING in (2, 3)) THEN 2
            ELSE NULL END) AS ACTIVITY_TYPE_ID,
      MISSINGTREE,
      INCORRECTLOCATION,
      EXTRATREE,
      UNAPPROVEDSPECIES,
      CORRECTSPECIES,
      INCORRECTSIZE,
      TAGNUMBER,
      TAGCOLOR AS TAG_COLOR_ID,
      STC.CODE_NAME AS TAG_COLOR,
      CROWNDIEBACK,
      CROWNINSECTDISEASE,
      EPICORMICBRANCHING,
      BRANCHINGSTRUCTURE,
      ROOTBALLSIZE,
      ROOTBALLLOOSE,
      GIRDLINGROOTS,
      STEMINSECTDISEASE,
      STEMTISSUENECROSIS,
      STEMSCARS,
      GIRDLEDSTEM,
      DETAILEDINSPECTION,
      PLANTINGHOLESIZE,
      BACKFILL,
      PLANTINGLOW,
      PLANTINGHIGH,
      SOILRETENTIONRING,
      BURLAPWIREROPE,
      BEDPREPARATIONDIAMETER,
      BEDPREPARATIONSOD,
      BEDPREPARATIONCULTIVATION,
      BEDPREPARATIONCULTIVATIONDEPTH,
      MULCHDEPTH,
      MULCHDIAMETER,
      MULCHRING,
      MULCHSTEM,
      STEMCROWNROPE,
      TREEGATORBAG,
      TREEGUARD,
      PRUNING,
      STAKING,
      STOCKTYPE AS STOCK_TYPE_ID,
      TO_CHAR(SST.CODE_NAME) AS STOCK_TYPE,
      PLANTSIZE AS PLANT_TYPE_ID,
      TO_CHAR(SPT.CODE_NAME) AS PLANT_TYPE,
      STUMPING AS STUMPING_ID,
      TO_CHAR(SSS.CODE_NAME) AS STUMPING_SIZE,
      ROOTBALLDAMAGE,
      INSPECTIONID,
      SEQUENCEID,
      CORRECTSTOCKTYPE AS CORRECT_STOCK_TYPE_ID,
      TO_CHAR(SST2.CODE_NAME) AS CORRECT_STOCK_TYPE,
      CORRECTPLANTSIZE as CORRECT_PLANT_TYPE_ID,
      TO_CHAR(SPT2.CODE_NAME) AS CORRECT_PLANT_TYPE,
      COMMLOCATIONSPECIES,
      COMMCROWN,
      COMMROOTBALL,
      COMMSTEM,
      COMMPLANTINGHOLE,
      COMMBEDPREPARATION,
      COMMMULCH,
      COMMOTHER,
      CREATEUSER,
      CONTRACTITEM,
      CASE
      WHEN FSTD.MissingTree<>1
      AND FSTD.INCORRECTLOCATION<>1
      AND FSTD.EXTRATREE<>1
      AND FSTD.UNAPPROVEDSPECIES<>1
      AND FSTD.INCORRECTSIZE<>1
      AND FSTD.CrownDieback<>1
      AND FSTD.CrownInsectDisease<>1
      AND FSTD.EpicormicBranching<>1
      AND FSTD.BranchingStructure<>1
      AND FSTD.RootballSize<>1
      AND FSTD.RootballLoose<>1
      AND FSTD.RootballDamage<>1
      AND FSTD.GirdlingRoots<>1
      AND FSTD.StemInsectDisease<>1
      AND FSTD.StemTissueNecrosis<>1
      AND FSTD.StemScars<>1
      AND FSTD.GirdledStem<>1 THEN 1 ELSE 0 END AS READY_STATUS
FROM TRANSD.FSTDEFICIENCY_EVW@etrans FSTD
left join stp_stocktype_lk SST
on SST.CODE_VALUE = FSTD.STOCKTYPE
left join stp_plantsize_lk SPT
on SPT.CODE_VALUE = FSTD.PLANTSIZE
left join stp_stumping_lk SSS
on SSS.CODE_VALUE = FSTD.STUMPING
left join stp_stocktype_lk SST2
on SST2.CODE_VALUE = FSTD.STOCKTYPE
left join stp_plantsize_lk SPT2
on SPT2.CODE_VALUE = FSTD.PLANTSIZE
LEFT JOIN STP_TAGCOLOR_LK STC
ON FSTD.TAGCOLOR = STC.CODE_VALUE;
--------------------------------------------------------
--  DDL for View STP_NURSERY_INSPECTION_V
--------------------------------------------------------

  CREATE OR REPLACE FORCE EDITIONABLE VIEW "BSMART_DATA"."STP_NURSERY_INSPECTION_V" ("ID", "STATUS_ID", "STATUS", "YEAR", "TAG_NUM", "TAG_DATE", "STOCK_TYPE_ID", "STOCK_TYPE", "PLANT_TYPE_ID", "PLANT_TYPE", "SPECIES_ID", "SPECIES", "NURSERY_TYPE", "LOT", "TAG_COLOR", "TREE_DUG", "STEM_WRAPPED", "BUDS_EMERGED", "AVERAGE_ROOT_COLLAR_DEPTH", "COMMENTS", "SUB_STOCK_TYPE_ID", "SUB_STOCK_TYPE", "SUB_PLANT_TYPE_ID", "SUB_PLANT_TYPE", "SUB_SPECIES_ID", "SUB_SPECIES") AS 
  SELECT
SNI.ID,
SNI.STATUS_ID,
STP_STATUS.DESCRIPTION AS STATUS,
SNI.YEAR,
SNI.TAG_NUM,
SNI.TAG_DATE,
SNI.STOCK_TYPE_ID,
SST_1.CODE_NAME AS STOCK_TYPE,
SNI.PLANT_TYPE_ID,
SPT_1.CODE_NAME AS PLANT_TYPE,
SNI.SPECIES_ID,
SS_1.SPECIES,
SNI.NURSERY_TYPE,
SNI.LOT,
SNI.TAG_COLOR,
SNI.TREE_DUG,
SNI.STEM_WRAPPED,
SNI.BUDS_EMERGED,
SNI.AVERAGE_ROOT_COLLAR_DEPTH,
SNI.COMMENTS,
SNI.SUB_STOCK_TYPE_ID,
SST_2.CODE_NAME AS SUB_STOCK_TYPE,
SNI.SUB_PLANT_TYPE_ID,
SPT_2.CODE_NAME AS SUB_PLANT_TYPE,
SNI.SUB_SPECIES_ID,
SS_2.SPECIES AS SUB_SPECIES
FROM STP_NURSERY_INSPECTION SNI
LEFT JOIN stp_stocktype_lk SST_1
ON SST_1.CODE_VALUE = SNI.STOCK_TYPE_ID
LEFT JOIN stp_plantsize_lk SPT_1
ON SPT_1.CODE_VALUE = SNI.PLANT_TYPE_ID
LEFT JOIN STP_SPECIES_LK SS_1
ON SS_1.SPECIESID = SNI.SPECIES_ID
LEFT JOIN stp_stocktype_lk SST_2
ON SST_2.CODE_VALUE = SNI.SUB_STOCK_TYPE_ID
LEFT JOIN stp_plantsize_lk SPT_2
ON SPT_2.CODE_VALUE = SNI.SUB_PLANT_TYPE_ID
LEFT JOIN STP_SPECIES_LK SS_2
ON SS_2.SPECIESID = SNI.SUB_SPECIES_ID
LEFT JOIN STP_STATUS
ON STP_STATUS.ID = SNI.STATUS_ID;
--------------------------------------------------------
--  DDL for View STP_PRICE_V
--------------------------------------------------------

  CREATE OR REPLACE FORCE EDITIONABLE VIEW "BSMART_DATA"."STP_PRICE_V" ("ID", "YEAR", "ITEM_CODE", "SERIAL_NUM", "TYPE_ID", "TYPE", "STOCK_TYPE_ID", "STOCK_TYPE", "PLANT_TYPE_ID", "PLANT_TYPE", "SPECIES_ID", "SPECIES", "STUMPING_SIZE_ID", "STUMPING_SIZE", "TRANSP_DIS_ID", "TRANSP_DIS", "DESCRIPTION", "INUSE", "LAST_YEAR_PRICE", "PRICE_EST", "UNIT_PRICE", "MEASUREMENT", "DISPLAY", "CREATED_BY", "CREATED_ON", "MODIFIED_BY", "MODIFIED_ON") AS 
  SELECT 
SP.ID,
SP.YEAR,
SP.ITEM_CODE,
SP.SERIAL_NUM,
SP.TYPE_ID,
stp_activities.activity as TYPE,
SP.STOCK_TYPE_ID,
to_char(stp_stocktype_lk.code_name) AS STOCK_TYPE,
SP.PLANT_TYPE_ID,
to_char(PLANT_TYPE.code_name) AS PLANT_TYPE,
SP.SPECIES_ID,
to_char(STP_SPECIES_LK.SPECIES) AS SPECIES,
SP.STUMPING_SIZE_ID,
to_char(stp_stumping_lk.code_name) AS STUMPING_SIZE,
SP.TRANSP_DIS_ID,
to_char(TRANSP_DIS.code_name) AS TRANSP_DIS,
SP.DESCRIPTION,
SP.INUSE,
SP.LAST_YEAR_PRICE,
SP.PRICE_EST,
SP.UNIT_PRICE,
SP.MEASUREMENT,
SP.DISPLAY,
SP.CREATED_BY,
SP.CREATED_ON,
SP.MODIFIED_BY,
SP.MODIFIED_ON
from STP_PRICE SP
left join stp_activities
on stp_activities.id= SP.TYPE_ID
left join stp_stocktype_lk
on stp_stocktype_lk.CODE_VALUE = SP.STOCK_TYPE_ID
left join stp_plantsize_lk PLANT_TYPE
on PLANT_TYPE.CODE_VALUE = SP.PLANT_TYPE_ID
left join STP_SPECIES_LK
on STP_SPECIES_LK.SPECIESID = SP.SPECIES_ID
left join stp_stumping_lk
on stp_stumping_lk.CODE_VALUE = SP.STUMPING_SIZE_ID
left join stp_plantsize_lk TRANSP_DIS
on TRANSP_DIS.CODE_VALUE = SP.TRANSP_DIS_ID
;
--------------------------------------------------------
--  DDL for View STP_TREE_COUNT_V
--------------------------------------------------------

  CREATE OR REPLACE FORCE EDITIONABLE VIEW "BSMART_DATA"."STP_TREE_COUNT_V" ("CONTRACTYEAR", "CONTRACTITEM", "STATUS", "TREEID", "INSPECTIONDATE", "PROGRAM") AS 
  select distinct d.CONTRACTYEAR,
                  d.CONTRACTITEM,
                  t.STATUS,
                  t.TREEID,
                  i.INSPECTIONDATE,
                  ci.PROGRAM
  from transd.fsttree@etrans t 
  left join transd.fstdeficiency@etrans d on t.TREEID = d.TREEID
  left join transd.fstinspection@etrans i on t.TREEID = i.TREEID
  left join STP_CONTRACT_ITEM ci on d.CONTRACTITEM = ci.ITEM_NUM and d.CONTRACTYEAR = ci.YEAR
;
--------------------------------------------------------
--  DDL for View STP_TREE_LOCATION_V
--------------------------------------------------------

  CREATE OR REPLACE FORCE EDITIONABLE VIEW "BSMART_DATA"."STP_TREE_LOCATION_V" ("TREEID", "CONTRACTITEM", "CONTRACTYEAR", "YEARPLANTED", "REGIONALROAD", "ROADSIDE", "SEGMENT_ID", "ROADID", "MUNICIPALITY", "MUNID", "INSPECTIONDATE", "INSPECTIONTYPE", "STOCK_TYPE", "PLANT_TYPE", "PLANT_TYPE_ID", "SPECIES", "ITEMNAME", "STATUS", "TAG_COLOR", "TAG_NUMBER", "CURRENTHEALTH", "HEALTHNAME", "PROGRAM") AS 
  select STPDV.TREEID,
to_number(STPDV.CONTRACTITEM),
STPDV.CONTRACTYEAR,
TTREE.YEARPLANTED,
TTREE.ONSTREET,
TTREE.SIDEOFSTREET,
TTREE.SEGMENT_ID,
case when TTREE.SIDEOFSTREET = 'North' then 1
when TTREE.SIDEOFSTREET = 'East' then 2
when TTREE.SIDEOFSTREET = 'South' then 3
when TTREE.SIDEOFSTREET = 'West' then 4
when TTREE.SIDEOFSTREET = 'Centre Median' then 5
else null end,
TTREE.MUNICIPALITY,
case when TTREE.MUNICIPALITY = 'Aurora' then 1
when TTREE.MUNICIPALITY = 'King' then 2
when TTREE.MUNICIPALITY = 'Vaughan' then 3
when TTREE.MUNICIPALITY = 'Newmarket' then 4
when TTREE.MUNICIPALITY = 'East Gwillimbury' then 5
when TTREE.MUNICIPALITY = 'Georgina' then 6
when TTREE.MUNICIPALITY = 'Durham' then 7
when TTREE.MUNICIPALITY = 'Markham' then 8
when TTREE.MUNICIPALITY = 'Richmond Hill' then 9
when TTREE.MUNICIPALITY = 'Whitchurch-Stouffville' then 10
else null end,
INSPEC.INSPECTIONDATE,
INSPEC.INSPECTIONTYPE,
STPDV.STOCK_TYPE,
STPDV.PLANT_TYPE,
STPDV.PLANT_TYPE_ID,
TTREE.SPECIES,
STPDV.STOCK_TYPE ||'-'|| PLANT_TYPE ||'-'|| TTREE.SPECIES as "ITEMNAME",
TTREE.STATUS,
STPDV.TAG_COLOR,
STPDV.TAGNUMBER,
TTREE.CURRENTTREEHEALTH,
case when TTREE.CURRENTTREEHEALTH = 1 then 'Good'
when TTREE.CURRENTTREEHEALTH = 2 then 'Satisfactory'
when TTREE.CURRENTTREEHEALTH = 3 then 'Potential Trouble'
when TTREE.CURRENTTREEHEALTH = 4 then 'Declining'
when TTREE.CURRENTTREEHEALTH = 5 then 'Death Imminent'
when TTREE.CURRENTTREEHEALTH = 6 then 'Dead'
end as "HEALTHNAME",
CI.PROGRAM
from STP_DEFICIENCY_V STPDV
join transd.fsttree_evw@etrans TTREE on STPDV.TREEID = TTREE.TREEID
join transd.fstinspection_evw@etrans INSPEC on STPDV.TREEID = INSPEC.TREEID
join STP_CONTRACT_ITEM CI on STPDV.CONTRACTITEM = CI.ITEM_NUM;
--------------------------------------------------------
--  DDL for View STP_TREE_PLANTING_DETAIL_ROW_V
--------------------------------------------------------

  CREATE OR REPLACE FORCE EDITIONABLE VIEW "BSMART_DATA"."STP_TREE_PLANTING_DETAIL_ROW_V" ("ID", "TREE_PLANTING_DETAIL_ID", "RIN", "ROADSIDE", "BETWEEN_ROAD_1", "BETWEEN_ROAD_2", "ADDRESS", "COMMENTS", "MARK_TYPE_ID", "MARK_TYPE", "MARKING_LOCATION_ID", "MARKING_LOCATION", "OFFSET_FROM_MARK", "SPACING_ON_CENTRE", "HYDRO", "TYPE_ID", "TYPE", "STOCK_TYPE_ID", "STOCK_TYPE", "PLANT_TYPE_ID", "PLANT_TYPE", "SPECIES_ID", "SPECIES", "STUMP_SIZE_ID", "STUMP_SIZE", "TRANSPLANTING_DISTANCE_ID", "TRANSP_DIS", "QUANTITY", "ORD", "ASSIGNMENT_NUM", "ORDER_NO") AS 
  select tpdr.ID,
tpdr.TREE_PLANTING_DETAIL_ID,
tpdr.RIN,
tpdr.ROADSIDE,
tpdr.BETWEEN_ROAD_1,
tpdr.BETWEEN_ROAD_2,
tpdr.ADDRESS,
tpdr.COMMENTS,
tpdr.MARK_TYPE_ID,
mt.MARK_TYPE,
tpdr.MARKING_LOCATION_ID,
ml.MARKING_LOCATION,
tpdr.OFFSET_FROM_MARK,
tpdr.SPACING_ON_CENTRE,
tpdr.HYDRO,
tpdr.ACTIVITY_TYPE_ID AS TYPE_ID,
stp_activities.activity AS TYPE,
tpdr.STOCK_TYPE_ID,
stp_stocktype_lk.CODE_NAME AS STOCK_TYPE,
tpdr.PLANT_TYPE_ID,
PLANT_TYPE.CODE_NAME AS PLANT_TYPE,
tpdr.SPECIES_ID,
STP_SPECIES_LK.SPECIES,
tpdr.STUMP_SIZE_ID,
stp_stumping_lk.CODE_NAME AS STUMPING_SIZE,
tpdr.TRANSPLANTING_DISTANCE_ID,
TRANSP_DIS.CODE_NAME AS TRANSP_DIS,
tpdr.QTY AS QUANTITY,
tpdr.ORD,
tpdr.ASSIGNMENT_NUM,
tpdr.ORDER_NO
from stp_tree_planting_detail_row tpdr
left join STP_MARK_TYPE mt
on mt.id = MARK_TYPE_ID
left join STP_MARKING_LOCATION ml
on ml.id = tpdr.MARKING_LOCATION_ID
left join stp_activities
on stp_activities.id=tpdr.ACTIVITY_TYPE_ID
left join stp_stocktype_lk
on stp_stocktype_lk.CODE_VALUE = tpdr.STOCK_TYPE_ID
left join stp_plantsize_lk PLANT_TYPE
on PLANT_TYPE.CODE_VALUE = tpdr.PLANT_TYPE_ID
left join STP_SPECIES_LK
on STP_SPECIES_LK.SPECIESID = tpdr.SPECIES_ID
left join stp_stumping_lk
on stp_stumping_lk.CODE_VALUE = tpdr.STUMP_SIZE_ID
left join stp_plantsize_lk TRANSP_DIS
on TRANSP_DIS.CODE_VALUE = tpdr.TRANSPLANTING_DISTANCE_ID
;
--------------------------------------------------------
--  DDL for View STP_TREE_WATERING_V
--------------------------------------------------------

  CREATE OR REPLACE FORCE EDITIONABLE VIEW "BSMART_DATA"."STP_TREE_WATERING_V" ("TREEID", "CONTRACTITEM", "CONTRACTYEAR", "YEARPLANTED", "ROADSIDE", "SEGMENT_ID", "ROADID", "MUNICIPALITY", "MUNID", "STOCK_TYPE", "PLANT_TYPE", "PLANT_TYPE_ID", "SPECIES", "ITEMNAME", "STATUS", "TAG_COLOR", "TAG_NUMBER", "CURRENTHEALTH") AS 
  select distinct STPDV.TREEID,
to_number(STPDV.CONTRACTITEM),
STPDV.CONTRACTYEAR,
TTREE.YEARPLANTED,
TTREE.SIDEOFSTREET,
TTREE.SEGMENT_ID,
case when TTREE.SIDEOFSTREET = 'North' then 1
when TTREE.SIDEOFSTREET = 'East' then 2
when TTREE.SIDEOFSTREET = 'South' then 3
when TTREE.SIDEOFSTREET = 'West' then 4
when TTREE.SIDEOFSTREET = 'Centre Median' then 5
else null end,
TTREE.MUNICIPALITY,
case when TTREE.MUNICIPALITY = 'Aurora' then 1
when TTREE.MUNICIPALITY = 'King' then 2
when TTREE.MUNICIPALITY = 'Vaughan' then 3
when TTREE.MUNICIPALITY = 'Newmarket' then 4
when TTREE.MUNICIPALITY = 'East Gwillimbury' then 5
when TTREE.MUNICIPALITY = 'Georgina' then 6
when TTREE.MUNICIPALITY = 'Durham' then 7
when TTREE.MUNICIPALITY = 'Markham' then 8
when TTREE.MUNICIPALITY = 'Richmond Hill' then 9
when TTREE.MUNICIPALITY = 'Whitchurch-Stouffville' then 10
else null end,
STPDV.STOCK_TYPE,
STPDV.PLANT_TYPE,
STPDV.PLANT_TYPE_ID,
TTREE.SPECIES,
STPDV.STOCK_TYPE ||'-'|| PLANT_TYPE ||'-'|| TTREE.SPECIES as "ITEMNAME",
TTREE.STATUS,
STPDV.TAG_COLOR,
STPDV.TAGNUMBER,
TTREE.CURRENTTREEHEALTH
from STP_DEFICIENCY_V STPDV 
join transd.fsttree_evw@etrans TTREE on STPDV.TREEID = TTREE.TREEID;
--------------------------------------------------------
--  DDL for View STP_WARRANTY_PRINT_V
--------------------------------------------------------

  CREATE OR REPLACE FORCE EDITIONABLE VIEW "BSMART_DATA"."STP_WARRANTY_PRINT_V" ("TREEID", "TAG_NUMBER", "CONTRACT_NUM", "CONTRACTYEAR", "CONTRACTOPERATION", "CREATEDATE", "STOCK_TYPE", "PLANT_TYPE", "HEALTH", "HEALTHNAME", "MUNICIPALITY", "MUNID", "SPECIESID", "SPECIES", "COMMONNAME", "ROADSIDE", "WARRANTYACTION", "STATUS", "YEARPLANTED", "WARRANTY_TYPE_ID", "INSPECTIONTYPE") AS 
  select distinct d.TREEID,
  d.TAGNUMBER,
to_number(d.CONTRACTITEM) as "CONTRACT_NUM",
d.CONTRACTYEAR,
d.CONTRACTOPERATION,
d.CREATEDATE,
d.STOCK_TYPE,
d.PLANT_TYPE,
ft.CURRENTTREEHEALTH,
case when ft.CURRENTTREEHEALTH = 1 then 'Good'
when ft.CURRENTTREEHEALTH = 2 then 'Satisfactory'
when ft.CURRENTTREEHEALTH = 3 then 'Potential Trouble'
when ft.CURRENTTREEHEALTH = 4 then 'Declining'
when ft.CURRENTTREEHEALTH = 5 then 'Death Imminent'
when ft.CURRENTTREEHEALTH = 6 then 'Dead'
else null end as "HEALTHNAME",
ft.MUNICIPALITY,
case when ft.MUNICIPALITY = 'Aurora' then 1
when ft.MUNICIPALITY = 'King' then 2
when ft.MUNICIPALITY = 'Vaughan' then 3
when ft.MUNICIPALITY = 'Newmarket' then 4
when ft.MUNICIPALITY = 'East Gwillimbury' then 5
when ft.MUNICIPALITY = 'Georgina' then 6
when ft.MUNICIPALITY = 'Durham' then 7
when ft.MUNICIPALITY = 'Markham' then 8
when ft.MUNICIPALITY = 'Richmond Hill' then 9
when ft.MUNICIPALITY = 'Whitchurch-Stouffville' then 10
else null end,
ft.SPECIESID,
ft.SPECIES,
ft.COMMONNAME,
ft.SIDEOFSTREET,
fi.WARRANTYACTION,
ft.STATUS,
ft.YEARPLANTED,
fi.WARRANTYINSPECTIONTYPE,
fi.INSPECTIONTYPE
from transd.fstinspection_evw@etrans fi 
left join transd.fsttree_evw@etrans ft on ft.TREEID = fi.TREEID
left join STP_DEFICIENCY_V d on d.TREEID = fi.TREEID
left join stp_wrnty_inspection swi on d.CONTRACTYEAR = swi.CONTRACT_YEAR
where d.TREEID is not null;
--------------------------------------------------------
--  DDL for View STP_WATERING_ADDITIONAL_ITEM_V
--------------------------------------------------------

  CREATE OR REPLACE FORCE EDITIONABLE VIEW "BSMART_DATA"."STP_WATERING_ADDITIONAL_ITEM_V" ("RIN", "ROADSIDE", "QTY", "CONTRACT_ITEM_ID", "PLANT_TYPE", "CONTRACT_ITEM_NUM", "CONTRACT_ITEM_YEAR") AS 
  select stp_watering_additional_item.RIN, stp_watering_additional_item.ROADSIDE, stp_watering_additional_item.QTY, stp_watering_additional_item.CONTRACT_ITEM_ID, stp_watering_additional_item.plant_type, stp_contract_item.contract_item_num,stp_contract_item.year
from stp_watering_additional_item join stp_contract_item
on stp_watering_additional_item.contract_item_id = stp_contract_item.id
;
