# **Function Dependency and Normal Forms**

## 1. Relational Database Design Evaluation

The primary goal of relational database design is to store information without unnecessary redundancy and to allow for easy information retrieval. A schema's quality can be evaluated using informal measures and formal Normal Forms.

Informal evaluations measure a schema by how well it handles the following issues:

* **Attribute Semantics:** The meaning of a relation's attributes should be easily explained and possess unambiguous interpretations.


* **Redundant Information:** Bad schema design risks redundant information, making insertion, deletion, and updates difficult.


* **NULL Values:** Too many inapplicable or unknown attributes waste storage space and complicate JOIN, COUNT, or SUM operations.


* **Spurious Tuples:** Performing joins on attributes that are neither primary nor foreign keys can produce invalid, spurious tuples that do not exist in the original relation.

## 2. Functional Dependencies (FD)

A functional dependency (FD) is a constraint expressing a relationship between sets of attributes. If two tuples agree on attributes $A_1, A_2, \dots, A_n$, they must also agree on attributes $B_1, B_2, \dots, B_m$. This unique-value constraint is denoted mathematically as $A_1, A_2, \dots, A_n \rightarrow B_1, B_2, \dots, B_m$.

### Inference Rules (Armstrong's Axioms)

Database designers can infer additional valid dependencies from a stated set of FDs using the following rules:

* **Reflexive:** If $Y \subseteq X$, then $X \rightarrow Y$.
* **Augmentation:** If $X \rightarrow Y$ and $Z$ is a set of attributes, then $X, Z \rightarrow Y, Z$.
* **Transitive:** If $X \rightarrow Y$ and $Y \rightarrow Z$, then $X \rightarrow Z$.
* **Pseudo Transitive:** If $X \rightarrow Y$ and $Y, W \rightarrow Z$, then $X, W \rightarrow Z$.
* **Combining:** If $X \rightarrow Y$ and $X \rightarrow Z$, then $X \rightarrow Y, Z$.
* **Splitting:** If $X \rightarrow Y$ and $Z \subseteq Y$, then $X \rightarrow Z$.

### Closures and Practical Implementations

* **Closure of Attributes:** The closure set, denoted as $\{A_1, A_2, \dots, A_n\}^+$, includes all attributes that can be functionally determined by the initial set.
* **FD Optimization:** To implement constraints efficiently, trivial FDs (where $Y \subseteq X$), incomplete FDs, and excessive FDs should be identified and removed to find a minimal, cost-effective set.

## 3. Keys and Decomposition

Keys define the uniqueness of tuples within a relation.

* **Super Key:** Any set of attributes specifying uniqueness.
* **Key:** A minimal super key, denoted as $K \subseteq R^+$, where no subset of $K$ can functionally determine all attributes in the relation.

When a relation is flawed, it must be decomposed (split) into smaller schemas. A valid decomposition must satisfy two properties:

* **Lossless Join:** Any instance of the original relation must be perfectly recoverable from the decomposed schemas using natural joins, avoiding spurious tuples. The Tableau algorithm is a matrix-based method used to prove this property.
* **Dependency Preservation:** All functional dependencies from the original relation must be preserved to avoid computationally expensive constraint checks across multiple tables.

## 4. Normal Forms (NF)

Normalization is the process of putting a schema through tests to certify its degree of optimization.

| Normal Form | Definition & Requirements |
| --- | --- |
| **1NF** | Disallows "relations within relations" and multivalued attributes; all values must be single, atomic values. |
| **2NF** | Satisfies 1NF and requires that all nonprime attributes are completely functionally dependent on the key (removes partial dependencies). |
| **3NF** | Satisfies 2NF and ensures that no nonprime attributes are transitively dependent on the key. |
| **BCNF (Boyce-Codd)** | Satisfies 3NF and dictates that the left-hand side of any nontrivial functional dependency must be a super key. |
| **4NF** | Eliminates Multivalued Dependencies (MVDs), denoted as $X \twoheadrightarrow Y$, where a set of attributes is independent of others in the relation. |

## 5. Extended Insights: The Normalization Trade-Off

While higher normal forms strictly reduce data redundancy, they inherently slow down data retrieval speeds. Splitting data across many tables in BCNF or 4NF eliminates update anomalies, but reconstructing that data for a user requires the database engine to perform numerous JOIN operations.

As a result, database engineers must routinely compromise between ideal data storage and practical retrieval speed. In real-world enterprise design, this leads to **denormalization**. Engineers will consciously reverse the normalization process—intentionally reintroducing controlled redundancy into tables (such as lowering a schema from 3NF down to 2NF)—to skip costly JOIN operations and ensure fast query execution for end-users.