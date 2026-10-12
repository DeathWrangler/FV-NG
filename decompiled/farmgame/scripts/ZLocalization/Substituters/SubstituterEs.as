package ZLocalization.Substituters
{
   public class SubstituterEs extends SubstituterSimple
   {
      
      public function SubstituterEs()
      {
         super();
      }
      
      override public function replace(param1:String, param2:Object) : String
      {
         var _loc3_:String = null;
         var _loc4_:String = null;
         var _loc5_:String = null;
         for(_loc3_ in param2)
         {
            _loc4_ = param2[_loc3_];
            if(_loc4_.indexOf("el ") == 0)
            {
               _loc5_ = _loc4_.substr(3);
               param1 = param1.replace(new RegExp(" de {" + _loc3_ + "}","g")," del " + _loc5_);
               param1 = param1.replace(new RegExp(" a {" + _loc3_ + "}","g")," al " + _loc5_);
            }
            param1 = param1.replace(new RegExp("{" + _loc3_ + "}","g"),_loc4_);
         }
         return param1;
      }
   }
}

