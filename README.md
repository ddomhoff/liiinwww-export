# liinwww-export
Simple export tool for The Collection of Computer Science Bibliographies (https://liinwww.ira.uka.de/bibliography/)
Runs search query in database and outputs single file with all BibTex records. If number of results exceeds 1,000 queries are run separately for each publication year to avoid the limitation per query.

## Requirements
Ruby >= 1.9

Nokogiri

## Usage
Command line use only. Supply search string and optionale output file name

Save results to ./csbout.bib
```
./liinwww-export.rb "+search +string" 
```

Save results to ./outfile.bib
```
 ./liinwww-export.rb "+search +string" outfile.bib
```

Conversion to other formats for use with reference managers (e.g. Endnote) can be achivied by using bibutils:
```
cat outfile.bib | bib2xml | xml2end > outfile.enw
```

## License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details
