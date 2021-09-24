//package compiler.token;

/**
* Importerer:
* Anvendes af: Lex, Parser
* Ydre funktionalitet: Fungerer som kommunikation mellem LEX'er og PARSE'r
* Indre funktionalitet: Er en lagerklasse (som struct i C) med et ID felt samt et tal-værdi og streng-værdi felt. Disse felter initialiseres via deres konstruktorer.
*/
  
public class Token
{
	/** Værdierne Token klassen kan indeholde */
	int id;
	int nval;
	String sval;
	int lineno;

	// Konstruktoren
	Token(int id, int lineno) 
	{ this.id = id; this.lineno = lineno;}
	
	Token(int id, int nval, int lineno) 
	{ this.id = id; this.nval = nval; this.lineno = lineno;}
	
	Token(int id, String sval, int lineno) 
	{ this.id = id; this.sval = sval; this.lineno = lineno;}
		
}

