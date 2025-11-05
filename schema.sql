--#DDL queries
  create table Policyholder (
    policyholder_id int primary key AUTO_INCREMENT,
    name varchar(100) not null,
    contact_number varchar(20),
    email varchar(100)
);

create table Policies (
    policy_id varchar(20) primary key,
    policyholder_id int,
    policy_type varchar(50),
    policy_status ENUM('ACTIVE', 'INACTIVE', 'LAPSED', 'CANCELLED'),
    start_date DATE,
    end_date DATE,
    foreign key (policyholder_id) references Policyholder(policyholder_id)
);

create table Claims (
 claim_id int primary key AUTO_INCREMENT,
 policy_id varchar(20),
 claim_status ENUM('REGISTERED','VERIFIED','APPROVED','REJECTED','FAILED') default 'REGISTERED',
 claim_amount DECIMAL(10,2) check (claim_amount > 0),
 claim_date DATE default (CURRENT_DATE),
 foreign key (policy_id) references Policies(policy_id)
);

create table Payment (
 payment_id int primary key AUTO_INCREMENT,
 claim_id int,
 payment_amount DECIMAL(10,2),
 payment_date DATE default (CURRENT_DATE),
 foreign key (claim_id) references Claims(claim_id)
);

create table Log (
 log_id int primary key AUTO_INCREMENT,
 transaction_id varchar(50),
 operation_type varchar(20),
 table_name varchar(50),
 data_item varchar(50),
 old_value varchar(50),
 new_value varchar(50),
 log_time TIMESTAMP default CURRENT_TIMESTAMP
);

create table Claim_Audit_Log (
 audit_id int primary key AUTO_INCREMENT,
 claim_id int,
 operation varchar(50),
 description text,
 audit_time TIMESTAMP default CURRENT_TIMESTAMP
);


--#DML queries
insert into Policyholder (name, contact_number, email) values ('Alice Smith', '9991112222', 'alice@example.com'),
('Bob Jones', '8883334444', 'bob@example.com'),('Carol White', '7775556666', 'carol@example.com');

insert into Policies (policy_id, policyholder_id, policy_type, policy_status, start_date, end_date)
values('P1001', 1, 'Health', 'ACTIVE', '2024-01-01', '2026-01-01'),
('P1002', 2, 'Vehicle', 'INACTIVE', '2023-01-01', '2024-01-01'),('P1003', 3, 'Travel', 'ACTIVE', '2024-06-01', '2025-06-01');

Selection and Projection Operation
 (use of select query):

 --To show all active policies
select policy_id, policy_type, start_date, end_date
from Policies
where policy_status = 'ACTIVE';

-- To show only specific attributes (projection)
select name, contact_number from Policyholder;

-- To show all claims for a specific policyholder (selection + join)
select ph.name, p.policy_type, c.claim_id, c.claim_amount, c.claim_status
from Policyholder ph
join Policies p on ph.policyholder_id = p.policyholder_id
join Claims c on p.policy_id = c.policy_id
where ph.name = 'Alice Smith';


--#Joins
-- To show claim details with policyholder and payment info
select 
    ph.name as policyholder_name,
    p.policy_id,
    p.policy_type,
    c.claim_id,
    c.claim_amount,
    c.claim_status,
    pay.payment_amount,
    pay.payment_date
from Policyholder ph
join Policies p on ph.policyholder_id = p.policyholder_id
join Claims c on p.policy_id = c.policy_id
left join Payment pay on c.claim_id = pay.claim_id;
