package cipro.Profiler
{
   public class GameTagAssignObject extends GameTagObject
   {
      
      private var changeCallbacks:Vector.<Function> = null;
      
      public function GameTagAssignObject(param1:String, param2:Function, param3:int, param4:int)
      {
         super(param1,param2,param3,param4);
      }
      
      override public function refresh() : void
      {
         var _loc2_:Function = null;
         var _loc1_:* = value;
         value = accessor();
         if(this.changeCallbacks != null && value != _loc1_)
         {
            for each(_loc2_ in this.changeCallbacks)
            {
               _loc2_(name);
            }
         }
      }
      
      public function addCallback(param1:Function) : void
      {
         if(this.changeCallbacks == null)
         {
            this.changeCallbacks = new Vector.<Function>();
         }
         this.changeCallbacks.push(param1);
      }
   }
}

