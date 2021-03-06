import java.io.*;


// this class takes care of the whole compilationprocess
public class CompilerFacade
{
	CompilerFacade(String input, String output)
	{
		try
		{
			// lex the code
			Lexer lexer = new Lexer(input);
		
			SymbolTable symboltable = new SymbolTable();

			// build a parsertree and SymbolTable
			Parser parser = new Parser(lexer, symboltable);
			Tree parsetree = parser.parse();

			// generate code
			CodeGenerator codegenerator = new CodeGenerator(symboltable);
			String asmSource = codegenerator.generate(parsetree);

			// write assembler code
			FileWriter fp = new FileWriter(output);
			PrintWriter oup = new PrintWriter(fp);
			oup.println(asmSource);
			oup.close();
		}
		catch(FileNotFoundException e)
		{	System.out.print("Inputfile not found!\n" + e);	}

		catch(IOException e)
		{	System.out.print("IO error!\n" + e);}

		catch(Exception e)
		{	System.out.print("Internal error!\n" + e);}
	}


 
}