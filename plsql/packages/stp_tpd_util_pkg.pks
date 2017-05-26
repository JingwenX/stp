create or replace PACKAGE             STP_TPD_UTIL_PKG AS 

  /* Utilities for Tree Planting Detail Pages. */

  DETAIL_COLLECTION_NAME CONSTANT VARCHAR2(30) := 'TPD_COLLECTION';
  
  PROCEDURE load_detail_row(P_TREE_PLANTING_DETAIL_ID IN BSMART_DATA.STP_TREE_PLANTING_DETAIL_ROW.TREE_PLANTING_DETAIL_ID%TYPE);

  PROCEDURE create_or_save_detail_row(P_TREE_PLANTING_DETAIL_ID IN  BSMART_DATA.STP_TREE_PLANTING_DETAIL_ROW.TREE_PLANTING_DETAIL_ID%TYPE);

  PROCEDURE process_detail_rows(P_TREE_PLANTING_DETAIL_ID IN  BSMART_DATA.STP_TREE_PLANTING_DETAIL_ROW.TREE_PLANTING_DETAIL_ID%TYPE);
    

END STP_TPD_UTIL_PKG;