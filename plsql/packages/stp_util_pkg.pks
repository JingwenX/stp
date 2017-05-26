create or replace package stp_util_pkg as 

  /* Common utility functions. */

  COMMENT_COLLECTION_NAME CONSTANT VARCHAR2(30) := 'COMMENT_COLLECTION';
  
  FUNCTION GET_CONTRACT_NUM(P_YEAR IN NUMBER) RETURN VARCHAR2;

  FUNCTION GET_WATERING_AMOUNT( p_year   IN NUMBER )RETURN number;
  
  PROCEDURE send_lock_notification( p_year IN NUMBER, p_comments IN VARCHAR2 DEFAULT NULL);

  PROCEDURE LOAD_COMMENT_COLLECTION( P_ITEM_ID IN NUMBER);
  
  PROCEDURE PROCESS_COMMENT_COLLECTION( P_ITEM_ID IN NUMBER);

  FUNCTION LOAD_PARAMETER( P_TYPE IN NUMBER,
                           P_ID   IN NUMBER) RETURN VARCHAR2;
                           


end stp_util_pkg;