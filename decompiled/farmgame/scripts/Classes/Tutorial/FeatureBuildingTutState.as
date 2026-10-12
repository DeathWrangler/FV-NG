package Classes.Tutorial
{
   import Classes.FeatureBuilding;
   import Classes.FeatureComponents.TutorialArrowIndicatorFManager;
   import Classes.Managers.HUDTutorialManager;
   import Classes.util.ZLocUtils;
   import Display.HUD.HUDWidgets.HUDTutorialWindow;
   import flash.events.Event;
   
   public class FeatureBuildingTutState implements IHUDTutorialState
   {
      
      private var m_completed:Boolean = false;
      
      private var m_ftueConfig:Object;
      
      private var m_featureBuilding:FeatureBuilding;
      
      public function FeatureBuildingTutState(ftueConfig:Object)
      {
         super();
         this.m_ftueConfig = ftueConfig;
      }
      
      public function initialize() : void
      {
         var tutArrow:TutorialArrowIndicatorFManager = null;
         Global.world.addEventListener(this.m_ftueConfig.eventType,this.onUpdateProgress);
         var itemCode:String = this.m_ftueConfig.itemCode;
         var worldItems:Array = Global.world.getObjectsByCode(itemCode);
         if(worldItems.length > 0)
         {
            this.m_featureBuilding = worldItems[0] as FeatureBuilding;
            if(this.m_featureBuilding != null)
            {
               this.m_featureBuilding.setHighlighted(true);
               this.m_featureBuilding.centerOn();
               tutArrow = this.m_featureBuilding.arrowIndicator as TutorialArrowIndicatorFManager;
               tutArrow.canShow = true;
               this.m_featureBuilding.showIndicator();
            }
            else
            {
               this.m_completed = true;
            }
         }
         else
         {
            this.m_completed = true;
         }
         HUDTutorialManager.instance.step();
         var message:String = ZLocUtils.t_pk(this.m_ftueConfig.message);
         HUDTutorialManager.instance.hudTutorial.updateText(message,false,HUDTutorialWindow.LARGE_BUBBLE);
      }
      
      private function onUpdateProgress(event:Event) : void
      {
         this.m_completed = true;
         if(this.isCompleted())
         {
            HUDTutorialManager.instance.step();
         }
      }
      
      public function isCompleted() : Boolean
      {
         return this.m_completed;
      }
      
      public function cleanUp() : void
      {
         Global.world.removeEventListener(this.m_ftueConfig.eventType,this.onUpdateProgress);
         if(this.m_featureBuilding != null)
         {
            this.m_featureBuilding.hideIndicator();
            this.m_featureBuilding.setHighlighted(false);
         }
      }
   }
}

