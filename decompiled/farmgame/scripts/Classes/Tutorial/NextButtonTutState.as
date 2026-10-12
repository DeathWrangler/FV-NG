package Classes.Tutorial
{
   import Classes.EmbeddedArt;
   import Classes.Managers.HUDTutorialManager;
   import Classes.util.ZLocUtils;
   import Display.HUD.HUDWidgets.HUDTutorialWindow;
   import Display.UI;
   import flash.display.DisplayObject;
   
   public class NextButtonTutState implements IHUDTutorialState
   {
      
      private static const X_COORDINATE:int = 0;
      
      private static const Y_COORDINATE:int = 1;
      
      private var m_completed:Boolean = false;
      
      private var m_ftueConfig:Object;
      
      private var m_bouncingArrow:DisplayObject;
      
      public function NextButtonTutState(ftueConfig:Object)
      {
         super();
         this.m_ftueConfig = ftueConfig;
      }
      
      public function initialize() : void
      {
         var coordinates:Array = null;
         var message:String = ZLocUtils.t_pk(this.m_ftueConfig.message);
         var showButton:Boolean = this.m_ftueConfig.button != "false";
         var buttonText:String = null;
         if(this.m_ftueConfig.hasOwnProperty("buttonText"))
         {
            buttonText = this.m_ftueConfig.buttonText;
         }
         HUDTutorialManager.instance.hudTutorial.updateText(message,showButton,HUDTutorialWindow.EXTRA_LARGE_BUBBLE,buttonText);
         if(this.m_ftueConfig.hasOwnProperty("arrowIndicator"))
         {
            this.m_bouncingArrow = new EmbeddedArt.bouncing_arrow() as DisplayObject;
            coordinates = (this.m_ftueConfig.arrowIndicator as String).split(",");
            if(Boolean(coordinates) && Boolean(coordinates[X_COORDINATE]) && Boolean(coordinates[Y_COORDINATE]))
            {
               if(this.m_ftueConfig.hasOwnProperty("absoluteUIPosition") && this.m_ftueConfig.absoluteUIPosition == "true")
               {
                  this.m_bouncingArrow.x = int(coordinates[X_COORDINATE]);
                  this.m_bouncingArrow.y = int(coordinates[Y_COORDINATE]);
                  this.m_bouncingArrow.scaleX = 1;
                  this.m_bouncingArrow.scaleY = -1;
                  this.m_bouncingArrow.rotation = 90;
                  Global.hud.addChildAt(this.m_bouncingArrow,0);
               }
               else
               {
                  this.m_bouncingArrow.x = GlobalEngine.stage.stageWidth - UI.DEFAULT_WIDTH + int(coordinates[X_COORDINATE]);
                  this.m_bouncingArrow.y = int(coordinates[Y_COORDINATE]);
                  this.m_bouncingArrow.scaleX = 1;
                  this.m_bouncingArrow.scaleY = -1;
                  this.m_bouncingArrow.rotation = 90;
                  Global.hud.addChildAt(this.m_bouncingArrow,0);
               }
               if(this.m_ftueConfig.hasOwnProperty("arrowRotation"))
               {
                  this.m_bouncingArrow.rotation = this.m_ftueConfig.arrowRotation;
               }
            }
         }
      }
      
      public function isCompleted() : Boolean
      {
         return true;
      }
      
      public function cleanUp() : void
      {
         if(this.m_bouncingArrow)
         {
            Global.hud.removeChild(this.m_bouncingArrow);
            this.m_bouncingArrow = null;
         }
      }
   }
}

