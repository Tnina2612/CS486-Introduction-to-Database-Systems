# DATABASE SYSTEMS (CS486) — MOCK FINAL EXAMINATION
**Course:** VNUHCM - University of Science, Faculty of Information Technology  
**Instructor Material Grounded Mock Exam**  
**Duration:** 100 Minutes | **Total Points:** 10.0 (20 sub-questions, 0.5 points each)  
**Permitted Materials:** None (Closed book, closed notes)  

---

## IMPORTANT INSTRUCTIONS
1. This exam consists of **8 major questions** broken down into **20 sub-questions**. Each sub-question is worth exactly **0.5 points**.
2. **Question 1 (ERD & Mapping)** and **Question 2 (Query Languages)** use **independent database schemas**. Any mistake in your ERD design will not cascade into your query answers.
3. Show all your work, including intermediate steps, formulas, and diagrams where requested.
4. For SQL queries, use standard SQL or T-SQL of Microsoft SQL Server as taught by the instructor.
5. For cost estimations, express all costs strictly in **Disk I/O pages**, following the exact conventions and formulas of the slides.

---

# PART I: EXAM QUESTIONS (No Hints or Solutions)

## QUESTION 1: ER DIAGRAM & RELATIONAL SCHEMA MAPPING (1.0 Point)
An international shipping and logistics company wants to design a relational database to track its operations. Based on their business requirements, you must design an Entity-Relationship (ER) model and map it to a relational schema:

1. **Entities & Attributes:**
   * **Shipment:** Identified by a unique `ShipmentID`. It also has a `Weight`, a `DestinationAddress` (composed of `Street`, `City`, and `Country`), and multiple `TrackingStatus` updates (e.g., "Departed", "In Transit", "Delivered") which are stored as historical updates.
   * **Courier:** Identified by a unique `EmployeeID`. It also has a `Name` and a `Phone` number.
   * **Vehicle:** Identified by a unique `LicensePlate`. It has a `Capacity` and a `VehicleType`.
   * **Dependent:** Represented as a weak entity of `Courier` to store their dependents' info for health insurance. A dependent is identified by their `DependentName` (partial key) and has a `BirthDate`.

2. **Relationships:**
   * **Deliver:** A Courier drives a Vehicle to deliver Shipments.
     * Each Shipment is delivered by **exactly one** Courier using **exactly one** Vehicle.
     * A Courier can deliver **many** Shipments.
     * A Vehicle can be used to deliver **many** Shipments.
   * **Employ:** Each Courier works for **exactly one** regional office (not modeled as an entity here, but represent as a plain attribute `OfficeCode` in the Courier entity).
   * **Support:** A Courier can support **zero or more** Dependents. Each Dependent is supported by **exactly one** Courier.

### Sub-Questions:
*   **[Q1.1] (0.5 pts):** Draw or describe the conceptual Entity-Relationship Diagram (ERD). Specifically, list all **entities** (highlighting weak entities), **attributes** (identifying composite, multivalued, primary key, and partial key attributes), **relationships**, and **cardinality/participation constraints** using the instructor's standard notation.
*   **[Q1.2] (0.5 pts):** Map the ERD into a complete relational schema. Write out the table definitions (attributes, primary keys, foreign keys, and referential integrity constraints). Follow the instructor's mapping rules for 1:1, 1:N, M:N, weak entities, and ternary relationships.

---

## QUESTION 2: DATABASE QUERY LANGUAGES (2.0 Points)
Consider the following independent relational database schema for a university registry:

*   `STUDENT(StudentID, StudentName, Gender, Major, GPA)`
*   `COURSE(CourseID, CourseName, Credits, DeptName)`
*   `ENROLL(StudentID, CourseID, SchoolYear, Semester, Grade)`

*Note: Underlined attributes represent Primary Keys. Refer to this schema for all sub-questions.*

### Sub-Questions:
*   **[Q2.1] (0.5 pts):** Write a query in **Relational Algebra (RA)** to find the `StudentID` and `StudentName` of students who have enrolled in *every* course offered by the `'Computer Science'` department. (Do not use any non-standard division operators without defining them).
*   **[Q2.2] (0.5 pts):** Write the exact same query as [Q2.1] (students who enrolled in *every* computer science course) using **Tuple Relational Calculus (TRC)**.
*   **[Q2.3] (0.5 pts):** Write a query in **Domain Relational Calculus (DRC)** to find the `StudentID` and `StudentName` of all female students (`Gender = 'F'`) who have received a `'A'` grade in at least one course of the `'Information Technology'` department.
*   **[Q2.4] (0.5 pts):** Write a **SQL** query to find the `CourseID` and `CourseName` of the course(s) with the **highest number of credits** in the database. 
    *   *Constraint:* You are **not allowed** to use any aggregate functions (e.g., `MAX`, `COUNT`, `AVG`), nor are you allowed to use `LIMIT`, `TOP`, or `FETCH FIRST` clauses. Your query must handle ties correctly (i.e., if multiple courses have the same maximum credits, return all of them).

---

## QUESTION 3: INTEGRITY CONSTRAINTS & DATABASE CODE (1.0 Point)
Using the university registry schema from Question 2, the university wishes to enforce the following business rule:
> *"No student with a GPA strictly less than 2.0 can enroll in any course offered by the 'Computer Science' department."*

### Sub-Questions:
*   **[Q3.1] (0.5 pts):** 
    1. Express this integrity constraint formally using **Relational Calculus** (either TRC or DRC).
    2. Construct a complete **Table of Influence (Bảng ảnh hưởng)** for this constraint, listing the affected relations (`STUDENT` and `ENROLL`) and indicating with `+`, `-`, or `*(attributes)` the effects of `Insert`, `Delete`, and `Update` operations.
*   **[Q3.2] (0.5 pts):** Write a robust **T-SQL AFTER TRIGGER** (Microsoft SQL Server dialect) named `trg_CheckCSEnrollment` on the appropriate table(s) to enforce this constraint. The trigger must handle multi-row inserts and updates correctly, and rollback the entire transaction with an informative error message if a violation is detected.

---

## QUESTION 4: TRANSACTION SCHEDULES, SERIALIZABILITY & LOCKING (2.0 Points)
Consider the following transaction schedule $S$ involving transactions $T_1$, $T_2$, and $T_3$ operating on database items $A$, $B$, and $C$:

$$S: r_1(A); r_2(B); w_1(A); r_3(C); w_2(B); r_2(A); w_3(C); w_2(A); \text{commit}_1; \text{commit}_3; \text{commit}_2;$$

### Sub-Questions:
*   **[Q4.1] (0.5 pts):** 
    1. Identify all **conflicting operations** (read-write, write-read, write-write on the same data item) in the schedule $S$.
    2. Construct the **Precedence Graph (Conflict Graph)** for $S$. Is $S$ conflict-serializable? If yes, state all equivalent serial schedules. If no, explain why.
*   **[Q4.2] (0.5 pts):** Classify the schedule $S$ regarding recoverability. Is it **Recoverable**? Does it **Avoid Cascading Rollback (Cascadeless)**? Is it a **Strict** schedule? Explain your reasoning for each classification by referencing the exact operations and commit times in $S$.
*   **[Q4.3] (0.5 pts):** Show how the schedule $S$ would execute under the **Two-Phase Locking (2PL)** protocol. 
    1. List the sequence of locking and unlocking operations (use $l_i(X)$ for acquiring a lock, and $u_i(X)$ for releasing a lock. Note: assume only exclusive locks are available for simplicity, or specify shared $ls_i(X)$ and exclusive $lx_i(X)$ locks).
    2. Does 2PL result in a deadlock in this schedule? If yes, show the Wait-For Graph and identify the cycle.
*   **[Q4.4] (0.5 pts):** Suppose the system uses timestamp-based concurrency control to prevent deadlocks. Contrast how the **Wait-Die** and **Wound-Wait** schemes would handle a lock conflict when a transaction $T_{young}$ requests a lock held by $T_{old}$, versus when $T_{old}$ requests a lock held by $T_{young}$.

---

## QUESTION 5: CONCURRENCY CONTROL & ISOLATION LEVELS (1.0 Point)
Two transactions, $T_1$ and $T_2$, run concurrently. The initial state of the database has a table `PRODUCT` with a single row: `(ID=101, Name='Laptop', Stock=5, Price=1000)`.

*   **Transaction $T_1$:**
    1.  `SELECT Stock FROM PRODUCT WHERE ID = 101` (Let this be $R_1(\text{Stock})$)
    2.  `UPDATE PRODUCT SET Stock = Stock - 2 WHERE ID = 101` (Let this be $W_1(\text{Stock})$)
    3.  `COMMIT`
*   **Transaction $T_2$:**
    1.  `SELECT Stock FROM PRODUCT WHERE ID = 101` (Let this be $R_2(\text{Stock})$)
    2.  `UPDATE PRODUCT SET Stock = Stock - 1 WHERE ID = 101` (Let this be $W_2(\text{Stock})$)
    3.  `COMMIT`

The concurrent interleaved execution of these operations is as follows:
$$t_1: R_1(\text{Stock}) 
\rightarrow t_2: R_2(\text{Stock}) 
\rightarrow t_3: W_1(\text{Stock}) 
\rightarrow t_4: W_2(\text{Stock}) 
\rightarrow t_5: \text{Commit}_1 
\rightarrow t_6: \text{Commit}_2$$

### Sub-Questions:
*   **[Q5.1] (0.5 pts):** 
    1. What is the final value of `Stock` in the database after both transactions commit?
    2. Name and define the specific concurrency anomaly (dirty read, lost update, non-repeatable read, phantom read) that occurred in this execution.
*   **[Q5.2] (0.5 pts):** Trace how this interleaved execution is resolved under SQL standard Isolation Levels:
    1. Explain what happens if both $T_1$ and $T_2$ run under **Read Committed**.
    2. Explain what happens if both $T_1$ and $T_2$ run under **Repeatable Read** (assuming standard locking implementation).

---

## QUESTION 6: DATABASE RECOVERY (1.0 Point)
A database recovery manager uses a Write-Ahead Log (WAL) with a steal/no-force policy. The system crashes, and the following log records are found on disk:

```text
[1]  <Start T1>
[2]  <T1, A, 50, 100>
[3]  <Start T2>
[4]  <T2, B, 200, 300>
[5]  <Commit T1>
[6]  <Checkpoint [T2]>
[7]  <Start T3>
[8]  <T3, C, 15, 45>
[9]  <Start T4>
[10] <T4, D, 80, 20>
[11] <Commit T3>
[12] <T2, B, 300, 500>
*** CRASH ***
```
*Note: Log format is `<Tx, Variable, OldValue, NewValue>`.*

### Sub-Questions:
*   **[Q6.1] (0.5 pts):** For **Undo-only** recovery logging:
    1. Which transactions are classified as **Active** (to be undone), and which are **Completed** (to be ignored/redone)?
    2. What is the exact sequence of undo operations performed? State the variables and their restored values.
    3. How far back in the log does the recovery manager need to scan? State the line number of the log record and explain why.
*   **[Q6.2] (0.5 pts):** For **Undo/Redo** recovery logging:
    1. Identify the set of transactions in the **Undo-List** and the **Redo-List** immediately after the crash.
    2. Show the step-by-step recovery process, detailing the **Redo Phase** (forward pass) and the **Undo Phase** (backward pass). Specify which values are written to disk and in what order.

---

## QUESTION 7: FUNCTIONAL DEPENDENCIES & NORMALIZATION (1.0 Point)
Consider the relation schema $R(A, B, C, D, E, G)$ and the set of functional dependencies (FDs):
$$F = \{ A 
\rightarrow BC, \quad CD 
\rightarrow E, \quad B 
\rightarrow D, \quad E 
\rightarrow A \}$$

### Sub-Questions:
*   **[Q7.1] (0.5 pts):** 
    1. Compute the attribute closures: $(AB)^+$ and $(CE)^+$. Show each step of your computation.
    2. Find **all candidate keys** of the relation $R$. Clearly show how you verified that each is a candidate key (superkey and minimal). Identify the prime and non-prime attributes.
*   **[Q7.2] (0.5 pts):** 
    1. Determine the highest Normal Form (1NF, 2NF, 3NF, BCNF) that relation $R$ satisfies, giving a rigorous proof based on the FDs.
    2. Decompose $R$ into Boyce-Codd Normal Form (BCNF). Is your decomposition **Lossless**? Is it **Dependency Preserving**? Prove the Lossless Join property using the **Tableau (Matrix) Method**.

---

## QUESTION 8: QUERY OPTIMIZATION & COST ESTIMATION (1.0 Point)
Consider two database relations representing a library catalog:
*   `BOOK(BookID, Title, Publisher, Pages)` — stored in $P(\text{BOOK}) = 1,000$ disk pages, with $T(\text{BOOK}) = 20,000$ tuples.
*   `PUBLISHER(PubName, Address, Phone)` — stored in $P(\text{PUBLISHER}) = 500$ disk pages, with $T(\text{PUBLISHER}) = 10,000$ tuples.

The database system allocates $B + 1 = 51$ buffer pages in main memory (giving $B = 50$ pages available for sorting, partitioning, and buffering). The join operation is on `Publisher = PubName`. We assume the output size is $OUT = 400$ pages.

### Sub-Questions:
*   **[Q8.1] (0.5 pts):** Compute the Disk I/O cost (including the cost of reading input and writing output $OUT$) for the following two join algorithms:
    1. **Block Nested Loop Join (BNLJ):** Calculate the cost for both options: with `BOOK` as the outer relation, and with `PUBLISHER` as the outer relation. Which option is cheaper?
    2. **Index Nested Loop Join (INLJ):** Assuming there is a secondary, unclustered B+ Tree index on the join attribute `PubName` of the table `PUBLISHER`. The height of the B+ Tree is $HT = 3$ levels, and accessing a matching tuple requires $1$ additional disk I/O. `BOOK` is used as the outer relation.
*   **[Q8.2] (0.5 pts):** Compute the Disk I/O cost (including the cost of reading input and writing output $OUT$) for:
    1. **Sort-Merge Join (SMJ):** Assume that the relations are not initially sorted. Use the optimized 2-pass Sort-Merge Join formula where the sort and merge phases are combined if the number of runs is $\le B$ (state if this condition holds).
    2. **Hash Partition Join (HPJ):** Assume the hash function distributes the tuples uniformly and memory is sufficient to avoid recursive partitioning.
    3. Compare all 4 join algorithms (BNLJ, INLJ, SMJ, HPJ) and identify which physical plan the Query Optimizer should select.

---
---

# PART II: ANSWER KEY & SOLUTIONS

This section provides the complete, step-by-step mathematical, formal, and structural solutions to every question on the exam, utilizing the instructor's standard notations, theories, and methodologies.

---

## SOLUTION TO QUESTION 1: ER DIAGRAM & RELATIONAL SCHEMA MAPPING

### [Q1.1] Conceptual ER Diagram Structure & Analysis
To represent the ER diagram in text format following the instructor's rules [02.ER Data Model.pdf]:

1.  **Entity Types:**
    *   **EMPLOYEE (Courier):** Strong entity. Primary Key: `EmployeeID`. Simple attributes: `Name`, `Phone`, `OfficeCode`.
    *   **VEHICLE:** Strong entity. Primary Key: `LicensePlate`. Simple attributes: `Capacity`, `VehicleType`.
    *   **SHIPMENT:** Strong entity. Primary Key: `ShipmentID`. Simple attributes: `Weight`.
        *   *Composite Attribute:* `DestinationAddress` composed of sub-attributes `Street`, `City`, and `Country`.
        *   *Multivalued Attribute:* `TrackingStatus` (represented as a double-ovaled attribute connected to `SHIPMENT` in ERD notation).
    *   **DEPENDENT:** Weak entity of `EMPLOYEE`. Identifying relationship: `Support`. Partial Key (Discriminator): `DependentName` (underlined with a dashed line). Attribute: `BirthDate`.

2.  **Relationship Types:**
    *   **DELIVER:** A **ternary** relationship connecting `EMPLOYEE`, `VEHICLE`, and `SHIPMENT`.
        *   *Cardinality Constraints:* Since each shipment is delivered by *exactly one* courier using *exactly one* vehicle, the cardinality from `SHIPMENT` to the relationship is **1**, whereas from `EMPLOYEE` and `VEHICLE` to the relationship, it is **M** and **N** respectively.
        *   Therefore, the ternary relationship has cardinalities **M:N:1** (Employee:Vehicle:Shipment). This means a particular Shipment is associated with exactly one Employee and one Vehicle, but an Employee-Vehicle pair can deliver multiple Shipments.
        *   *Participation:* Participation of `SHIPMENT` in `DELIVER` is **total** (every shipment must be delivered).
    *   **SUPPORT:** Binary **identifying relationship** connecting strong entity `EMPLOYEE` (owner) and weak entity `DEPENDENT`.
        *   *Cardinality:* **1:N** (one Employee supports many Dependents; a Dependent is supported by exactly one Employee).
        *   *Participation:* Participation of `DEPENDENT` is **total** (represented with double lines in ERD, as a weak entity cannot exist without its owner).

---

### [Q1.2] Relational Schema Mapping
Following the standard relational mapping rules [03.Relation Data Model.pdf]:

1.  **Step 1: Map Strong Entities**
    *   `COURIER(EmployeeID, Name, Phone, OfficeCode)`
        *   Primary Key: `EmployeeID`
    *   `VEHICLE(LicensePlate, Capacity, VehicleType)`
        *   Primary Key: `LicensePlate`
    *   `SHIPMENT(ShipmentID, Weight, Street, City, Country)`
        *   Primary Key: `ShipmentID`
        *   *Note on Composite Attribute:* `DestinationAddress` is flattened into its component attributes.

2.  **Step 2: Map Weak Entities**
    *   `DEPENDENT(EmployeeID, DependentName, BirthDate)`
        *   Primary Key: `(EmployeeID, DependentName)`
        *   Foreign Key: `EmployeeID` references `COURIER(EmployeeID)` with `ON DELETE CASCADE` (referential integrity rule for weak entities).

3.  **Step 3: Map Multivalued Attributes**
    *   `SHIPMENT_STATUS(ShipmentID, Status)`
        *   Primary Key: `(ShipmentID, Status)`
        *   Foreign Key: `ShipmentID` references `SHIPMENT(ShipmentID)` with `ON DELETE CASCADE`.

4.  **Step 4: Map Ternary Relationship (DELIVER)**
    *   Because the ternary relationship `DELIVER` has cardinalities **M:N:1** (where `SHIPMENT` is on the "1" side), we do **not** create a separate table for `DELIVER`. Instead, following the instructor's mapping optimization for N-ary relationships with a "1" side, we map the relationship by migrating the keys of the other entities as foreign keys into the relation representing the "1" side (`SHIPMENT`).
    *   **Modified SHIPMENT table:**
        *   `SHIPMENT(ShipmentID, Weight, Street, City, Country, EmployeeID, LicensePlate)`
        *   Primary Key: `ShipmentID`
        *   Foreign Key 1: `EmployeeID` references `COURIER(EmployeeID)` on delete set null / restrict.
        *   Foreign Key 2: `LicensePlate` references `VEHICLE(LicensePlate)` on delete set null / restrict.
        *   Non-null constraint: `EmployeeID` and `LicensePlate` must be `NOT NULL` if participation is mandatory.

#### Common Mistakes to Avoid:
*   *Creating a separate table for Deliver:* Students often create a `DELIVER(EmployeeID, LicensePlate, ShipmentID)` table. Since a shipment is delivered by exactly one courier and vehicle, `ShipmentID` would be the primary key of this separate table, which is redundant and should be merged directly into `SHIPMENT`.
*   *Forgetting multi-valued attributes:* `TrackingStatus` must be in a separate table, not comma-separated inside `SHIPMENT`.

---

## SOLUTION TO QUESTION 2: DATABASE QUERY LANGUAGES

### [Q2.1] Relational Algebra (RA) Solution
To find students who enrolled in *every* course of the `'Computer Science'` department, we use **Relational Division ($\div$)** [04.Query Languages 1.pdf, 04.Query Languages 2.pdf]:

1.  **Define target courses (CS department courses):**
    $$R_{CS\_Courses} \leftarrow \pi_{CourseID}(\sigma_{DeptName = 'Computer Science'}(COURSE))$$
2.  **Define students' course enrollments:**
    $$R_{Student\_Enrollments} \leftarrow \pi_{StudentID, CourseID}(ENROLL)$$
3.  **Perform Division to find StudentIDs of students who enrolled in all of them:**
    $$R_{Qualified\_IDs} \leftarrow R_{Student\_Enrollments} \div R_{CS\_Courses}$$
4.  **Retrieve Student Names by joining back with STUDENT:**
    $$R_{Result} \leftarrow \pi_{StudentID, StudentName}(R_{Qualified\_IDs} \bowtie STUDENT)$$

*Alternative without Division operator (using Difference $\cup$/$-$ and Cartesian Product $\times$):*
1.  $$All\_Combinations \leftarrow \pi_{StudentID}(STUDENT) \times R_{CS\_Courses}$$
2.  $$Missing\_Enrollments \leftarrow All\_Combinations - R_{Student\_Enrollments}$$
3.  $$Qualified\_IDs \leftarrow \pi_{StudentID}(STUDENT) - \pi_{StudentID}(Missing\_Enrollments)$$
4.  $$Result \leftarrow \pi_{StudentID, StudentName}(Qualified\_IDs \bowtie STUDENT)$$

---

### [Q2.2] Tuple Relational Calculus (TRC) Solution
Following TRC syntax where variables represent tuples [04.Query Languages 3.pdf]:
$$\{ t \,|\, \exists s \in STUDENT \,(t[StudentID] = s[StudentID] \wedge t[StudentName] = s[StudentName] \wedge \forall c \in COURSE \,(c[DeptName] = 'Computer Science' \Rightarrow \exists e \in ENROLL \,(e[StudentID] = s[StudentID] \wedge e[CourseID] = c[CourseID])))\}$$

*Using double negation (equivalent logical form):*
$$\{ t \,|\, \exists s \in STUDENT \,(t[StudentID] = s[StudentID] \wedge t[StudentName] = s[StudentName] \wedge 
\neg \exists c \in COURSE \,(c[DeptName] = 'Computer Science' \wedge 
\neg \exists e \in ENROLL \,(e[StudentID] = s[StudentID] \wedge e[CourseID] = c[CourseID])))\}$$

---

### [Q2.3] Domain Relational Calculus (DRC) Solution
In DRC, variables represent individual attribute values (domains) [04.Query Languages 4.pdf]:
$$\{ \langle sid, sname \rangle \,|\, \exists gen, maj, gpa \,(\langle sid, sname, gen, maj, gpa \rangle \in STUDENT \wedge gen = 'F' \wedge \exists cid, sy, sem, gr, cname, cred, dname \,(\langle sid, cid, sy, sem, gr \rangle \in ENROLL \wedge gr = 'A' \wedge \langle cid, cname, cred, dname \rangle \in COURSE \wedge dname = 'Information Technology'))\}$$

---

### [Q2.4] SQL Solution (Highest credits without aggregate/limit functions)
To solve this, we find the set of courses that have *fewer* credits than some other course, and subtract that set from the set of all courses [04.Query Languages 5.pdf, 04.Query Languages 6.pdf]:

```sql
SELECT C.CourseID, C.CourseName
FROM COURSE C
WHERE C.Credits NOT IN (
    -- Find all credits that are strictly smaller than some other credit in the database
    SELECT C1.Credits
    FROM COURSE C1, COURSE C2
    WHERE C1.Credits < C2.Credits
);
```

*Alternative using ALL:*
```sql
SELECT CourseID, CourseName
FROM COURSE
WHERE Credits >= ALL (
    SELECT Credits FROM COURSE
);
```
*(This is pure, standard SQL that handles ties correctly and satisfies all negative constraints).*

#### Common Mistakes to Avoid:
*   *Using MAX/LIMIT:* The prompt explicitly banned aggregate functions and LIMIT clauses.
*   *Incorrectly handling NULLs:* In the first approach, if `Credits` can be NULL, `NOT IN` will return empty. We assume `Credits` is non-null as per database constraints.

---

## SOLUTION TO QUESTION 3: INTEGRITY CONSTRAINTS & DATABASE CODE

### [Q3.1] Formal Constraint & Table of Influence
**1. Relational Calculus Expression (TRC):**
$$\neg \exists s \in STUDENT \, \exists e \in ENROLL \, \exists c \in COURSE \, (s[StudentID] = e[StudentID] \wedge e[CourseID] = c[CourseID] \wedge s[GPA] < 2.0 \wedge c[DeptName] = 'Computer Science')$$

**2. Table of Influence (Bảng ảnh hưởng) [05.Integrity Constraints.pdf]:**
The business rule affects both the `STUDENT` table and the `ENROLL` table. The `COURSE` table is read-only for checking, but if updated, can also cause violations.

| Relation | Insert | Delete | Update |
| :--- | :---: | :---: | :--- |
| **STUDENT** | $-$ | $-$ | $+ \text{ (GPA)}$ |
| **ENROLL** | $+$ | $-$ | $+ \text{ (StudentID, CourseID)}$ |
| **COURSE** | $-$ | $-$ | $+ \text{ (DeptName)}$ |

*Explanation of signs:*
*   `+`: Danger of violation. E.g., inserting a new `ENROLL` record or updating a student's `GPA` downwards might violate the constraint.
*   `-`: No danger of violation. E.g., deleting a student or an enrollment cannot cause a low-GPA student to be newly enrolled.
*   `*(attributes)`: Violation is only possible if the specified attributes are updated.

---

### [Q3.2] T-SQL AFTER TRIGGER Implementation
Since the constraint spans multiple tables (`STUDENT` and `ENROLL`), a simple `CHECK` constraint is **not sufficient** because SQL Server `CHECK` constraints cannot contain subqueries/joins on other tables. We must use an **AFTER TRIGGER** [05.Integrity Constraints.pdf, Review Final from Voice-To-Text.md].

The trigger should reside on **ENROLL** (for insert/update) and **STUDENT** (for update on GPA). Here is the implementation on `ENROLL`:

```sql
CREATE TRIGGER trg_CheckCSEnrollment
ON ENROLL
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Check if any newly inserted/updated enrollment violates the rule
    IF EXISTS (
        SELECT 1
        FROM inserted i
        JOIN STUDENT s ON i.StudentID = s.StudentID
        JOIN COURSE c ON i.CourseID = c.CourseID
        WHERE s.GPA < 2.0 
          AND c.DeptName = 'Computer Science'
    )
    BEGIN
        RAISERROR ('Violation of Business Rule: Students with GPA < 2.0 are not allowed to enroll in Computer Science courses.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END
END;
GO
```

*(Note: In a production database, you would also need a trigger on `STUDENT` for `AFTER UPDATE OF GPA` to prevent a student's GPA from being modified to `< 2.0` while they are currently enrolled in a CS course).*

---

## SOLUTION TO QUESTION 4: TRANSACTION SCHEDULES, SERIALIZABILITY & LOCKING

### [Q4.1] Conflict Analysis & Precedence Graph
Let's analyze the schedule $S$ chronologically:
$$S: r_1(A); r_2(B); w_1(A); r_3(C); w_2(B); r_2(A); w_3(C); w_2(A); \text{commit}_1; \text{commit}_3; \text{commit}_2;$$

1.  **Conflicting Operations [06.Concurrency Control.pdf]:**
    *   On item $A$:
        *   $r_1(A)$ conflicts with $w_2(A)$ (Read-Write conflict) $\Rightarrow T_1 
\rightarrow T_2$
        *   $w_1(A)$ conflicts with $r_2(A)$ (Write-Read conflict) $\Rightarrow T_1 
\rightarrow T_2$
        *   $w_1(A)$ conflicts with $w_2(A)$ (Write-Write conflict) $\Rightarrow T_1 
\rightarrow T_2$
    *   On item $B$:
        *   $r_2(B)$ conflicts with $w_2(B)$ (No conflict since both belong to $T_2$).
    *   On item $C$:
        *   $r_3(C)$ conflicts with $w_3(C)$ (No conflict since both belong to $T_3$).

2.  **Precedence Graph:**
    *   Nodes: $\{T_1, T_2, T_3\}$
    *   Directed Edges: There is only one unique direction of conflict: $T_1 
\rightarrow T_2$ (due to operations on item $A$).
    *   There are no conflict edges involving $T_3$, as $T_3$ only operates on $C$ and no other transaction accesses $C$.

3.  **Conflict-Serializability:**
    *   Since there are **no cycles** in the Precedence Graph, the schedule $S$ is **conflict-serializable**.
    *   **Equivalent Serial Schedules:** Any topological sort of the graph is an equivalent serial schedule.
        *   $T_1 
\rightarrow T_2$ must be preserved. $T_3$ can be placed anywhere.
        *   Thus, the equivalent serial schedules are:
            1.  $T_1 
\rightarrow T_2 
\rightarrow T_3$
            2.  $T_1 
\rightarrow T_3 
\rightarrow T_2$
            3.  $T_3 
\rightarrow T_1 
\rightarrow T_2$

---

### [Q4.2] Recoverability, Cascadeless, and Strictness Analysis
*   **1. Is $S$ Recoverable?**
    *   *Definition:* A schedule is recoverable if, whenever $T_j$ reads a value written by $T_i$ ($T_i \Rightarrow_S T_j$), then $T_i$ commits before $T_j$ commits ($C_i <_S C_j$).
    *   *Analysis:* $T_2$ performs $r_2(A)$ after $T_1$ performs $w_1(A)$. Thus, $T_2$ reads uncommitted data written by $T_1$ ($T_1 \Rightarrow_S T_2$).
    *   For the schedule to be recoverable, $T_1$ must commit before $T_2$ commits ($C_1 <_S C_2$).
    *   In $S$, $\text{commit}_1$ occurs at step 9, and $\text{commit}_2$ occurs at step 11. Since $C_1 <_S C_2$ holds, **the schedule is Recoverable**.

*   **2. Is $S$ Cascadeless (Avoids Cascading Rollback)?**
    *   *Definition:* A schedule is cascadeless if transactions only read values written by *already committed* transactions.
    *   *Analysis:* $T_2$ performs $r_2(A)$ at step 6, but $T_1$ (which wrote $A$ at step 3) does not commit until step 9. Since $T_2$ read uncommitted data, if $T_1$ aborted, $T_2$ would have to be rolled back.
    *   Therefore, **S is NOT Cascadeless**.

*   **3. Is $S$ Strict?**
    *   *Definition:* A schedule is strict if no transaction can read or write an item $X$ until the transaction that previously wrote $X$ has committed or aborted.
    *   *Analysis:* $T_2$ writes $w_2(A)$ at step 8 while $T_1$ (which wrote $w_1(A)$ at step 3) has not yet committed.
    *   Therefore, **S is NOT Strict**.

---

### [Q4.3] Two-Phase Locking (2PL) Execution & Deadlock
Let's trace schedule $S$ using Exclusive locks [07.Locking.pdf, Locking, Tree Protocol and Recoverablity]:

1.  $T_1$ requests lock on $A$: $l_1(A)$ (granted) $
\rightarrow r_1(A)$
2.  $T_2$ requests lock on $B$: $l_2(B)$ (granted) $
\rightarrow r_2(B)$
3.  $T_1$ writes $A$: $w_1(A)$ (already holds lock on $A$)
4.  $T_3$ requests lock on $C$: $l_3(C)$ (granted) $
\rightarrow r_3(C)$
5.  $T_2$ writes $B$: $w_2(B)$ (already holds lock on $B$)
6.  $T_2$ requests lock on $A$ to perform $r_2(A)$:
    *   $T_1$ holds the lock on $A$.
    *   **$T_2$ is forced to WAIT** for $T_1$.
7.  $T_3$ writes $C$: $w_3(C)$ (already holds lock on $C$)
8.  $T_3$ commits and releases lock on $C$: $u_3(C)$
9.  $T_1$ wants to commit. Since it is standard 2PL, it can commit and release its locks:
    *   $T_1$ commits $
\rightarrow u_1(A)$.
10. Now that $A$ is unlocked, $T_2$'s pending lock request $l_2(A)$ is granted:
    *   $T_2$ acquires lock on $A 
\rightarrow r_2(A) 
\rightarrow w_2(A)$.
11. $T_2$ commits and releases locks: $u_2(B), u_2(A)$.

**Conclusion:** Under standard 2PL, the transactions execute **without any deadlock**. The Wait-For Graph at step 6 contains only a single directed edge $T_2 
\rightarrow T_1$, which is resolved when $T_1$ commits.

---

### [Q4.4] Wait-Die vs. Wound-Wait Concurrency Schemes
Wait-Die and Wound-Wait use transaction timestamps ($TS$) to prevent deadlocks [06.Concurrency Control.pdf]:
Assume $TS(T_{old}) < TS(T_{young})$.

| Scenario | Wait-Die (Non-preemptive) | Wound-Wait (Preemptive) |
| :--- | :--- | :--- |
| **$T_{old}$ requests lock held by $T_{young}$** | **Wait:** $T_{old}$ is allowed to wait for the lock. | **Wound:** $T_{old}$ "wounds" (aborts) $T_{young}$, forcing it to rollback and release the lock. |
| **$T_{young}$ requests lock held by $T_{old}$** | **Die:** $T_{young}$ immediately dies (rolls back/restarts). | **Wait:** $T_{young}$ is allowed to wait for the lock. |

*Crucial Distinction:* Wait-Die always rolls back younger transactions requesting locks held by older ones. Wound-Wait preempts (aborts) younger transactions when older ones request their locks. Both are guaranteed to be deadlock-free because lock waiting is only allowed in one direction of age.

---

## SOLUTION TO QUESTION 5: CONCURRENCY CONTROL & ISOLATION LEVELS

### [Q5.1] Interleaved Execution Analysis
1.  **Trace of values:**
    *   Initial: `Stock = 5`
    *   $t_1$: $T_1$ reads `Stock` $
\rightarrow R_1(5)$.
    *   $t_2$: $T_2$ reads `Stock` $
\rightarrow R_2(5)$.
    *   $t_3$: $T_1$ calculates $5 - 2 = 3$ and writes `Stock = 3`.
    *   $t_4$: $T_2$ calculates $5 - 1 = 4$ and writes `Stock = 4`.
    *   $t_5$: $T_1$ commits (Stock = 3 in its local/uncommitted write, but overwritten by $T_2$'s write).
    *   $t_6$: $T_2$ commits (overwriting $T_1$'s update with the value **`Stock = 4`**).

2.  **Anomaly Identification:**
    *   This anomaly is a **Lost Update (Ghi đè/Mất dữ liệu cập nhật)**.
    *   *Definition:* Occurs when two transactions read the same initial state, modify it, and write it back. The second transaction overwrites the updates of the first transaction without incorporating them, causing the first transaction's update to be lost.

---

### [Q5.2] Resolution Under SQL Isolation Levels
1.  **Under Read Committed [06.Concurrency Control.pdf]:**
    *   *Mechanism:* Read Committed prevents Dirty Reads by using short-term shared locks for reading and long-term exclusive locks for writing.
    *   *Execution:*
        *   $t_1$: $T_1$ reads `Stock` (acquires and immediately releases shared lock) $
\rightarrow$ reads $5$.
        *   $t_2$: $T_2$ reads `Stock` (acquires and immediately releases shared lock) $
\rightarrow$ reads $5$.
        *   $t_3$: $T_1$ attempts to update `Stock`. It requests an exclusive lock on the row. Lock is **granted**. $T_1$ writes `Stock = 3`.
        *   $t_4$: $T_2$ attempts to update `Stock`. It requests an exclusive lock on the row. Since $T_1$ holds the exclusive lock, **$T_2$ is blocked and must wait**.
        *   $t_5$: $T_1$ commits and releases its exclusive lock.
        *   $t_6$: $T_2$ is unblocked, acquires the exclusive lock. In standard Read Committed, when unblocked, $T_2$ re-reads the row (now seeing `Stock = 3`). It then performs `3 - 1 = 2` and writes **`Stock = 2`**.
        *   **Outcome:** Correct execution, final stock is `2`. The Lost Update is prevented.

2.  **Under Repeatable Read (with standard locking) [Review Final from Voice-To-Text.md]:**
    *   *Mechanism:* Repeatable Read holds shared locks until the end of the transaction (Commit/Abort).
    *   *Execution:*
        *   $t_1$: $T_1$ reads `Stock` and acquires a **long-term shared lock** on the row.
        *   $t_2$: $T_2$ reads `Stock` and acquires another **long-term shared lock** on the row (shared locks are compatible).
        *   $t_3$: $T_1$ attempts to update `Stock`. It requests to upgrade its shared lock to an exclusive lock.
            *   Since $T_2$ still holds a shared lock on the row, **$T_1$ must wait**.
        *   $t_4$: $T_2$ attempts to update `Stock`. It requests to upgrade its shared lock to an exclusive lock.
            *   Since $T_1$ still holds a shared lock on the row, **$T_2$ must wait**.
        *   **Outcome:** Both transactions are waiting for each other to release their shared locks. A **Deadlock** occurs immediately. The DBMS deadlock detector will choose one (e.g., $T_2$) to abort/rollback, allowing the other ($T_1$) to successfully complete.

---

## SOLUTION TO QUESTION 6: DATABASE RECOVERY

### [Q6.1] Undo-Only Recovery Logging
Following the strict rules of Undo-only recovery [08.Recovery.pdf, Database Recovery: A Comprehensive Overview]:

1.  **Transaction Classification:**
    *   **Completed Transactions:** $\{T_1, T_3\}$ (since `<Commit T1>` and `<Commit T3>` exist in the log).
    *   **Active Transactions:** $\{T_2, T_4\}$ (no commit records found).

2.  **Backward Scan Range:**
    *   The recovery scan begins from the end of the log and proceeds backward.
    *   It must scan back to the **earliest active transaction** at the time of the checkpoint or thereafter.
    *   At the record `[6] <Checkpoint [T2]>`, $T_2$ was active.
    *   The earliest active transaction is $T_2$ (which started at line `[3]`).
    *   Therefore, the scan must go all the way back to the start of $T_2$, which is **line [3] `<Start T2>`**.

3.  **Undo Sequence & Value Restoration:**
    *   Undo operations are processed **backwards** from the crash point:
        1.  `[12] <T2, B, 300, 500>`: Restore `B = 300` (since $T_2$ is active).
        2.  `[10] <T4, D, 80, 20>`: Restore `D = 80` (since $T_4$ is active).
        3.  `[8] <T3, C, 15, 45>`: Skip (since $T_3$ is committed).
        4.  `[4] <T2, B, 200, 300>`: Restore `B = 200`.
        5.  `[2] <T1, A, 50, 100>`: Skip (since $T_1$ is committed).
    *   *Final restored states:* `B = 200`, `D = 80`.

---

### [Q6.2] Undo/Redo Recovery Logging
Under Undo/Redo logging [08.Recovery.pdf]:

1.  **List Classification:**
    *   **Undo-List:** $\{T_2, T_4\}$ (active/incomplete transactions).
    *   **Redo-List:** $\{T_1, T_3\}$ (committed/complete transactions).

2.  **Phase 1: Redo Phase (Forward Pass)**
    *   Scan forward from the earliest start log record of any transaction active at the checkpoint. The checkpoint is at line `[6] <Checkpoint [T2]>`, so the earliest active is $T_2$ (started at line `[3]`).
    *   We scan forward from line `[3]` and re-apply all modifications for transactions in the Redo-List:
        *   `[8] <T3, C, 15, 45>`: Redo $
\rightarrow$ Write `C = 45`.
        *   (Note: `[2] <T1, A, 50, 100>` is skipped if we only scan from checkpoint, but traditionally, if $T_1$ committed before the checkpoint and its pages were already flushed to disk, we don't need to redo it. Under a non-quiescent checkpoint, we assume $T_1$ is already persistent. If not, we redo $T_1$ as well).

3.  **Phase 2: Undo Phase (Backward Pass)**
    *   Scan backward from the end of the log, reversing modifications for transactions in the Undo-List:
        *   `[12] <T2, B, 300, 500>`: Undo $T_2 
\rightarrow$ Restore `B = 300`.
        *   `[10] <T4, D, 80, 20>`: Undo $T_4 
\rightarrow$ Restore `D = 80`.
        *   `[4] <T2, B, 200, 300>`: Undo $T_2 
\rightarrow$ Restore `B = 200`.

---

## SOLUTION TO QUESTION 7: FUNCTIONAL DEPENDENCIES & NORMALIZATION

### [Q7.1] Closures & Candidate Keys
Given $F = \{ A 
\rightarrow BC, \quad CD 
\rightarrow E, \quad B 
\rightarrow D, \quad E 
\rightarrow A \}$.

**1. Attribute Closures [09.FD and NF.pdf]:**
*   **To find $(AB)^+$:**
    *   Initialize: $(AB)^+ = \{A, B\}$
    *   Using $A 
\rightarrow BC$: add $C \Rightarrow (AB)^+ = \{A, B, C\}$
    *   Using $B 
\rightarrow D$: add $D \Rightarrow (AB)^+ = \{A, B, C, D\}$
    *   Using $CD 
\rightarrow E$: add $E \Rightarrow (AB)^+ = \{A, B, C, D, E\}$
    *   Since $G$ is not functionally determined by any FD, we stop.
    *   **$(AB)^+ = \{A, B, C, D, E\}$**

*   **To find $(CE)^+$:**
    *   Initialize: $(CE)^+ = \{C, E\}$
    *   Using $E 
\rightarrow A$: add $A \Rightarrow (CE)^+ = \{A, C, E\}$
    *   Using $A 
\rightarrow BC$: add $B, C \Rightarrow (CE)^+ = \{A, B, C, E\}$
    *   Using $B 
\rightarrow D$: add $D \Rightarrow (CE)^+ = \{A, B, C, D, E\}$
    *   Using $CD 
\rightarrow E$: (already contains $E$).
    *   **$(CE)^+ = \{A, B, C, D, E\}$**

**2. All Candidate Keys:**
*   First, notice that attribute $G$ never appears on the right-hand side (RHS) of any FD in $F$. This means $G$ must be part of every candidate key.
*   Let's test combinations with $G$:
    *   Does $(AG)^+ = R$?
        *   $A^+ = \{A, B, C, D, E\}$ (from above steps).
        *   Thus, $(AG)^+ = \{A, B, C, D, E, G\} = R$.
        *   Since no proper subset of $\{A, G\}$ is a superkey (G alone cannot determine anything), **$\{A, G\}$ is a Candidate Key**.
    *   Does $(EG)^+ = R$?
        *   Since $E 
\rightarrow A$, then $(EG)^+ = (AG)^+ = R$.
        *   Thus, **$\{E, G\}$ is a Candidate Key**.
    *   Does $(CEG)^+ = R$? Yes, but it is not minimal because $\{E,G\}$ is a subset.
    *   Does $(BG)^+ = R$?
        *   $(BG)^+ = \{B, D, G\} 
\neq R$. Not a key.
    *   Does $(CG)^+ = R$?
        *   $(CG)^+ = \{C, G\} 
\neq R$. Not a key.
    *   Does $(BCG)^+ = R$?
        *   $(BCG)^+ = \{B, C, D, G\}$ (using $B 
\rightarrow D$).
        *   Using $CD 
\rightarrow E$: add $E \Rightarrow \{B, C, D, E, G\}$.
        *   Using $E 
\rightarrow A$: add $A \Rightarrow \{A, B, C, D, E, G\} = R$.
        *   Is $\{B, C, G\}$ minimal? Yes, because $(BC)^+ 
\neq R$, $(BG)^+ 
\neq R$, and $(CG)^+ 
\neq R$.
        *   Thus, **$\{B, C, G\}$ is a Candidate Key**.

*   **Candidate Keys:** $\{A, G\}$, $\{E, G\}$, and $\{B, C, G\}$.
*   **Prime Attributes** (attributes belonging to at least one candidate key): $\{A, B, C, E, G\}$.
*   **Non-Prime Attributes:** $\{D\}$.

---

### [Q7.2] Normal Forms & BCNF Decomposition
**1. Highest Normal Form:**
*   **Is it in 2NF?** Yes. 2NF states that non-prime attributes must be fully functionally dependent on any key. The only non-prime attribute is $D$. The FDs determining $D$ are $A 
\rightarrow BC 
\rightarrow D$ and $B 
\rightarrow D$. Since $D$ is not partially dependent on the candidate keys $\{A, G\}$ or $\{E, G\}$ (it requires the full key including G, wait, actually $A 
\rightarrow D$, which means $D$ depends on a proper subset of $\{A, G\}$. This is a partial dependency!
    *   Let's check: Key is $\{A, G\}$. We have $A 
\rightarrow D$. Since $D$ is a non-prime attribute and depends on $A$ (a proper subset of the key $\{A,G\}$), this is a **partial dependency**.
    *   Therefore, $R$ is **NOT in 2NF**.
*   **Highest Normal Form is 1NF**.

**2. BCNF Decomposition:**
BCNF requires that for every non-trivial FD $X 
\rightarrow Y$, $X$ must be a superkey.
*   Let's decompose $R(A, B, C, D, E, G)$ using the violating FD $A 
\rightarrow BC$ (since $A$ is not a superkey of $R$):
    *   $R_1(A, B, C)$ with $F_1 = \{A 
\rightarrow BC\}$ (now in BCNF, key is $A$).
    *   $R_2(A, D, E, G)$ with remaining attributes.
*   In $R_2$, the FD $E 
\rightarrow A$ violates BCNF (E is not a superkey of $R_2$). Decompose $R_2$:
    *   $R_3(E, A)$ with key $E$.
    *   $R_4(E, D, G)$ with remaining attributes.
*   In $R_4$, we have no non-trivial FDs because $D$ was determined by $B$ and $E$ determined $A$.
*   Wait, another FD is $B 
\rightarrow D$. Since $B$ is in $R_1$ and $D$ is in $R_4$, this is not preserved. Let's do an alternative BCNF decomposition:
    *   Decompose by $B 
\rightarrow D$:
        *   $R_1(B, D)$ (Key is $B$, BCNF).
        *   $R_2(A, B, C, E, G)$ (Remaining).
    *   In $R_2$, $A 
\rightarrow BC$ violates BCNF. Decompose:
        *   $R_3(A, B, C)$ (Key is $A$, BCNF).
        *   $R_4(A, E, G)$ (Remaining).
    *   In $R_4$, $E 
\rightarrow A$ violates BCNF. Decompose:
        *   $R_5(E, A)$ (Key is $E$, BCNF).
        *   $R_6(E, G)$ (Key is $EG$, BCNF).

**Final BCNF Relations:** $R_1(B, D)$, $R_3(A, B, C)$, $R_5(E, A)$, and $R_6(E, G)$.

**3. Tableau Proof of Lossless Join [09.FD and NF.pdf]:**
Let's construct the initial matrix for $R_1, R_3, R_5, R_6$ over attributes $A, B, C, D, E, G$:

| Relation | A | B | C | D | E | G |
| :--- | :---: | :---: | :---: | :---: | :---: | :---: |
| $R_1(B, D)$ | $b_{11}$ | $a_2$ | $b_{13}$ | $a_4$ | $b_{15}$ | $b_{16}$ |
| $R_3(A, B, C)$ | $a_1$ | $a_2$ | $a_3$ | $b_{24}$ | $b_{25}$ | $b_{26}$ |
| $R_5(E, A)$ | $a_1$ | $b_{32}$ | $b_{33}$ | $b_{34}$ | $a_5$ | $b_{36}$ |
| $R_6(E, G)$ | $b_{41}$ | $b_{42}$ | $b_{43}$ | $b_{44}$ | $a_5$ | $a_6$ |

Applying FDs to equate symbols:
1.  **Using $E 
\rightarrow A$ on rows 3 & 4 (both have $a_5$ in E):** Equate $A$ values. Since row 3 has $a_1$, we change $b_{41}$ in row 4 to $a_1$.
2.  **Using $A 
\rightarrow BC$ on rows 2, 3 & 4 (all have $a_1$ in A):** Equate $B$ and $C$ values to $a_2$ and $a_3$.
    *   Row 3: $b_{32} 
\rightarrow a_2$, $b_{33} 
\rightarrow a_3$.
    *   Row 4: $b_{42} 
\rightarrow a_2$, $b_{43} 
\rightarrow a_3$.
3.  **Using $B 
\rightarrow D$ on rows 1, 2, 3 & 4 (all now have $a_2$ in B):** Equate $D$ values to $a_4$ (from row 1).
    *   Row 2: $b_{24} 
\rightarrow a_4$.
    *   Row 3: $b_{34} 
\rightarrow a_4$.
    *   Row 4: $b_{44} 
\rightarrow a_4$.

The updated row 4 ($R_6$) now contains: $a_1, a_2, a_3, a_4, a_5, a_6$.
Since **row 4 consists entirely of $a$ symbols**, the decomposition is **Lossless**.

---

## SOLUTION TO QUESTION 8: QUERY OPTIMIZATION & COST ESTIMATION

### [Q8.1] BNLJ and INLJ Cost Calculation
Given:
*   $P(\text{BOOK}) = 1,000$ pages, $T(\text{BOOK}) = 20,000$ tuples.
*   $P(\text{PUBLISHER}) = 500$ pages, $T(\text{PUBLISHER}) = 10,000$ tuples.
*   $B = 50$ memory pages available for partitioning/buffering [11.Query Optimization.pdf, Database Query Optimization Guide].
*   $OUT = 400$ pages.

**1. Block Nested Loop Join (BNLJ):**
The cost formula is:
$$\text{Cost} = P(\text{outer}) + \left( \lceil \frac{P(\text{outer})}{B-1} \rceil \times P(\text{inner}) \right) + OUT$$

*   **Option A: BOOK as outer, PUBLISHER as inner:**
    *   $\text{Outer blocks} = \lceil \frac{1000}{50-1} \rceil = \lceil \frac{1000}{49} \rceil = 21$ blocks.
    *   $\text{Cost} = 1000 + (21 \times 500) + 400 = 1000 + 10500 + 400 = \mathbf{11,900 \text{ I/Os}}$.

*   **Option B: PUBLISHER as outer, BOOK as inner:**
    *   $\text{Outer blocks} = \lceil \frac{500}{49} \rceil = 11$ blocks.
    *   $\text{Cost} = 500 + (11 \times 1000) + 400 = 500 + 11000 + 400 = \mathbf{11,900 \text{ I/Os}}$.

**2. Index Nested Loop Join (INLJ):**
The cost formula with BOOK as outer and PUBLISHER as inner is:
$$\text{Cost} = P(\text{BOOK}) + T(\text{BOOK}) \times (\text{Index Access Cost } L) + OUT$$
*   For each of the $20,000$ tuples in `BOOK`, we perform an index lookup on `PUBLISHER`.
*   The index lookup cost $L$ = B+ Tree height ($HT = 3$) + 1 I/O for the data page = $4$ I/Os.
*   $\text{Cost} = 1,000 + 20,000 \times 4 + 400 = 1,000 + 80,000 + 400 = \mathbf{81,400 \text{ I/Os}}$.

---

### [Q8.2] SMJ and HPJ Cost Calculation
**1. Sort-Merge Join (SMJ):**
*   **Step 1: Check if 2-pass merge is possible:**
    *   We can sort each relation in 2 passes if $P \le B(B-1)$.
    *   For BOOK: $1000 \le 50 \times 49 = 2450$ (True).
    *   For PUBLISHER: $500 \le 2450$ (True).
    *   Thus, we can sort both in $k = 2$ passes.
*   **Step 2: Cost of Sorting Phase:**
    *   $\text{Sort BOOK} = 2 \times P(\text{BOOK}) \times k = 2 \times 1000 \times 2 = 4000$ I/Os.
    *   $\text{Sort PUBLISHER} = 2 \times P(\text{PUBLISHER}) \times k = 2 \times 500 \times 2 = 2000$ I/Os.
*   **Step 3: Cost of Merge-Join Phase:**
    *   Since we assume no duplicate-induced back-ups, the merge-join pass reads both sorted relations once:
    *   $\text{Merge Cost} = P(\text{BOOK}) + P(\text{PUBLISHER}) = 1000 + 500 = 1500$ I/Os.
*   **Total SMJ Cost:**
    *   $\text{Total} = \text{Sort BOOK} + \text{Sort PUBLISHER} + \text{Merge} + OUT$
    *   $\text{Total} = 4000 + 2000 + 1500 + 400 = \mathbf{7,900 \text{ I/Os}}$.

**2. Hash Partition Join (HPJ):**
Under optimal conditions with sufficient memory [11.Query Optimization.pdf]:
$$\text{Cost} \approx 3 \times [P(\text{BOOK}) + P(\text{PUBLISHER})] + OUT$$
*   **Partition Phase:** Read and write both relations: $2 \times [1000 + 500] = 3000$ I/Os.
*   **Join Phase:** Read each partition once: $1000 + 500 = 1500$ I/Os.
*   **Total HPJ Cost:**
    *   $\text{Total} = 3000 + 1500 + 400 = \mathbf{4,900 \text{ I/Os}}$.

---

### Summary of Physical Plan Comparison:
*   **HPJ:** 4,900 I/Os
*   **SMJ:** 7,900 I/Os
*   **BNLJ:** 11,900 I/Os
*   **INLJ:** 81,400 I/Os

**Recommendation:** The Query Optimizer should select **Hash Partition Join (HPJ)** as the optimal plan, as it incurs the absolute lowest I/O cost ($4,900$ pages).
