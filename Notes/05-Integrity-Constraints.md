# **Integrity Constraints**

## 1. Introduction to Integrity Constraints

Integrity constraints are invariant conditions that all instances of a relational database must satisfy at any given time. They are derived from the rules and conditions present in the "mini-world" that the database represents, as well as the underlying data model.

**Purpose of Integrity Constraints:**

* They guarantee the coherence of the various components that make up the database.
* They ensure data consistency, preventing arbitrary modifications that could lead the database into a "bad" state.
* They ensure the database always precisely represents the real-world context.

**Constraint Examples:**

* An employee's salary cannot be larger than their manager's salary.
* The supervisor of an employee must also be an employee within the company.

## 2. Characteristics and Representation

To effectively model an integrity constraint, designers must define its context, content, and influence.

### 2.1 Context

The context of an integrity constraint refers to the specific relations (tables) that could potentially violate the constraint when data modifications occur.

**Example:** For the salary constraint (manager vs. employee), the context involves both the `EMPLOYEE` and `DEPARTMENT` relations. Modifying a salary, adding an employee, or appointing a new manager could trigger a violation.

### 2.2 Content

The content is the actual rule, which can be stated in multiple ways:

* **Natural Language:** Easy to understand but lacks strict coherence.
* **Formal Language:** Uses relational algebra or relational calculus to provide a condensed, mathematically coherent definition.
* **Pseudo-code:** Outlines the logical steps to validate the rule.

**Example:**

* The salary of an employee cannot be larger than the salary of the manager:
* The supervisor of an employee must be an employee in the company:

### 2.3 Table of Influence

A Table of Influence is used to determine exactly which data modification operations (`INSERT`, `DELETE`, `UPDATE`) require the database to check the constraint.

* A `(+)` symbol indicates that the operation could violate the constraint and must be checked.
* A `(-)` symbol indicates that the operation will not violate the constraint.
* Designers can create a Synthesis Table to map multiple relations against multiple constraints simultaneously.

<table>
  <thead>
    <tr>
      <th rowspan="2"></th>
      <th colspan="3">Constraint 1</th>
      <th colspan="3">Constraint 2</th>
      <th colspan="3">...</th>
      <th colspan="3">Constraint m</th>
    </tr>
    <tr>
      <th>I</th><th>D</th><th>U</th>
      <th>I</th><th>D</th><th>U</th>
      <th>...</th><th>...</th><th>...</th>
      <th>I</th><th>D</th><th>U</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><strong>Relation 1</strong></td>
      <td>+</td><td>-</td><td>+</td>
      <td>+</td><td>-</td><td>+</td>
      <td></td><td></td><td></td>
      <td>+</td><td>-</td><td>+</td>
    </tr>
    <tr>
      <td><strong>Relation 2</strong></td>
      <td>-</td><td>+</td><td>-</td>
      <td></td><td></td><td></td>
      <td></td><td></td><td></td>
      <td></td><td></td><td></td>
    </tr>
    <tr>
      <td><strong>Relation 3</strong></td>
      <td>-</td><td>-</td><td>+</td>
      <td></td><td></td><td></td>
      <td></td><td></td><td></td>
      <td>-</td><td>+</td><td>-</td>
    </tr>
    <tr>
      <td><strong>...</strong></td>
      <td></td><td></td><td></td>
      <td></td><td></td><td></td>
      <td></td><td></td><td></td>
      <td></td><td></td><td></td>
    </tr>
    <tr>
      <td><strong>Relation n</strong></td>
      <td></td><td></td><td></td>
      <td>-</td><td>+</td><td>-</td>
      <td></td><td></td><td></td>
      <td>-</td><td>-</td><td>+</td>
    </tr>
  </tbody>
</table>

## 3. Categories of Constraints

Constraints are categorized based on whether they apply to a single relation or span across multiple relations.

### Constraints on One Relation

* **Domain Constraints:** Ensure that the value of an attribute is an atomic value belonging to its defined domain (e.g., `Sex` must be 'Male' or 'Female', or `Hours` must be $\le 60$).
* **Correlated Tuples:** The existence of a tuple depends on other tuples in the same relation. This includes Primary Key and Unique constraints.
* **Correlated Attributes:** Constraints among attributes within the same relation (e.g., an employee's `SuperSSN` cannot be equal to their own `SSN`).

### Constraints on Many Relations

* **Referential Constraints (Foreign Keys):** An attribute's value must refer to an existing primary key value in another relation (e.g., a dependent must be linked to a valid employee).
* **Correlated Tuples/Attributes:** Rules spanning multiple tables (e.g., a manager's birth date must be earlier than their start date as a manager).
* **Aggregate Attributes:** Attributes whose values are calculated from other tables (e.g., `No_Emp` in the `DEPARTMENT` table must match the actual count of employees in that department).
* **Cycles:** Complex constraints arising when a database schema graph contains a closed loop of relationships.

## 4. Implementation Mechanisms

Databases utilize several mechanisms to enforce these constraints during operations.

### Standard SQL Constraints

* **Primary Key, Foreign Key, and CHECK constraints** handle the majority of basic validation directly within the table definitions.
* If the table has composite primary or foreign key or `CHECK` involves more than 1 column, we need to create table-level constraint:
    ```sql
    [CONSTRAINT <PK_TableName>] PRIMARY KEY(col1, col2,...)
    [CONSTRAINT <FK_ChildName_ParentName>] FOREIGN KEY(col1, col2,...) REFERENCES Parent(col1, col2,...)
    [CONSTRAINT <CK_Campaigns_dates>] CHECK (start_date < end_date)
    ```
* If the foreign key is not composite, we can just add `REFERENCES Parent(col)` inline.
* Common naming conventions:
    * Primary Key: `PK_<TableName>` 
    * Foreign Key: `FK_<ChildName_ParentName>`
    * Unique: `UQ_<TableName>_<ColName>`
    * Check: `CK_<TableName>_<ColName>`
    * Default: `DF_<TableName>_<ColName>`
* For more complex conditions involving data from another table via foreign key, we need to use `TRIGGER` instead of `CHECK`.

### Assertions

* An assertion is a standalone, boolean-valued SQL expression that the database guarantees must evaluate to `TRUE` at all times.
* It is created using `CREATE ASSERTION <Name> CHECK (<Condition>)`.

### Triggers

* A trigger is a series of actions automatically performed whenever a specific event (`INSERT`, `UPDATE`, `DELETE`) occurs.
* They can be configured to fire `BEFORE` or `AFTER` the event, and can execute per row (`FOR EACH ROW`) or per statement (`FOR EACH STATEMENT`).
* Triggers have access to the `NEW ROW` and `OLD ROW` states to evaluate conditions.
* **Implementation process:** Write the business rule in a precise and testable form. 
  1. Identify the complete scope and risk table. 
  2. Choose the table and events for each required trigger. 
  3. Write the violation query first as a normal SELECT statement. 
  4. Place the violation query inside IF EXISTS. 
  5. Test one valid row, one invalid row, and a multi-row statement.
* **Syntax:**
    ```sql
    CREATE TRIGGER trigger_name
    ON table_name
    FOR INSERT|DELETE|UPDATE
    AS
    BEGIN
        BEGIN 
        -- Trigger logic here 
        -- Whenever a trigger belonging to table A is invoked, two temporary (virtual) tables with the same structure as A are available: 
        -- INSERTED: contains the new rows being inserted or updated
        -- DELETED: contains the old rows being deleted or update

        -- Error message
        -- RAISERROR (msg, severity, state)
        -- msg: A custom error message (string) or a message ID from sys.messages 
        -- severity: Indicates the seriousness of the error (range: 0–25)
        -- state: A user-defined code (0-255) to indicate where the error occurred
    END;
    ```

### Transactions

* A transaction groups multiple statements into a single logical process that guarantees **Atomicity** (either all statements succeed, or none do) and **Consistency** (no constraints are violated before or after the transaction).
* If a statement fails, the transaction issues a `ROLLBACK`; if successful, it issues a `COMMIT`.

### Stored Procedures

* Stored procedures are functions stored directly in the database schema.
* Because relying on too many triggers can significantly slow down a system, stored procedures offer a more efficient way to encapsulate complex constraint logic and transaction management.
* **Syntax:**
    ```sql
    CREATE PROCEDURE <procedure_name>
    <list_of_parameters_with_types>
    AS
        local variable declaration
        body of the procedure
    GO;
    EXEC <procedure_name> <list_of_parameters>
    ```



## 5. Advanced Extension: Modern Constraint Management

While the lecture slides cover the foundational logic of constraints, modern enterprise Database Management Systems (DBMS) extend these concepts in several practical ways:

### Deferrable Constraints

By default, constraints are checked immediately after a statement executes. However, complex transactions (like cyclic foreign keys) require constraints to be temporarily suspended. Modern SQL supports **Deferrable Constraints** (`DEFERRABLE INITIALLY DEFERRED`), which instructs the database to wait until the `COMMIT` statement is issued before validating the constraint.

### INSTEAD OF Triggers

While the slides mention `BEFORE` and `AFTER` triggers, many systems (like SQL Server and PostgreSQL) utilize `INSTEAD OF` triggers. These are specifically used on Views. Because views joining multiple tables cannot inherently accept `UPDATE` or `INSERT` commands, an `INSTEAD OF` trigger intercepts the command and allows the developer to write custom logic to manually update the underlying base tables.

### Semantic Integrity vs. State Integrity

* **State/Static Constraints:** (Covered in the slides). Evaluate the database at a specific moment (e.g., Salary > 0).
* **Transition/Dynamic Constraints:** Evaluate the *change* in state rather than just the final state. For example, a constraint dictating that "an employee's salary can only increase, never decrease." This requires comparing the `OLD` and `NEW` tuple values dynamically via triggers, as standard `CHECK` constraints cannot reference historical data.

### ACID Properties Context

The transactions mentioned in the slides rely on the ACID model to maintain integrity:

* **Atomicity:** Handled by Rollback/Commit logs.
* **Consistency:** The actual enforcement of the Integrity Constraints discussed.
* **Isolation:** Ensuring concurrent transactions do not interfere with each other (preventing dirty reads that could momentarily violate constraints).
* **Durability:** Ensuring that once a transaction satisfying all constraints is committed, it survives system crashes.