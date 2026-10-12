package Classes.feed
{
   import Classes.FeatureBuilding;
   import Classes.MapResource;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocFailoverEntry;
   import Classes.util.ZLocUtils;
   import Display.GenericIconPopup;
   import Display.GenericPopup;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Events.GenericPopupEvent;
   import Transactions.TCancelFriendReward;
   
   public class ShareHarvestNeighborRewardFeed extends FarmFeed
   {
      
      protected static const LOCALIZATION_KEY_STRING:String = "shareHarvestNeighbor";
      
      protected var m_localizationKey:String = "";
      
      protected var m_harvestedResource:MapResource = null;
      
      protected var m_rewardItem:FarmItem = null;
      
      protected var m_numRewards:int = 1;
      
      public function ShareHarvestNeighborRewardFeed(harvestedResource:MapResource, result:Object)
      {
         var fallbackStats:Object = null;
         super();
         if(result.numRewards)
         {
            this.m_numRewards = result.numRewards;
         }
         else
         {
            this.m_numRewards = (this.m_harvestedResource as FeatureBuilding).storageLevel;
         }
         this.m_rewardItem = Global.farmGameSettingsManager.getFarmItemByName(result.rewardItem);
         this.m_harvestedResource = harvestedResource;
         this.m_localizationKey = getRewardType(harvestedResource);
         var fallbackKey:String = FeatureBuilding.FALLBACK_KEY + LOCALIZATION_KEY_STRING;
         fallbackStats = {"subcategory":this.m_harvestedResource.getItem().name};
         m_bundleId = this.m_localizationKey;
         m_params.reward_link = result.rewardLink;
         m_params.first_name = Global.player.firstName;
         m_params.rewardItem = this.m_rewardItem.friendlyName;
         m_params.building_name = this.m_harvestedResource.getItem().friendlyName;
         m_params.reward_name = this.m_rewardItem.friendlyName;
         m_params.images = [{
            "src":this.m_rewardItem.newsfeed,
            "href":"{SN_APP_URL}" + result.rewardUrl
         }];
         m_params.fallbackAction = fallbackKey;
         m_params.fallbackStats = fallbackStats;
      }
      
      public static function getRewardType(harvestedResource:MapResource) : String
      {
         return harvestedResource.getItem().resourcePrefix + "_" + LOCALIZATION_KEY_STRING;
      }
      
      public function startFeedFlow() : void
      {
         var genericIconPopup:GenericIconPopup = null;
         var fallbackDialogKey:String = FeatureBuilding.FALLBACK_KEY + LOCALIZATION_KEY_STRING;
         var message:String = ZLocUtils.getFailoverLocString([new ZLocFailoverEntry("Dialogs",this.m_localizationKey),new ZLocFailoverEntry("Dialogs",fallbackDialogKey)],{
            "quantity":this.m_numRewards,
            "item":ZLocUtils.tk_pk(this.m_rewardItem.friendlyName,"",this.m_numRewards),
            "building":ZLocUtils.tk_pk(this.m_harvestedResource.getItem().friendlyName)
         });
         var trackerKey:String = "feed-" + this.m_localizationKey;
         if(this.m_rewardItem != null && this.m_rewardItem.icon != null)
         {
            genericIconPopup = new GenericIconPopup(message,GenericPopup.TYPE_SHARE,this.onShare,this.m_rewardItem.icon,false,true,"",true);
            genericIconPopup.setTrackerKey(trackerKey);
            UI.displayPopup(genericIconPopup,true);
         }
         else
         {
            UI.displayMessage(message,GenericPopup.TYPE_SHARE,this.onShare,"",false,false,trackerKey);
         }
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
      
      public function setTargetUids(targets:Array) : void
      {
         this.m_targetUids = targets;
      }
   }
}

