## Database Recovery

### Introduction to Database Integrity

Maintaining data integrity is a fundamental requirement for any Database Management System (DBMS). To ensure a database remains reliable, it must operate within a consistent state.

* Data integrity relies on the correctness of the data and the consistency of the constraints.
* A consistent database state means that all integrity constraints are fully satisfied.
* Constraints can be violated through transaction bugs, programming bugs within the DBMS, hardware failures, or data sharing issues.
* The primary purpose of recovery operations is to put the database back into the last consistent state it was in before a failure occurred.
* Recovery systems are designed to assure that all transactions maintain atomicity and durability.

### Database Failure Modes

Failures in a database environment are categorized as either wanted or unwanted, and unwanted failures can be foreseen or unforeseen. The table below outlines the primary failure modes and how a DBMS mitigates them.

| Failure Mode | Description | Handling Mechanism |
| --- | --- | --- |
| **Erroneous Data Entry** | Data is evidently in error or mistyped, though some errors are impossible to detect. | The DBMS catches these using key constraints, foreign key constraints, value constraints, and triggers.|
| **Media Failure** | A major failure where an entire disk or its sectors become unreadable or damaged, causing data loss. | Handled by RAID schemes, maintaining redundant copies online across distributed sites, and archiving on tape or optical disks. |
| **Catastrophic Failure** | Complete destruction of media due to extreme events like fires, explosions, or vandalism. | RAID cannot help here; the system must rely on archived and redundant, distributed copies.|
| **Transaction Failure** | A transaction ends unusually due to events like arithmetic overflow or a divide-by-zero error, leading to an aborted transaction.| The DBMS handles this by redoing the transaction.|
| **System Failure** | Power loss or software errors that cause main memory contents to disappear or be overwritten, resulting in lost transaction states.| The DBMS relies on the transaction log to recover the system.|

### Transaction Logs and Checkpoints

The transaction log is a sequential file stored in main memory that records what transactions have done, which is written to disk as soon as possible. If a system crash happens, the log is consulted to reconstruct transaction activity and repair the effects of the crash.

**Key Transaction Log Records:**

* `<start T>` indicates that transaction T has begun.
* `<commit T>` indicates that transaction T completed successfully and will make no more database changes.
* `<abort T>` indicates that transaction T could not complete successfully.
* `<T, X, v>` or `<T, X, v, w>` indicates transaction T changed database element X, with former value v and new value w.

**Checkpointing Mechanisms:**
To prevent the DBMS from having to scan the entire log backward from the end during recovery, checkpoints are written periodically when database changes are moved from main memory to disk.

* **Simple Checkpoint:** The system stops accepting new transactions, waits for currently active ones to commit or abort, flushes the log, writes a `<Checkpoint>` record, flushes again, and then resumes.
* **Nonquiescent Checkpoint:** The system allows new transactions to enter during the checkpoint.
* It writes a `<start ckpt (T1,...,Tn)>` record detailing active transactions and flushes the log.
* It waits for those specific transactions to finish while accepting others, then writes an `<end ckpt>` record and flushes the log.

### Core Recovery Methods

The DBMS utilizes different logging methods to ensure durability and consistency, depending on when data modifications are written to disk.

#### 1. Undo-Logging (Immediate Modification)

In Undo-Logging, the log records only the old value of a modified database element using `<T, X, v>`.

* The log record must be written to disk before the new value is written to the database disk.
* The `<commit T>` record must be written to disk after all database elements changed by the transaction have been written to disk.
* During recovery, incomplete transactions (those without a commit or abort record) are undone by writing the old values back to the disk, and committed transactions are ignored.
* Data must be written to disk immediately after the transaction finishes, which increases the number of required disk I/Os.

#### 2. Redo-Logging (Deferred Modification)

Redo-Logging uses the format `<T, X, v>`, but only records the *new* value of the database element.

* All log records pertaining to a modification, including the `<commit T>` record, must appear on disk before the actual database element is modified on disk.
* During recovery, incomplete transactions are ignored (an abort record is written), while complete transactions are redone by writing their new values to disk.
* Modified blocks are kept in buffers until the transaction commits and logs are flushed, which increases the average number of buffers required by transactions.

#### 3. Undo/Redo Logging

This method combines the previous two, recording both the old and new values in the format `<T, X, v, w>`.

* The update log record must appear on disk before the database element is modified on disk.
* The `<commit T>` record can either precede or follow any changes made to the database elements on disk.
* During recovery, all committed transactions are redone in earliest-first order.
* During recovery, all incomplete transactions are undone in latest-first order.
