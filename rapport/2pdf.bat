echo "convert rapport2page.ps to rapport.pdf"

rem convert to pdf - requires gswin32 to be in path
gswin32.exe -q -dNOPAUSE -dBATCH -sDEVICE=pdfwrite -sOutputFile=rapport.pdf -c save pop -f rapport2page.ps
