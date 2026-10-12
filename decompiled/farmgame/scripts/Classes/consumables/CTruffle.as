package Classes.consumables
{
   import Classes.Consumable;
   import Classes.util.ZLocUtils;
   import Display.GenericIconPopup;
   import Display.GenericPopup;
   import Display.UI;
   import Events.GenericPopupEvent;
   import Managers.FarmStatsManager;
   
   public class CTruffle extends Consumable
   {
      
      private var m_rewardData:Object;
      
      private var m_rewardIconPath:String;
      
      private var m_rewardFriendlyName:String;
      
      public function CTruffle(itemName:String)
      {
         super(itemName);
      }
      
      override public function initialize(data:Object) : void
      {
         this.m_rewardData = data;
      }
      
      override public function onUse() : void
      {
         var itemName:String = null;
         var dialog:GenericIconPopup = null;
         if(Boolean(this.m_rewardData) && this.m_rewardData.hasOwnProperty("rewardName"))
         {
            itemName = this.m_rewardData["rewardName"];
            this.m_rewardFriendlyName = "Items:" + itemName + "_friendlyName";
            Global.player.addGift(itemName);
            this.m_rewardIconPath = m_item.iconUrl;
            UI.closeAndLockGifts();
            dialog = new GenericIconPopup(ZLocUtils.t("Dialogs","truffleShareBody",{
               "itemA":ZLocUtils.tk_pk(m_item.friendlyName),
               "itemB":ZLocUtils.tk_pk(this.m_rewardFriendlyName)
            }),GenericPopup.TYPE_SHARE,this.onCloseRewardPopup,this.m_rewardIconPath);
            dialog.setTrackerKey("pigpen_share_prize");
            UI.displayPopup(dialog,false);
            FarmStatsManager.count("pigpen","truffleInventory","sharePrizeDialog","show");
         }
      }
      
      private function onCloseRewardPopup(event:GenericPopupEvent) : void
      {
         var bundleData:Object = null;
         if(event.button == GenericPopup.ACCEPT)
         {
            bundleData = {
               "reward_link":this.m_rewardData.rewardUrl,
               "itemName":this.m_rewardFriendlyName,
               "images":[{
                  "href":"{SN_APP_URL}" + this.m_rewardData.rewardUrl,
                  "src":this.m_rewardIconPath
               }]
            };
            FarmStatsManager.count("pigpen","truffleInventory","sharePrizeDialog","clickShare");
            Global.farmSocialNetwork.publishFeedStory("PigpenShareTrufflePrize",bundleData,null,false);
         }
         else
         {
            FarmStatsManager.count("pigpen","truffleInventory","sharePrizeDialog","clickCancel");
         }
         UI.unlockGifts();
         UI.displayGiftBoxWindow(false);
      }
   }
}

