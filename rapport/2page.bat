@echo .
@echo "generate 2 page in 1 ps file called 'rapport2page.ps' from 'rapport.ps'"
dvips -Ppdf rapport
pstops 2:0L@.7(21cm,0)+1L@.7(21cm,14.85cm) rapport.ps rapport2page.ps
