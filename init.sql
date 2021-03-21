CREATE TABLE IF NOT EXISTS regions
(
    region_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    region_name VARCHAR(25) NOT NULL
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4;


CREATE TABLE IF NOT EXISTS countries
(
    country_id VARCHAR(2) PRIMARY KEY NOT NULL,
    country_name VARCHAR(40),
    region_id INT UNSIGNED,

    CONSTRAINT countr_reg_fk FOREIGN KEY (region_id) REFERENCES regions (region_id)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4;


CREATE TABLE IF NOT EXISTS locations
(
    location_id    INT(4) UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    street_address VARCHAR(40),
    postal_code    VARCHAR(12),
    city           VARCHAR(30) NOT NULL,
    state_province VARCHAR(25),
    country_id     VARCHAR(2),

    CONSTRAINT loc_c_id_fk FOREIGN KEY (country_id) REFERENCES countries (country_id)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  AUTO_INCREMENT = 3300;

-- INSERTS TO THE locations table
START TRANSACTION;
SET @@auto_increment_increment = 100;

SET @@auto_increment_increment = 1;
COMMIT;

CREATE TABLE IF NOT EXISTS departments
(
    department_id   INT(4) UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    department_name VARCHAR(30) NOT NULL,
    manager_id      INT(6),
    location_id     INT(4) UNSIGNED,

    CONSTRAINT dept_loc_fk FOREIGN KEY (location_id) REFERENCES locations (location_id)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  AUTO_INCREMENT = 280;

-- INSERTS TO THE departments table
START TRANSACTION;
SET @@auto_increment_increment = 10;

SET @@auto_increment_increment = 1;
COMMIT;

CREATE TABLE IF NOT EXISTS jobs
(
    job_id     VARCHAR(10) PRIMARY KEY,
    job_title  VARCHAR(35) NOT NULL,
    min_salary INT(6),
    max_salary INT(6)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4;


CREATE TABLE IF NOT EXISTS employees
(
    employee_id    INT(6) PRIMARY KEY AUTO_INCREMENT NOT NULL,
    first_name     VARCHAR(20),
    last_name      VARCHAR(25)                       NOT NULL,
    email          VARCHAR(25)                       NOT NULL UNIQUE,
    phone_number   VARCHAR(20),
    hire_date      DATE                              NOT NULL,
    job_id         VARCHAR(10)                       NOT NULL,
    salary         INT(8) CHECK (salary > 0),
    commission_pct INT(2),
    manager_id     INT(6),
    department_id  INT(4) UNSIGNED,

    FOREIGN KEY emp_manager_fk (manager_id) REFERENCES employees (employee_id),
    FOREIGN KEY emp_dept_fk (department_id) REFERENCES departments (department_id)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  AUTO_INCREMENT = 207;

ALTER TABLE departments
    ADD CONSTRAINT dept_mgr_fk FOREIGN KEY (manager_id) REFERENCES employees (employee_id);

CREATE TABLE IF NOT EXISTS job_history
(
    employee_id   INT(6) NOT NULL,
    start_date    DATE   NOT NULL,
    end_date      DATE   NOT NULL,
    job_id        VARCHAR(10),
    department_id INT(4) UNSIGNED,

    CONSTRAINT jhist_emp_fk FOREIGN KEY (employee_id) REFERENCES employees (employee_id),
    CONSTRAINT jhist_dept_fk FOREIGN KEY (department_id) REFERENCES departments (department_id),
    CONSTRAINT jhist_date_interval CHECK ( end_date > start_date), -- Check constrains don't really work on MYSQL 5.7, but well
    CONSTRAINT jhist_emp_id_st_date_pk PRIMARY KEY (employee_id, start_date)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4;


CREATE OR REPLACE VIEW emp_details_view
(
    employee_id,
    job_id,
    manager_id,
    department_id,
    location_id,
    country_id,
    first_name,
    last_name,
    salary,
    commission_pct,
    department_name,
    job_title,
    city,
    state_province,
    country_name,
    region_name
)
AS
SELECT
    e.employee_id,
    e.job_id,
    e.manager_id,
    e.department_id,
    d.location_id,
    l.country_id,
    e.first_name,
    e.last_name,
    e.salary,
    e.commission_pct,
    d.department_name,
    j.job_title,
    l.city,
    l.state_province,
    c.country_name,
    r.region_name
FROM
    employees e,
    departments d,
    jobs j,
    locations l,
    countries c,
    regions r
WHERE e.department_id = d.department_id
    AND d.location_id = l.location_id
    AND l.country_id = c.country_id
    AND c.region_id = r.region_id
    AND j.job_id = e.job_id;
