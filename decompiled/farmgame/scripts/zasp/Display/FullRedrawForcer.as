package zasp.Display
{
   import flash.display.Sprite;
   import flash.events.Event;
   
   public class FullRedrawForcer extends Sprite
   {
      
      public function FullRedrawForcer()
      {
         super();
         this.addListener(Event.ADDED_TO_STAGE,this.added_to_stage);
      }
      
      private static function render(param1:int, param2:int, param3:int, param4:int, param5:Object) : void
      {
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         param5.clear();
         param5.lineStyle(1,16777215);
         param5.beginFill(16777215);
         param5.drawRect(2,2,10,10);
         param5.endFill();
         param5.lineStyle(2,11468800);
         param5.moveTo(5,5);
         param5.lineTo(10,10);
         param5.moveTo(5,10);
         param5.lineTo(10,5);
         _loc6_ = 0;
         while(_loc6_ < param2)
         {
            _loc7_ = 0;
            while(_loc7_ < param3)
            {
               param5.drawCircle(_loc6_,_loc7_,param4);
               _loc7_ += param1;
            }
            _loc6_ += param1;
         }
         _loc7_ = 0;
         while(_loc7_ < param3)
         {
            _loc6_ = param2 - 1;
            param5.drawCircle(_loc6_,_loc7_,param4);
            _loc7_ += param1;
         }
         _loc6_ = 0;
         while(_loc6_ < param2)
         {
            _loc7_ = param3 - 1;
            param5.drawCircle(_loc6_,_loc7_,param4);
            _loc6_ += param1;
         }
         _loc6_ = param2 - 1;
         _loc7_ = param3 - 1;
         param5.drawCircle(_loc6_,_loc7_,param4);
      }
      
      private function addListener(param1:String, param2:Function) : void
      {
         addEventListener(param1,param2,false,0,true);
      }
      
      private function removeListener(param1:String, param2:Function) : void
      {
         removeEventListener(param1,param2,false);
      }
      
      private function added_to_stage(param1:Event) : void
      {
         this.removeListener(Event.ADDED_TO_STAGE,this.added_to_stage);
         this.addListener(Event.ENTER_FRAME,this.enter_frame);
         this.addListener(Event.REMOVED_FROM_STAGE,this.removed_from_stage);
      }
      
      private function removed_from_stage(param1:Event) : void
      {
         this.addListener(Event.ADDED_TO_STAGE,this.added_to_stage);
         this.removeListener(Event.ENTER_FRAME,this.enter_frame);
         this.removeListener(Event.REMOVED_FROM_STAGE,this.removed_from_stage);
      }
      
      private function enter_frame(param1:Event) : void
      {
         var _loc2_:int = 160;
         var _loc3_:int = stage.stageWidth;
         var _loc4_:int = stage.stageHeight;
         var _loc5_:int = 2;
         render(_loc2_,_loc3_,_loc4_,_loc5_,graphics);
      }
   }
}

