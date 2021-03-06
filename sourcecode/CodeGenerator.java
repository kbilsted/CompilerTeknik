import java.util.Vector;

public class CodeGenerator implements TokenNames
{
	// user-specifik compileroptions
	private String HOBSIZE = "32605";

	// to generate unique labels
	private int X = 0; 
	
	// temporary storage of program divided into the two assembler segments
	// and a block of startup code
	private AsmBlock segptr; // points to the AsmBlock to be written to
	private AsmBlock startcode=new AsmBlock(); // upstart code
	private AsmBlock stdfnc  = new AsmBlock(); // standard functions
	private AsmBlock dataseg = new AsmBlock(); // data segment code
	private AsmBlock codeseg = new AsmBlock(); // code segment code
	private AsmBlock maincode= new AsmBlock(); // code containing static void main()
	// other
	String className; // name of class we are currently working in
	String fncName;		// name of fnc we are currently working in
	SymbolTable sbtb;	// symbol table containing all variables in parsetree
	
	
	// konstruktÝr
	CodeGenerator(SymbolTable sbtb){this.sbtb = sbtb;}
		

	private void errorAndExit(String s)
	{System.out.print("\n" + s); System.exit(0);}


	private void errorAndExit(String s, String s2, int l)
	{System.out.print(s + "("+l+"): " + s2); System.exit(0);}
	
	public String generate(Tree parsetree)
	{

		generateStartCode();
		segptr = codeseg; // write the whole thing to codeseg
		sGen((Classdef) parsetree);
		return( startcode.toString() + dataseg.toString() + 
			    stdfnc.toString()    + codeseg.toString() +
			    maincode.toString() 
			  );
	}
	

	private void sGen(Classdef tree)
	{
		// a classdefinition is defined as two sepperate elements in the parsetree
		className = (String) tree.getNext();

		while(className != null)
		{	
			fncName = null;
			classdefGen((Classcontents) tree.getNext() );
			
			className = (String) tree.getNext(); // read next elem
		}
	}
	
	
	private void classdefGen(Classcontents tree)
	{	classcontentsGen(tree);	}
	
		
	private void classcontentsGen(Classcontents tree)
	{
		Tree t = tree.getNext();
		
		while(t != null)
		{
			if(t instanceof Vardef)
			{
				// do nothing, as all the variables are allocated on beforehand.
			}
			else // instanceof Fncdef
			{
				// special case if functionname == "main"
				if( ((Fncdef) t).getName().equals("main") )
					fncdefMainGen((Fncdef) t);
				else
					fncdefGen((Fncdef) t);
			}
			
			t = tree.getNext();
		}
	}
	
	

	private void vardefGen(Vardef tree)
	{
		return; // variables are handed by newGen() and fncdefGen()
	}
	
	
	
	private void fncdefMainGen(Fncdef tree)
	{
		int offset = 0;
		fncName = "main";
		String fnc_endlabel = className + "_" + fncName + "_end";
		
		segptr = maincode;
		
		segptr.add("\n\nSTART:");
		segptr.add("mov  ax, @data ; setup DOS program");
		segptr.add("mov  ds, ax");
		segptr.add("; allocate object main resides in");
		segptr.add("mov  cx, "+sbtb.classSize(className) );
		segptr.add("call new");
		segptr.add("mov  bp, sp     ; adjust bp to point at functions local variable");
		segptr.add("sub  bp, 2      ;");
		segptr.add("mov  bx, ax    ; store main's 'this' ");
		segptr.add("; execute mains contents");
				
		// put all fnc local variables on stack with value = 0
		int fncsize = sbtb.fncSize(className, fncName)/2;
		for(int i = 0; i < fncsize; i++)
			segptr.add("push 0    ; push local variables to stack ");

		// generate all the sentences in function
		sentencesGen((Sentences) tree.getSentence(), null, fnc_endlabel);
		segptr.add("jmp  SystemExit");
		segptr.add("END"); 
		
		fncName = null;
		segptr = codeseg; // write again to the codeseg segment
	}
	



		
	/*
	 * all the argumentvariables have been put on stack - we must added them to the 
	 * SymbolTable in the fncCallGen() so their possition on the stack can be calculated
	 */	
	private void fncdefGen(Fncdef tree)
	{
		int offset = 0;
		fncName = tree.getName();
		Vector argList = tree.getArgList();
		
		String fnc_endlabel = className + "_" + fncName + "_end";
		
		segptr.add("\n\n"+className+"_" + fncName + " PROC" ); // declare PROC		
		segptr.add("mov  bp, sp ; adjust bp to point at functions local variable");
		segptr.add("sub  bp, 2");

		// put all fnc local variables on stack with value = 0
		int fncsize = sbtb.fncSize(className, fncName);
		for(int i = 0; i < fncsize/2; i++)
			segptr.add("push 0 ; put all local variables on stack");
	
	
		// put arglist variable names in SymbolTable with their corresponding
		// index # on the stack. 
		// index # = first local variable (2bytes) + return adr (2bytes) 
		// the index is also negated, as argument-variables are fetched with [bp+x] 
		// unlike local variables which are fetched with [bp-x]
		for(int index=0, i=0; i < argList.size(); i++)
		{
			sbtb.add((String) argList.elementAt(i++), className, fncName, 
				     (String) argList.elementAt(i), -(4+index) );
			index += 2;
		}


		// generate all the sentences in function
		sentencesGen((Sentences) tree.getSentence(), null, fnc_endlabel);
			
	

		// fnc end_label must be set in front of the de-stacking of variables
		segptr.add(fnc_endlabel + ":");
	
		// de-stack local variables
		for(int i = 0; i < fncsize/2; i++)
			segptr.add("pop  ax   ; de-stack local variables");

		// end function
		segptr.add("ret");
		segptr.add(className+"_" + fncName + " ENDP" ); // declare PROC		
			
		fncName = null;
		
		// clear SymbolTable of argument variables
		for(int i = 0; i < argList.size(); i++)
		{
			sbtb.remove((String) argList.elementAt(i++), className, 
				     fncName, (String) argList.elementAt(i));
		}
	}
	
			

	// input <sentences>, endlabel == if/while or fnc if break is called outside, 
	private void sentencesGen(Sentences tree, String endlabel, String fnc_endlabel)
	{
		Tree t = tree.getNext();
		while(t != null)
		{
			if(t instanceof Vardef)	
				vardefGen((Vardef) t);
			else
			if(t instanceof Fnccall) 
				fnccallGen((Fnccall) t);
			else
			if(t instanceof If)	
				ifGen((If) t, fnc_endlabel);
			else
			if(t instanceof While)
				whileGen((While) t, fnc_endlabel);
			else
			if(t instanceof Break)
				breakGen((Break) t, endlabel);
			else
			if(t instanceof Return)
				segptr.add("jmp  "+fnc_endlabel+" ; return");
			else
			if(t instanceof Assign)
				assignGen((Assign) t);	
			
			t = tree.getNext();
		}
	}
	
	

	private void fnccallGen(Fnccall tree)
	{
		String name = tree.getName();
		
		segptr.add("; fnccallGen");
		
		// standard functions
		if(tree.getName().equals("System.out.print") )
		{
			segptr.add("push bp");
			segptr.add("push bx");
			eGen((Tree)tree.getArgList().elementAt(0));
			segptr.add("call SystemOutPrint");
			segptr.add("pop  cx ; de-stack argument");
			segptr.add("pop  bx");
			segptr.add("pop  bp");
			return;
		}

		if(tree.getName().equals("System.in.read"))
		{
			segptr.add("call SystemInRead");
			segptr.add("push ax ; store read letter");	
			return;
		}

		if(tree.getName().equals("System.exit"))
		{
			segptr.add("jmp  SystemExit");
			return;
		}
		
		if(tree.getName().equals("Integer.toString"))
		{
			// generate first argument and put result in ax
			segptr.add("push bp");
			segptr.add("push bx");
			eGen((Tree)tree.getArgList().elementAt(0));
			segptr.add("call Integer_toString");
			segptr.add("pop  cx ; de-stack arguments");
			segptr.add("pop  bx");
			segptr.add("pop  bp");
			segptr.add("push ax ; store generated String");	
			return;
		}
		
		
		// else non-local non standard function
		
		String callFnc   ="";// used in if isCallLocal == false
		String callClass ="";// used in if isCallLocal == false
			
		if(tree.isCallLocal() == false)
		{
			// we must first extract Obj pointer name  == classptr
			int sepp = name.indexOf('.');
			String classptr = name.substring(0, sepp);
			callFnc = name.substring(sepp+1);
		
			// find the pointers type to determine which class to call
			callClass = sbtb.varType(className, fncName, classptr);

			// reference variable is defined in class scope
			if(callClass == null)
			{
				callClass = sbtb.varType(className, null, classptr);
				int stackPos = sbtb.varIndex(className, null, classptr);

				segptr.add("push bp");
				segptr.add("push bx");
				segptr.add("mov  bx, hob[" + stackPos + "] ; push callers class' 'this'");
			}
			else
			{
				// fetch 'this' for the class that the pointer points at
				int stackPos = sbtb.varIndex(className, fncName, classptr);
			
				if(stackPos != -1)
				{
					segptr.add("push bp");
					segptr.add("push bx");
					segptr.add("mov  bx, [bp-" + stackPos + "] ; push callers class' 'this'");
				}
				else
					errorAndExit("Error", "Functioncall '"+name+"()' is unknown!", tree.lineno());
			}
		}
		else // local non standard function 
		{	
			segptr.add("push bp");
			// since the call is local, 'this' (bx) is set up correctly
		}
				
						
   	   /* push all arguments to stack (local variables will be pushed as the 
   	    * first thing in the funktion)
		* The names will later be connected with the stack possition (in the 
		* begining of the function, but generated in fncdefGen() )
		* All we do here is putting the values on the stack in reverse order, so 
		* the varIndex in SymbolTable works correctly
		*/
		Vector v = tree.getArgList();
		for(int i = v.size()-1; i >= 0 ; i--)
			eGen((Tree) v.elementAt(i));

		if(tree.isCallLocal() == true)
			segptr.add("call "+className+"_"+name);
		else
		{
			segptr.add("call " + callClass +"_"+ callFnc);
		}


		// since functions normaly doesn't support return-value we
		// have to do something special in the cases where we need a
		// returnvalue
		for(int i = 0; i < v.size(); i++)
			segptr.add("pop  cx ; de-stack arguments");

		if(tree.isCallLocal() == false)
		{
			segptr.add("pop  bx ; restore this class' 'this'");
			segptr.add("pop  bp");
		}
		else // only restore bp in local calls
		{
			segptr.add("pop bp");
		}		

		// we do not have returnvalues for functions, but in these special
		// cases we need it and so "emulate" it.
		if(callFnc.equals("length") || 
		   callFnc.equals("charAt") || 
		   callFnc.equals("concat") 
		  )
			segptr.add("push  ax ; 'emulated' return value on the stack");

	}
	
	
	
	private void ifGen(If tree, String fnc_endlabel)
	{
		int x = X++;
		final String ifend_label = "endif_"+X;
		final String else_label  = "else_"+X;
		final String then_label  = "then_"+X;
		
		// gen IF
		eGen(tree.getCond());
		segptr.add("pop  cx     ; start if_"+x);
		segptr.add("cmp  cx, 0");
		segptr.add("je   " + else_label); // if CX == 0
		
		// gen THEN
		segptr.add(then_label+":");
		sentencesGen((Sentences) tree.getThen(), null, fnc_endlabel);	
		segptr.add("jmp  " + ifend_label);
	
		// gen ELSE 
		segptr.add(else_label+":");
		sentencesGen((Sentences) tree.getElse(), null, fnc_endlabel);
		segptr.add(ifend_label+":");
	}




	private void whileGen(While tree, String fnc_endlabel)
	{
		X++;
		String while_startlabel = "start_while"+X;
		String while_endlabel = "end_while"+X;
		
		// condition
		segptr.add(while_startlabel+":");
		segptr.add("; condition code");
		eGen(tree.getCond() );

		segptr.add("pop  ax ; compare condition code");
		segptr.add("cmp  ax, 0");
		segptr.add("je   " + while_endlabel + " ; condition is false");
		sentencesGen((Sentences) tree.getWhile(), while_endlabel, fnc_endlabel);
		segptr.add("jmp  " + while_startlabel + " ; loop once more");
		segptr.add(while_endlabel+":");
	}


	private void breakGen(Break tree, String endlabel)
	{	
		if(endlabel == null)
		{
			String fnc;
			if(fncName != null)
				fnc = fncName + "() ";
			else 
				fnc = " ";
					
			errorAndExit("Error", "\"break\" is only allowed inside while-scopes!", tree.lineno());
		}
		else
			segptr.add("jmp  "+endlabel+" ; break");
	}


		
	private void assignGen(Assign tree)
	{	segptr.add("; assign");
		
		eGen(tree.getE());
		segptr.add("pop  ax ; get value (assign)");
		
		if(tree.getOp() == ID)
		{
			String varname = tree.getName();
			int index = sbtb.varIndex(className, null, varname);		
			
			if(index >= 0)
			{
				segptr.add("mov  hob[bx+"+index+"], ax ; set class variable " + varname);
			}
			else// not a class variable, but a fnc variable
			{	
				index = sbtb.varIndex(className, fncName, varname);		
				
				if(index == -1)
					errorAndExit("Error","Variable "+varname+" not defined in current scope.", tree.lineno());
				
				// if variable is from arguments, they must be fetched differently
				if(index < 0)
				{	
					segptr.add("mov  [bp+"+(index*-1)+"], ax ; set argument variable " + varname);
				}
				else
					segptr.add("mov  [bp-"+index+"], ax ; set local variable " + varname);
			}
		}
		else // getOp() == NAME
		{
			String name = tree.getName();

			// we must first extract Obj pointer name 
			int sepp = name.indexOf('.');
			String classptr = name.substring(0, sepp);
			String varname = name.substring(sepp+1);
	
			// find the class ptr is pointing at 
			String callClass = sbtb.varType(className, fncName, classptr);
			
			int classptrIndex = sbtb.varIndex(className, null, varname);
			int varindexOtherClass = sbtb.varIndex(callClass, null, varname);

			if(varindexOtherClass >= 0)
			{			
				// get value p points at (in p.a)
				segptr.add("push bx");
				segptr.add("                            ; value of " + name);
				segptr.add("mov  bx, [bp-"+(classptrIndex)+"] ; this of other class");
				// get value of a (in p.a)
				segptr.add("mov  hob[bx+"+varindexOtherClass+"], ax ; set value of variable in other class");
				segptr.add("pop  bx");
			}
			else
			{
				errorAndExit("Error", "Variable \""+name+"\" does not exist.", tree.lineno());
			}
		}
	}	

	
	// generate <E>
	private void eGen(Tree e)
	{	
		if(e instanceof OpMonadic)	opMonadicGen((OpMonadic) e);
		else
		if(e instanceof OpDual) 	opDualGen((OpDual) e);
		else
		if(e instanceof OpConst)	opConstGen((OpConst) e); 
		else
		if(e instanceof OpCall)		opCallGen((OpCall) e);
		else
			errorAndExit("Internal error: Tried to generate <E> - but tree was no <E>!");
	}
	
	
	private void opMonadicGen(OpMonadic tree)
	{	segptr.add("; monadic begin");		
		eGen(tree.getR() );
		segptr.add("pop  ax");
	
		switch(tree.getOp())
		{
			case MINUS:
				segptr.add("neg  ax");
				segptr.add("push ax");
				break;
				
			case NOT:
				segptr.add("not  ax");
				segptr.add("push ax");
				break;
		}
	}
		
		
	
	private void opDualGen(OpDual tree)
	{
		eGen(tree.getL() );
		segptr.add("; ");
		eGen(tree.getR() );
		
		switch(tree.getOp()) 
		{
			case OR:
			case BITOR:	
				segptr.add("pop  dx");
				segptr.add("pop  ax");
				segptr.add("or   ax, dx"); 
				segptr.add("push ax");
				break;

			case AND:
			case BITAND:
				segptr.add("pop  dx");
				segptr.add("pop  ax");
				segptr.add("and  ax, dx"); 
				segptr.add("push ax");
				break;
				
			case EQUAL: 
				X++;
				segptr.add("; equal");
				segptr.add("pop  dx");
				segptr.add("pop  ax");
				segptr.add("cmp  ax, dx"); 
				segptr.add("je   eq_"+X);
				segptr.add("xor  ax, ax  ; is !="); // false result
				segptr.add("jmp  eq_end"+X);
				segptr.add("eq_"+X+":");
				segptr.add("mov  ax, 65535 ; is =="); // true result
				segptr.add("eq_end"+X+":"); 
				segptr.add("push ax");
				break;
		
			case NEQUAL: 
				X++;
				segptr.add("pop  dx");
				segptr.add("pop  ax");
				segptr.add("cmp  ax, dx"); 
				segptr.add("jne  neq_"+X); // remember 2 != 3 is true
				segptr.add("xor  ax, ax  ; is ==");
				segptr.add("jmp  neq_end"+X);
				segptr.add("neq_"+X+":");
				segptr.add("mov  ax, 65535 ; is !="); // true result
				segptr.add("neq_end"+X+":"); 
				segptr.add("push ax");
				break;
		
			case LESS:
				X++;
				segptr.add("pop  dx");
				segptr.add("pop  ax");
				segptr.add("cmp  ax, dx");
				segptr.add("jl   less_"+X);
				segptr.add("xor  ax, ax ; is not <");
				segptr.add("jmp  less_end"+X);
				segptr.add("less_"+X+":");
				segptr.add("mov  ax, 65535 ; is <"); // true result
				segptr.add("less_end"+X+":"); 
				segptr.add("push ax");
				break;
		
			case LEQUAL:
				X++;
				segptr.add("pop  dx");
				segptr.add("pop  ax");
				segptr.add("cmp  ax, dx");
				segptr.add("jle  lequal_"+X);
				segptr.add("xor  ax, ax  ; is not <=");
				segptr.add("jmp  lequal_end"+X);
				segptr.add("lequal_"+X+":");
				segptr.add("mov  ax, 65535 ; is <="); // true result
				segptr.add("lequal_end"+X+":"); 
				segptr.add("push ax");
				break;
					
			case PLUS: 
				segptr.add("pop  dx");
				segptr.add("pop  ax");
				segptr.add("add  ax, dx"); 
				segptr.add("push ax");
				break;
				
			case MINUS: 
				segptr.add("pop  dx");
				segptr.add("pop  ax");
				segptr.add("sub  ax, dx"); 
				segptr.add("push ax");
				break;
				
				
			case MULT:
				segptr.add("pop  dx");
				segptr.add("pop  ax");
				segptr.add("mul  dx"); 
				segptr.add("push ax");
				break;
		
		
			case DIV:
				segptr.add("pop  si");
				segptr.add("pop  ax");
				segptr.add("xor  dx, dx");
				segptr.add("div  si");
				segptr.add("push ax");
				break;

			case MODULO:
				segptr.add("pop  si");
				segptr.add("pop  ax");
				segptr.add("xor  dx, dx");
				segptr.add("div  si");
				segptr.add("push dx");
				break;
		}
	}
	
	private void opConstGen(OpConst t)
	{		
		switch(t.getOp())		
		{
			case VAL_INT:
				segptr.add("mov  ax, " + t.getNval() );
				segptr.add("push ax");
				break;
								
			case VAL_CHAR:
				segptr.add("mov  ax, '" + t.getSval() + "'");
				segptr.add("push ax");
				break;
		
			case VAL_STRING: 
				String s = t.getSval();
				int len = s.length();
				segptr.add("; string - allocate class and return pointer on stack");
				segptr.add("mov  cx, "+((2*len)+2) + " ; length of 2*str + 2 ");
				segptr.add("call new");
				segptr.add("mov  si, ax ; mov (adr of obj in hob) to si");
				
				segptr.add("mov  hob[si], "+len+" ; insert strlength");
				for(int i = 0, index = 2; i < len; i++, index+=2)
					segptr.add("mov  hob[si+"+index+"], '"+ s.charAt(i)+ "'");
								
				segptr.add("push ax");
				break;
			
			default: errorAndExit("Internal error in opConstGen()");
		}
	}		



	private void opCallGen(OpCall tree)
	{
		// variable from this object
		if(tree.getOp() == ID && tree.isFncCall() == false)
		{
			String varname = tree.getName();
			int index = sbtb.varIndex(className, fncName, varname);		

			// variable is declared in class-scope
			if(index == -1)
			{
				index = sbtb.varIndex(className, null, varname);		

				// if still unknown the variable does not exist
				if(index == -1)
					errorAndExit("Error", "variable \"" + tree.getName() +"\" is not defined within the scope it was used.", tree.lineno()); 
								
				segptr.add("mov  ax, hob[bx+"+index+"] ; get class variable " + varname);
				segptr.add("push ax");
				return;
			}
			if(index < 0)
			{	
				segptr.add("mov  ax, [bp+"+(index*-1)+"] ; get argument variable " + varname);
				segptr.add("push ax");
			}
			else
			{	
				segptr.add("mov  ax, [bp-"+(index)+"] ; get local variable " + varname);
				segptr.add("push ax");
			}
		}
		else	
		// variable from other object
		if(tree.getOp() == NAME && tree.isFncCall() == false)
		{

			// we must first extract Obj pointer name 
			int sepp = tree.getName().indexOf('.');
			String classptr = tree.getName().substring(0, sepp); // name of class, "p" in p.a
			String varname = tree.getName().substring(sepp+1);   // name of var,   "a" in p.a
	
			// find the class ptr is pointing at 
			String callClass = sbtb.varType(className, fncName, classptr);
			
			if(callClass != null)
			{
				int classptrIndex = sbtb.varIndex(className, null, varname);
				int varindexOtherClass = sbtb.varIndex(callClass, null, varname);
			
				// if still unknown the variable does not exist
				if(varindexOtherClass == -1)
					errorAndExit("Error", "variable \""+varname+"\" is not defined in class "+callClass, tree.lineno()); 

				// get value p points at (in p.a)
				segptr.add("mov  ax, [bp-"+(classptrIndex)+"] ; this of other class");
				// get value of a (in p.a)
				segptr.add("mov  ax, hob[ax+"+varindexOtherClass+"] ; get value of variable in other class");
				segptr.add("push ax");
			}
			else
				errorAndExit("Error", "variable \""+classptr+"\" is not defined within the scope it is being used.", tree.lineno());
		}
		else
		if(tree.getOp() == NEW)
		{
			segptr.add("; new");
			segptr.add("mov  cx, "+ sbtb.classSize(tree.getName()) + " ; size of class " + tree.getName() );
			segptr.add("call new");
			segptr.add("push ax ; save adr pointer of object");
		}
		else // fnccall with <ID>/<NAME>
		{
			Fnccall tmp;
			
			if(tree.getOp() == NAME)
				tmp = new Fnccall(tree.getName(), tree.getArgList(), false);
			else
				tmp = new Fnccall(tree.getName(), tree.getArgList(), true);
			
			fnccallGen(tmp);
		}
	}	
		
	// All the code necesary for a program
	private void generateStartCode()
	{
		startcode.add("DOSSEG");
		startcode.add(".MODEL SMALL");
		startcode.add(".STACK 100h");
		
		dataseg.add("\n\n.DATA");
		dataseg.add("hobptr  dw 0");
		dataseg.add("hob     dw "+HOBSIZE+" dup(0) ; allocate hob");
		dataseg.add("; error messages");
		dataseg.add("oomstr	db	10,13,'Out of memory! Can not allocate another class.','$',0,0");
		
		
		stdfnc.add("\n\n.CODE");
		stdfnc.add("jmp  START\n");

		stdfnc.add("; ------------ STANDARD FUNCTIONS BEGIN ----------:");
		stdfnc.add("\nnew PROC");
		stdfnc.add("mov  ax, hobptr     ; get hop size");
		stdfnc.add("push ax            ; save pos. of class in stack");
		stdfnc.add("add  ax, cx	       ; add size of obj");
		stdfnc.add("cmp  ax, "+HOBSIZE);
		stdfnc.add("jg   OutOfMem        ; if ax < HOBSIZE jump to OutOfMemory");
		stdfnc.add("mov  hobptr, ax     ; save hop size");
		stdfnc.add("pop  ax             ;   ax = pos. of class in hob");
		stdfnc.add("ret");
		stdfnc.add("OutOfMem:");		
		stdfnc.add("mov  dx, OFFSET oomstr; write out of mem string to screen");
		stdfnc.add("mov  ah, 9h");
		stdfnc.add("int  21h");
		stdfnc.add("jmp  SystemExit");
		stdfnc.add("new  ENDP");

	
		// prints String's only!
		stdfnc.add("\nSystemOutPrint PROC");
		stdfnc.add("mov  bp, sp");
		stdfnc.add("sub  bp, 2");
		stdfnc.add("mov  bx, [bp+4]     ; get adr of str obj");
		stdfnc.add("mov  cx, hob[bx]    ; strlen");
		stdfnc.add("mov  si, bx         ; source-print ptr");
		stdfnc.add("add  si, 2          ; get past length field");
		stdfnc.add("printloop:");
		stdfnc.add("mov  dx, hob[si]");
		stdfnc.add("add  si, 2          ; next char");
		stdfnc.add("mov  ah, 2h         ; print char");
		stdfnc.add("int  21h");
		stdfnc.add("loop printloop");
		stdfnc.add("ret");
		stdfnc.add("SystemOutPrint ENDP");


		stdfnc.add("\nSystemInRead PROC");
		stdfnc.add("mov  ah, 1h ; read with screen echo");
		stdfnc.add("int  21h");
		stdfnc.add("mov  ah, 0 ; clear AH as only AL contains userinput");
 		stdfnc.add("ret");
		stdfnc.add("SystemInRead ENDP");


		stdfnc.add("\nSystemExit PROC");
		stdfnc.add("mov  ah, 4ch");
		stdfnc.add("int  21h");
		stdfnc.add("ret");
		stdfnc.add("SystemExit ENDP");


		stdfnc.add("\nInteger_toString PROC");
		stdfnc.add("mov  bp, sp");
		stdfnc.add("sub  bp, 2");
		stdfnc.add("mov  ax, [bp+4]    ; get number (first argument)");
		stdfnc.add("xor  cx, cx        ; cx counts size of str");
		stdfnc.add("xor  di, di        ; flag for negative numbers");
        stdfnc.add("cmp  ax, 0         ; is negative?");
        stdfnc.add("jge  nonneg");
        stdfnc.add("inc  di            ; di == 1 == number is negative");
        stdfnc.add("inc  cx");
        stdfnc.add("neg  ax            ; make the number positive");
		stdfnc.add("nonneg:");
		stdfnc.add("mov  si, 10        ; div with reg SI as many times as possible");
		stdfnc.add("getDigits:");
		stdfnc.add("xor  dx, dx");
		stdfnc.add("div  si");
		stdfnc.add("add  dx, 48        ; conv digit to ASCII");
		stdfnc.add("push dx");
		stdfnc.add("inc  cx");
		stdfnc.add("cmp  ax, 0         ; are we done?");
		stdfnc.add("jg   getDigits\n");
		stdfnc.add("push cx            ; store cx");
		stdfnc.add("shl  cx, 1         ; calc str size = (2*strlen)+2");
		stdfnc.add("add  cx, 2");
		stdfnc.add("call new           ; alloc new str");
		stdfnc.add("pop  cx            ; get original strlen");
		stdfnc.add("mov  si, ax        ; ptr to str in hob");
		stdfnc.add("mov  hob[si], cx   ; store size of str");
		stdfnc.add("cmp  di, 0         ; is no negative?");
		stdfnc.add("je   toStr");
		stdfnc.add("add  si, 2         ; next pos");
		stdfnc.add("mov  hob[si], '-'  ; write '-' sign");
		stdfnc.add("dec  cx");
		stdfnc.add("toStr:");
		stdfnc.add("add  si, 2         ; next pos");
		stdfnc.add("pop  dx            ; get digit");
		stdfnc.add("mov  hob[si], dx   ; store size of str");
		stdfnc.add("loop toStr");
		stdfnc.add("ret");
		stdfnc.add("Integer_toString ENDP");




		stdfnc.add("\nString_charAt PROC");
		stdfnc.add("mov  bp, sp");
		stdfnc.add("sub  bp, 2");
		stdfnc.add("mov  si, bx        ; pos in hob where obj begins");
		stdfnc.add("mov  ax, [bp+4]    ; get (first) argument telling pos to get");
		stdfnc.add("shl  ax, 1         ; ax = ax * 2 every char is 2 elems");
		stdfnc.add("add  si, ax        ; pos in hob to fetch character");   
		stdfnc.add("mov  ax, hob[si+2] ; +2 as first field contains str_len");
		stdfnc.add("ret");
		stdfnc.add("String_charAt ENDP");

			
		// bx is source ptr
		stdfnc.add("\nString_concat PROC");
		stdfnc.add("mov  bp, sp");
		stdfnc.add("sub  bp, 2");
		stdfnc.add("mov  cx, hob[bx] ; size of caller str");
    	stdfnc.add("mov  si, [bp+4]  ; pos in hob of 2nd str len");
    	stdfnc.add("add  cx, hob[si] ; add 2nd str len");  
		stdfnc.add("push cx");
		stdfnc.add("add  cx, 2	    ; add space for sizefield");
		stdfnc.add("call new        ; alloc new String object");
		stdfnc.add("pop  cx			; total strsize");
		stdfnc.add("mov  si, ax      ; can't just use the AX");
		stdfnc.add("mov  hob[si], cx ; set concat'ed String size\n");
		stdfnc.add("mov  cx, hob[bx] ; size of str1");
		stdfnc.add("add  bx, 4       ; start in 2nd pos (but why +4 instead of +2 ??)");
		stdfnc.add("mov  di, ax      ; destination ptr = adr of new String obj");
		stdfnc.add("add  di, 2       ; start in 2nd pos");
		stdfnc.add("strcat1:");
		stdfnc.add("mov  si, [bx]    ; we can't just use [bx]");
		stdfnc.add("mov  hob[di], si");
		stdfnc.add("add  bx, 2");
		stdfnc.add("add  di, 2");
		stdfnc.add("loop strcat1\n");
    	stdfnc.add("mov  si, [bp+4]  ; pos in hob of 2nd str len");
    	stdfnc.add("mov  cx, hob[si] ; size of 2nd str len");  
		stdfnc.add("mov  bx, [bp+4]  ; point at start of 2nd string");
		stdfnc.add("add  bx, 4       ; start in 2nd pos (but why +4??)");	
		stdfnc.add("strcat2:");
		stdfnc.add("mov  si, [bx]    ; we can't just use [bx]");
		stdfnc.add("mov  hob[di], si");
		stdfnc.add("add  bx, 2");
		stdfnc.add("add  di, 2");
		stdfnc.add("loop strcat2");
		stdfnc.add("ret");
		stdfnc.add("String_concat ENDP");


		stdfnc.add("\nString_length PROC ; str_len length()");
		stdfnc.add("mov  ax, hob[bx] ; first field in string");
		stdfnc.add("ret");
		stdfnc.add("String_length ENDP");

		stdfnc.add("; ------------ STANDARD FUNCTIONS END ----------:");
	}	
}