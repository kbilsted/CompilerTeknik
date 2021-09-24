import java.io.*;
    

public class Lexer extends StreamTokenizer implements TokenNames
{

    boolean pushBackFlag = false; // used in pushBack()
    Token T;                      // used to make pushBack() method
         
// Constructor
Lexer(String fname) throws FileNotFoundException
{    
    super( new FileReader(fname) ); 
        
    // setup StreamTokenizer
    slashSlashComments(true); 
    slashStarComments(true);
    whitespaceChars((int) '\t', (int) '\t');
    whitespaceChars((int) ' ',  (int) ' ');
    ordinaryChar((int) '/');         // or ``/'' is a comment
    ordinaryChar((int) '.');         // or ``.'' is a number
    ordinaryChar((int) '-');         // so StreamTokenizer gives <-><4> instead of <-4>
    wordChars((int) '_',(int) '_');  // or ``_'' works as a sepperator
}


public Token getNextToken() throws IOException
{
    // T == null if pushBack() is issued before getNextToken() 
    // (first call could be a pushback call)
    if(pushBackFlag == true && T != null)
    {
        pushBackFlag = false;
        return(T);
    }

    int read = super.nextToken();
    
    switch(read)
    {
        case TT_WORD: 
            if(sval.equals("break")) {T = new Token(BREAK, lineno()); break;}
            if(sval.equals("class")) {T = new Token(CLASS, lineno()); break;}
            if(sval.equals("else"))  {T = new Token(ELSE,  lineno()); break;}
            if(sval.equals("if"))    {T = new Token(IF, lineno());    break;}
            if(sval.equals("new"))   {T = new Token(NEW, lineno());   break;}
            if(sval.equals("null"))  {T = new Token(NULL, lineno());  break;}
            if(sval.equals("return")){T = new Token(RETURN, lineno());break;}
            if(sval.equals("void"))  {T = new Token(VOID, lineno());  break;}
            if(sval.equals("while")) {T = new Token(WHILE, lineno()); break;}

            // Error if token isn't supported get next token
            if(unsupportedToken() == true)
            	return(getNextToken()); 

            // extract <ID> or <NAME>
            T = extractIdOrName();
        break;

                    
        case TT_NUMBER:
            T = new Token(VAL_INT, (int) nval, lineno()); 
        break;
            
                    
        default:
            if(read == TT_EOF) {T = new Token(EOF, lineno()); break;}
            
            if(isIllegalChar((char) read) == false)
            {
                switch((char) read)
                {
                    // char length must be 0 or 1
                    case '\'': if(sval.length() <= 1) T = new Token(VAL_CHAR, sval, lineno()); 
                               else errorAndExit("Error", "Char definition more than 1 character long.", 
                                                 lineno()); 
                               break;
                               
                    case '\"': T = new Token(VAL_STRING, sval, lineno()); break;
                    
                    // These operators can be a compound of a longer operator.
                    case '&':    
                    case '|':
                    case '<':    
                    case '!':    
                    case '=': T = fetchOperator((char) read); break;
                        
                    default: T = c2Token((char)read); break;
                }
            }
            else
                errorAndExit("Error", "Illegal character \"" + read + "\"", lineno());
    }        
        
    return(T);
}
    
// sets a flag so next time getNextToken() is issued it will return last read token
// instead of reading a new token.
public void pushBack()
{
    pushBackFlag = true;
}        

        

private Token extractIdOrName() throws IOException
{
    int state = 0;                         // for the statemachine 
    StringBuffer buf = new StringBuffer(); 
    buf.append(sval);                      // save sval before we read on

    int nt = super.nextToken();

    if((char) nt == '.')
    {
        buf.append("."); state = 1;
    }
        
    while(true)
    {
        // statemachine
        switch(state)
        {
        // stop
        case 0: super.pushBack(); return(new Token(ID, buf.toString(), lineno()) ); 
        
        // after "." is read, and next is <ID> then <NAME> is found -- otherwise return <ID>
        case 1: nt = super.nextToken();
                if(nt == TT_WORD)
                {
                    buf.append(sval); state = 2;
                }
                else
                    state = 0;    
                break;
        
        // <NAME> is found, now look for { <.> <ID> }
        case 2: nt = super.nextToken();
                if((char) nt == '.')
                {
                    buf.append("."); state = 3;
                }
                else state = 9; // return <NAME>
                break;
            
        case 3: nt = super.nextToken();
                if(nt == TT_WORD)
                {
                    buf.append(sval); state = 2;
                }
                else state = 9; // return <NAME>
                break;
    
        
        // return <NAME>        
        case 9: super.pushBack(); return( new Token(NAME, buf.toString(), lineno()) );
        
        } // EOswitch()
    } // EOwhile()
}
            

// converts a character to a token.
private Token c2Token(char c)
{
    switch(c)
    {
        case ',': return(new Token(COMMA, lineno()) );
        case '.': return(new Token(DOT, lineno()) );
        case ';': return(new Token(SEMICOLON, lineno()) );
        case ':': return(new Token(COLON, lineno()) );
        case '(': return(new Token(LPAR, lineno()) );
        case ')': return(new Token(RPAR, lineno()) );
        case '{': return(new Token(LBRACE, lineno()) );
        case '}': return(new Token(RBRACE, lineno()) );
        case '[': return(new Token(LSQBRACE, lineno()) );
        case ']': return(new Token(RSQBRACE, lineno()) );

        case '+': return(new Token(PLUS, lineno()) );
        case '-': return(new Token(MINUS, lineno()) );
        case '*': return(new Token(MULT, lineno()) );
        case '/': return(new Token(DIV, lineno()) );
        case '%': return(new Token(MODULO, lineno()) );
        case '<': return(new Token(LESS, lineno()) );
        case '=': return(new Token(SET, lineno()) );

        case '&': return(new Token(BITAND, lineno()) );
        case '|': return(new Token(BITOR, lineno()) );
        case '!': return(new Token(NOT, lineno()) );

        default: errorAndExit("Error", "Unsuported character \""+ c + "\" found.", lineno());
    }    
    
    // We will never get here, but Java wants the line...
    return( new Token(COMMA, lineno()));
}

// check if character is illegal
private boolean isIllegalChar(char c)
{
    if(c == '@' || c == '#' || c == '$' || c == '�' || c == '�' || c == '~') 
        return(true);
    else 
        return(false);  
} 


// check if keyword is unsupported by the compiler
private boolean unsupportedToken()
{
    boolean illegal = false;
    
    if(sval.equals("case"))     illegal = true; else
    if(sval.equals("catch"))    illegal = true; else
    if(sval.equals("continue")) illegal = true; else
    if(sval.equals("double"))   illegal = true; else
    if(sval.equals("extends"))  illegal = true; else
    if(sval.equals("final"))    illegal = true; else
    if(sval.equals("float"))    illegal = true; else
    if(sval.equals("for"))      illegal = true; else
    if(sval.equals("goto"))     illegal = true; else
    if(sval.equals("interface"))illegal = true; else
    if(sval.equals("package"))  illegal = true; else
    if(sval.equals("switch"))   illegal = true; else
    if(sval.equals("throw"))    illegal = true; else
    if(sval.equals("try"))      illegal = true; else
    if(sval.equals("static") || sval.equals("public") ||
      sval.equals("private") || sval.equals("protected") )
	{
        System.out.println("Warning("+lineno()+"): \""+sval+"\" is not supported.");
        return(true);
	}


    if(illegal)
        errorAndExit("Error", "keyword \"" + sval + "\" is not yet supported.", lineno()); 
    
    return(false);
}



// check if token is a compound of another token, ie < is a compound of <=
private Token fetchOperator(char c) throws IOException
{
    int nt = super.nextToken();    

    // the operator is a single operator
    if(nt != TT_WORD && nt != TT_NUMBER && nt != TT_EOF)
    {    
        String s = "" + c + (char) nt;
        if(s.equals("!=")) return( new Token(NEQUAL,lineno()) );
        if(s.equals("==")) return( new Token(EQUAL, lineno()) );
        if(s.equals("<=")) return( new Token(LEQUAL,lineno()) );
        if(s.equals("&&")) return( new Token(AND,   lineno()) );
        if(s.equals("||")) return( new Token(OR,    lineno()) );
        
        // Warn of un-implemented operators
        if(s.equals("+=") || s.equals("-=") || s.equals("*=") || s.equals("/=") || s.equals("++") || s.equals("--") || s.equals(">="))
            errorAndExit("Error", "Keyword \"" + s + "\" is not supported!", lineno());
            
        // Token was not a compound token, so we need to pushback last read token.
        super.pushBack();
        return(c2Token(c));
    }        
    else
    {    
        // The second token was not an operator, so push it back 
        // and return the operator as a token
        super.pushBack();
        return(c2Token(c));
    }
}


private void errorAndExit(String s, String s2, int lineno)
{
    System.out.println(s+"("+lineno+"): "+s2);
    System.exit(0);
}


/*
//main exists only for testpurposes - note output is in LaTeX format
static void main(String[] args)
{
    try
    {
        int taeller = 0;
        Lexer read = new Lexer("d:\\modul1\\proj\\lextester.txt");
        Token t;
        
        do {
            t = read.getNextToken();
            System.out.print(taeller++ + " & ");
        
            switch(t.id)
            {
                case COMMA:    System.out.print(","); break;
                case DOT:    System.out.print("."); break;
                case SEMICOLON:System.out.print(";"); break;
                case COLON:    System.out.print(":"); break;
                case LPAR:    System.out.print("("); break;
                case RPAR:    System.out.print(")"); break;
                case LBRACE:System.out.print("\\{"); break;
                case RBRACE:System.out.print("\\}"); break;
                case LSQBRACE:System.out.print("["); break;
                case RSQBRACE:System.out.print("]"); break;
                case PLUS:    System.out.print("$+$"); break;
                case MINUS:    System.out.print("$-$"); break;
                case MULT:    System.out.print("*"); break;
                case DIV:    System.out.print("/"); break;
                case MODULO:System.out.print("\\%"); break;
                case LESS:    System.out.print("$<$"); break;
                case SET:    System.out.print("="); break;
                case EQUAL:    System.out.print("=="); break;
                case NEQUAL:System.out.print("!="); break;
                case LEQUAL:System.out.print("<="); break;
                case AND:    System.out.print("\\&\\&"); break;
                case OR:    System.out.print("$||$"); break;
                case BITAND:System.out.print("\\&"); break;
                case BITOR:    System.out.print("$|$"); break;
                case NOT:    System.out.print("!"); break;
                case BREAK:    System.out.print("break"); break;
                case ELSE:    System.out.print("else"); break;
                case IF:    System.out.print("if"); break;
                case WHILE:    System.out.print("while"); break;
                case CLASS:    System.out.print("class"); break;
                case NEW:    System.out.print("new"); break;
                case RETURN:System.out.print("return"); break;
                case ID:    System.out.print("id ("+ t.sval +")"); break;
                case NAME:    System.out.print("name ("+ t.sval +")"); break;

                case VOID:    System.out.print("void"); break;
                case NULL:    System.out.print("null"); break;
                
                case VAL_CHAR:    System.out.print("chVal('"+ t.sval +"')"); break;
                case VAL_INT:    System.out.print("intVal("+ t.nval +")"); break;
                case VAL_STRING:System.out.print("StrVal("+ t.sval +")"); break;
                case EOF:        System.out.print("<EOF>"); break;
                
                default: System.out.print("OUPS!! cant decode "+t.id + " id!\n");
            }
    
                
            if(taeller%4 == 0)
                System.out.print("\\\\ \\hline \n");
            else
                System.out.print(" & ");
        } while(t.id != EOF);
        
        System.out.println("\\\\ \\hline \n");
    }
    catch(Exception e)
    {
        System.out.println(e);
        System.exit(0);
    }
}
*/
    
} // EOClass    