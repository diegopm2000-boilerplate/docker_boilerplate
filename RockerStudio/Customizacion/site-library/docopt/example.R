"Usage: prog [options] A
Options:
  -q  Be quiet
  -v  Be verbose." -> doc

library(docopt, quietly = TRUE)
docopt(doc)
