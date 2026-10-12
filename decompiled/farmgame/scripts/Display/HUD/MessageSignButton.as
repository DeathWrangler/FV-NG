package Display.HUD
{
   import Classes.util.ZLocUtils;
   import Display.SpriteButton;
   import GameMode.GMMessageSignPlace;
   import flash.events.Event;
   
   public class MessageSignButton extends SpriteButton
   {
      
      private static const X_POSITION:Number = 487;
      
      private static const Y_POSITION:Number = 9;
      
      public function MessageSignButton(normalImageClass:Class, overImageClass:Class, downImageClass:Class)
      {
         super(normalImageClass,overImageClass,downImageClass,this.placeMessageSign);
         this.x = X_POSITION;
         this.y = Y_POSITION;
         this.toolTip = ZLocUtils.t("FarmGame","MessageSign_ToolTip");
      }
      
      private function placeMessageSign(event:Event) : void
      {
         Global.world.addGameMode(new GMMessageSignPlace("messageSign"));
      }
   }
}

