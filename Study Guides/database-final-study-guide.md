# DATABASE SYSTEMS (CS486) — FINAL EXAM MASTER STUDY GUIDE

This comprehensive study guide is compiled directly from the instructor's final review voice notes, slides, and course materials. It is designed to serve as an exam-focused manual, detailing the **8 core questions** of the final exam, their underlying theory, step-by-step solution methodologies, and common traps.

---

## SECTION 1: EXAM STRUCTURE & GENERAL STRATEGY
*   **Duration:** 100 minutes.
*   **Total Points:** 10 points, distributed across approximately **20 sub-questions (each worth ~0.5 points)** [1].
*   **Structure:** 8 main questions [1].
*   **Database Schema Isolation:** **Question 1 (ERD & Mapping)** and **Question 2 (Query Languages)** use **two independent database schemas** [1]. If you make a mistake in your ER Diagram in Question 1, it will **not** cascade and ruin your queries in Question 2 [1].
*   **Time Management:** Aim to spend no more than **5 minutes per sub-question** [1]. Allocate approximately **10–12 minutes** for Question 1 (ERD) [2], and prioritize high-weight sections (Question 2, Question 4, Question 7, and Question 8) which require rigorous calculations and formulation [1].

---

## SECTION 2: MAIN QUESTIONS — THEORY & PROBLEM TYPES

### QUESTION 1: ER Diagram & Relational Mapping (approx. 1.0 Point)
This question is divided into two parts: **1A (Draw ER Diagram)** and **1B (Relational Mapping)**, each worth approximately 0.5 points [1].

#### 1A — Draw ER Diagram
*   **How to Recognize It:** You are given a natural language requirement describing a database "mini-world" (e.g., a company, university, or store) with entity sets, their attributes, and relationships [1, 3].
*   **Essential Concepts & Notation:**
    *   **Entity Set:** Rectangular node. Represents a collection of real-world objects [3].
    *   **Attribute:** Oval node connected to its entity set [3]. Attributes must be *atomic values* (strings, integers, or reals) [3].
    *   **Key Attribute (Primary Key):** Underlined attribute name inside the oval [3].
    *   **Relationship Set:** Diamond-shaped node [3].
    *   **Cardinality Ratio:** 
        *   **1:1** (one-to-one) [1].
        *   **1:N** (one-to-many) [1].
        *   **M:N** (many-to-many) [1].
    *   **Participation Constraints:**
        *   **Total Participation (Double Line):** Every entity in the entity set must participate in at least one relationship instance [3].
        *   **Partial Participation (Single Line):** Entities can exist without participating in the relationship [3].
    *   **Weak Entity Set:** Double rectangle. An entity set that does not have a primary key of its own and depends on an *identifying owner entity set* (connected via a double-diamond *identifying relationship*) [1, 3]. Its key is a *composite key* formed by the primary key of the owner and its own *partial key* (dashed underline) [2, 3].
    *   **Multivalued Attribute:** Double oval. An attribute that can have multiple values for a single entity (e.g., `Locations` of a department) [1, 3].
    *   **Composite Attribute:** An oval with sub-ovals branching out (e.g., `Name` branches into `FName`, `MInit`, `LName`) [1, 3].
    *   **Derived Attribute:** Dashed oval. An attribute whose value is computed from other attributes (e.g., `Age` derived from `BirthDate`) [1, 3].
*   **Standard Step-by-Step Methodology:**
    1.  **Identify Entities:** Highlight nouns in the description that represent main objects (e.g., `Employee`, `Department`, `Project`) [1].
    2.  **Identify Attributes & Keys:** For each entity, map its properties. Identify which attribute(s) uniquely identify the entity (underlined) [1, 3].
    3.  **Identify Relationships & Cardinalities:** Find verbs linking entities. Determine cardinalities (e.g., "An employee works for *one* department, but a department has *many* employees" $\rightarrow$ `Works_For` is $1:N$) [1].
    4.  **Identify Participation:** Look for constraints (e.g., "Every employee *must* work for a department" $\rightarrow$ double line from `Employee` to `Works_For`) [1, 3].
    5.  **Identify Advanced Constructs:** Look for weak entities, multivalued attributes, or composite attributes [1].
    6.  **Draw and Refine:** Draw the diagram neatly. Ensure simplicity and minimize redundant relationships [1].
*   **Common Mistakes & Traps:**
    *   *Missing Double Lines:* Forgetting total participation or weak entity identifying relationships [1].
    *   *Incorrect Weak Keys:* Forgetting to mark the partial key of a weak entity with a dashed underline [3].
    *   *Redundancy:* Adding relationship lines that can be transitively inferred, which complicates the schema unnecessarily [1].
    *   *Grading Rule:* Grading is strict. Points are deducted individually for missing/incorrect entities, attributes, relationships, or cardinality markings [1].

#### 1B — Convert ERD to Relational Schema
*   **How to Recognize It:** Follow-up to 1A. You must map your ER Diagram into a set of SQL-compatible relational tables [1, 2].
*   **Mapping Rules (The Instructor's Approach):**
    1.  **Strong Entity:** Becomes a relation. Primary key remains the underlined attribute [2].
    2.  **Weak Entity:** Becomes a relation. Its attributes include all its own attributes, plus the primary key of the identifying owner entity set as a **Foreign Key (FK)** [2]. Its primary key is a **composite key** composed of the owner's primary key and the weak entity's partial key [2].
    3.  **1:N Relationship:** Do **not** create a new table. Instead, take the Primary Key (PK) of the "1" side and place it as a **Foreign Key (FK)** on the "N" side [2]. If the relationship has attributes, place them on the "N" side as well.
    4.  **1:1 Relationship:** Take the PK of one side and put it as an FK on the other side.
        *   *Optimization Rule:* Place the FK on the side that has **total participation** to minimize NULL values [2]. Add a **UNIQUE** constraint to this FK to enforce the 1:1 cardinality [2].
    5.  **M:N Relationship:** **Must** create a new junction table [2]. Its attributes are the PKs of both participating entities (which act as FKs pointing back to their tables). The primary key of this junction table is the **composite key** of both FKs [2].
    6.  **Multivalued Attribute:** **Must** create a new table [2]. Its columns are the multivalued attribute itself and the PK of the parent entity (acting as an FK) [2]. The primary key of this new table is the composite of both columns [2].
    7.  **N-ary Relationship (Degree > 2):** Create a new table containing the PKs of all participating entities as FKs [2]. The primary key is the composite key of all these FKs [2].
*   **Common Mistakes & Traps:**
    *   *Junction Tables for 1:N:* Creating a separate table for a 1:N relationship. This is an incorrect design that wastes join performance [2].
    *   *Missing Composite Keys:* Forgetting that weak entity tables and M:N junction tables have composite primary keys [2].
    *   *Unique Constraints on 1:1:* Forgetting to write `UNIQUE` on the foreign key of a 1:1 relation mapping [2].

---

### QUESTION 2: Database Query Languages (approx. 2.0 Points)
This section is heavily weighted and typically consists of 4 parts (2A, 2B, 2C, 2D) worth 0.5 points each [1, 2]. You are given a new, independent database schema and must write queries in **Relational Algebra (RA)**, **Tuple Relational Calculus (TRC)**, **Domain Relational Calculus (DRC)**, and **SQL** [1, 2].

#### 2.1 — Relational Algebra (RA)
*   **Core Operators:**
    *   **Selection ($\sigma_{cond}(R)$):** Filters rows matching `cond` [2].
    *   **Projection ($\pi_{attrs}(R)$):** Keeps only specified columns [2].
    *   **Rename ($\rho_{S(B_1, ..., B_n)}(R)$):** Renames relation to $S$ and attributes to $B_i$ [2].
    *   **Cartesian Product ($R \times S$):** Pairs every row of $R$ with every row of $S$ [2].
    *   **Join ($R \bowtie_{cond} S$):** Theta join. Equi-join when operator is `=` [2].
    *   **Natural Join ($R \bowtie S$):** Joins on attributes with identical names and automatically projects out the duplicate join columns [2].
    *   **Set Operations ($R \cup S, R \cap S, R - S$):** Only valid if relations are **union-compatible** (identical attributes and matching domains) [2].
    *   **Division ($R \div S$):** Crucial for "for all", "every", or "each" queries [2].
*   **Standard Method for Division ($R(X, Y) \div S(Y)$):**
    *   Finds all values of $X$ in $R$ that are paired with **every** value of $Y$ in $S$.
    *   *Equivalence Formula without Division:* If $\div$ is banned, represent $R \div S$ as:
        $$\pi_X(R) - \pi_X((\pi_X(R) \times S) - R)$$

#### 2.2 — Tuple Relational Calculus (TRC)
*   **Notation:** $\{ t | P(t) \}$ where $t$ is a tuple variable representing a row [2].
*   **Key Symbols:** Membership ($t \in Relation$) [2], logical operators ($\land, \lor, \neg$) [2], implication ($p \rightarrow q$ equivalent to $\neg p \lor q$) [2], and quantifiers ($\exists, \forall$) [2].
*   **The "For All" Translation:** "Retrieve employees who work on all projects."
    *   *Implication Approach:* $\{ e | e \in EMPLOYEE \land \forall p (p \in PROJECT \rightarrow \exists w (w \in WORKS\_ON \land w.ESSN = e.SSN \land w.PNO = p.PNUMBER)) \}$ [2]
    *   *Double Negation (No Universal Quantifier):* $\{ e | e \in EMPLOYEE \land \neg \exists p (p \in PROJECT \land \neg \exists w (w \in WORKS\_ON \land w.ESSN = e.SSN \land w.PNO = p.PNUMBER)) \}$ [2]

#### 2.3 — Domain Relational Calculus (DRC)
*   **Notation:** $\{ \langle x_1, x_2, \dots, x_n \rangle | P(x_1, x_2, \dots, x_n) \}$ where $x_i$ represent specific attribute values (not tuples) [2].
*   **Key Distinction:** You must define variables for *every* attribute of a relation when stating membership [2].
    *   *Example:* If `PROJECT` has columns `(PName, PNumber, PLocation, DNum)` [2]:
        $$\exists x, y, z, w (\langle x, y, z, w \rangle \in PROJECT \land y = 5)$$

#### 2.4 — SQL
*   **Required Constructs:** `EXISTS`, `NOT EXISTS` [2], `IN`, `NOT IN` [2], `ANY`, `ALL` [2], Set operations (`UNION`, `INTERSECT`, `EXCEPT`) [2], `GROUP BY`, `HAVING` [2], and self-joins [2].
*   **Crucial "For All" SQL Pattern (Double NOT EXISTS):**
    "Retrieve names of students who have passed all courses of department 'IS'" [2]:
    ```sql
    SELECT s.student_name 
    FROM Student s
    WHERE NOT EXISTS (
        SELECT c.course_id 
        FROM Course c
        WHERE c.department_id = 'IS'
          AND NOT EXISTS (
              SELECT gr.section_id 
              FROM GradeReport gr
              JOIN Section sec ON gr.section_id = sec.section_id
              WHERE gr.student_id = s.student_id
                AND sec.course_id = c.course_id
                AND gr.grade_ABC <> 'F' -- Passed
          )
    );
    ```

#### Important Exam Traps (Question 2):
1.  **Read the "Not Allowed" Clause:** The instructor explicitly warns that the exam may forbid specific operators (e.g., "Do not use aggregate functions like `MAX` or `MIN`", "Do not use the division operator `\div`", or "Do not use `AVG`") [1, 2].
2.  **How to find Maximum without `MAX`:**
    *   *In Relational Algebra:* $AllSalaries = \pi_{Salary}(EMPLOYEE)$
        $$MaxSalary = AllSalaries - \pi_{R1.Salary}(\rho_{R1}(AllSalaries) \bowtie_{R1.Salary < R2.Salary} \rho_{R2}(AllSalaries))$$
    *   *In SQL:*
        ```sql
        SELECT Salary FROM Employee 
        WHERE Salary NOT IN (
            SELECT e1.Salary FROM Employee e1 
            JOIN Employee e2 ON e1.Salary < e2.Salary
        );
        ```
3.  **The "Exclusion" Flaw (The Instructor's Favorite Edge Case):**
    *   *Incorrect SQL for "Courses where instructor I002 has NOT taught":*
        ```sql
        -- BUGGY: If course has another instructor, it gets included!
        SELECT DISTINCT c.course_id FROM Course c
        JOIN Section s ON c.course_id = s.course_id
        JOIN Teaching t ON s.section_id = t.section_id
        WHERE t.instructor_id <> 'I002';
        ```
    *   *Correct SQL (Using Subquery Exclusion):*
        ```sql
        SELECT course_id FROM Course
        WHERE course_id NOT IN (
            SELECT DISTINCT s.course_id FROM Section s
            JOIN Teaching t ON s.section_id = t.section_id
            WHERE t.instructor_id = 'I002'
        );
        ```

---

### QUESTION 3: Integrity Constraints & Database Code (approx. 1.0 Point)
This question is divided into two parts: **3A (Write in Formal Language)** and **3B (Implement in Database Code)** [1, 2].

#### 3A — Natural Language to Formal Language
*   **How to Recognize It:** You are given a business rule, such as: "No two courses in the same department can have the same name." [1, 2].
*   **Standard Method:** Use Relational Algebra, TRC, or DRC to express that the violating state must be empty or invalid [1, 2].
    *   *Implication Approach (TRC):*
        $$\forall c_1, c2 \in Course ( (c_1.department\_id = c_2.department\_id \land c_1.course\_name = c_2.course\_name) \rightarrow c_1.course\_id = c_2.course\_id )$$
    *   *Empty Set Approach (Relational Algebra):*
        $$\sigma_{R1.department\_id = R2.department\_id \land R1.course\_name = R2.course\_name \land R1.course\_id \neq R2.course\_id}(\rho_{R1}(Course) \times \rho_{R2}(Course)) = \emptyset$$

#### 3B — Implement Constraint in SQL
*   **How to Recognize It:** Write the T-SQL / DDL code to enforce the rule written in 3A [1, 2].
*   **Linguistic Mapping of Constraints:**
    1.  **Uniqueness/Key Constraints:** Use `PRIMARY KEY` or `UNIQUE` [2].
    2.  **Referential Integrity:** Use `FOREIGN KEY ... REFERENCES` [2].
    3.  **Single-row Attribute Domain Constraints:** Use `CHECK` (e.g., `CHECK (salary > 0)`) [2].
    4.  **Multi-row / Multi-table Constraints:** A standard `CHECK` constraint or `ALTER TABLE ... ADD CONSTRAINT` with a subquery is **not** supported by standard SQL engines [1, 2]. You **must** use a **TRIGGER** [1, 2]. (Note: Although some slides show assertions, modern DBMSs like MS SQL Server do not implement `CREATE ASSERTION` [2]).
*   **T-SQL Trigger Blueprint (MS SQL Server):**
    Triggers **must** handle **multi-row operations** [2]. Never write a trigger that assumes `inserted` contains only one row [2].
    *   *Example Constraint:* "The salary of an employee cannot be larger than the salary of their department manager." [3]
    ```sql
    CREATE TRIGGER trg_CheckEmployeeSalary
    ON Employee
    AFTER INSERT, UPDATE
    AS
    BEGIN
        IF EXISTS (
            SELECT 1 
            FROM inserted i
            JOIN Department d ON i.DNo = d.DNumber
            JOIN Employee mgr ON d.MgrSSN = mgr.SSN
            WHERE i.Salary > mgr.Salary
        )
        BEGIN
            RAISERROR('Employee salary cannot exceed manager salary.', 16, 1);
            ROLLBACK TRANSACTION;
        END
    END;
    ```
*   **Table of Influence (Bảng ảnh hưởng):**
    To design a trigger or identify where the constraint must be checked, construct a table of influence showing which operations on which relations can violate the constraint [3].
    *   *Violation Matrix (+ denotes potential violation, - denotes safe):*
        | Relation | Insert | Delete | Update |
        |---|---|---|---|
        | **Employee** | `+` (new salary might exceed manager) | `-` | `+ (Salary, DNo)` |
        | **Department** | `-` (new dept, but manager must be set) | `-` | `+ (MgrSSN)` (new manager might have lower salary) |

---

### QUESTION 4: Transaction Schedules, Serializability & Locking (approx. 2.0 Points)
This section evaluates concurrency control theory, including **Conflict Serializability**, **Locking Protocols**, **Recoverability**, and **Deadlocks** [1].

#### 4A — Conflict Serializability
*   **Definitions:**
    *   **Schedule (S):** A time-ordered sequence of read/write actions from multiple transactions [3].
    *   **Conflicting Operations:** Two operations in a schedule conflict if and only if [2]:
        1. They belong to **different** transactions [2].
        2. They access the **same** data item [2].
        3. At least one of the operations is a **WRITE** [2].
        *   *Conflicting Pairs:* $r_i(X)$ and $w_j(X)$; $w_i(X)$ and $r_j(X)$; $w_i(X)$ and $w_j(X)$.
        *   *Non-conflicting Pairs:* $r_i(X)$ and $r_j(X)$ (both reads); $r_i(X)$ and $w_j(Y)$ (different items) [2].
*   **Precedence Graph (P(S)) / Conflict Graph:**
    1.  Create a **node** for each transaction $T_i$ in the schedule [2].
    2.  Draw a directed edge $T_i \rightarrow T_j$ if an operation of $T_i$ precedes and conflicts with an operation of $T_j$ [2].
    3.  **Theorem:** A schedule $S$ is conflict-serializable if and only if its precedence graph $P(S)$ has **no cycles** [2].
    4.  **Equivalent Serial Order:** If acyclic, perform a **topological sort** on the graph to find the serial order (e.g., $T_1 \rightarrow T_3 \rightarrow T_2$) [2].

#### 4B — Locking Protocols
*   **Lock Compatibility Matrix:**
    | Lock Held | S-Lock (Shared) | X-Lock (Exclusive) |
    |---|---|---|
    | **S-Lock** | Compatible (OK) | Conflict (Wait) [2] |
    | **X-Lock** | Conflict (Wait) [2] | Conflict (Wait) [2] |

*   **Two-Phase Locking (2PL):**
    Transactions must acquire and release locks in two distinct, non-overlapping phases [2]:
    1.  **Growing Phase:** Transaction may acquire locks, but cannot release any [2].
    2.  **Shrinking Phase:** Transaction may release locks, but cannot acquire any new ones [2].
    *   *Basic 2PL:* Guaranteed conflict-serializable [2], but can still suffer from cascading rollbacks and deadlocks [2].
    *   *Strict 2PL:* Basic 2PL rule + all **Exclusive (X) locks** must be held until the transaction **commits or aborts** [2]. Prevents cascading rollbacks.
    *   *Rigorous 2PL:* All locks (both **S** and **X**) must be held until **commit or abort**.

#### 4C — Recoverable, Cascadeless, and Strict Schedules
The safety of a schedule is determined by the order of **Read (r)**, **Write (w)**, **Commit (c)**, and **Abort (a)** operations between dependent transactions.
Let $T_j$ read a data item $X$ written by $T_i$ ($w_i(X) \rightarrow r_j(X)$) [2].
1.  **Recoverable Schedule:** $T_i$ must commit before $T_j$ commits ($c_1$ precedes $c_2$) [2]. If $T_i$ aborts, $T_j$ can be safely aborted [2].
    *   *Condition:* $w_i(X) \rightarrow r_j(X) \rightarrow c_i \rightarrow c_j$ [3].
2.  **Cascadeless Schedule (Avoids Cascading Aborts - ACA):** $T_i$ must commit before $T_j$ reads the modified data [2]. This ensures $T_j$ never reads uncommitted (dirty) data [2].
    *   *Condition:* $w_i(X) \rightarrow c_i \rightarrow r_j(X) \rightarrow c_j$ [3].
3.  **Strict Schedule:** No transaction can read or write a data item $X$ that was written by $T_i$ until $T_i$ has committed or aborted [2].
    *   *Condition:* $w_i(X) \rightarrow c_i \rightarrow [r_j(X) \text{ or } w_j(X)] \rightarrow c_j$ [3].
    *   *Hierarchical Venn Relationship:* $\text{Strict} \subset \text{Cascadeless} \subset \text{Recoverable}$ [2].

#### 4D — Deadlock
*   **Wait-for Graph (WFG):**
    *   Nodes are active transactions [2].
    *   Directed edge $T_i \rightarrow T_j$ if $T_i$ is waiting to lock an item that is currently locked by $T_j$ [2].
    *   **Theorem:** A deadlock exists if and only if the WFG has a **cycle** [2].
*   **Deadlock Prevention (Timestamp Protocols - $TS(T_i) < TS(T_j) \Rightarrow T_i$ is older):**
    *   **Wait-Die (Non-preemptive):** If $T_i$ requests a lock held by $T_j$:
        *   If $T_i$ is older ($TS(T_i) < TS(T_j)$): $T_i$ is allowed to **wait** [2].
        *   If $T_i$ is younger ($TS(T_i) > TS(T_j)$): $T_i$ **dies** (aborts and restarts with its original timestamp) [2].
    *   **Wound-Wait (Preemptive):** If $T_i$ requests a lock held by $T_j$:
        *   If $T_i$ is older ($TS(T_i) < TS(T_j)$): $T_i$ **wounds** $T_j$ (forces $T_j$ to abort and release the lock) [2].
        *   If $T_i$ is younger ($TS(T_i) > TS(T_j)$): $T_i$ is allowed to **wait** [2].

---

### QUESTION 5: Concurrency Control & Isolation Levels (approx. 1.0 Point)
*   **How to Recognize It:** You are given 2 to 4 concurrent transactions with specified operations, initial database values, and an SQL Isolation Level for each [2]. You must trace their execution by hand and output the final database state [2].
*   **Theory — Concurrency Anomalies:**
    1.  **Dirty Read ($r_2(X)$ after $w_1(X)$ before $c_1/a_1$):** Reading changes made by an uncommitted transaction that subsequently aborts [2, 3].
    2.  **Lost Update ($r_1(X); r_2(X); w_1(X); w_2(X)$):** $T_2$ overwrites $T_1$'s committed changes without realizing $T_1$ modified the value [2, 3].
    3.  **Non-repeatable Read ($r_1(X); w_2(X); c_2; r_1(X)$):** $T_1$ reads the same row twice but gets different attribute values because $T_2$ modified and committed it in between [2, 3].
    4.  **Phantom Read ($r_1(cond); w_2(insert/delete \in cond); c_2; r_1(cond)$):** $T_1$ executes a query twice with a search condition, but receives a different set of matching rows because $T_2$ inserted or deleted rows in between [2, 3].
*   **SQL Isolation Levels & Allowed Anomalies Matrix:**
    | Isolation Level | Dirty Read | Non-repeatable Read | Phantom Read | Lost Update |
    |---|---|---|---|---|
    | **READ UNCOMMITTED** | Allowed [2] | Allowed [2] | Allowed [2] | Allowed [2] |
    | **READ COMMITTED** | Prevented [2] | Allowed [2] | Allowed [2] | Allowed [2] |
    | **REPEATABLE READ** | Prevented [2] | Prevented [2] | Allowed [2] | Prevented [2] |
    | **SERIALIZABLE** | Prevented [2] | Prevented [2] | Prevented [2] | Prevented [2] |

*   **Hand-Tracing Solution Method:**
    Draw a trace table with the following columns [2]:
    $$\begin{array}{|c|c|c|c|c|c|}
    \hline
    \text{Step} & \text{Transaction} & \text{Operation} & \text{Local Value} & \text{DB Value} & \text{Lock State / Status} \\
    \hline
    \end{array}$$
    *   *Rules for tracing:*
        *   Under **Read Committed**, a transaction immediately releases S-locks after reading [2], but keeps X-locks until commit.
        *   Under **Repeatable Read**, S-locks and X-locks are held until the transaction commits (Strict 2PL).
        *   If a transaction requests a conflicting lock, freeze its execution (mark as "Waiting") [2] and proceed with other transactions' operations in the schedule until the blocking lock is released.

---

### QUESTION 6: Database Recovery (approx. 1.0 Point)
*   **How to Recognize It:** You are given a sequence of transaction log records, a point of crash (Failure), and a recovery protocol (Undo-only, Redo-only, or Undo/Redo) [2]. You must analyze the log and specify which transactions must be undone or redone and the final values of database items [2].
*   **The Three Logging Rules:**
    1.  **Undo-Only Logging (Immediate Modification):**
        *   *Log Record Format:* `[T, X, old_value]` [2].
        *   *Rule:* The log record `[T, X, v]` must be flushed to disk **before** the modified database block of $X$ is written to disk [2]. The `<commit>` log record must be flushed **after** all changed database blocks have reached the disk [2].
        *   *Recovery:* Identify transactions *without* a `<commit>` record. Undo them from **bottom to top (latest-first)**, writing `old_value` to disk [2]. Ignore committed transactions.
    2.  **Redo-Only Logging (Deferred Modification):**
        *   *Log Record Format:* `[T, X, new_value]` [2].
        *   *Rule:* All log records representing a modification must reach disk **before** the actual database block is written [2]. The `<commit>` record must reach disk **before** any changes are written to the database disk [2].
        *   *Recovery:* Identify transactions *with* a `<commit>` record. Redo them from **top to bottom (earliest-first)**, writing `new_value` to disk [2]. Ignore uncommitted transactions.
    3.  **Undo/Redo Logging (Hybrid):**
        *   *Log Record Format:* `[T, X, old_value, new_value]` [2].
        *   *Rule:* The log record must reach disk **before** the database disk block is modified [2]. There is no restriction on when the `<commit>` record is written relative to database disk writes.
        *   *Recovery:*
            1.  **Redo Phase:** Scan **top to bottom (earliest-first)** and redo all committed transactions using `new_value` [2].
            2.  **Undo Phase:** Scan **bottom to top (latest-first)** and undo all uncommitted transactions using `old_value` [2].

*   **Checkpoint Analysis (Non-quiescent):**
    A checkpoint reduces the range of the log we must scan during recovery [2].
    *   *Log Syntax:* `<start ckpt (T1, ..., Tn)>` where $T_i$ are active transactions [2], followed eventually by `<end ckpt>` [2].
    *   *Scanning Range Rules (Undo/Redo):*
        1.  If the crash occurs **after** `<end ckpt>`:
            *   We only need to scan backward until the **earliest start record** among the transactions that were active at `<start ckpt>` (i.e., $T_1, \dots, T_n$) [2]. Any transaction that committed before `<start ckpt>` is guaranteed to have its database blocks safely flushed to disk [2].
        2.  If the crash occurs **before** `<end ckpt>`:
            *   The current checkpoint is invalid [2]. We must search backward for the **previous** `<start ckpt>` and find the earliest start record of any transaction active at *that* point [2].

---

### QUESTION 7: Functional Dependency & Normalization (approx. 1.0 Point)
*   **Functional Dependency (FD) Definition:** $X \rightarrow Y$ means if two tuples agree on the values of attributes in $X$, they must agree on the values of attributes in $Y$ [2].

#### 7.1 — Attribute Closure ($X^+$)
*   **Algorithm:**
    1.  Initialize $X^+ = X$ [2].
    2.  Loop through FDs in $F$. If there is $Y \rightarrow Z$ such that $Y \subseteq X^+$, then update $X^+ = X^+ \cup Z$ [2].
    3.  Repeat until $X^+$ does not grow [2].
*   **Superkey Test:** $X$ is a superkey if and only if $X^+ = R^+$ (all attributes) [2].

#### 7.2 — Candidate Keys Discovery
*   **The Instructor's Sourcing Rule:**
    1.  **Source Attributes (LHS only):** Attributes that appear *only* on the Left-Hand Side of FDs, or *do not appear at all* in $F$. These attributes **must** belong to **every** candidate key [2].
    2.  **Destination Attributes (RHS only):** Attributes that appear *only* on the Right-Hand Side of FDs. These attributes **never** belong to **any** candidate key [2].
    3.  **Neutral Attributes (Both/Neither):** Attributes on both sides can belong to some keys.
*   **Key Finding Procedure:**
    1.  Compute the closure of the set of Source Attributes. If its closure equals $R^+$, it is the unique candidate key [2].
    2.  If not, systematically add Neutral Attributes to the set, compute the closure, and verify minimality (removing any attribute should make it no longer a superkey) [2].

#### 7.3 — Checking Normal Forms (NF)
*   **Prime Attribute:** An attribute that belongs to **at least one** candidate key [2].
*   **Non-prime Attribute:** An attribute that belongs to **no** candidate keys [2].
*   **Definitions:**
    *   **1NF:** All attribute values are atomic (no repeating groups or nested tables) [2].
    *   **2NF:** Satisfies 1NF + no **partial dependencies** [2]. A partial dependency is $X \rightarrow A$ where $X$ is a *proper subset* of a candidate key and $A$ is a non-prime attribute [2]. (Only check if keys are composite).
    *   **3NF:** Satisfies 2NF + no **transitive dependencies** [2]. 
        *   *Test:* For every non-trivial FD $X \rightarrow A$, either **$X$ is a superkey** OR **$A$ is a prime attribute** [2].
    *   **BCNF:** For every non-trivial FD $X \rightarrow A$, **$X$ must be a superkey** [2]. (More restrictive than 3NF since it forbids $A$ being prime if $X$ is not a superkey).
    *   **4NF:** For every non-trivial Multivalued Dependency (MVD) $X \twoheadrightarrow Y$, **$X$ must be a superkey** [2].

#### 7.4 — Decomposition Properties
*   **Lossless Join (No Spurious Tuples):** A decomposition of $R$ into $R_1, R_2$ is lossless if and only if [2]:
    $$(R_1 \cap R_2) \rightarrow R_1 \in F^+ \quad \text{or} \quad (R_1 \cap R_2) \rightarrow R_2 \in F^+$$
    *(Meaning: the shared attributes must functionally determine at least one of the decomposed relations).*
*   **Dependency Preservation:** A decomposition preserves the set of FDs if $(F_1 \cup F_2)^+ = F^+$ [2].
*   **BCNF Decomposition Algorithm (Lossless but may not preserve dependencies):**
    1.  Check if $R$ is in BCNF [2]. If yes, stop.
    2.  If there is an FD $X \rightarrow Y$ that violates BCNF ($X$ is not a superkey), decompose $R$ into [2]:
        *   $R_1 = X \cup Y$ [2]
        *   $R_2 = R - Y$ [2]
    3.  Compute FDs that hold on $R_1$ and $R_2$ and recursively decompose them if they violate BCNF [2].

---

### QUESTION 8: Query Optimization & Cost Estimation (approx. 1.0 Point)
*   **How to Recognize It:** You are given relations $R$ and $S$, their record counts $T(R)$, their physical disk block sizes $P(R)$ (number of pages), and the available memory buffers $B$ [2]. You must calculate the **Disk I/O cost** for different Join Algorithms and select the cheapest option [2].
*   **Crucial Rule:** Disk I/O is calculated by the number of physical page reads/writes, **not the number of tuples** [2]. CPU computations on RAM cost 0 I/Os [2].

#### 8.1 — Join Cost Formulas (R is the Outer, S is the Inner Relation)
1.  **Tuple Nested Loop Join (TNLJ):**
    Loops over every tuple of $R$ and scans the entire table $S$ [2].
    $$\text{Cost} = P(R) + T(R) \times P(S) + OUT$$
2.  **Page Nested Loop Join (PNLJ):**
    Locks 1 page of $R$ and scans the entire table $S$ [2].
    $$\text{Cost} = P(R) + P(R) \times P(S) + OUT$$
3.  **Block Nested Loop Join (BNLJ):**
    Utilizes memory buffers. Loads $B-1$ pages of $R$ (Outer) into RAM, and scans $S$ once per block [2].
    $$\text{Cost} = P(R) + \left\lceil \frac{P(R)}{B-1} \right\rceil \times P(S) + OUT$$
    *   *Optimization Note:* Always place the **smaller relation** as the **outer relation** to minimize the block count $\lceil P(Outer)/(B-1) \rceil$ [2].
4.  **Index Nested Loop Join (INLJ):**
    Uses an index (like a B+ tree) on $S.A$ (Inner relation join attribute) [2]. For each tuple in $R$, search the index [2].
    $$\text{Cost} = P(R) + T(R) \times L + OUT$$
    where $L$ is the I/O cost to traverse the index from root to leaf (typically a small integer, $L \approx 3 \text{ to } 5$) [2].
5.  **Sort-Merge Join (SMJ):**
    If the relations are not sorted, they must first be sorted using an external merge sort [2].
    *   *Sorting Cost for R:* $2 \times P(R) \times k_R$ where $k_R$ is the number of passes [2]. (Pass 1 creates sorted runs of size $B$; subsequent passes merge $B-1$ runs at a time).
    *   *Merging/Joining Cost:* Once both are sorted, a single parallel scan is performed [2].
    *   *Total SMJ Cost:*
        $$\text{Cost} = \text{Sort}(R) + \text{Sort}(S) + P(R) + P(S) + OUT$$
6.  **Hash Partition Join (HPJ) / Grace Hash Join:**
    Requires enough buffer pages ($B > \sqrt{\min(P(R), P(S))}$).
    *   *Partition Phase:* Both relations are read and written to disk partitioned into $B-1$ buckets. Cost = $2 \times (P(R) + P(S))$ [2].
    *   *Join Phase:* Each bucket pair is loaded and joined in memory. Cost = $P(R) + P(S)$ [2].
    *   *Total HPJ Cost:*
        $$\text{Cost} = 3 \times (P(R) + P(S)) + OUT$$

---

## SECTION 3: KEY DISTINCTIONS MATRIX

| Concept A | Concept B | Core Structural Difference |
|---|---|---|
| **Tuple Calculus (TRC)** | **Domain Calculus (DRC)** | TRC uses variables that bind to **entire tuples/rows** [2]. DRC uses variables that bind directly to **individual column values** [2]. |
| **Basic 2PL** | **Strict 2PL** | Basic 2PL allows releasing locks at any time during the shrinking phase (can lead to cascading rollbacks) [2]. Strict 2PL **forces** all exclusive (write) locks to be held until transaction commit/abort [2]. |
| **Cascadeless Schedule** | **Strict Schedule** | Cascadeless prevents reading uncommitted data ($r_j(X)$ must wait for $c_i$) [2]. Strict prevents **both reading and writing** uncommitted data ($r_j(X)$ and $w_j(X)$ must wait for $c_i$) [2]. |
| **Sort-Merge Join (SMJ)** | **Hash Join (HPJ)** | SMJ is highly robust to **data skew** (uneven value distribution) and leaves output sorted [2]. HPJ is faster under ideal conditions ($3(P_R+P_S)$ cost) and highly parallelizable, but suffers from expensive recursive bhash loops if buckets overflow RAM [2]. |

---

## SECTION 4: EXAM PREPARATION CHECKLIST
Before walking into the exam room, verify that you can confidently execute the following tasks:

*   [ ] Read natural requirements and draw a full, syntactically correct ER Diagram in **under 12 minutes** [2].
*   [ ] Apply the correct conversion rules to map weak entities, 1:1, 1:N, and M:N relationships into relations [2].
*   [ ] Write identical complex queries in **Relational Algebra, TRC, DRC, and SQL** [2].
*   [ ] Translate "for all / every" queries using division in RA, universal quantifiers in TRC, and double `NOT EXISTS` in SQL [2].
*   [ ] Formulate natural language business rules into formal integrity constraints [2].
*   [ ] Identify whether an integrity constraint can be enforced via a `CHECK` constraint or requires a T-SQL `TRIGGER` [2].
*   [ ] Build a **Precedence Graph** for a schedule, test for conflict-serializability, and output the serial order [2].
*   [ ] Categorize schedules into **Recoverable, Cascadeless, or Strict** [2].
*   [ ] Construct a **Wait-for Graph** to detect deadlocks, and apply Wait-Die or Wound-Wait protocols [2].
*   [ ] Hand-trace concurrent transactions running under different **SQL Isolation Levels** and list the final DB state [2].
*   [ ] Classify concurrent execution anomalies: Dirty Read, Lost Update, Non-repeatable Read, and Phantom Read [2].
*   [ ] Analyze a transaction log and execute recovery using **Undo-only, Redo-only, or Undo/Redo** [2].
*   [ ] Determine how far back a recovery scan must go when a non-quiescent checkpoint is present [2].
*   [ ] Calculate **Attribute Closures** and identify all candidate keys using the LHS/RHS sourcing rule [2].
*   [ ] Determine the highest normal form of a relation (1NF $\rightarrow$ 2NF $\rightarrow$ 3NF $\rightarrow$ BCNF $\rightarrow$ 4NF) [2].
*   [ ] Decompose a relation into lossless and dependency-preserving **3NF or BCNF** [2].
*   [ ] Compute the precise Disk I/O costs for **TNLJ, PNLJ, BNLJ, INLJ, SMJ, and HPJ** [2].
