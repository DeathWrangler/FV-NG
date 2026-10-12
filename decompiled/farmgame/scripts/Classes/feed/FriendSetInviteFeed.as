package Classes.feed
{
   import Engine.Managers.TransactionManager;
   import Transactions.TAddToFriendSet;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   
   public class FriendSetInviteFeed extends FarmFeed
   {
      
      protected const MAX_INVITE_DELAY:int = 30000;
      
      protected var m_publishTimer:Timer;
      
      protected var m_extPerm:Boolean = false;
      
      protected var m_feature:String;
      
      protected var m_hasPublished:Boolean = false;
      
      protected var m_customMessage:String = "";
      
      private const FEED_ICON_URL:String = "assets/newsfeed/newyearsinvite.png";
      
      public function FriendSetInviteFeed(uid:String, bundle:String, feature:String, perm:Boolean = false, message:String = "")
      {
         super();
         m_bundleId = bundle;
         this.m_extPerm = perm;
         this.m_customMessage = message;
         this.m_feature = feature;
         m_targetUids.push("_" + uid);
         m_params.rewardLink = this.getRewardUrl();
         m_params.first_name = Global.player.firstName;
         m_params.images = [{
            "src":Global.getAssetURL(this.FEED_ICON_URL),
            "href":"{SN_APP_URL}" + m_params.rewardLink
         }];
         if(this.m_extPerm)
         {
            this.m_publishTimer = new Timer(5000);
            this.m_publishTimer.addEventListener(TimerEvent.TIMER,this.onPublishTimer);
            this.m_publishTimer.start();
         }
         else
         {
            this.publish();
            this.m_hasPublished = true;
         }
      }
      
      protected function getRewardUrl() : String
      {
         return "confirmfeatureinvite.php?host=" + Global.player.uid + "&feature=" + this.m_feature + "&extPerms=" + this.m_extPerm;
      }
      
      protected function onPublishTimer(e:TimerEvent) : void
      {
         this.m_publishTimer.stop();
         this.m_publishTimer.removeEventListener(TimerEvent.TIMER,this.onPublishTimer);
         this.m_publishTimer = null;
         this.publishWithExtendedPerms();
      }
      
      protected function publishWithExtendedPerms() : void
      {
         var id:String = null;
         var uid:String = null;
         var targets:Array = new Array();
         for each(id in this.m_targetUids)
         {
            targets.push(id.substr(1));
         }
         m_targetUids = targets;
         if(this.m_extPerm)
         {
            TransactionManager.addTransaction(new TAddToFriendSet(this.m_feature,m_targetUids),true);
            for each(uid in this.m_targetUids)
            {
               GlobalEngine.socialNetwork.publishFeedStory(m_bundleId,m_params,[uid],false,null,0,false,true,this.m_customMessage);
            }
         }
         this.m_hasPublished = true;
      }
      
      override public function publish() : void
      {
         var uid:String = null;
         var targets:Array = new Array();
         for each(uid in this.m_targetUids)
         {
            targets.push(uid.substr(1));
         }
         m_targetUids = targets;
         super.publish();
      }
      
      public function addTarget(uid:String) : void
      {
         m_targetUids.push("_" + String(uid));
         this.m_publishTimer.reset();
         this.m_publishTimer.start();
      }
      
      public function get published() : Boolean
      {
         return this.m_hasPublished;
      }
   }
}

