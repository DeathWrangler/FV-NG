package Display
{
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Events.GenericPopupEvent;
   import Managers.FarmStatsManager;
   import flash.events.MouseEvent;
   
   public class HolidayTreePopup extends MysteryPopup
   {
      
      private var m_isTrade:Boolean = false;
      
      private var m_rewardLink:String;
      
      public function HolidayTreePopup(closeCallback:Function = null, item:FarmItem = null, isTrade:Boolean = false, rewardLink:String = null)
      {
         m_dialogAsset = "assets/dialogs/FV_holidayTree.swf";
         super(MysteryPopup.TYPE_CONFIRM,closeCallback,item);
         m_acceptButtonText = isTrade == true ? "Share" : "Okay";
         m_lootableItemName = "present";
         this.m_isTrade = isTrade;
         this.m_rewardLink = rewardLink;
      }
      
      override protected function onLoadComplete() : void
      {
         super.onLoadComplete();
         if(this.m_rewardLink)
         {
            m_reject = new GenericButton(m_window.mysteryBox_mc.cancel_bt,this.onCancel);
            m_reject.text = ZLocUtils.t("Dialogs","Skip");
            m_window.mysteryBox_mc.cancel_bt.visible = true;
         }
         else
         {
            m_window.mysteryBox_mc.okay_bt.x += 55;
            m_window.mysteryBox_mc.cancel_bt.visible = false;
         }
         FarmStatsManager.count("holidayTree","shareable_present","impressions");
      }
      
      override protected function onCancel(event:MouseEvent) : void
      {
         describeDialogOpen = false;
         if(m_closeCallback != null)
         {
            removeEventListener(GenericPopupEvent.SELECTED,m_closeCallback);
         }
         FarmStatsManager.count("holidayTree","shareable_present","cancel");
         close();
      }
      
      override protected function onOkClick(event:MouseEvent) : void
      {
         var params:Object = null;
         if(this.m_rewardLink)
         {
            params = {
               "item_name":m_item.friendlyName,
               "actor":Global.player.snUser.firstName,
               "reward_link":this.m_rewardLink,
               "images":[{
                  "src":m_item.getImageByName("icon"),
                  "href":"{SN_APP_URL}" + this.m_rewardLink
               }]
            };
            GlobalEngine.socialNetwork.publishFeedStory("HolidayTree_ShareWealth",params,[],false);
            FarmStatsManager.count("holidayTree","shareable_present","share");
         }
         super.onOkClick(event);
      }
   }
}

