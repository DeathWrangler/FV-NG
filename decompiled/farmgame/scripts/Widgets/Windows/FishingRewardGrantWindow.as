package Widgets.Windows
{
   import Classes.ZItem.FarmItem;
   import Managers.FarmStatsManager;
   import Managers.FishingV2Manager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class FishingRewardGrantWindow extends GenericSingleRewardPopup
   {
      
      private var m_bonusItemName:Array = null;
      
      private var m_shareButton:FarmAnimatedTextButton;
      
      private var m_rewardItem:FarmItem;
      
      private var m_rewardType:String;
      
      public function FishingRewardGrantWindow(dialogAsset:String, featureName:String, rewardItem:FarmItem, callback:Function = null, dialogBackground:String = null, rewardType:String = null)
      {
         m_featureName = featureName;
         this.m_rewardType = rewardType;
         this.m_rewardItem = rewardItem;
         super(dialogAsset,featureName,rewardItem,callback,dialogBackground);
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         if(m_window.hasOwnProperty("okay_bt"))
         {
         }
      }
      
      override protected function afterLoad() : void
      {
         if(m_window.hasOwnProperty("bonus_mc"))
         {
            m_window["bonus_mc"].visible = false;
         }
      }
      
      public function closePopup(event:MouseEvent = null) : void
      {
         super.close();
      }
      
      public function shareCallback(e:Event) : void
      {
         var fi:FarmItem = this.m_rewardItem;
         var bundleData:Object = {
            "images":[{
               "href":"{SN_APP_URL}",
               "src":fi.icon
            }],
            "user":Global.player.firstName,
            "item":fi.friendlyTitle
         };
         GlobalEngine.socialNetwork.publishFeedStory("FishingV2_BragFeed",bundleData,[],false,null);
         close();
         FarmStatsManager.count(FishingV2Manager.FEATURE_NAME,"reward_bragfeed",fi.friendlyTitle);
      }
   }
}

