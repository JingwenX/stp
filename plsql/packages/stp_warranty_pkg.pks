create or replace package                                                                                     STP_WARRANTY_PKG as

    --moving to aop_factory, won't comment for now
    function AOP_species_report
    return varchar2;
    
    function AOP_municipality_report 
    return varchar2;  
    
    function AOP_health_report
    return varchar2;
    
    function AOP_contract_report
    return varchar2;
    
    function AOP_species_list_report
    return varchar2;
    
    function AOP_dlist_details_report
    return varchar2;
    
    function AOP_dlist_summary_report
    return varchar2;
  
end STP_WARRANTY_PKG;