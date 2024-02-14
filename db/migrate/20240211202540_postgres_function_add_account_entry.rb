class PostgresFunctionAddAccountEntry < ActiveRecord::Migration[7.1]
  # rubocop:disable Metrics/MethodLength, Layout/LineLength
  def up
    sql = %{
      CREATE OR REPLACE FUNCTION public.add_account_entry(account_id integer, value integer, description character varying)
       RETURNS TABLE(success boolean, message character varying, current_balance integer, current_limit integer)
       LANGUAGE plpgsql
      AS $function$
        declare
          current_credit_limit integer;
          current_balance integer;
          new_balance integer;
        begin

          select credit_limit, balance
            into current_credit_limit, current_balance
            from accounts
            where id = account_id
            for update nowait;

          new_balance = current_balance + value;

          if new_balance < current_credit_limit * -1 then
            return query
              select s, em, cb, cl
                from (
                  values (false, 'credit_limit_exceeded'::VARCHAR, current_balance, current_credit_limit)
                  ) s(s, em, cb, cl);
            return;
          end if;

          update accounts
            set balance = new_balance,
                updated_at = now()
            where id = account_id;

          insert into account_entries (value, description, account_id, created_at, updated_at)
            values (value, description, account_id, now(), now());

          return query
            select s, m, nb, cl
              from (
                values (true, 'ok'::VARCHAR, new_balance, current_credit_limit)
              ) s(s, m, nb, cl);
        end;
      $function$
      ;
    }

    ActiveRecord::Base.connection.execute(sql)
  end
  # rubocop:enable Metrics/MethodLength, Layout/LineLength

  def down
    sql = 'DROP FUNCTION public.add_account_entry(int4, int4);'
    ActiveRecord::Base.connection.execute(sql)
  end
end
