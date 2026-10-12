package MyLife
{
   import flash.utils.ByteArray;
   
   public class MyLifeUtils
   {
      
      private static const SALT:String = "2a716a175fe550f7";
      
      public function MyLifeUtils()
      {
         super();
      }
      
      public static function deepTrace(param1:*, param2:int = 0) : void
      {
         var _loc3_:String = "";
      }
      
      public static function cloneObject(param1:Object) : *
      {
         var _loc2_:ByteArray = new ByteArray();
         _loc2_.writeObject(param1);
         _loc2_.position = 0;
         return _loc2_.readObject();
      }
      
      public static function peekArray(param1:Array, param2:int = 0) : *
      {
         var _loc4_:* = undefined;
         var _loc3_:int = 0;
         for each(_loc4_ in param1)
         {
            if(_loc3_ == param2)
            {
               return _loc4_;
            }
            _loc3_++;
         }
         return null;
      }
      
      public static function deleteItemFromData(param1:String, param2:Object) : Object
      {
         var _loc3_:String = null;
         var _loc4_:Object = null;
         var _loc5_:String = null;
         if(Number(param1) > 0)
         {
            for(_loc3_ in param2)
            {
               _loc4_ = param2[_loc3_];
               _loc5_ = _loc4_.hasOwnProperty("itemId") && Number(_loc4_["itemId"]) > 0 ? _loc4_["itemId"] : null;
               if((Boolean(_loc5_)) && Boolean(param1) && _loc5_ == param1)
               {
                  delete param2[_loc3_];
               }
            }
         }
         return param2;
      }
   }
}

