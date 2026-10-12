package Classes
{
   import Classes.util.ZLocUtils;
   import Display.ContextMenuItem;
   import Display.TutorialUI;
   import Display.UI;
   import GameMode.GMIrrigationSprinkler;
   import Managers.FarmStatsManager;
   import Widgets.Windows.IrrigationFTUECompleteWindow;
   import flash.events.MouseEvent;
   
   public class IrrigationSprinkler extends Equipment
   {
      
      public static const MORE_INFO_ACTION:String = "showMoreInfo";
      
      private static const TUTORIAL_ASSET_PATH_PREFIX:String = "assets/dialogs/4d_elements/Irrigation/irrigation_sprinkler";
      
      public function IrrigationSprinkler(itemName:String = null, active:Boolean = false, upgradeParts:Number = 0)
      {
         super(itemName,active,upgradeParts);
      }
      
      override public function onMenuClick(event:MouseEvent) : void
      {
         var item:ContextMenuItem = null;
         if(event.target is ContextMenuItem)
         {
            item = event.target as ContextMenuItem;
            switch(item.action)
            {
               case LOOK_INSIDE:
                  break;
               case MOVE_OBJECT:
                  this.move();
                  break;
               case SELL_OBJECT:
                  this.sell();
                  break;
               case MORE_INFO_ACTION:
                  this.showTutorial();
                  FarmStatsManager.count("tutorial",getItemName(),"menu");
                  break;
               case VEHICLE_ACTION:
                  Global.world.addGameMode(new GMIrrigationSprinkler(this));
                  break;
               default:
                  super.onMenuClick(event);
            }
         }
      }
      
      override public function onPlacedFirstTime() : void
      {
         super.onPlacedFirstTime();
         UI.displayPopup(new IrrigationFTUECompleteWindow());
      }
      
      override protected function getMenuItems() : Array
      {
         var menuArray:Array = new Array();
         var action:String = this.getItem().className;
         menuArray = [{
            "label":ZLocUtils.t("FarmGame",action),
            "action":VEHICLE_ACTION
         },{
            "label":ZLocUtils.t("FarmGame","ContextMenuMoreInfo"),
            "action":MORE_INFO_ACTION
         },{
            "label":ZLocUtils.t("FarmGame","Move"),
            "action":MOVE_OBJECT
         },{
            "label":ZLocUtils.t("FarmGame","Sell"),
            "action":SELL_OBJECT
         }];
         return getStoreOptions(menuArray);
      }
      
      public function showTutorial(closeCallback:Function = null) : void
      {
         TutorialUI.displayBundleTutorialWindow("Dialogs","IrrigationSprinkler",TUTORIAL_ASSET_PATH_PREFIX,true,closeCallback);
      }
   }
}

