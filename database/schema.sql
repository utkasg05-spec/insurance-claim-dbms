delimiter //

create procedure Undo_Incomplete_Transactions()
begin
    update Claims
    set claim_status = 'REGISTERED'
    where claim_status = 'APPROVED'
      and claim_id not in (select claim_id from Payment);

    insert into Log (transaction_id, operation_type, table_name, data_item, old_value, new_value)
    values ('SYS', 'UNDO', 'Claims', 'claim_status', 'APPROVED', 'REGISTERED');
end;
//

delimiter ;
create procedure Redo_Completed_Transactions()
begin
    update Claims c
    join Payment p on c.claim_id = p.claim_id
    set c.claim_status = 'APPROVED';

    insert into Log (transaction_id, operation_type, table_name, data_item, new_value)
    values ('SYS', 'REDO', 'Claims', 'claim_status', 'APPROVED');
end;
//

delimiter ;

-- ============================================
-- UNIT IV: PL/SQL OBJECTS (VIEWS & TRIGGERS)
-- ============================================

-- VIEW
create or replace view Approved_Claims as
select 
    c.claim_id,
    p.policy_id,
    ph.name as policyholder,
    c.claim_amount,
    c.claim_status,
    p.policy_type
from Claims c
join Policies p on c.policy_id = p.policy_id
join Policyholder ph on p.policyholder_id = ph.policyholder_id
where c.claim_status = 'APPROVED';

-- TRIGGER
delimiter //

create trigger trg_claim_update
after update on Claims
for each row
begin
    insert into Claim_Audit_Log (claim_id, operation, description)
    values (
        new.claim_id,
        'UPDATE',
        CONCAT('Claim status changed from ', OLD.claim_status, ' to ', NEW.claim_status)
    );

    insert into Log (transaction_id, operation_type, table_name, data_item, old_value, new_value)
    values (
        new.policy_id,
        'UPDATE',
        'Claims',
        'claim_status',
        old.claim_status,
        new.claim_status
    );
end;
//

delimiter;
