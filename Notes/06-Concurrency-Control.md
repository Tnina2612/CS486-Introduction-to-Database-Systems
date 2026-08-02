# **Concurrency Control and Transactions**

## 1. Introduction to Database Transactions

In multi-user database environments, hundreds of operations may be executed concurrently. Without constraints, overlapping operations can cause critical errors, such as double-booking a single airline seat or losing money during a failed bank transfer.

To solve these problems, databases group operations into **Transactions**.

* A transaction is a collection of operations on the database that must be executed atomically.
* It transforms the database from one valid, consistent state to another valid, consistent state.

### The ACID Properties

To guarantee data integrity, transactions must adhere to four core properties (ACID):

* **Atomicity:** The "all or nothing" principle. Either all operations within the transaction are properly reflected in the database, or none are.
* **Consistency:** The execution of a transaction in isolation preserves the consistency of the database. If the database is consistent before execution, it remains consistent after.
* **Isolation:** Each transaction is completely unaware of other transactions executing concurrently in the system. The concurrent execution behaves as if the transactions were executed one at a time sequentially.
* **Durability:** Once a transaction completes successfully (commits), the changes it made persist permanently, even in the event of system failures.

### Transaction States

During its lifecycle, a transaction transitions through several states:

1. **Active:** The initial state while operations are executing.
2. **Partially Committed:** The state after the final operation has executed but before the final commit is recorded.
3. **Committed:** The transaction has successfully concluded.
4. **Failed:** The normal execution can no longer proceed.
5. **Aborted:** The transaction has been rolled back, and the database has been restored to its state prior to the start of the transaction.

## 2. Concurrency Control & Schedulers

**Concurrency Control** is the process of ensuring that transactions preserve data consistency when executing simultaneously.

* **Why run concurrently?** It maximizes resource utilization (CPU and disk parallel processing), increases throughput, and reduces the waiting time for short transactions that would otherwise be blocked by long-running ones.

To manage this, the Database Management System (DBMS) utilizes a **Scheduler**.

* The scheduler regulates the exact order in which individual read/write actions from different transactions occur.
* It accepts requests and either executes them immediately in memory buffers or delays them to prevent data corruption.

## 3. Schedules and Serializability

A **Schedule** ($S$) is a time-ordered sequence of actions taken by one or more transactions.

* **Serial Schedule:** A schedule where the actions of one transaction are executed completely before the next transaction begins, with absolutely no interleaving. While this perfectly assures consistency, it is far too slow for real-world applications.
* **Serializable Schedule:** A schedule where operations are interleaved (concurrent), but the final effect on the database state is guaranteed to be identical to some serial schedule. This represents the ideal compromise: it maintains consistency while allowing quick, concurrent execution.

## 4. Conflict Serializability

Because schedulers cannot analyze the complex internal application logic of every transaction, they focus strictly on basic **Read ($r$)** and **Write ($w$)** operations.

### Identifying Conflicts

Two operations are considered in **Conflict** if swapping their execution order changes the behavior or outcome of the database. A conflict occurs when:

1. The actions belong to *different* transactions.
2. Both actions involve the *same* database element ($X$).
3. At least one of the actions is a Write ($w$).

* **No Conflict:** $r_i(X)$ and $r_j(X)$ do not conflict because concurrent reads do not alter data. Actions on completely different elements ($X \ne Y$) also never conflict.
* **Conflict Equivalency:** Two schedules, $S$ and $S'$, are conflict-equivalent if one can be transformed into the other simply by swapping adjacent, *non-conflicting* actions.

### The Precedence Graph $P(S)$

To test if a schedule is mathematically safe, the scheduler builds a Precedence Graph.

* **Nodes** represent the transactions ($T_i$).
* An **Arc** (directed edge) is drawn from $T_i$ to $T_j$ if $T_i$ performs a conflicting action before $T_j$ ($T_i <_S T_j$).
* **The Theorem:** If the Precedence Graph $P(S)$ is **acyclic** (contains no circular loops), then schedule $S$ is conflict-serializable. If it contains a cycle, the schedule cannot be serialized via conflict resolution.

**Crucial Distinction:** All conflict-serializable schedules are serializable, but *not all* serializable schedules are conflict-serializable. Sometimes a schedule with a conflict cycle still results in a consistent state due to "blind writes" (writing without reading first), though traditional schedulers will usually reject them anyway for safety.

## 5. Advanced Extension: Modern Concurrency Implementation

While the lecture defines the theoretical mathematics of serializability, modern relational databases implement these theories using specific protocols:

### Two-Phase Locking (2PL)

To guarantee that a schedule's Precedence Graph remains acyclic, most DBMS engines (like SQL Server or PostgreSQL) implement Strict Two-Phase Locking.

* Transactions must acquire a **Shared Lock** before reading and an **Exclusive Lock** before writing.
* Under 2PL, a transaction cannot acquire any new locks once it releases its first lock. This strictly enforces conflict-serializability.

### Multi-Version Concurrency Control (MVCC)

In modern, high-performance systems, relying solely on locks creates bottlenecks. MVCC extends concurrency by keeping multiple timestamped versions of a single row.

* When $T_1$ writes to element $A$, it creates a *new version* of $A$ rather than overwriting it immediately.
* If $T_2$ needs to read $A$ simultaneously, the scheduler simply provides $T_2$ with the older, committed version of $A$.
* This allows **readers to never block writers, and writers to never block readers**, drastically improving throughput while mathematically ensuring the schedule remains completely serializable.