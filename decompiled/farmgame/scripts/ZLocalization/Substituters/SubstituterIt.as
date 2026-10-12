package ZLocalization.Substituters
{
   public class SubstituterIt extends SubstituterContractions
   {
      
      protected static var contractionMap:Object = {
         "le":{
            "a":"alle",
            "su":"sulle",
            "con":"colle",
            "in":"nelle",
            "di":"delle",
            "da":"dalle"
         },
         "lo":{
            "a":"allo",
            "su":"sullo",
            "con":"collo",
            "in":"nello",
            "di":"dello",
            "da":"dallo"
         },
         "il":{
            "a":"al",
            "su":"sul",
            "con":"col",
            "in":"nel",
            "di":"del",
            "da":"dal"
         },
         "gli":{
            "a":"agli",
            "su":"sugli",
            "con":"cogli",
            "in":"negli",
            "di":"degli",
            "da":"dagli"
         },
         "l\'":{
            "a":"all\'",
            "su":"sull\'",
            "con":"coll\'",
            "in":"nell\'",
            "di":"dell\'",
            "da":"dall\'"
         },
         "i":{
            "a":"ai",
            "su":"sui",
            "con":"coi",
            "in":"nei",
            "di":"dei",
            "da":"dai"
         },
         "la":{
            "a":"alla",
            "su":"sulla",
            "con":"colla",
            "in":"nella",
            "di":"della",
            "da":"dalla"
         }
      };
      
      public function SubstituterIt()
      {
         super();
      }
      
      override protected function getContractionMap() : Object
      {
         return SubstituterIt.contractionMap;
      }
   }
}

