package Display
{
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Managers.FarmStatsManager;
   import flash.events.Event;
   
   public class QuestConsumableBoxMigrationNotificationPopup
   {
      
      protected static var m_dialog:FarmDynamicDialog;
      
      private static const QUEST_CONSUMABLE_STORAGE_MOVED_FLAG:String = "queststoragemoved";
      
      private static const QUEST_CONSUMABLE_STORAGE_MOVED_TOASTER_SHOWN_FLAG:String = "queststoragemovednotif";
      
      private static const ITEMNAME:String = "consume_coins_50";
      
      private static const PLAYER_MIN_LEVEL:Number = 5;
      
      public function QuestConsumableBoxMigrationNotificationPopup()
      {
         super();
      }
      
      public static function canShow() : Boolean
      {
         var result:Boolean = false;
         if(Global.player.getSeenFlag(QUEST_CONSUMABLE_STORAGE_MOVED_FLAG) && Global.player.level >= PLAYER_MIN_LEVEL)
         {
            if(!Global.player.getSeenFlag(QUEST_CONSUMABLE_STORAGE_MOVED_TOASTER_SHOWN_FLAG))
            {
               result = true;
               FarmStatsManager.sample(100,"questConsumableMigrationNotif","success","scheduledToShowDialog");
            }
         }
         return result;
      }
      
      public static function showDialog() : void
      {
         var textTitle:String = ZLocUtils.t("Dialogs","QuestConsumableBoxMigration_Title");
         var textSubtitle:String = ZLocUtils.t("Dialogs","QuestConsumableBoxMigration_Subtitle");
         var item:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(ITEMNAME);
         var itemIconAssetPath:String = item.icon;
         m_dialog = UI.showMessage(textSubtitle,UI.BUTTON_LAYOUT_OK,textTitle,itemIconAssetPath,false,setToasterSeenFlag,null,true,null);
         FarmStatsManager.sample(100,"questConsumableMigrationNotif","success","dialogShowed");
      }
      
      public static function setToasterSeenFlag(event:Event) : void
      {
         Global.player.setSeenFlag(QUEST_CONSUMABLE_STORAGE_MOVED_TOASTER_SHOWN_FLAG,true);
         FarmStatsManager.sample(100,"questConsumableMigrationNotif","success","pressedOk");
         if(m_dialog)
         {
            m_dialog.destroy();
            FarmStatsManager.sample(100,"questConsumableMigrationNotif","success","dialogDestoryed");
         }
      }
   }
}

