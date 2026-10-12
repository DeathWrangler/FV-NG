package Widgets.Windows.MOTD
{
   import Classes.ZItem.FarmItem;
   import Display.UI;
   import Managers.FarmStatsManager;
   import Managers.SubscriberWalletManager;
   import Widgets.Frames.ObjectPreviewFrame;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class SubscriberWalletNewRewardsMOTD extends GenericSingleButtonWidgetMOTD
   {
      
      private var m_rewardCodes:Array;
      
      private var m_movieClips:Array;
      
      public function SubscriberWalletNewRewardsMOTD(displayParams:Object = null)
      {
         var rewardItem:Object = null;
         this.m_movieClips = ["superRare_mc","rare_mc_0","rare_mc_1"];
         super(displayParams);
         this.m_rewardCodes = new Array();
         var rewards:Object = SubscriberWalletManager.getInstance().getNewRewardsArray();
         for each(rewardItem in rewards)
         {
            if(this.m_rewardCodes.length == 3)
            {
               break;
            }
            if(rewardItem.hasOwnProperty("rewardType") && (rewardItem["rewardType"] == "ultrarare" || rewardItem["rewardType"] == "superrare"))
            {
               this.m_rewardCodes.push(rewardItem["rewardItemName"]);
            }
         }
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
         FarmStatsManager.count("subscriber_wallet","newRewardsMOTD","click");
      }
      
      override protected function onClose(event:Event) : void
      {
         super.onClose(event);
         close();
         UI.stopPopups(false);
      }
   }
}

