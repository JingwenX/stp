INSERT INTO STP_CONTRACT_ITEM (STATUS_ID, PROGRAM, PROJECT_TYPE, MUNICIPALITY, REGIONAL_ROAD, BETWEEN_ROAD_1, BETWEEN_ROAD_2, RINS, CONTRACT_ITEM_NUM, YEAR, OWNERSHIP)
SELECT 1, CI."Program", CP."ProjectName", "Municipality", "RegionalRoad", "BetweenRoad1", "BetweenRoad2", "RINs", "ContractYear" || ' - ' ||  TO_CHAR("ContractNum", '009'), "ContractYear", 'Regional ROW' from dbo."ContractItem"@stp CI left join dbo."CapitalProjects"@stp CP on CI."ProjectNumber" = CP."ProjectNumber" where "ContractYear" = 2012
/