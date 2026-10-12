package Classes.Tutorial
{
   import Classes.EmbeddedArt;
   import Classes.Managers.HUDTutorialManager;
   import Classes.util.ZLocUtils;
   import Display.HUD.HUDWidgets.HUDTutorialWindow;
   import GameMode.GMFishing;
   import GameMode.GameMode;
   import Managers.FishingDerbyManager;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.geom.Point;
   
   public class FishingModeTutState implements IHUDTutorialState
   {
      
      private var m_completed:Boolean = false;
      
      private var m_ftueConfig:Object;
      
      private var m_bouncingArrow:DisplayObject;
      
      public function FishingModeTutState(ftueConfig:Object)
      {
         super();
         this.m_ftueConfig = ftueConfig;
      }
      
      public function initialize() : void
      {
         var message:String = ZLocUtils.t_pk(this.m_ftueConfig.message);
         var showButton:Boolean = false;
         HUDTutorialManager.instance.hudTutorial.updateText(message,showButton,HUDTutorialWindow.LARGE_BUBBLE);
         Global.world.addGameMode(new GMFishing(null,true,{"tutorial":true}),true);
         Global.world.addEventListener(GMFishing.FISHING_DISABLED,this.onMouseUp);
         Global.world.addEventListener(GMFishing.FISHING_CAST,this.updateProgress);
         FishingDerbyManager.detachAllFishingBobbers();
         var tutArrowClass:Class = EmbeddedArt.bouncing_arrow;
         var tutArrowMC:MovieClip = new tutArrowClass() as MovieClip;
         tutArrowMC.visible = true;
         var coordsArray:Array = (this.m_ftueConfig.coords as String).split(",");
         var coords:Point = new Point(coordsArray[0],coordsArray[1]);
         this.m_bouncingArrow = new EmbeddedArt.bouncing_arrow() as DisplayObject;
         this.m_bouncingArrow.x = 600;
         this.m_bouncingArrow.y = 200;
         this.m_bouncingArrow.scaleX = 1;
         this.m_bouncingArrow.scaleY = -1;
         this.m_bouncingArrow.rotation = 135;
         Global.hud.addChildAt(this.m_bouncingArrow,0);
      }
      
      private function updateProgress(event:Event = null) : void
      {
         this.m_completed = true;
         if(this.isCompleted())
         {
            HUDTutorialManager.instance.step();
         }
      }
      
      private function onMouseUp(event:Event) : void
      {
         var gameMode:GameMode = Global.world.getTopGameMode();
      }
      
      public function isCompleted() : Boolean
      {
         return this.m_completed;
      }
      
      public function cleanUp() : void
      {
         Global.world.removeEventListener(HUDTutorialManager.EVENT_CONTINUE,this.updateProgress);
         Global.world.removeEventListener(GMFishing.FISHING_CAST,this.updateProgress);
         Global.world.removeEventListener(GMFishing.FISHING_DISABLED,this.onMouseUp);
         if(this.m_bouncingArrow)
         {
            Global.hud.removeChild(this.m_bouncingArrow);
            this.m_bouncingArrow = null;
         }
      }
   }
}

