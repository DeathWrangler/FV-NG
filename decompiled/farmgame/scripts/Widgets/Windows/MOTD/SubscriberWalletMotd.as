package Widgets.Windows.MOTD
{
   import Classes.ZItem.FarmItem;
   import Display.UI;
   import Managers.FarmStatsManager;
   import Managers.SubscriberWalletManager;
   import Widgets.Frames.ObjectPreviewFrame;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class SubscriberWalletMotd extends GenericSingleButtonWidgetMOTD
   {
      
      private var m_rewardCodes:Array;
      
      private var m_movieClips:Array = ["superRare_mc","rare_mc_0","rare_mc_1"];
      
      public function SubscriberWalletMotd(displayParams:Object = null)
      {
         super(displayParams);
         this.m_rewardCodes = new Array();
         this.m_rewardCodes = SubscriberWalletManager.getInstance().getRewardsForMotd();
      }
      
      override protected function postLoadComplete() : void
      {
         var itemCode:String = null;
         var item:FarmItem = null;
         super.postLoadComplete();
         var index:int = 0;
         for each(itemCode in this.m_rewardCodes)
         {
            item = Global.farmGameSettingsManager.getFarmItemByCode(itemCode);
            addWidget(new ObjectPreviewFrame(m_window["mainWindow"][this.m_movieClips[index]],item,null,null,[m_window["mainWindow"][this.m_movieClips[index]]["width"]]),true);
            index++;
         }
         UI.stopPopups(true);
      }
      
      override protected function onAccept(event:MouseEvent) : void
      {
         super.onAccept(event);
         super.onClose(event);
         close();
         UI.stopPopups(false);
         SubscriberWalletManager.getInstance().showMainUI();
         FarmStatsManager.count("subscriber_wallet","MOTD","click");
      }
      
      override protected function onClose(event:Event) : void
      {
         super.onClose(event);
         close();
         UI.stopPopups(false);
      }
   }
}

