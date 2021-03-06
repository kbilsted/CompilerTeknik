import java.io.*;
import java.util.Vector;


public class Parser implements TokenNames 
{
	private Lexer lexer;		
	private boolean isEOF = false;
	private Token T; 		// indeholder det aktuelle token
	
	
	// for constructing the SymbolTable (sbtb)
	private String sbtbFncname = null;
	private String sbtbClassname;
	private SymbolTable symbolTable;
	


// Constructor
Parser(Lexer lexer, SymbolTable symbolTable) throws IOException
{
	if(lexer != null)
	{
		this.lexer = lexer;
	    T = lexer.getNextToken();	// l?s f?rste token 
	    this.symbolTable = symbolTable;
	}
	else
		errorAndExit("Lexer not available\n");
}
	

public Tree parse() throws IOException
{
	return( S() );// start parsing
}


private Tree S() throws IOException
{
	return( classdef () );
}


private Tree classdef() throws IOException 
{
	Classdef tree = new Classdef(T.lineno);

	while(isEOF == false)
	{
		eat(CLASS);
		tree.add(T.sval); 
		sbtbClassname = T.sval;
		
    	eat(ID);	            // verificer className er en <ID>
		eat(LBRACE);			// verificer "{"
		tree.add( classcontents() );
    	eat(RBRACE);			// verificer "}"
	}

	return(tree);
}
		

private Tree classcontents() throws IOException
{
	Classcontents tree = new Classcontents(T.lineno);
	
    if(T.id != ID && T.id != VOID)
        errorAndExit("Error", "Expected <ID> or \"void\" got token #"+T.id, T.lineno);
       
	// vardef || fncdef
	while(T.id == ID || T.id == VOID || T.id == SEMICOLON)
	{
		if(T.id != SEMICOLON)
		{	// vardef
			if(T.id == ID) 
				tree.add( vardef() );
			else 
				 tree.add( fncdef() );
		}
		else
			eat(SEMICOLON);
	}
	
	return(tree);
}
	
		
private Tree vardef() throws IOException
{	
	String type = T.sval;
	eat(ID);
	
	String name = T.sval;
	eat(ID);

	symbolTable.add(type, sbtbClassname, sbtbFncname, name); 
	
	eat(SEMICOLON);
	return( new Vardef(type, name, T.lineno) );
}



private Tree fncdef() throws IOException
{
	Vector v = new Vector();

	eat(VOID);
	String name = T.sval;
	sbtbFncname = T.sval;
	eat(ID);
	eat(LPAR);
	
	// EBNF: [<ID> <ID> { "," <ID> <ID> } ]
	if(T.id == ID)
	{
		v.addElement(T.sval);
		eat(ID);

		v.addElement(T.sval);
		eat(ID);
		
		// EBNF: { "," <ID> <ID> }
		while(T.id == COMMA)
		{
			eat(COMMA);
			v.addElement(T.sval);
			eat(ID);
			v.addElement(T.sval);
			eat(ID);
		}
	}

	eat(RPAR);
	
	eat(LBRACE);
	Tree s = sentences();
	eat(RBRACE);	

	sbtbFncname = null;
	return( new Fncdef(name, v, s, T.lineno) );
}




private Tree sentences() throws IOException
{	
	Sentences tree = new Sentences(T.lineno);
	
	if(T.id != IF && T.id != WHILE && T.id != BREAK && T.id != RETURN && T.id != ID && T.id != NAME && T.id != RBRACE && T.id != SEMICOLON)
		errorAndExit("Error", "Expecting either: \"if\", \"while\", \"break\", \"return\", <ID>, <NAME>, \";\", or \"}\"", T.lineno);
	while(T.id == IF || T.id == WHILE || T.id == BREAK || T.id == RETURN || T.id == ID || T.id == NAME || T.id == SEMICOLON)
	{
		switch(T.id)
		{
			case SEMICOLON: eat(SEMICOLON); break;
			case IF:    tree.add(if_());    break;
			case WHILE: tree.add(while_()); break;
			case BREAK: tree.add(break_()); break;
			case RETURN:tree.add(return_()); break; 
			case ID:
			case NAME: int lookAhead = peek(); // read next char
				switch(lookAhead)
				{
					case -1:   errorAndExit("Error", "Unexpected End Of File", T.lineno);
					case ID:   tree.add(vardef()); break;
					case LPAR: tree.add(fnccall());break;
					case SET:  tree.add(assign()); break;
					default: errorAndExit("Error", "Expected <ID>, \")\" or \"=\"", T.lineno);
				}
				break;
			
			default: 
				errorAndExit("Error", "Something beyond my comprehension took place...!", T.lineno);
		}
	}

	return(tree);
}
	


private Tree fnccall() throws IOException
{	
	String name = T.sval;
	
	Fnccall tree;
	
	if(T.id == ID)
	{ 
		eat(ID);
		tree = new Fnccall(name, true, T.lineno); // local call
	}
	else 
	{
		eat(NAME);
		tree = new Fnccall(name, false, T.lineno); // not local call
	}
	
	eat(LPAR);
		
	// EBNF: [ <E> { , <E> } ] 
	if(T.id != RPAR)
	{
		tree.add( E() );
		
		while(T.id == COMMA)
		{
			eat(COMMA);
			tree.add( E() );
		}	
	}
	
	eat(RPAR);
	eat(SEMICOLON);
	
	return(tree);
}


private Tree if_() throws IOException
{
	eat(IF); 
	eat(LPAR); 
	Tree condCode = E(); 
	eat(RPAR);
	
	eat(LBRACE);
	Tree thenCode = sentences(); 
	eat(RBRACE);
	
	eat(ELSE);
	eat(LBRACE); 
	Tree elseCode = sentences();
	eat(RBRACE);
	
	return( new If(condCode, thenCode, elseCode, T.lineno) );
}



private Tree while_() throws IOException
{	
	eat(WHILE); 
	eat(LPAR); 
	Tree condCode =	E();
	eat(RPAR);
	eat(LBRACE); 
	Tree whileCode = sentences(); 
	eat(RBRACE);
	
	return( new While(condCode, whileCode, T.lineno) );
}


private Tree break_() throws IOException
{
	eat(BREAK);	
	eat(SEMICOLON);
	
	return( new Break(T.lineno) );
}


private Tree return_() throws IOException
{
	eat(RETURN); 
	
	if(T.id == LPAR) { eat(LPAR); eat(RPAR);}
	eat(SEMICOLON);
	
	return( new Return(T.lineno) );
}

	
private Tree assign() throws IOException
{
	int op;
	String name = T.sval;

	if(T.id == ID)	
	{	op = ID;
		eat(ID);
	}
	else
	{	op = NAME;
		eat(NAME);
	}

	eat(SET); 
	Tree E = E(); 
	eat(SEMICOLON);
	
	return( new Assign(name, op, E, T.lineno) );
}
		
		
private Tree E() throws IOException
{	
	Tree t = E1();

	while(T.id == OR)
	{	
		eat(OR); 
		OpDual tree = new OpDual(OR, t, E1(),T.lineno);
		t = tree;
	}

	return(t);
}

private Tree E1() throws IOException
{
	Tree t = E2();
	
	while(T.id == AND)
	{
		eat(AND); 
		OpDual tree = new OpDual(AND, t, E2(),T.lineno);
		t = tree;
	}
	return(t);
}


private Tree E2() throws IOException
{
	Tree t = E3();
	
	while(T.id == BITOR)
	{
		eat(BITOR);
		OpDual tree = new OpDual(BITOR, t, E3(), T.lineno);
		t = tree;
	}
	return(t);
}
	
		
private Tree E3() throws IOException
{	
	Tree t = E4();
	while(T.id == BITAND)
	{
		eat(BITAND); 
		OpDual tree = new OpDual(BITAND, t, E4(), T.lineno);
		t = tree;
	}
	return(t);
}


private Tree E4() throws IOException
{	
	Tree t = E5();
	
	while(T.id == EQUAL || T.id == NEQUAL)
	{
		int op;

		if(T.id == EQUAL)
		{
			eat(EQUAL);	op = EQUAL;
		}
		else // !=
		{
			eat(NEQUAL); op = NEQUAL;
		}
		OpDual tree = new OpDual(op, t, E5(), T.lineno);
		t = tree;
	}

	return(t);
}



private Tree E5() throws IOException
{
	Tree t = E6();
	
	while(T.id == LESS || T.id == LEQUAL)
	{
		int op;

		if(T.id == LESS)
		{
			eat(LESS); op = LESS;
		}
		else // <=
		{
			eat(LEQUAL); op = LEQUAL;
		}
		OpDual tree = new OpDual(op, t, E6(), T.lineno);
		t = tree;
	}

	return(t);
}


private Tree E6() throws IOException
{
	Tree t = E7();
	
	while(T.id == PLUS || T.id == MINUS)
	{
		int op;

		if(T.id == PLUS)
		{
			eat(PLUS); op = PLUS;
		}
		else // -
		{
			eat(MINUS); op = MINUS;
		}
		OpDual tree = new OpDual(op, t, E7(), T.lineno);
		t = tree;
	}
	return(t);
}




private Tree E7() throws IOException
{
	Tree t = E8();

	while(T.id == MULT || T.id == DIV || T.id == MODULO)
	{
		int op = 0; // = 0 to make Java happy

		if(T.id == MULT)
		{
			eat(MULT); op = MULT;
		}
		
		if(T.id == DIV)
		{
			eat(DIV); op = DIV;
		}
		
		if(T.id == MODULO)
		{
			eat(MODULO); op = MODULO;
		}
		OpDual tree = new OpDual(op, t, E8(), T.lineno);
		
		t = tree;
	}

	return(t);
}


private Tree E8() throws IOException
{
	if(T.id == NEW)
	{
		eat(NEW); 
		OpCall tree = new OpCall(NEW, T.sval, T.lineno);
		eat(ID); 
		eat(LPAR); eat(RPAR);

		return(tree);	
	}
	else
	{
		return( E9() );
	}
}

	
private Tree E9() throws IOException
{
	if(T.id == NOT || T.id == MINUS)
	{
		int op;

		if(T.id == NOT)
		{
			eat(NOT); op = NOT;
		}
		else 
		{
			eat(MINUS); op = MINUS;
		}
		return( new OpMonadic(op, E10(),T.lineno) );
	}
	else
	{
		return( E10() );
	}
}
	
	
private Tree E10() throws IOException
{
	if(T.id != ID && T.id != NAME)
	{
		return( E11() );
	}
	else
	{
		OpCall tree;
		
		if(T.id == ID) 
		{
			tree = new OpCall(ID, T.sval, T.lineno);
			eat(ID);
		}
		else
		{
			tree = new OpCall(NAME, T.sval, T.lineno);
			eat(NAME);
		}

		if(T.id == LPAR)
		{
			eat(LPAR);
			
			tree.setIsFncCall(); // this is a fnc call not a variable
						
			if(T.id != 6)
			{
				tree.add( E() );
			
				while(T.id == COMMA)
				{
					eat(COMMA);
					tree.add( E() );
				}
			}
			
			eat(RPAR);
		}				

		return(tree);
	}
}
	
	
private Tree E11() throws IOException
{	
	String s;
	int n;
	switch(T.id)
	{
		case VAL_STRING: 
			s = T.sval; eat(VAL_STRING); 
			return( new OpConst(VAL_STRING, s, T.lineno) );
		
		case VAL_CHAR:
			s = T.sval; eat(VAL_CHAR); 
			return( new OpConst(VAL_CHAR, s, T.lineno) );
		
		case VAL_INT:
			n= T.nval; eat(VAL_INT); 
			return( new OpConst(VAL_INT, n, T.lineno) );
		
		case LPAR:
			eat(LPAR);
			Tree t = E(); 
			eat(RPAR);
			return(t);
		
		// null is for now just treated as a zero
		case NULL:
			eat(NULL);
			return( new OpConst(VAL_INT, 0, T.lineno) );

			
		default: 
			errorAndExit("\nError", "Unexpected token: " + T.id + " (" + T.sval + " " + T.nval + ")", T.lineno);
	}
	return(null);
	//return(new OpCall()); // Only here because of Java<tm>
}

	

private int peek() throws IOException
{
	if(T.id == EOF)
		return(-1);
	
	Token tmp = lexer.getNextToken();
	lexer.pushBack();
	
	return(tmp.id);
}



private void eat(int id) throws IOException
{
	if(T.id != id)
		errorAndExit("Error", "Expected token #"+id+ " got #" + T.id, T.lineno);

	T = lexer.getNextToken();

	if(T.id == EOF)
		isEOF = true;
}
	
	
private void errorAndExit(String error)
{
	System.out.println(error);
	System.exit(0);
}
	
	
private void errorAndExit(String s, String s2, int l)
{
	System.out.println(s +"("+l+"): "+ s2);
	System.exit(0);
}


public static void main(String s[])
{
	try
	{	SymbolTable myst = new SymbolTable();
		Parser a = new Parser(new Lexer("d:\\modul1\\proj\\parsertester.txt"), myst);
		
		Tree root = a.parse();
		
		//gennneml?b af parsetr?et
		System.out.println("\n\ngennemgang\n----------\n");
		System.out.print(root.toString() );

		System.out.println("\nTest af symbolTable\n");
		System.out.println("A = " + myst.classSize("A"));
		System.out.println("B = " + myst.classSize("B"));

		System.out.println("B.c() = " + myst.fncSize("B","c"));
		System.out.println("B.c().x = " + myst.varIndex("B","c","x") );
		System.out.println("B.k = " + myst.varIndex("B", null, "k") );
		System.out.println("vartype i = " + myst.varType("A", "a", "i") );
		myst.add("char", "A", null, "c", 42);
		System.out.println("A.c = " + myst.varIndex("A", null, "c") );
		
	}
	catch(Exception e)
	{
		System.out.print("cought " +e);
	}
}
		

		
} // EOC
	