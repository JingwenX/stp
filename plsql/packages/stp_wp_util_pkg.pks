create or replace package                                                             STP_WP_UTIL_PKG as



procedure create_new_payment_col( p_year in number, p_wa_num in number);


procedure create_col_from_payment_temp( p_year in number, p_wa_num in number);


procedure update_wp_detail;

end;