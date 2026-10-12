package Classes.Tutorial
{
   import Classes.EmbeddedArt;
   import Classes.FarmGameObject;
   import Classes.Managers.HUDTutorialManager;
   import Classes.util.ZLocUtils;
   import Display.HUD.HUDWidgets.HUDTutorialWindow;
   import flash.display.DisplayObject;
   import flash.events.Event;
   
   public class NextButtonCenteredWithArrowTutState implements IHUDTutorialState
   {
      
      private static const CENTER_WIDTH_OF_SCREEN:int = GlobalEngine.stage.stageWidth / 2;
      
      private static const CENTER_HEIGHT_OF_SCREEN:int = GlobalEngine.stage.stageHeight / 2;
      
      private static const X_COORDINATE:int = 0;
      
      private static const Y_COORDINATE:int = 1;
      
      private var m_completed:Boolean = false;
      
      private var m_ftueConfig:Object;
      
      private var m_bouncingArrow:DisplayObject;
      
      public function NextButtonCenteredWithArrowTutState(ftueConfig:Object)
      {
         super();
         this.m_ftueConfig = ftueConfig;
      }
      
      public function initialize() : void
      {
         var itemCode:String = null;
         var worldItems:Array = null;
         var message:String = null;
         var position:Array = null;
         var gameObject:FarmGameObject = null;
         var farmGameObject:FarmGameObject = null;
         var coordinates:Array = null;
         if(this.m_ftueConfig.eventType)
         {
            Global.world.addEventListener(this.m_ftueConfig.eventType,this.updateProgress);
         }
         if(this.m_ftueConfig.itemCode)
         {
            itemCode = this.m_ftueConfig.itemCode;
            worldItems = Global.world.getObjectsByCode(itemCode);
         }
         if(Boolean(worldItems) && worldItems.length > 0)
         {
            if(this.m_ftueConfig.itemPosition)
            {
               position = (this.m_ftueConfig.itemPosition as String).split(",");
               if(Boolean(position) && Boolean(position[X_COORDINATE]) && Boolean(position[Y_COORDINATE]))
               {
                  for each(gameObject in worldItems)
                  {
                     if(gameObject.getPosition().x == position[X_COORDINATE] && gameObject.getPosition().y == position[Y_COORDINATE])
                     {
                        gameObject.setHighlighted(true);
                        if(Boolean(this.m_ftueConfig.shouldCenterOnItem) && this.m_ftueConfig.shouldCenterOnItem != "false")
                        {
                           gameObject.centerOn();
                        }
                        break;
                     }
                     gameObject.setHighlighted(false);
                  }
               }
            }
            else
            {
               farmGameObject = worldItems[0] as FarmGameObject;
               if(farmGameObject != null)
               {
                  farmGameObject.setHighlighted(true);
                  if(Boolean(this.m_ftueConfig.shouldCenterOnItem) && this.m_ftueConfig.shouldCenterOnItem != "false")
                  {
                     farmGameObject.centerOn();
                  }
               }
            }
         }
         if(this.m_ftueConfig.message)
         {
            message = ZLocUtils.t_pk(this.m_ftueConfig.message);
         }
         var showButton:Boolean = false;
         if(this.m_ftueConfig.hasOwnProperty("button"))
         {
            showButton = this.m_ftueConfig.button != "false";
         }
         if(this.m_ftueConfig.hasOwnProperty("button"))
         {
            showButton = this.m_ftueConfig.button != "false";
         }
         var buttonText:String = null;
         if(this.m_ftueConfig.hasOwnProperty("buttonText"))
         {
            buttonText = this.m_ftueConfig.buttonText;
         }
         if(HUDTutorialManager.instance.hudTutorial)
         {
            HUDTutorialManager.instance.hudTutorial.updateText(message,showButton,HUDTutorialWindow.EXTRA_LARGE_BUBBLE,buttonText);
         }
         if(this.m_ftueConfig.hasOwnProperty("offset"))
         {
            coordinates = (this.m_ftueConfig.offset as String).split(",");
            if(Boolean(coordinates) && Boolean(coordinates[X_COORDINATE]) && Boolean(coordinates[Y_COORDINATE]))
            {
               this.m_bouncingArrow = new EmbeddedArt.bouncing_arrow() as DisplayObject;
               this.m_bouncingArrow.x = CENTER_WIDTH_OF_SCREEN - coordinates[X_COORDINATE];
               this.m_bouncingArrow.y = CENTER_HEIGHT_OF_SCREEN - coordinates[Y_COORDINATE];
               this.m_bouncingArrow.scaleX = 1;
               this.m_bouncingArrow.scaleY = -1;
               this.m_bouncingArrow.rotation = 90;
               Global.hud.addChildAt(this.m_bouncingArrow,0);
            }
         }
      }
      
      private function updateProgress(event:Event = null) : void
      {
         this.m_completed = true;
         HUDTutorialManager.instance.step();
      }
      
      public function isCompleted() : Boolean
      {
         return this.m_completed;
      }
      
      public function cleanUp() : void
      {
         if(this.m_bouncingArrow)
         {
            Global.hud.removeChild(this.m_bouncingArrow);
            this.m_bouncingArrow = null;
         }
         if(Global.world.hasEventListener(this.m_ftueConfig.eventType))
         {
            Global.world.removeEventListener(this.m_ftueConfig.eventType,this.updateProgress);
         }
      }
   }
}

