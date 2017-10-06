create or replace package body                                                                                                                                                                                                                                                                         STP_WARRANTY_PKG as
    
    function AOP_species_report return varchar2
    as
      l_return clob;
    begin
      l_return := q'[
        with treeStatus as(
        select distinct t.TREEID as "TREEID",
               t.SPECIESID as "SPECIESID",
               t.SPECIES as "SPECIES",
               t.WARRANTYACTION as "ACTION"
        from STP_WARRANTY_PRINT_V t
        where --t.STATUS = 'Active'
        t.contractyear = :p0_year
        and t.warranty_type_id = :P113_WTYPE 
        and t.CONTRACTOPERATION = decode(:P113_WTYPE, 1,1,
                                                      2,1,
                                                      3,3)
        and t.INSPECTIONTYPE in ('Warranty', 'Warranty Replacement')
        order by 3
      ),
      
      accepted_sum as(
        select ts.SPECIES as "SPECIES",
               ts.SPECIESID as "SPECIESID",
               count(ts.SPECIES) as "ASUM"
        from treeStatus ts
        where ts.ACTION = 'Accept'
        group by ts.SPECIES, ts.SPECIESID
        order by 1
      ),
      
      rejected_sum as(
        select ts.SPECIES as "SPECIES",
               ts.SPECIESID as "SPECIESID",
               count(ts.SPECIES) as "RSUM"
        from treeStatus ts
        where ts.ACTION = 'Reject'
        group by ts.SPECIES, ts.SPECIESID
        order by 1
      ),
      
      missing_sum as(
        select ts.SPECIES as "SPECIES",
               ts.SPECIESID as "SPECIESID",
               count(ts.SPECIES) as "MSUM"
        from treeStatus ts
        where ts.ACTION = 'Missing Tree'
        group by ts.SPECIES, ts.SPECIESID
        order by 1
      )

select null as "filename",
cursor(
  select 
  SYSDATE as "DAT",
  :P0_YEAR as "YR",
  :P0_CONTRACTNUMBER as "CONNUM",
  cursor(
    select w.species as "SPEC", 
           (nvl(acsum.ASUM, 0) + nvl(rjsum.rsum, 0) + nvl(misum.msum, 0)) as "TOT",
           nvl(acsum.ASUM, 0) as "ACC",
           nvl(rjsum.rsum, 0) as "REJ",
           nvl(misum.msum, 0) as "MISS"
           from STP_WARRANTY_PRINT_V w
           left join accepted_sum acsum on acsum.SPECIESID = w.SPECIESID
           left join rejected_sum rjsum on rjsum.SPECIESID = w.SPECIESID
           left join missing_sum misum on misum.SPECIESID = w.SPECIESID
           where w.species is not null and 
           w.CONTRACTOPERATION in (1,3) and
           w.INSPECTIONTYPE = 'Warranty' and
           w.contractyear = :p0_year and
           w.warranty_type_id = :P113_WTYPE -- remove is null from or condition when stp has correct data
           group by w.species, w.speciesid, acsum.asum, rjsum.rsum, misum.msum
    order by w.Species
    ) "SLIST",
    (select nvl(sum(ASUM), 0) from accepted_sum) + (select nvl(sum(RSUM), 0) from rejected_sum) + (select nvl(sum(MSUM), 0) from missing_sum) as "TOTTOT",
    (select nvl(sum(ASUM), 0) from accepted_sum) as "ATOT",
    (select nvl(sum(RSUM), 0) from rejected_sum) as "RTOT",
    (select nvl(sum(MSUM), 0) from missing_sum) as "MTOT"
    from dual
    group by :P0_YEAR
) "data"
from dual 
      ]';
      
      return l_return;
    end;
    
    function AOP_municipality_report return varchar2
    as
      l_return clob;
    begin
      l_return := q'[
        with treeStatus as(
        select distinct t.TREEID as "TREEID",
               t.munid as "MUNID",
               t.SPECIESID as "SPECIESID",
               t.SPECIES as "SPECIES",
               t.WARRANTYACTION as "ACTION"
        from STP_WARRANTY_PRINT_V t
        where --t.STATUS = 'Active'
        t.contractyear = :p0_year
        and t.warranty_type_id = :P114_WTYPE 
        and t.CONTRACTOPERATION = decode(:P114_WTYPE, 1,1,
                                                      2,1,
                                                      3,3)
        and t.INSPECTIONTYPE = 'Warranty'
        order by 3
      ),
      
      accepted_sum as(
        select ts.SPECIES as "SPECIES",
               ts.SPECIESID as "SPECIESID",
               ts.MUNID as "MU",
               count(ts.SPECIES) as "ASUM"
        from treeStatus ts
        where ts.ACTION = 'Accept'
        group by ts.SPECIES, ts.SPECIESID, ts.MUNID
        order by 1
      ),
      
      rejected_sum as(
        select ts.SPECIES as "SPECIES",
               ts.SPECIESID as "SPECIESID",
               ts.MUNID as "MU",
               count(ts.SPECIES) as "RSUM"
        from treeStatus ts
        where ts.ACTION = 'Reject'
        group by ts.SPECIES, ts.SPECIESID, ts.MUNID
        order by 1
      ),
      
      missing_sum as(
        select ts.SPECIES as "SPECIES",
               ts.SPECIESID as "SPECIESID",
               ts.MUNID as "MU",
               count(ts.SPECIES) as "MSUM"
        from treeStatus ts
        where ts.ACTION = 'Missing Tree'
        group by ts.SPECIES, ts.SPECIESID, ts.MUNID
        order by 1
      )

select null as "filename",
cursor(
  select 
  SYSDATE as "DAT",
  :P0_YEAR as "YR",
  :P0_CONTRACTNUMBER as "CONNUM",
  cursor(
    select w1.municipality as "MUN",
    cursor(
   select 
     cursor(
        select w.species as "SPEC", 
               w.speciesid,
               (nvl(acsum.ASUM, 0) + nvl(rjsum.rsum, 0) + nvl(misum.msum, 0)) as "TOT",
               nvl(acsum.ASUM, 0) as "ACC",
               nvl(rjsum.rsum, 0) as "REJ",
               nvl(misum.msum, 0) as "MISS"
               from STP_WARRANTY_PRINT_V w
               left join accepted_sum acsum on acsum.SPECIESID = w.SPECIESID and acsum.mu = w.munid
               left join rejected_sum rjsum on rjsum.SPECIESID = w.SPECIESID and rjsum.mu = w.munid
               left join missing_sum misum on misum.SPECIESID = w.SPECIESID and misum.mu = w.munid
               where w.species is not null and 
               (nvl(acsum.ASUM, 0) + nvl(rjsum.rsum, 0) + nvl(misum.msum, 0))<>0 and
               w.CONTRACTOPERATION in (1, 3) and
               w.INSPECTIONTYPE = 'Warranty' and
               w.contractyear = :p0_year and
               w.warranty_type_id = :P114_WTYPE and -- remove is null from or condition when stp has correct data
               convert(w.municipality, 'AL16UTF16', 'AL32UTF8') = w1.municipality
               group by w.species, w.speciesid, w.munid, acsum.asum, rjsum.rsum, misum.msum
        order by w.Species
        ) "SLIST",
        (select nvl(sum(a.ASUM), 0) from accepted_sum a where a.mu = w1.munid) + 
        (select nvl(sum(r.RSUM), 0) from rejected_sum r where r.mu = w1.munid) + 
        (select nvl(sum(m.MSUM), 0) from missing_sum m where m.mu = w1.munid) as "TOTTOT",
        (select nvl(sum(a.ASUM), 0) from accepted_sum a where a.mu = w1.munid) as "ATOT",
        (select nvl(sum(r.RSUM), 0) from rejected_sum r where r.mu = w1.munid) as "RTOT",
        (select nvl(sum(m.MSUM), 0) from missing_sum m where m.mu = w1.munid) as "MTOT"
        from dual
        where exists(
          select w.species as "SPEC", 
                 w.speciesid
                 from STP_WARRANTY_PRINT_V w
                 where w.species is not null and
                 w.status = 'Active' and 
                 w.CONTRACTOPERATION in (1, 3) and
                 w.yearplanted = :p0_year and
                (w.warranty_type_id = :P114_WTYPE or w.warranty_type_id is null)
                group by w.species, w.speciesid
        )
      ) "MUNICIPALITIES"
      from STP_WARRANTY_PRINT_V w1
      where w1.municipality is not null
      and w1.municipality<>'Durham'
      and exists(
           select w.species as "SPEC", 
               w.speciesid,
               (nvl(acsum.ASUM, 0) + nvl(rjsum.rsum, 0) + nvl(misum.msum, 0)) as "TOT",
               nvl(acsum.ASUM, 0) as "ACC",
               nvl(rjsum.rsum, 0) as "REJ",
               nvl(misum.msum, 0) as "MISS"
               from STP_WARRANTY_PRINT_V w
               left join accepted_sum acsum on acsum.SPECIESID = w.SPECIESID and acsum.mu = w.munid
               left join rejected_sum rjsum on rjsum.SPECIESID = w.SPECIESID and rjsum.mu = w.munid
               left join missing_sum misum on misum.SPECIESID = w.SPECIESID and misum.mu = w.munid
               where w.species is not null and 
               (nvl(acsum.ASUM, 0) + nvl(rjsum.rsum, 0) + nvl(misum.msum, 0))<>0 and
               w.status = 'Active' and 
               w.CONTRACTOPERATION in (1, 3) and
               w.yearplanted = :p0_year and
               (w.warranty_type_id = :P114_WTYPE or w.warranty_type_id is null) and -- remove is null from or condition when stp has correct data
               w.municipality = w1.municipality
               group by w.species, w.speciesid, w.munid, acsum.asum, rjsum.rsum, misum.msum
        )
      group by w1.municipality, w1.munid
      order by w1.municipality
  ) "OUTER"
  from dual
  group by :P0_YEAR
) "data"
from dual
      ]';
      
      return l_return;
    end;
    
    function AOP_health_report return varchar2
    as
      l_return clob;
   begin
      l_return := q'[
          with treeStatus as(
        select distinct t.TREEID as "TREEID",
               t.munid as "MUNID",
               t.SPECIESID as "SPECIESID",
               t.SPECIES as "SPECIES",
               t.HEALTH as "HEALTH",
               t.WARRANTYACTION as "ACTION"
        from STP_WARRANTY_PRINT_V t
        where --t.STATUS = 'Active'
        t.contractyear = :p0_year
        and t.warranty_type_id = :P115_WTYPE 
        and t.CONTRACTOPERATION = decode(:P115_WTYPE, 1,1,
                                                      2,1,
                                                      3,3)
        and t.INSPECTIONTYPE = 'Warranty'
        order by 3
      ),
      
      accepted_sum as(
        select ts.MUNID as "MU",
               ts.HEALTH as "HEALTH",
               count(ts.HEALTH) as "ASUM"
        from treeStatus ts
        where ts.ACTION = 'Accept'
        group by ts.MUNID, ts.HEALTH
        order by 1
      ),
      
      rejected_sum as(
        select ts.MUNID as "MU",
               ts.HEALTH as "HEALTH",
               count(ts.HEALTH) as "RSUM"
        from treeStatus ts
        where ts.ACTION = 'Reject'
        group by ts.MUNID, ts.HEALTH
        order by 1
      ),
      
      missing_sum as(
        select ts.MUNID as "MU",
               ts.HEALTH as "HEALTH",
               count(ts.HEALTH) as "MSUM"
        from treeStatus ts
        where ts.ACTION = 'Missing Tree'
        group by ts.MUNID, ts.HEALTH
        order by 1
      )

select null as "filename",
cursor(
  select 
  SYSDATE as "DAT",
  :P0_YEAR as "YR",
  :P0_CONTRACTNUMBER as "CONNUM",
  cursor(
    select w1.municipality as "MUN",
    cursor(
   select 
     cursor(
        select w.health ||' - '|| case w.health 
        when 1 then 'Good'
        when 2 then 'Satisfactory'
        when 3 then 'Potential Trouble'
        when 4 then 'Declining'
        when 5 then 'Death Immenent'
        when 6 then 'Dead'
        else null end as "HELRAT", 
               (nvl(acsum.ASUM, 0) + nvl(rjsum.rsum, 0) + nvl(misum.msum, 0)) as "TOT",
               nvl(acsum.ASUM, 0) as "ACC",
               nvl(rjsum.rsum, 0) as "REJ",
               nvl(misum.msum, 0) as "MISS"
               from STP_WARRANTY_PRINT_V w
               left join accepted_sum acsum on acsum.health = w.health and acsum.mu = w.munid
               left join rejected_sum rjsum on rjsum.health = w.health and rjsum.mu = w.munid
               left join missing_sum misum on misum.health = w.health and misum.mu = w.munid
               where w.species is not null and 
               (nvl(acsum.ASUM, 0) + nvl(rjsum.rsum, 0) + nvl(misum.msum, 0))<>0 and
               w.CONTRACTOPERATION in (1, 3) and
               w.INSPECTIONTYPE = 'Warranty' and
               w.contractyear = :p0_year and
               w.warranty_type_id = :P115_WTYPE and -- remove is null from or condition when stp has correct data
               convert(w.municipality, 'AL16UTF16', 'AL32UTF8') = w1.municipality
               group by w.health, w.munid, acsum.asum, rjsum.rsum, misum.msum
               order by w.health
        ) "SLIST",
        (select nvl(sum(a.ASUM), 0) from accepted_sum a where a.mu = w1.munid) + 
        (select nvl(sum(r.RSUM), 0) from rejected_sum r where r.mu = w1.munid) + 
        (select nvl(sum(m.MSUM), 0) from missing_sum m where m.mu = w1.munid) as "TOTTOT",
        (select nvl(sum(a.ASUM), 0) from accepted_sum a where a.mu = w1.munid) as "ATOT",
        (select nvl(sum(r.RSUM), 0) from rejected_sum r where r.mu = w1.munid) as "RTOT",
        (select nvl(sum(m.MSUM), 0) from missing_sum m where m.mu = w1.munid) as "MTOT" -- 
        from dual
        where exists(
          select w.health,
                 w.munid
                 from STP_WARRANTY_PRINT_V w
                 where w.species is not null and
                 w.status = 'Active' and 
                 w.CONTRACTOPERATION in (1, 3) and
                 w.yearplanted = :p0_year 
                group by w.health, w.munid
        )
      ) "MUNICIPALITIES"
      from STP_WARRANTY_PRINT_V w1
      where w1.municipality is not null
      and w1.municipality<>'Durham'
      and exists(
            select w.health ||' - '|| case w.health 
        when 1 then 'Good'
        when 2 then 'Satisfactory'
        when 3 then 'Potential Trouble'
        when 4 then 'Declining'
        when 5 then 'Death Immenent'
        when 6 then 'Dead'
        else null end as "HELRAT", 
               (nvl(acsum.ASUM, 0) + nvl(rjsum.rsum, 0) + nvl(misum.msum, 0)) as "TOT",
               nvl(acsum.ASUM, 0) as "ACC",
               nvl(rjsum.rsum, 0) as "REJ",
               nvl(misum.msum, 0) as "MISS"
               from STP_WARRANTY_PRINT_V w
               left join accepted_sum acsum on acsum.health = w.health and acsum.mu = w.munid
               left join rejected_sum rjsum on rjsum.health = w.health and rjsum.mu = w.munid
               left join missing_sum misum on misum.health = w.health and misum.mu = w.munid
               where w.species is not null and 
               (nvl(acsum.ASUM, 0) + nvl(rjsum.rsum, 0) + nvl(misum.msum, 0))<>0 and
               w.status = 'Active' and 
               w.CONTRACTOPERATION in (1, 3) and
               w.yearplanted = :p0_year and
               (w.warranty_type_id = :P115_WTYPE or w.warranty_type_id is null) and -- remove is null from or condition when stp has correct data
               w.municipality = w1.municipality
               group by w.health, w.munid, acsum.asum, rjsum.rsum, misum.msum
        )
      group by w1.municipality, w1.munid
      order by w1.municipality
  ) "OUTER"
  from dual
  group by :P0_YEAR
) "data"
from dual 
      ]';
      
      return l_return;
   end;
   
   function AOP_contract_report return varchar2
   as
    l_return clob;
   begin
    l_return := q'[
     with treeStatus as(
        select distinct t.TREEID as "TREEID",
               t.CONTRACT_NUM as "CONTRACT_NUM",
               t.SPECIESID as "SPECIESID",
               t.SPECIES as "SPECIES",
               t.HEALTH as "HEALTH",
               t.WARRANTYACTION as "ACTION"
        from STP_WARRANTY_PRINT_V t
        where --t.STATUS = 'Active'
        t.contractyear = :p0_year
        and t.warranty_type_id = :P116_WTYPE 
        and t.CONTRACTOPERATION = decode(:P116_WTYPE, 1,1,
                                                      2,1,
                                                      3,3)
        and t.INSPECTIONTYPE = 'Warranty'
        order by 3
      ),
      
      accepted_sum as(
        select ts.CONTRACT_NUM as "MU",
               ts.HEALTH as "HEALTH",
               count(ts.HEALTH) as "ASUM"
        from treeStatus ts
        where ts.ACTION = 'Accept'
        group by ts.CONTRACT_NUM, ts.HEALTH
        order by 1
      ),
      
      rejected_sum as(
        select ts.CONTRACT_NUM as "MU",
               ts.HEALTH as "HEALTH",
               count(ts.HEALTH) as "RSUM"
        from treeStatus ts
        where ts.ACTION = 'Reject'
        group by ts.CONTRACT_NUM, ts.HEALTH
        order by 1
      ),
      
      missing_sum as(
        select ts.CONTRACT_NUM as "MU",
               ts.HEALTH as "HEALTH",
               count(ts.HEALTH) as "MSUM"
        from treeStatus ts
        where ts.ACTION = 'Missing Tree'
        group by ts.CONTRACT_NUM, ts.HEALTH
        order by 1
      )

select null as "filename",
cursor(
  select 
  SYSDATE as "DAT",
  :P0_YEAR as "YR",
  :P0_CONTRACTNUMBER as "CONNUM",
  cursor(
    select w1.contract_num,
    :p0_year ||' - '|| to_char(w1.contract_num, '000') as "CON",
    cursor(
   select 
     cursor(
        select w.health ||' - '|| case w.health 
        when 1 then 'Good'
        when 2 then 'Satisfactory'
        when 3 then 'Potential Trouble'
        when 4 then 'Declining'
        when 5 then 'Death Immenent'
        when 6 then 'Dead'
        else null end as "HELRAT", 
               (nvl(acsum.ASUM, 0) + nvl(rjsum.rsum, 0) + nvl(misum.msum, 0)) as "TOT",
               nvl(acsum.ASUM, 0) as "ACC",
               nvl(rjsum.rsum, 0) as "REJ",
               nvl(misum.msum, 0) as "MISS"
               from STP_WARRANTY_PRINT_V w
               left join accepted_sum acsum on acsum.health = w.health and acsum.mu = w.contract_num
               left join rejected_sum rjsum on rjsum.health = w.health and rjsum.mu = w.contract_num
               left join missing_sum misum on misum.health = w.health and misum.mu = w.contract_num
               where w.species is not null and 
               (nvl(acsum.ASUM, 0) + nvl(rjsum.rsum, 0) + nvl(misum.msum, 0))<>0 and
               w.CONTRACTOPERATION in (1, 3) and
               w.INSPECTIONTYPE = 'Warranty' and
               w.contractyear = :p0_year and
               w.warranty_type_id = :P116_WTYPE and -- remove is null from or condition when stp has correct data
               w.contract_num = w1.contract_num
               group by w.health, w.contract_num, acsum.asum, rjsum.rsum, misum.msum
               order by w.health
        ) "SLIST",
        (select nvl(sum(a.ASUM), 0) from accepted_sum a where a.mu = w1.contract_num) + 
        (select nvl(sum(r.RSUM), 0) from rejected_sum r where r.mu = w1.contract_num) + 
        (select nvl(sum(m.MSUM), 0) from missing_sum m where m.mu = w1.contract_num) as "TOTTOT",
        (select nvl(sum(a.ASUM), 0) from accepted_sum a where a.mu = w1.contract_num) as "ATOT",
        (select nvl(sum(r.RSUM), 0) from rejected_sum r where r.mu = w1.contract_num) as "RTOT",
        (select nvl(sum(m.MSUM), 0) from missing_sum m where m.mu = w1.contract_num) as "MTOT"
        from dual
      ) "CONTRACTS"
      from STP_WARRANTY_PRINT_V w1
      where w1.municipality is not null
      and w1.municipality<>'Durham'
      and exists(
          select w.health 
               from STP_WARRANTY_PRINT_V w
               left join accepted_sum acsum on acsum.health = w.health and acsum.mu = w.contract_num
               left join rejected_sum rjsum on rjsum.health = w.health and rjsum.mu = w.contract_num
               left join missing_sum misum on misum.health = w.health and misum.mu = w.contract_num
               where w.species is not null and 
               (nvl(acsum.ASUM, 0) + nvl(rjsum.rsum, 0) + nvl(misum.msum, 0))<>0 and
               w.CONTRACTOPERATION in (1, 3) and
               w.contractyear = :p0_year and
               w.warranty_type_id = :P116_WTYPE and -- remove is null from or condition when stp has correct data
               w.contract_num = w1.contract_num
               group by w.health, w.contract_num, acsum.asum, rjsum.rsum, misum.msum
      )
      group by w1.contract_num
      order by w1.contract_num
  ) "OUTER"
  from dual
  group by :P0_YEAR
) "data"
from dual 
    ]';
    
    return l_return;
   end;
   
   function AOP_species_list_report return varchar2
   as
    l_return clob;
   begin
    l_return := 
  q'[
      with def as (
    select 
       STPDV.TREEID as "TREEID",
       case
       when STPDV.CROWNDIEBACK = 1 then 'Crown dieback (<75% crown density)'
       when STPDV.CROWNINSECTDISEASE = 1 then 'Crown disease/insect'
       when STPDV.EPICORMICBRANCHING = 1 then 'Epicormic branching'
       when STPDV.BRANCHINGSTRUCTURE = 1 then 'Poor branching structure'
       when STPDV.ROOTBALLSIZE = 1 then 'Root ball size too small'
       when STPDV.ROOTBALLLOOSE = 1 then 'Stem loose in root ball'
       when STPDV.GIRDLINGROOTS = 1 then 'Root ball and/or roots damage'
       when STPDV.STEMINSECTDISEASE = 1 then 'Stem insect/disease'
       when STPDV.STEMTISSUENECROSIS = 1 then 'Stem tissue necrosis'
       when STPDV.STEMSCARS = 1 then 'Stem scars'
       when STPDV.GIRDLEDSTEM = 1 then 'Girdled stem'
       -- all above need tree replacement
       when STPDV.PLANTINGHOLESIZE = 1 then 'Planting hole incorrect size'
       when STPDV.BACKFILL = 1 then 'Insufficient soil tamping / air pockets present'
       when STPDV.PLANTINGLOW = 1 then 'Root ball planted too deep'
       when STPDV.PLANTINGHIGH = 1 then 'Root ball planted too high'
       when STPDV.SOILRETENTIONRING = 1 then 'Deficient soil water retention ring'
       when STPDV.BURLAPWIREROPE = 1 then 'Exposed burlap, wire or rope not removed'
       when STPDV.BEDPREPARATIONDIAMETER = 1 then 'Deficient diameter of bed preparation area'
       when STPDV.BEDPREPARATIONSOD = 1 then 'Sod remains on site/within bed preparation area'
       when STPDV.BEDPREPARATIONCULTIVATION = 1 then 'Deficient soil cultivation'
       when STPDV.BEDPREPARATIONCULTIVATIONDEPTH = 1 then 'Deficient soil cultivation depth'
       when STPDV.MULCHDEPTH = 1 then 'Deficient depth of mulch'
       when STPDV.MULCHDIAMETER = 1 then 'Deficient mulch diameter'
       when STPDV.MULCHRING = 1 then 'Deficient mulch retention ring'
       when STPDV.MULCHSTEM = 1 then 'Mulch too close to the stem'
       when STPDV.STEMCROWNROPE = 1 then 'Stem/crown rope and/or ties present'
       when STPDV.TREEGATORBAG = 1 then 'Missing gator bag'
       when STPDV.TREEGUARD = 1 then 'Missing tree guard'
       when STPDV.PRUNING = 1 then 'Crown requires pruning'
       when STPDV.STAKING = 1 then 'Staking required'
       end as "DEF",
    
       case
       when STPDV.CROWNDIEBACK = 1 or
       STPDV.CROWNINSECTDISEASE = 1 or
       STPDV.EPICORMICBRANCHING = 1 or
       STPDV.BRANCHINGSTRUCTURE = 1 or
       STPDV.ROOTBALLSIZE = 1  or
       STPDV.ROOTBALLLOOSE = 1 or
       STPDV.GIRDLINGROOTS = 1 or
       STPDV.STEMINSECTDISEASE = 1 or
       STPDV.STEMTISSUENECROSIS = 1 or
       STPDV.STEMSCARS = 1 or
       STPDV.GIRDLEDSTEM = 1 then 'Replace Tree'
       -- all above need tree replacement
       when STPDV.PLANTINGHOLESIZE = 1 then 'Increase diameter of planting hole'
       when STPDV.BACKFILL = 1 then 'Tamp backfill to eliminate air pockets'
       when STPDV.PLANTINGLOW = 1 then 'Raise tree so root collar 5 - 10 cm above grade'
       when STPDV.PLANTINGHIGH = 1 then 'Lower tree so root collar 5 - 10 cm above grade'
       when STPDV.SOILRETENTIONRING = 1 then 'Add/correct soil water retention ring'
       when STPDV.BURLAPWIREROPE = 1 then 'Remove burlap, wire and/or rope'
       when STPDV.BEDPREPARATIONDIAMETER = 1 then 'Increase diameter of bed preparation area'
       when STPDV.BEDPREPARATIONSOD = 1 then 'Remove sod from bed preparation area'
       when STPDV.BEDPREPARATIONCULTIVATION = 1 then 'Cultivate bed preparation area'
       when STPDV.BEDPREPARATIONCULTIVATIONDEPTH = 1 then 'Increase depth of cultivation'
       when STPDV.MULCHDEPTH = 1 then 'Increase depth of mulch'
       when STPDV.MULCHDIAMETER = 1 then 'Increase diameter of mulch'
       when STPDV.MULCHRING = 1 then 'Add/correct mulch water retention ring'
       when STPDV.MULCHSTEM = 1 then 'Move mulch a minimum of 5 cm away from stem'
       when STPDV.STEMCROWNROPE = 1 then 'Remove rope and/or ties from tree crown'
       when STPDV.TREEGATORBAG = 1 then 'Install TreeGator bag'
       when STPDV.TREEGUARD = 1 then 'Install tree guard'
       when STPDV.PRUNING = 1 then 'Prune crown to remove dead, diseased or broken branches'
       when STPDV.STAKING = 1 then 'Stake leaning or loose tree, correct inproper staking'
       end as "REP"
       from STP_DEFICIENCY_V STPDV 
),

species as(
  select distinct
         w.SPECIES,
         w.COMMONNAME,
         w.TREEID,
         count(w.TREEID)
  from STP_WARRANTY_PRINT_V w
  join def d on d.TREEID = w.TREEID
  --where d.def is not null --and d.rep = 'Replace Tree'
  where w.CONTRACTYEAR = :P0_YEAR and w.WARRANTY_TYPE_ID = :P118_WTYPE
  and w.CONTRACTOPERATION in (1, 3) and w.WARRANTYACTION = 'Reject'
  group by w.SPECIES, w.COMMONNAME, w.TREEID
  order by 1
)

select null as "filename",
cursor(
  select 
  SYSDATE as "DAT",
  :P0_YEAR as "YR",
  :P0_CONTRACTNUMBER as "CONNUM",
  cursor(
    select s.SPECIES as "SPEC",
           s.COMMONNAME as "NAME",
           count(s.SPECIES) as "COUNT"
       from species s
       group by s.SPECIES, s.COMMONNAME
       order by 1
  ) "ITEMS",
  (select sum(c) from (select count(s.species) as c from species s )) as "TOT"
  from dual
  group by :P0_YEAR
) "data"
from dual
    ]'; 
    
    return l_return;
   end;
   
   function AOP_dlist_details_report return varchar2
   as
    l_return clob;
   begin
    l_return := q'[
        with def as (
    select 
       STPDV.TREEID as "TREEID",
       case
       when STPDV.CROWNDIEBACK = 1 then 'Crown dieback (<75% crown density)'
       when STPDV.CROWNINSECTDISEASE = 1 then 'Crown disease/insect'
       when STPDV.EPICORMICBRANCHING = 1 then 'Epicormic branching'
       when STPDV.BRANCHINGSTRUCTURE = 1 then 'Poor branching structure'
       when STPDV.ROOTBALLSIZE = 1 then 'Root ball size too small'
       when STPDV.ROOTBALLLOOSE = 1 then 'Stem loose in root ball'
       when STPDV.GIRDLINGROOTS = 1 then 'Root ball and/or roots damage'
       when STPDV.STEMINSECTDISEASE = 1 then 'Stem insect/disease'
       when STPDV.STEMTISSUENECROSIS = 1 then 'Stem tissue necrosis'
       when STPDV.STEMSCARS = 1 then 'Stem scars'
       when STPDV.GIRDLEDSTEM = 1 then 'Girdled stem'
       -- all above need tree replacement
       when STPDV.PLANTINGHOLESIZE = 1 then 'Planting hole incorrect size'
       when STPDV.BACKFILL = 1 then 'Insufficient soil tamping / air pockets present'
       when STPDV.PLANTINGLOW = 1 then 'Root ball planted too deep'
       when STPDV.PLANTINGHIGH = 1 then 'Root ball planted too high'
       when STPDV.SOILRETENTIONRING = 1 then 'Deficient soil water retention ring'
       when STPDV.BURLAPWIREROPE = 1 then 'Exposed burlap, wire or rope not removed'
       when STPDV.BEDPREPARATIONDIAMETER = 1 then 'Deficient diameter of bed preparation area'
       when STPDV.BEDPREPARATIONSOD = 1 then 'Sod remains on site/within bed preparation area'
       when STPDV.BEDPREPARATIONCULTIVATION = 1 then 'Deficient soil cultivation'
       when STPDV.BEDPREPARATIONCULTIVATIONDEPTH = 1 then 'Deficient soil cultivation depth'
       when STPDV.MULCHDEPTH = 1 then 'Deficient depth of mulch'
       when STPDV.MULCHDIAMETER = 1 then 'Deficient mulch diameter'
       when STPDV.MULCHRING = 1 then 'Deficient mulch retention ring'
       when STPDV.MULCHSTEM = 1 then 'Mulch too close to the stem'
       when STPDV.STEMCROWNROPE = 1 then 'Stem/crown rope and/or ties present'
       when STPDV.TREEGATORBAG = 1 then 'Missing gator bag'
       when STPDV.TREEGUARD = 1 then 'Missing tree guard'
       when STPDV.PRUNING = 1 then 'Crown requires pruning'
       when STPDV.STAKING = 1 then 'Staking required'
       when STPDV.EXTRATREE = 1 then 'Extra tree not required'
       when STPDV.INCORRECTLOCATION = 1 then 'Transplant Tree to Correct Location'
       when STPDV.UNAPPROVEDSPECIES = 1 then 'Unapproved Species Substitution'
       when STPDV.INCORRECTSIZE = 1 then 'Incorrect Tree Size'
       end as "DEF",
    
       case
       when STPDV.CROWNDIEBACK = 1 or
       STPDV.CROWNINSECTDISEASE = 1 or
       STPDV.EPICORMICBRANCHING = 1 or
       STPDV.BRANCHINGSTRUCTURE = 1 or
       STPDV.ROOTBALLSIZE = 1  or
       STPDV.ROOTBALLLOOSE = 1 or
       STPDV.GIRDLINGROOTS = 1 or
       STPDV.STEMINSECTDISEASE = 1 or
       STPDV.STEMTISSUENECROSIS = 1 or
       STPDV.STEMSCARS = 1 or
       STPDV.GIRDLEDSTEM = 1 then 'Replace Tree'
       -- all above need tree replacement
       when STPDV.PLANTINGHOLESIZE = 1 then 'Increase diameter of planting hole'
       when STPDV.BACKFILL = 1 then 'Tamp backfill to eliminate air pockets'
       when STPDV.PLANTINGLOW = 1 then 'Raise tree so root collar 5 - 10 cm above grade'
       when STPDV.PLANTINGHIGH = 1 then 'Lower tree so root collar 5 - 10 cm above grade'
       when STPDV.SOILRETENTIONRING = 1 then 'Add/correct soil water retention ring'
       when STPDV.BURLAPWIREROPE = 1 then 'Remove burlap, wire and/or rope'
       when STPDV.BEDPREPARATIONDIAMETER = 1 then 'Increase diameter of bed preparation area'
       when STPDV.BEDPREPARATIONSOD = 1 then 'Remove sod from bed preparation area'
       when STPDV.BEDPREPARATIONCULTIVATION = 1 then 'Cultivate bed preparation area'
       when STPDV.BEDPREPARATIONCULTIVATIONDEPTH = 1 then 'Increase depth of cultivation'
       when STPDV.MULCHDEPTH = 1 then 'Increase depth of mulch'
       when STPDV.MULCHDIAMETER = 1 then 'Increase diameter of mulch'
       when STPDV.MULCHRING = 1 then 'Add/correct mulch water retention ring'
       when STPDV.MULCHSTEM = 1 then 'Move mulch a minimum of 5 cm away from stem'
       when STPDV.STEMCROWNROPE = 1 then 'Remove rope and/or ties from tree crown'
       when STPDV.TREEGATORBAG = 1 then 'Install TreeGator bag'
       when STPDV.TREEGUARD = 1 then 'Install tree guard'
       when STPDV.PRUNING = 1 then 'Prune crown to remove dead, diseased or broken branches'
       when STPDV.STAKING = 1 then 'Stake leaning or loose tree, correct inproper staking'
       when STPDV.EXTRATREE = 1 then 'Remove Extra Tree and Restore Site'
       when STPDV.INCORRECTLOCATION = 1 then 'Transplant Tree to Correct Location'
       when STPDV.UNAPPROVEDSPECIES = 1 then 'Replace Tree'
       when STPDV.INCORRECTSIZE = 1 then 'Replace Tree'
       end as "REP"
       from STP_DEFICIENCY_V STPDV 
       where STPDV.CONTRACTYEAR = :P0_YEAR
),

uniqueTree as(
  select distinct STPDV.TREEID as "TREEID",
       d.DEF,
       d.REP,
       l.SPECIES as "SPEC"
       from STP_DEFICIENCY_V STPDV 
       join STP_TREE_LOCATION_V l on STPDV.TREEID = l.TREEID
       join STP_WARRANTY_PRINT_V w on STPDV.TREEID = w.TREEID
       join def d on d.TREEID = STPDV.TREEID
       where STPDV.CONTRACTYEAR = :P0_YEAR 
       and STPDV.OBJECTID in(select max(OBJECTID) from STP_DEFICIENCY_V where TREEID = STPDV.TREEID)
       and STPDV.CONTRACTOPERATION = decode(:P117_WTYPE, 1,3,
                                                         2,3,
                                                         3,4)
       and STPDV.STUMPING_ID not in (2,3)
       and w.STATUS = 'Active'
       and d.def is not null
       order by STPDV.TREEID asc
)

select null as "filename",
cursor(
  select 
  SYSDATE as "DAT",
  :P0_YEAR as "YR",
  :P0_CONTRACTNUMBER as "CONNUM",
    cursor(
    select loc.MUNICIPALITY as "MUN",
           :P0_YEAR ||' - '|| to_char(loc.CONTRACTITEM, '000') as "CON",
           loc.ROADSIDE as "RD",
           cursor(
               select distinct ut.TREEID as "TID",
                      s.TAG_COLOR as "COL",
                      s.TAGNUMBER as "TNO",
                      ut.def as "DEF",
                      ut.rep as "REP",
                      l.CURRENTHEALTH as "HEL",
                      :P0_YEAR ||' - '|| s.CONTRACTITEM as "Contract Item",
                      l.MUNICIPALITY as "Municipality",
                      l.ROADSIDE as "Road Side",
                      case when s.PLANT_TYPE is null then
                      to_char(s.STOCK_TYPE ||' - '||(select distinct PLANT_TYPE from STP_DEFICIENCY_V
                      where PLANT_TYPE is not null and TREEID = ut.TREEID) ||' - '|| ut.SPEC)
                      else to_char(s.STOCK_TYPE ||' - '|| s.PLANT_TYPE ||' - '|| ut.SPEC)
                      end as "ITEM"
              from uniqueTree ut
              left join STP_DEFICIENCY_V s on s.TREEID = ut.TREEID
              left join STP_TREE_LOCATION_V l on l.TREEID = ut.TREEID
              where convert(l.MUNICIPALITY, 'AL16UTF16', 'AL32UTF8') = loc.MUNICIPALITY
              and l.CONTRACTITEM = loc.CONTRACTITEM
              and convert(l.ROADSIDE, 'AL16UTF16', 'AL32UTF8') = loc.ROADSIDE
              order by 1
              ) "ITEMS"
              from STP_TREE_LOCATION_V loc
              where exists(
                select distinct ut.TREEID as "TID",
                      s.TAG_COLOR as "COL",
                      s.TAGNUMBER as "TNO",
                      ut.def as "DEF",
                      ut.rep as "REP",
                      l.CURRENTHEALTH as "HEL",
                      :P0_YEAR ||' - '|| s.CONTRACTITEM as "Contract Item",
                      l.MUNICIPALITY as "Municipality",
                      l.ROADSIDE as "Road Side",
                      case when s.PLANT_TYPE is null then
                      to_char(s.STOCK_TYPE ||' - '||(select distinct PLANT_TYPE from STP_DEFICIENCY_V
                      where PLANT_TYPE is not null and TREEID = ut.TREEID) ||' - '|| ut.SPEC)
                      else to_char(s.STOCK_TYPE ||' - '|| s.PLANT_TYPE ||' - '|| ut.SPEC)
                      end as "ITEM"
                from uniqueTree ut
                left join STP_DEFICIENCY_V s on s.TREEID = ut.TREEID
                left join STP_TREE_LOCATION_V l on l.TREEID = ut.TREEID
                where l.MUNID = loc.MUNID
                and l.CONTRACTITEM = loc.CONTRACTITEM
                and l.ROADID = loc.ROADID
              )
              group by loc.MUNICIPALITY, loc.CONTRACTITEM, loc.ROADSIDE
              order by 1,2,3
        ) "OUTER"
        from dual
        group by :P0_YEAR
    ) "data"
from dual
    ]';
    
    return l_return;
   end;
   
   function AOP_dlist_summary_report return varchar2
   as
    l_return clob;
   begin
    l_return := q'[
      with def as (
    select 
       STPDV.TREEID as "TREEID",
       case
       when STPDV.CROWNDIEBACK = 1 then 'Crown dieback (<75% crown density)'
       when STPDV.CROWNINSECTDISEASE = 1 then 'Crown disease/insect'
       when STPDV.EPICORMICBRANCHING = 1 then 'Epicormic branching'
       when STPDV.BRANCHINGSTRUCTURE = 1 then 'Poor branching structure'
       when STPDV.ROOTBALLSIZE = 1 then 'Root ball size too small'
       when STPDV.ROOTBALLLOOSE = 1 then 'Stem loose in root ball'
       when STPDV.GIRDLINGROOTS = 1 then 'Root ball and/or roots damage'
       when STPDV.STEMINSECTDISEASE = 1 then 'Stem insect/disease'
       when STPDV.STEMTISSUENECROSIS = 1 then 'Stem tissue necrosis'
       when STPDV.STEMSCARS = 1 then 'Stem scars'
       when STPDV.GIRDLEDSTEM = 1 then 'Girdled stem'
       -- all above need tree replacement
       when STPDV.PLANTINGHOLESIZE = 1 then 'Planting hole incorrect size'
       when STPDV.BACKFILL = 1 then 'Insufficient soil tamping / air pockets present'
       when STPDV.PLANTINGLOW = 1 then 'Root ball planted too deep'
       when STPDV.PLANTINGHIGH = 1 then 'Root ball planted too high'
       when STPDV.SOILRETENTIONRING = 1 then 'Deficient soil water retention ring'
       when STPDV.BURLAPWIREROPE = 1 then 'Exposed burlap, wire or rope not removed'
       when STPDV.BEDPREPARATIONDIAMETER = 1 then 'Deficient diameter of bed preparation area'
       when STPDV.BEDPREPARATIONSOD = 1 then 'Sod remains on site/within bed preparation area'
       when STPDV.BEDPREPARATIONCULTIVATION = 1 then 'Deficient soil cultivation'
       when STPDV.BEDPREPARATIONCULTIVATIONDEPTH = 1 then 'Deficient soil cultivation depth'
       when STPDV.MULCHDEPTH = 1 then 'Deficient depth of mulch'
       when STPDV.MULCHDIAMETER = 1 then 'Deficient mulch diameter'
       when STPDV.MULCHRING = 1 then 'Deficient mulch retention ring'
       when STPDV.MULCHSTEM = 1 then 'Mulch too close to the stem'
       when STPDV.STEMCROWNROPE = 1 then 'Stem/crown rope and/or ties present'
       when STPDV.TREEGATORBAG = 1 then 'Missing gator bag'
       when STPDV.TREEGUARD = 1 then 'Missing tree guard'
       when STPDV.PRUNING = 1 then 'Crown requires pruning'
       when STPDV.STAKING = 1 then 'Staking required'
       when STPDV.EXTRATREE = 1 then 'Extra tree not required'
       when STPDV.INCORRECTLOCATION = 1 then 'Transplant Tree to Correct Location'
       when STPDV.UNAPPROVEDSPECIES = 1 then 'Unapproved Species Substitution'
       when STPDV.INCORRECTSIZE = 1 then 'Incorrect Tree Size'
       end as "DEF",
    
       case
       when STPDV.CROWNDIEBACK = 1 or
       STPDV.CROWNINSECTDISEASE = 1 or
       STPDV.EPICORMICBRANCHING = 1 or
       STPDV.BRANCHINGSTRUCTURE = 1 or
       STPDV.ROOTBALLSIZE = 1  or
       STPDV.ROOTBALLLOOSE = 1 or
       STPDV.GIRDLINGROOTS = 1 or
       STPDV.STEMINSECTDISEASE = 1 or
       STPDV.STEMTISSUENECROSIS = 1 or
       STPDV.STEMSCARS = 1 or
       STPDV.GIRDLEDSTEM = 1 then 'Replace Tree'
       -- all above need tree replacement
       when STPDV.PLANTINGHOLESIZE = 1 then 'Increase diameter of planting hole'
       when STPDV.BACKFILL = 1 then 'Tamp backfill to eliminate air pockets'
       when STPDV.PLANTINGLOW = 1 then 'Raise tree so root collar 5 - 10 cm above grade'
       when STPDV.PLANTINGHIGH = 1 then 'Lower tree so root collar 5 - 10 cm above grade'
       when STPDV.SOILRETENTIONRING = 1 then 'Add/correct soil water retention ring'
       when STPDV.BURLAPWIREROPE = 1 then 'Remove burlap, wire and/or rope'
       when STPDV.BEDPREPARATIONDIAMETER = 1 then 'Increase diameter of bed preparation area'
       when STPDV.BEDPREPARATIONSOD = 1 then 'Remove sod from bed preparation area'
       when STPDV.BEDPREPARATIONCULTIVATION = 1 then 'Cultivate bed preparation area'
       when STPDV.BEDPREPARATIONCULTIVATIONDEPTH = 1 then 'Increase depth of cultivation'
       when STPDV.MULCHDEPTH = 1 then 'Increase depth of mulch'
       when STPDV.MULCHDIAMETER = 1 then 'Increase diameter of mulch'
       when STPDV.MULCHRING = 1 then 'Add/correct mulch water retention ring'
       when STPDV.MULCHSTEM = 1 then 'Move mulch a minimum of 5 cm away from stem'
       when STPDV.STEMCROWNROPE = 1 then 'Remove rope and/or ties from tree crown'
       when STPDV.TREEGATORBAG = 1 then 'Install TreeGator bag'
       when STPDV.TREEGUARD = 1 then 'Install tree guard'
       when STPDV.PRUNING = 1 then 'Prune crown to remove dead, diseased or broken branches'
       when STPDV.STAKING = 1 then 'Stake leaning or loose tree, correct inproper staking'
       when STPDV.EXTRATREE = 1 then 'Remove Extra Tree and Restore Site'
       when STPDV.INCORRECTLOCATION = 1 then 'Transplant Tree to Correct Location'
       when STPDV.UNAPPROVEDSPECIES = 1 then 'Replace Tree'
       when STPDV.INCORRECTSIZE = 1 then 'Replace Tree'
       end as "REP",
       
       case
       when STPDV.CROWNDIEBACK = 1 or
       STPDV.CROWNINSECTDISEASE = 1 or
       STPDV.EPICORMICBRANCHING = 1 or
       STPDV.BRANCHINGSTRUCTURE = 1 or
       STPDV.ROOTBALLSIZE = 1  or
       STPDV.ROOTBALLLOOSE = 1 or
       STPDV.GIRDLINGROOTS = 1 or
       STPDV.STEMINSECTDISEASE = 1 or
       STPDV.STEMTISSUENECROSIS = 1 or
       STPDV.STEMSCARS = 1 or
       STPDV.GIRDLEDSTEM = 1 then 'Stock Quality'
       -- all above need tree replacement
       when
       STPDV.PLANTINGHOLESIZE = 1 OR
       STPDV.BACKFILL = 1 OR
       STPDV.PLANTINGLOW = 1 OR
       STPDV.PLANTINGHIGH = 1 OR
       STPDV.SOILRETENTIONRING = 1 OR
       STPDV.BURLAPWIREROPE = 1 OR
       STPDV.BEDPREPARATIONDIAMETER = 1 OR
       STPDV.BEDPREPARATIONSOD = 1 OR
       STPDV.BEDPREPARATIONCULTIVATION = 1 OR
       STPDV.BEDPREPARATIONCULTIVATIONDEPTH = 1 OR
       STPDV.MULCHDEPTH = 1 OR
       STPDV.MULCHDIAMETER = 1 OR
       STPDV.MULCHRING = 1 OR
       STPDV.MULCHSTEM = 1 OR
       STPDV.STEMCROWNROPE = 1 OR
       STPDV.TREEGATORBAG = 1 OR
       STPDV.TREEGUARD = 1 OR
       STPDV.PRUNING = 1 OR
       STPDV.STAKING = 1 OR
       STPDV.EXTRATREE = 1 OR
       STPDV.INCORRECTLOCATION = 1 OR
       STPDV.UNAPPROVEDSPECIES = 1 OR
       STPDV.INCORRECTSIZE = 1 then 'Planting Quality'
       else 'Location/Species'
       end as "TYPE"
       from STP_DEFICIENCY_V STPDV 
       where STPDV.CONTRACTYEAR = :P0_YEAR
),

uniqueTree as(
  select distinct STPDV.TREEID as "TREEID",
       d.DEF,
       d.REP,
       d.TYPE,
       l.SPECIES as "SPEC"
       from STP_DEFICIENCY_V STPDV 
       join STP_TREE_LOCATION_V l on STPDV.TREEID = l.TREEID
       join STP_WARRANTY_PRINT_V w on STPDV.TREEID = w.TREEID
       join def d on d.TREEID = STPDV.TREEID
       where STPDV.CONTRACTYEAR = :P0_YEAR 
       and STPDV.OBJECTID in(select max(OBJECTID) from STP_DEFICIENCY_V where TREEID = STPDV.TREEID)
       and STPDV.CONTRACTOPERATION = decode(:P117_WTYPE, 1,3,
                                                         2,3,
                                                         3,4)
       and STPDV.STUMPING_ID not in (2,3)
       and w.STATUS = 'Active'
       and d.def is not null
       order by STPDV.TREEID asc
),

defGroup as(
select distinct ut.TREEID, 
                l.MUNICIPALITY,
                l.CONTRACTITEM,
                l.ROADSIDE,
                ut.def,
                ut.type
from uniqueTree ut
left join STP_TREE_LOCATION_V l on l.TREEID = ut.TREEID
)

select null as "filename",
cursor(
  select 
  SYSDATE as "DAT",
  :P0_YEAR as "YR",
  :P0_CONTRACTNUMBER as "CONNUM",
    cursor(
    select loc.MUNICIPALITY as "MUN",
           :P0_YEAR ||' - '|| to_char(loc.CONTRACTITEM, '000') as "CON",
           loc.ROADSIDE as "RD",
           cursor(
               select distinct
                      dg.type as "TYPE",
                      dg.def as "DEF",
                      count(dg.def) as "COUNT"
               from defGroup dg
               where convert(dg.MUNICIPALITY, 'AL16UTF16', 'AL32UTF8') = loc.MUNICIPALITY
               and dg.CONTRACTITEM = loc.CONTRACTITEM
               and convert(dg.ROADSIDE, 'AL16UTF16', 'AL32UTF8') = loc.ROADSIDE
               group by dg.def, dg.type
              ) "ITEMS",
              cursor(
                select distinct
                      dg.type as "TTYPE",
                      count(dg.type) as "TCOUNT"
               from defGroup dg
               where convert(dg.MUNICIPALITY, 'AL16UTF16', 'AL32UTF8') = loc.MUNICIPALITY
               and dg.CONTRACTITEM = loc.CONTRACTITEM
               and convert(dg.ROADSIDE, 'AL16UTF16', 'AL32UTF8') = loc.ROADSIDE
               group by dg.type
              ) "TYPES"
              from STP_TREE_LOCATION_V loc
              where exists(
               select distinct dg.def as "DEF",
               dg.type
               from defGroup dg
               where dg.MUNICIPALITY = loc.MUNICIPALITY
               and dg.CONTRACTITEM = loc.CONTRACTITEM
               and dg.ROADSIDE = loc.ROADSIDE
              )
              group by loc.MUNICIPALITY, loc.CONTRACTITEM, loc.ROADSIDE
              order by 1,2,3
        ) "OUTER"
        from dual
        group by :P0_YEAR
    ) "data"
from dual
    ]';
    
    return l_return;
   end;
  
end STP_WARRANTY_PKG;