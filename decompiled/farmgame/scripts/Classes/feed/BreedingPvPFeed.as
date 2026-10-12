package Classes.feed
{
   import Classes.Friend;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Display.GenericIconPopup;
   import Display.GenericPopup;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Events.GenericPopupEvent;
   import Managers.BreedingManager;
   import Transactions.TBreedingPvPFeed;
   import Transactions.TCancelFriendReward;
   
   public class BreedingPvPFeed extends FarmFeed
   {
      
      protected static const LOCALIZATION_KEY_STRING:String = "PvP";
      
      protected var m_localizationKey:String = "";
      
      protected var m_rewardItem:FarmItem = null;
      
      protected var m_featureItem:FarmItem = null;
      
      protected var m_featureName:String;
      
      protected var m_friend:Friend;
      
      public function BreedingPvPFeed(featureName:String, friend:Friend)
      {
         super();
         this.m_featureName = featureName;
         this.m_friend = friend;
         this.m_featureItem = Global.farmGameSettingsManager.getFarmItemByName(featureName);
         m_params.first_name = Global.player.firstName;
         m_params.neighbor = friend.firstName;
         TransactionManager.addTransaction(new TBreedingPvPFeed(featureName,this));
      }
      
      public function onGetReward(result:Object) : void
      {
         this.m_rewardItem = Global.farmGameSettingsManager.getFarmItemByCode(result.rewardItem);
         this.m_localizationKey = this.m_featureName + "_" + LOCALIZATION_KEY_STRING;
         m_bundleId = this.m_localizationKey;
         m_params.reward_link = result.rewardLink;
         m_params.images = [{
            "src":this.m_featureItem.icon,
            "href":"{SN_APP_URL}" + result.rewardUrl
         }];
         m_params.rank = BreedingManager.getInstance().getPvPRankByFeatureName(this.m_featureName);
         m_params.stat = BreedingManager.getInstance().getPvPStatByFeatureName(this.m_featureName);
         this.startFeedFlow();
      }
      
      public function startFeedFlow() : void
      {
         var dialogText:String = ZLocUtils.t("Dialogs",this.m_localizationKey,{
            "user":ZLocUtils.tn(this.m_friend.firstName,ZLocUtils.tg(this.m_friend.snUser.gender)),
            "rankNum":m_params.rank
         });
         var dialog:GenericIconPopup = new GenericIconPopup(dialogText,GenericPopup.TYPE_SHARE,this.onShare,this.m_friend.picture,false,true);
         UI.displayPopup(dialog,false,this.m_featureName + "_PassNeighbor",true);
      }
      
      protected function onShare(event:GenericPopupEvent) : void
      {
         if(GenericPopup.ACCEPT == event.button)
         {
            this.publish();
         }
         else
         {
            TransactionManager.addTransaction(new TCancelFriendReward([m_params.reward_link]));
         }
      }
      
      override public function publish() : void
      {
         GlobalEngine.socialNetwork.publishFeedStory(m_bundleId,m_params,m_targetUids,false,m_publishCallback);
      }
   }
}

