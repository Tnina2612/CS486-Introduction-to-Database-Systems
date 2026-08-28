# Locking protocols, transaction recovery, and deadlock management.

## 1. Core Issues in Concurrency Control

When multiple transactions execute simultaneously without proper isolation, several classic data anomalies can occur:

* **Lost Update:** Occurs when two concurrent transactions read the same data and subsequently update it; the second transaction blindly overwrites the first transaction's update, causing the first change to be lost.
* **Unrepeatable Read:** Occurs when a transaction reads the same database element twice during its execution but retrieves different values because another transaction modified the element in between the two reads.
* **Phantom:** Occurs when a transaction performs an aggregate calculation (like a sum of account balances), but a second transaction concurrently alters the underlying data components, resulting in an invalid or "phantom" aggregated result.
* **Dirty Read:** Occurs when a transaction reads data that has been modified by another uncommitted transaction that subsequently aborts, meaning the first transaction relies on data that technically never existed in the confirmed database.

## 2. Locking Protocols and Two-Phase Locking (2PL)

To prevent these anomalies and guarantee conflict-serializability, schedulers utilize lock protocols. Transactions must request a lock (`Lock(X)`) before operating on a database element and release it (`Unlock(X)`) afterward.

### Two-Phase Locking (2PL)

The 2PL protocol dictates that a transaction must execute its locks in two distinct phases:

1. **Phase 1 - Growing:** The transaction requests and acquires locks but is absolutely prohibited from releasing any locks.
2. **Phase 2 - Shrinking:** Once the transaction releases its first lock, it enters the shrinking phase and can no longer acquire any new locks.

*Theorem:* If a schedule satisfies transaction consistency, legal lock mechanics, and strictly adheres to Two-Phase Locking, it is mathematically guaranteed to be conflict-serializable.

## 3. Lock Modes

To increase concurrency, schedulers utilize different lock modes rather than forcing exclusive access for every operation.

* **Shared Lock (`RLock`):** Required to read an element. Multiple transactions can hold shared locks on the same element simultaneously.
* **Exclusive Lock (`WLock`):** Required to write an element. If granted, no other transaction can hold any lock on that element.
* **Update Lock (`ULock`):** Solves a specific deadlock scenario that occurs when two transactions hold a Shared Lock and both attempt to upgrade to an Exclusive Lock simultaneously. An Update Lock grants read privileges but acts as an "intent to write." Only one transaction can hold an Update Lock, which it later seamlessly upgrades to an Exclusive Lock without causing a deadlock.

Compatibility matrix:

| **Lock held in mode \ Lock requested** | **Share** | **eXclusive** | **Update** |
|-----------------------|:---------:|:-------------:|:----------:|
| **Share**             | yes       | no            | yes        |
| **eXclusive**         | no        | no            | no         |
| **Update**            | no        | no            | no         |

## 4. Multiple Granularity and Tree Protocols

Databases manage locks at different hierarchical granularities: **Relations $\rightarrow$ Blocks $\rightarrow$ Tuples**.

* Locking smaller units (tuples) yields more concurrency but increases the scheduler's tracking overhead.
* To safely navigate this hierarchy, databases use **Intention Locks** (e.g., `IS`, `IX`, `SIX`). These act as "warning signs." A transaction must lock a parent node with an intention lock before it is allowed to place a lock on a child node.

Compatibility matrix:

| **Lock held in mode \ Lock requested** | **IS** | **IX** | **S** | **SIX** | **X** |
|----------------------------------------|:------:|:------:|:-----:|:-------:|:-----:|
| **IS**                                 | yes    | yes    | yes   | yes     | no    |
| **IX**                                 | yes    | yes    | no    | no      | no    |
| **S**                                  | yes    | no     | yes   | no      | no    |
| **SIX**                                | yes    | no     | no    | no      | no    |
| **X**                                  | no     | no     | no    | no      | no    |

Parent-child rule:

| Parent locked in | Child can be locked in by the same transaction |
|------------------|-----------------------------------------------|
| IS               | IS, S                                         |
| IX               | IS, S, IX, X                                  |
| S                | [S, IS not necessary]                         |
| SIX              | X, IX, [SIX not necessary]                    |
| X                | None                                          |

**Rules:**

1. Follow multiple granularity compatibility matrix
2. Lock root of tree first in any mode
3. Node Q can be locked by Ti in S or IS only if parent(Q) locked by Ti in IX or IS
4. Node Q can be locked by Ti in X, SIX, IX only if parent(Q) locked by Ti in IX,SIX
5. Ti is two-phase locking
6. Ti can unlock node Q only if none of Q’s children are locked by Ti

### The Tree Protocol

Typically used for index structures like B-Trees, this protocol prevents deadlocks by enforcing directional locking:

* A transaction traverses the tree like "monkey bars".
* The first lock can be placed on any node. However, any subsequent node can only be locked if its parent node is currently locked by the transaction.
* Nodes can be unlocked at any time, but once unlocked, they cannot be relocked.

## 5. Transaction Recovery and Schedule Strictness

Even if a schedule is serializable, transaction failures can cause widespread issues. Schedulers categorize schedules based on their resilience to failures:

* **Cascading Rollback:** A scenario where transaction A aborts, forcing transaction B (which read A's dirty data) to abort, creating a domino effect.
* **Recoverable Schedule:** A schedule where a transaction only commits *after* all the transactions it has read data from have successfully committed.
* **Avoids Cascading Rollback (ACR):** A stricter schedule where transactions are only permitted to read values that have already been fully committed by the writer.
* **Strict Schedule:** The most rigid model (Strict 2PL), where a transaction holds all of its exclusive write locks until it completely commits or aborts.

> **Hierarchy of Strictness:** Serializable $\supset$ Recoverable $\supset$ Avoids Cascading Rollback $\supset$ Strict $\supset$ Serial.

## 6. Deadlock Prevention and Detection

When transactions are blocked waiting for locks held by each other, a deadlock occurs. Databases employ several strategies to handle them:

* **Wait-For Graph:** The database maintains a graph where nodes are transactions and arcs represent dependencies. If a cycle forms in the graph, a deadlock exists and the system must abort a transaction.
* **Resource Ordering:** Forcing all transactions to request locks in a predetermined alphabetical or numerical order prevents deadlocks, though it is often unrealistic in practice.
* **Timeout:** If a transaction waits for a lock longer than $L$ seconds, the system forcibly rolls it back.
* **Wait-Die:** Older transactions are allowed to wait for younger transactions. However, if a younger transaction requests a lock held by an older one, the younger transaction "dies" (aborts).
* **Wound-Wait:** Older transactions "wound" younger ones by forcing them to abort and yield the lock. Younger transactions are allowed to wait for older ones.

(Both Wait-Die and Wound-Wait use arrival timestamps to determine age and inherently prevent transaction starvation.)

## 7. Advanced Extension: Modern Concurrency Optimizations

While the slides provide the foundational mechanisms of 2PL, modern databases have evolved to mitigate the performance bottlenecks of aggressive locking.

### Multi-Version Concurrency Control (MVCC)

In systems heavily reliant on read/write locks, readers can block writers and vice versa. Modern RDBMS engines (like PostgreSQL and Oracle) utilize MVCC.

* Under MVCC, when a transaction writes a record, it does not immediately overwrite the original data. Instead, it creates a new, timestamped version of the row.
* If a concurrent transaction wants to read the data, the database simply serves the older, committed version of the row.
* **The Result:** Readers never block writers, and writers never block readers, effectively solving the "Unrepeatable Read" anomaly without requiring strict, performance-killing Shared Locks.

### Optimistic Concurrency Control (OCC)

In low-conflict environments, acquiring and managing locks wastes resources. OCC assumes transactions will rarely conflict. Instead of locking data during the transaction, the database allows the transaction to process in a private workspace. Right before committing, the system validates whether another transaction altered the underlying data. If a conflict is detected, the transaction is rolled back and retried; if not, the commit succeeds instantly.