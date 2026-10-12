package cipro.Profiler
{
   public class GameTagObject
   {
      
      public var value:*;
      
      public var name:String;
      
      public var accessor:Function;
      
      public var type:int;
      
      public var updateMethod:int;
      
      private var changeCallbacks:Vector.<Function> = null;
      
      public function GameTagObject(param1:String, param2:Function, param3:int, param4:int)
      {
         super();
         this.name = param1;
         this.accessor = param2;
         this.type = param3;
         this.updateMethod = param4;
      }
      
      public function refresh() : void
      {
         this.value = this.accessor();
      }
   }
}

