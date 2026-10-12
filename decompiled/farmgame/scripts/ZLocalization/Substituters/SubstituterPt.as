package ZLocalization.Substituters
{
   public class SubstituterPt extends SubstituterContractions
   {
      
      protected static var contractionMap:Object = {
         "o":{
            "de":"do",
            "em":"no",
            "por":"pelo",
            "a":"ao"
         },
         "a":{
            "de":"da",
            "em":"na",
            "por":"pela",
            "a":"à"
         },
         "os":{
            "de":"dos",
            "em":"nos",
            "por":"pelos",
            "a":"aos"
         },
         "as":{
            "de":"das",
            "em":"nas",
            "por":"pelas",
            "a":"às"
         }
      };
      
      public function SubstituterPt()
      {
         super();
      }
      
      override protected function getContractionMap() : Object
      {
         return SubstituterPt.contractionMap;
      }
   }
}

