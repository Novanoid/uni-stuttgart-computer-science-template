\cleardoublepage

\iftex4ht
\else
\microtypesetup{protrusion=false}
\fi

\tableofcontents

\listoffigures
\listoftables

\ifdeutsch
\listof{Listing}{Verzeichnis der Listings}
\else
\listof{Listing}{List of Listings}
\fi

\ifdeutsch
\listof{Algorithmus}{Verzeichnis der Algorithmen}
\else
\listof{Algorithmus}{List of Algorithms}
\fi

\printnoidxglossaries

\iftex4ht
\else
\microtypesetup{protrusion=true}
\fi

\renewcommand*{\chapterpagestyle}{scrplain}
\pagestyle{scrheadings}
