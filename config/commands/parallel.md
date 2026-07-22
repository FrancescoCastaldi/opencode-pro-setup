---
description: Esecuzione parallela di agenti per task complessi
agent: orchestrator
---

Eseguo un workflow parallelo. Suddivido il task in sotto-task indipendenti e li assegno a più agenti contemporaneamente.

Task: $ARGUMENTS

Piano:
1. Analizzo il task e lo scompongo in parti indipendenti
2. Lancio gli agenti in parallelo (usa task tool per ognuno)
3. Raccolgo e sintetizzo i risultati
