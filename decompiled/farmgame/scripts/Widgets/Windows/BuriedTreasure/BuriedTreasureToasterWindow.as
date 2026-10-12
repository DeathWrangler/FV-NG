package Widgets.Windows.BuriedTreasure
{
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Managers.BuriedTreasureManager;
   import Managers.FarmStatsManager;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import Widgets.Windows.AutoCloseToasterWindow;
   import flash.events.Event;
   
   public class BuriedTreasureToasterWindow extends AutoCloseToasterWindow
   {
      
      private static const ASSET_PATH:String = "assets/dialogs/FV_buriedTreasure_Toaster.swf";
      
      private var m_rewardName:String;
      
      public function BuriedTreasureToasterWindow(rewardName:String)
      {
         super(ASSET_PATH);
         this.m_rewardName = rewardName;
      }
      
      override protected function onLoadComplete(event:Event) : void
      {
         var rewardItem:FarmItem = null;
         var rewardFriendlyName:String = null;
         var description:String = null;
         var icon:FarmIcon = null;
         super.onLoadComplete(event);
         if(Boolean(this.m_rewardName) && this.m_rewardName != "")
         {
            rewardItem = Global.farmGameSettingsManager.getFarmItemByName(this.m_rewardName);
            if(rewardItem)
            {
               if(m_window.hasOwnProperty("title_tf"))
               {
                  addWidget(new ZwTextField(m_window.title_tf,ZLocUtils.t("Dialogs","BuriedTreasure_Congrats"))) as ZwTextField;
               }
               rewardFriendlyName = ZLocUtils.tk_pk_asTitle(rewardItem.friendlyName);
               description = ZLocUtils.t("Dialogs","BuriedTreasure_Body",{"rewardName":rewardFriendlyName});
               if(m_window.hasOwnProperty("description_tf"))
               {
                  addWidget(new ZwTextField(m_window.description_tf,description)) as ZwTextField;
               }
               if(m_window.hasOwnProperty("icon_mc"))
               {
                  icon = addWidget(new FarmIcon(m_window.icon_mc)) as FarmIcon;
                  icon.loadIcon(rewardItem.iconUrl);
               }
            }
         }
         FarmStatsManager.count(BuriedTreasureManager.BURIED_TREASURE_COUNTER,"see_toaster");
      }
   }
}

