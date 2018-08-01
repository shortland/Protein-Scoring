# Protein Scoring

### scraper.pl
Scrapes the webpage http://predictioncenter.org/casp12/targetlist.cgi for a list of proteins and crucial information on them, such as weight, atom count, unique protein chains and more.

### fetch_scores.pl
Creates individual `.xlsx` (excel) files for each gathered protein and the different (scientific) groups that algorithmically theorized what the protein's attributes could be by 3D modeling.

#### Files and Directories

`output.xlsx` contains the overall list of proteins and generalized data gathered for each protein. This file is generated from `scraper.pl`

While the directory `SCORES/` contains more verbose information on each individual protein. This data is generated from `fetch_scores.pl`