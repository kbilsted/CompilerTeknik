echo "convert rapport.dvi to rapport.pdf"

rem convert to pdf - requires gswin32 to be in path
dvips -Ppdf rapport
d:\progra~1\Ghostgum\gsview\gsview32.exe -q -dNOPAUSE -dBATCH -sDEVICE=pdfwrite -sOutputFile=rapport.pdf -c save pop -f rapport.ps
