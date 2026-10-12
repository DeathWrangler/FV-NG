package Classes
{
   import Classes.util.ZLocUtils;
   import Display.ContextMenuItem;
   import Engine.Managers.SoundManager;
   import Managers.FarmStatsManager;
   import flash.events.MouseEvent;
   
   public class ResourceHarvester extends ResourceEquipment
   {
      
      public static const REWARD_WINDOW_TIMER_DELAY:int = 2000;
      
      public static const MORE_INFO_ACTION:String = "showMoreInfo";
      
      public function ResourceHarvester(itemName:String = null, active:Boolean = false, upgradeParts:Number = 0)
      {
         super(itemName,active,upgradeParts);
      }
      
      override protected function getMenuItems() : Array
      {
         var menuArray:Array = super.getMenuItems();
         menuArray.push({
            "label":ZLocUtils.t("FarmGame","ContextMenuMoreInfo"),
            "action":MORE_INFO_ACTION
         });
         return menuArray;
      }
      
      override public function onMenuClick(event:MouseEvent) : void
      {
         var item:ContextMenuItem = null;
         if(event.target is ContextMenuItem)
         {
            item = event.target as ContextMenuItem;
            switch(item.action)
            {
               case HORN:
                  SoundManager.addSound("harvesterHorn",Global.getAssetURL("assets/sounds/harvester_horn.mp3"));
                  SoundManager.playSound("harvesterHorn");
                  break;
               case MORE_INFO_ACTION:
                  this.showTutorial();
                  FarmStatsManager.count("tutorial",getItemName(),"menu");
                  break;
               case SELECT_PATTERN_ACTION:
                  showSelectPatternWindow(Equipment.SOURCE_CONTEXT_MENU);
                  break;
               default:
                  super.onMenuClick(event);
            }
         }
      }
      
      override public function performEquipmentAction(source:String = null) : void
      {
         if(source)
         {
            FarmStatsManager.count("equipment_action_source",this.getItemName(),source);
         }
      }
      
      protected function onFirstTimeTutorialClosed() : void
      {
         showSelectPatternWindow("tutorial");
      }
      
      override public function onPlacedFirstTime() : void
      {
         var seenFlag:String = getItemName() + "_tutorial";
         if(!Global.player.getSeenFlag(seenFlag))
         {
            Global.player.setSeenFlag(seenFlag);
            this.showTutorial(this.onFirstTimeTutorialClosed);
            FarmStatsManager.count("tutorial",getItemName(),"on_place");
         }
      }
      
      protected function displayRewardWindow(assetPath:String = null) : void
      {
      }
      
      public function showTutorial(closeCallback:Function = null) : void
      {
      }
   }
}

