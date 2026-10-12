package Display
{
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import flash.events.MouseEvent;
   
   public class SweetSeedsThanks extends Dialog
   {
      
      private static const SWEETSEEDS_FEED_ICON:String = "assets/newsfeed/sweetseedsforhaiti_newsfeed02.png";
      
      private var m_accept:GenericButton;
      
      private var m_skip:GenericButton;
      
      private var m_rewardName:String = "";
      
      private var m_rewardLink:String = "";
      
      private var m_itemName:String = "";
      
      public function SweetSeedsThanks(itemName:String, rewardName:String = "", rewardLink:String = "")
      {
         m_dialogAsset = "assets/dialogs/FV_SweetSeedsThanks.swf";
         this.m_rewardName = rewardName;
         this.m_rewardLink = rewardLink;
         this.m_itemName = itemName;
         super();
      }
      
      override protected function onLoadComplete() : void
      {
         super.onLoadComplete();
         m_window.sweetSeedsThanks_mc = m_window.getChildAt(0);
         m_window.sweetSeedsThanks_mc.congrats_tf.text = ZLocUtils.t("Dialogs","ThanksForDonating");
         m_window.sweetSeedsThanks_mc.body0_tf.text = ZLocUtils.t("Dialogs","ReminderDonating");
         m_window.sweetSeedsThanks_mc.body1_tf.text = ZLocUtils.t("Dialogs","ReminderGiftBox");
         m_window.sweetSeedsThanks_mc.body2_tf.htmlText = ZLocUtils.t("Dialogs","TrackProgress",{"link":GlobalEngine.getFlashVar("sn_app_url")});
         this.m_accept = new GenericButton(m_window.sweetSeedsThanks_mc.share_bt,this.onShareClick);
         this.m_accept.text = ZLocUtils.t("Dialogs","ShareItem");
         this.m_skip = new GenericButton(m_window.sweetSeedsThanks_mc.skip_bt,this.onSkipClick);
         this.m_skip.text = ZLocUtils.t("Dialogs","Skip");
      }
      
      override public function onShareClick(event:MouseEvent) : void
      {
         var rewardItem:FarmItem = null;
         super.onShareClick(event);
         event.stopPropagation();
         var images:Array = [];
         var picSource:String = Global.getAssetURL(SweetSeedsThanks.SWEETSEEDS_FEED_ICON);
         images.push({
            "src":picSource,
            "href":"{SN_APP_URL}{creative:picture}" + this.m_rewardLink
         });
         if(this.m_rewardLink)
         {
            rewardItem = Global.farmGameSettingsManager.getFarmItemByName(this.m_rewardName);
            GlobalEngine.socialNetwork.publishFeedStory("SweetSeedsHaiti",{
               "player_name":Global.player.snUser.firstName,
               "item_name":rewardItem.friendlyName,
               "images":images,
               "reward_link":this.m_rewardLink,
               "subCategory":"sweet_seeds_haiti"
            },[],false);
         }
         else
         {
            GlobalEngine.socialNetwork.publishFeedStory("SweetSeedsHaiti",{
               "images":images,
               "reward_link":""
            },[],false);
         }
         close();
         UI.displayMarketDialog("acceptDonateSharePopup");
      }
      
      private function onSkipClick(event:MouseEvent) : void
      {
         event.stopPropagation();
         close();
         UI.displayMarketDialog("cancelDonateSharePopup");
      }
   }
}

