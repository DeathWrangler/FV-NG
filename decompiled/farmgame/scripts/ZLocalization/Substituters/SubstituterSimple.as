package ZLocalization.Substituters
{
   public class SubstituterSimple
   {
      
      public function SubstituterSimple()
      {
         super();
      }
      
      public function replace(param1:String, param2:Object) : String
      {
         var _loc3_:String = null;
         for(_loc3_ in param2)
         {
            param1 = param1.replace(new RegExp("{" + _loc3_ + "}","g"),param2[_loc3_]);
         }
         return param1;
      }
   }
}

