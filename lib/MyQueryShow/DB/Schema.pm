# THIS FILE IS AUTOGENERATED BY DBIx::Skinny::Schema::Loader 0.17, DO NOT EDIT DIRECTLY.

package MyQueryShow::DB::Schema;
use DBIx::Skinny::Schema;

install_table query_review => schema {
    pk qw/checksum/;
    columns qw/checksum fingerprint sample first_seen last_seen reviewed_by reviewed_on comments/;
};

install_table query_review_history => schema {
    pk qw/checksum ts_min ts_max/;
    columns qw/checksum sample ts_min ts_max ts_cnt query_time_sum query_time_min query_time_max query_time_pct_95 query_time_stddev query_time_median lock_time_sum lock_time_min lock_time_max lock_time_pct_95 lock_time_stddev lock_time_median rows_sent_sum rows_sent_min rows_sent_max rows_sent_pct_95 rows_sent_stddev rows_sent_median rows_examined_sum rows_examined_min rows_examined_max rows_examined_pct_95 rows_examined_stddev rows_examined_median/;
};

1;
