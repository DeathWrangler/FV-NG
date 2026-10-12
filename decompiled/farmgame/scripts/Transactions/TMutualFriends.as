package Transactions
{
   import Classes.Friend;
   import Classes.util.ZLocUtils;
   import Display.GenericIconPopup;
   import Display.GenericPopup;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Events.GenericPopupEvent;
   import Managers.FarmStatsManager;
   
   public class TMutualFriends extends TFarmTransaction
   {
      
      protected static const COUNTER_NAME:String = "neighbor_visit";
      
      protected static const KINGDOM_NAME:String = "mutual_friend_dialog";
      
      protected static const PHYLUM_VIEW:String = "view";
      
      protected static const PHYLUM_ACCEPT:String = "share_button";
      
      protected static const PHYLUM_REJECT:String = "cancel";
      
      protected static const PHYLUM_ERROR:String = "error";
      
      protected static const NO_FRIEND:String = "nofriend";
      
      protected static const W2W_BUNDLE_ID:String = "MutualFriendsTargetingW2W";
      
      protected static const W2W_FEATURE_NAME:String = "MutualFriends";
      
      protected static const W2W_FEED_NAME:String = "TargetingW2W";
      
      protected static const W2W_ICON_URL:String = "assets/newsfeed/sm_recruit.png";
      
      protected var m_neighbor:Friend = null;
      
      protected var m_mutual:Friend = null;
      
      public function TMutualFriends(neighborId:String)
      {
         super();
         this.m_neighbor = Global.friendManager.getFriendData(neighborId);
      }
      
      public static function canFire() : Boolean
      {
         return Global.worldManager.isVisiting();
      }
      
      override public function perform() : void
      {
         if(null != this.m_neighbor)
         {
            signedCall("MutualFriendsService.findMutualFriends",String(this.m_neighbor.uid),W2W_FEATURE_NAME,W2W_FEED_NAME);
         }
      }
      
      override protected function onComplete(result:Object) : void
      {
         if(Boolean(result) && Boolean(Global.worldManager.isVisiting()) && Global.worldManager.getVisiting() == this.m_neighbor.uid.toString())
         {
            if(result.mutualFriendId)
            {
               this.m_mutual = Global.friendManager.getAppFriendData(result.mutualFriendId);
               if(null == this.m_mutual)
               {
                  this.m_mutual = Global.friendManager.getNonAppNetworkFriendData(result.mutualFriendId);
               }
            }
            if(null != this.m_mutual)
            {
               FarmStatsManager.count(COUNTER_NAME,KINGDOM_NAME,PHYLUM_VIEW,this.m_mutual.uid.toString());
               this.displayFeedPrompt();
            }
         }
      }
      
      override protected function onFault(errorType:int, errorData:String) : void
      {
         GlobalEngine.log(W2W_FEATURE_NAME,"Fault in TMutualFriends: " + errorData);
         FarmStatsManager.count(COUNTER_NAME,KINGDOM_NAME,PHYLUM_ERROR);
      }
      
      protected function displayFeedPrompt() : void
      {
         var message:String = ZLocUtils.t("Dialogs","MutualFriends",{
            "friendA":ZLocUtils.tn(this.m_neighbor.firstName,ZLocUtils.tg(this.m_neighbor.snUser.gender)),
            "friendB":ZLocUtils.tn(this.m_mutual.name,ZLocUtils.tg(this.m_mutual.snUser.gender))
         });
         var icon:String = this.m_mutual.picture;
         var feedPrompt:GenericIconPopup = new GenericIconPopup(message,GenericPopup.TYPE_OK,this.onFeedPromptClose,icon);
         UI.displayPopup(feedPrompt);
      }
      
      protected function onFeedPromptClose(event:GenericPopupEvent) : void
      {
         if(event.button == GenericPopup.YES)
         {
            FarmStatsManager.count(COUNTER_NAME,KINGDOM_NAME,PHYLUM_ACCEPT,this.m_mutual.uid.toString());
            this.publishW2W();
         }
         else
         {
            FarmStatsManager.count(COUNTER_NAME,KINGDOM_NAME,PHYLUM_REJECT,this.m_mutual.uid.toString());
         }
      }
      
      protected function publishW2W() : void
      {
         var bundleData:Object = {
            "neighborName":this.m_neighbor.name,
            "mutualFriendName":this.m_mutual.name,
            "images":[{
               "href":"{SN_APP_URL}",
               "src":Global.getAssetURL(W2W_ICON_URL)
            }]
         };
         TransactionManager.addTransaction(new TCreateAndPublishW2W(W2W_BUNDLE_ID,bundleData,this.m_mutual.uid,W2W_FEATURE_NAME,W2W_FEED_NAME));
      }
   }
}

