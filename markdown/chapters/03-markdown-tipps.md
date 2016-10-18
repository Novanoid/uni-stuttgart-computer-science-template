# Markdown-Tipps

## Allgemein

### Überschriften {-}
Alle Überschriften der ersten Ebene (ein einzelnes vorangestelltes `#`, oder mit `===` unterstrichen) werden als `\chapter` behandelt.
Überschriften mit mehr als einem vorangestellten `#`, oder die mit `---` unterstrichen sind, werden als `\section`, `\subsection`, etc. interpretiert.

Alle Kapitel und Sektionen werden standardmäßig nummeriert, dies kann durch ein nachgestelltes `{.unnumbered}` oder kurz `{-}` unterbunden werden.

### Referenzen zu Kapiteln und Sektionen {-}
Referenzen lassen sich ganz einfach durch `[Ueberschrift der Sektion]`, bzw \linebreak`[Text][ueberschrift-der-sektion]` einbinden: **[Allgemein]**

Dies fügt automatisch `\label`s für die entsprechende Sektion ein, sodass im gerenderten PDF-Dokument auch auf die Referenz geklickt werden kann und die Ansicht automatisch zu der entsprechenden Sektion springt.

Für lange Überschriften kann es sich anbieten, eigene Labels zu definieren. Das geht, indem man nach der entsprechenden Überschrift ein `{#label}` anhängt.

---

```python
def fib(n):
	'''This is a method documentation string.'''
	a, b = 0, 1
	while a < n:
		# This is an inline comment.
		print(a, end=' ')
		a, b = b, a + b
	print()
```
