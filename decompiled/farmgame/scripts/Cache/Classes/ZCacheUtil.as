package Cache.Classes
{
   public class ZCacheUtil
   {
      
      public function ZCacheUtil()
      {
         super();
      }
      
      public static function traceActivity(param1:String, param2:String) : void
      {
      }
      
      public static function getFilenameFromUrl(param1:String) : String
      {
         return param1.substring(param1.lastIndexOf("/") + 1);
      }
      
      public static function callback(param1:Function, param2:* = null, param3:Array = null) : void
      {
         if(param1 !== null)
         {
            param1.apply(param2,param3);
         }
      }
      
      public static function applyPartial(param1:Function, param2:*, param3:Array = null) : Function
      {
         var _:Function = null;
         var f:Function = param1;
         var context:* = param2;
         var args:Array = param3;
         if(f == null)
         {
            throw new Error("Cannot bind a null function!");
         }
         _ = f;
         return function(... rest):*
         {
            return _.apply(context,args ? args.concat(rest) : rest);
         };
      }
   }
}

