package DataObjects
{
   public class BaseDataObject
   {
      
      public static const NUMERIC_DEFAULT_VALUE:Number = -2147483648;
      
      public function BaseDataObject()
      {
         super();
      }
      
      protected function _toString(param1:String = "DataObject") : String
      {
         if(param1 == null)
         {
            param1 = "";
         }
         return param1;
      }
      
      public function toString() : String
      {
         return this._toString();
      }
      
      public function isSet(param1:String) : Boolean
      {
         var _loc2_:Boolean = false;
         if(hasOwnProperty(param1))
         {
            if(this[param1] is int || this[param1] is Number)
            {
               _loc2_ = this[param1] != BaseDataObject.NUMERIC_DEFAULT_VALUE;
            }
            else
            {
               _loc2_ = this[param1] != null;
            }
         }
         return _loc2_;
      }
   }
}

