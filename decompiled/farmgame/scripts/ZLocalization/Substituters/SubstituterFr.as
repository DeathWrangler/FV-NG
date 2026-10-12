package ZLocalization.Substituters
{
   public class SubstituterFr extends SubstituterContractions
   {
      
      protected static const VOWEL:String = "vowel";
      
      protected static const CONSONANT:String = "consonant";
      
      protected static var vowels:Object = {
         "a":1,
         "à":1,
         "á":1,
         "â":1,
         "ä":1,
         "e":1,
         "è":1,
         "é":1,
         "ê":1,
         "ë":1,
         "i":1,
         "ì":1,
         "í":1,
         "î":1,
         "ï":1,
         "o":1,
         "ò":1,
         "ó":1,
         "ô":1,
         "ö":1,
         "u":1,
         "ù":1,
         "ú":1,
         "û":1,
         "ü":1
      };
      
      protected static var contractionMap:Object = {
         "le":{
            "de":"du",
            "à":"au"
         },
         "les":{
            "de":"des",
            "à":"aux"
         },
         "un":{"de":"d\'un"},
         "une":{"de":"d\'une"},
         "des":{"de":{
            "vowel":"d\'",
            "consonant":"de"
         }}
      };
      
      public function SubstituterFr()
      {
         super();
      }
      
      override protected function getContractionMap() : Object
      {
         return SubstituterFr.contractionMap;
      }
      
      override protected function getContraction(param1:Object, param2:String) : String
      {
         if(typeof param1 == "string")
         {
            return String(param1);
         }
         var _loc3_:Array = param2.match(/\S/);
         var _loc4_:String = _loc3_[0];
         if(SubstituterFr.vowels.hasOwnProperty(_loc4_))
         {
            return param1[SubstituterFr.VOWEL];
         }
         return param1[SubstituterFr.CONSONANT];
      }
   }
}

