ORM:ADEEM a aamas:Lexeme ;
  orm:derivedStem  ORM:Base  ;
  aama:gloss "go" ;
  aama:lang aama:Oromo ;
  aama:lemma "adeem-" ;
  rdfs:label "adeem" ;
  orm:pos  ORM:Verb
      .
 ?term aama:lang ?l . ?l rdfs:label ?Lang .

prefix aama:	 <http://id.oi.uchicago.edu/aama/2013/>
prefix aamas:	 <http://id.oi.uchicago.edu/aama/schema/2013/>
prefix rdf:	 <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
prefix rdfs:	 <http://www.w3.org/2000/01/rdf-schema#>
prefix orm:   <http://id.oi.uchicago.edu/aama/2013/oromo/> 
prefix ORM:   <http://id.oi.uchicago.edu/aama/2013/Oromo/>
prefix BAR:   <http://id.oi.uchicago.edu/aama/2013/Beja-Arteiga/>

SELECT DISTINCT  ?term ?lex ?Property ?Value
WHERE {
  ?term aamas:lexeme BAR:TAM .
  ?term ?ptype ?pval .
  ?ptype rdfs:label ?Property .
  ?pval rdfs:label ?Value .
}
ORDER BY  ASC(?Property) ASC(?Value)

