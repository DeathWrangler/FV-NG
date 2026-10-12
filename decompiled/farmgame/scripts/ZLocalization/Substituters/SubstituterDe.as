package ZLocalization.Substituters
{
   public class SubstituterDe extends SubstituterContractions
   {
      
      protected static var contractionMap:Object = {
         "der":{
            "an":"am",
            "bei":"beim",
            "in":"im",
            "von":"vom",
            "zu":"zum"
         },
         "die":{"zu":"zur"},
         "das":{
            "an":"ans",
            "in":"ins",
            "zu":"zum",
            "von":"vom",
            "bei":"beim"
         },
         "den":{
            "an":"am",
            "bei":"beim",
            "in":"im",
            "von":"vom",
            "zu":"zum"
         }
      };
      
      public function SubstituterDe()
      {
         super();
      }
      
      override protected function getContractionMap() : Object
      {
         return SubstituterDe.contractionMap;
      }
   }
}

