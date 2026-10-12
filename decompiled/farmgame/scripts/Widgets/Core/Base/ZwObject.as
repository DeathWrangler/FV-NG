package Widgets.Core.Base
{
   import Widgets.Core.Util.ZwProfiler;
   import flash.events.EventDispatcher;
   
   public class ZwObject extends EventDispatcher
   {
      
      public function ZwObject()
      {
         super();
         ZwProfiler.getInstance().addRef(this);
      }
      
      public function release() : void
      {
         ZwProfiler.getInstance().removeRef(this);
      }
   }
}

