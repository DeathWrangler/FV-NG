package Classes.FeatureDataObjects
{
   import Classes.feed.FriendSetInviteFeed;
   import Engine.Managers.ErrorManager;
   import Engine.Managers.TransactionManager;
   import Managers.FarmStatsManager;
   import Transactions.TAddToFriendSet;
   import Transactions.TBatchInitializeFriendSets;
   import Transactions.TInitializeLonelyAnimalFriendSet;
   import Transactions.TSetFriendSetSeen;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.utils.Dictionary;
   
   public class FriendSet extends EventDispatcher
   {
      
      public static const FRIEND_SET:String = "FriendSet";
      
      public static const FEATURE_FRIEND_SET:String = "FeatureFriendSet";
      
      public static const NEIGHBOR_FEATURE_FRIEND_SET:String = "NeighborFeatureFriendSet";
      
      public static const ITEM_FEATURE_FRIEND_SET:String = "ItemFeatureFriendSet";
      
      public static const SUPER_CROP_FRIEND_SET:String = "SuperCropFriendSet";
      
      public static const LONELYANIMAL_FEATURE_FRIEND_SET:String = "LonelyAnimalFeatureFriendSet";
      
      public static const MYSTERY_EGG_FRIEND_SET:String = "MysteryEggFriendSet";
      
      public static const VOTING_FEATURE_FRIEND_SET:String = "VotingFeatureFriendSet";
      
      public static const FAKE_FRIEND_UID:int = -2;
      
      protected var m_index:Number = 0;
      
      protected var m_code:String;
      
      protected var m_friends:Dictionary = new Dictionary();
      
      protected var m_numFriends:int;
      
      protected var m_pendingFriends:Array = [];
      
      protected var m_pendingFeeds:FriendSetInviteFeed;
      
      protected var m_recentFriends:Dictionary = new Dictionary();
      
      protected var m_seen:Boolean = false;
      
      protected var m_hasInitialized:Boolean = false;
      
      protected var m_callback:Function = null;
      
      public function FriendSet(code:String, index:Number = -2, callback:Function = null)
      {
         super();
         this.m_code = code;
         this.m_index = index;
         this.m_callback = callback;
      }
      
      public static function factory(code:String, index:Number = -2, callback:Function = null) : FriendSet
      {
         var result:FriendSet = null;
         var friendSetXml:XML = Global.farmGameSettingsManager.getFriendSetXMLByCode(code);
         var className:String = friendSetXml.dataType[0];
         switch(className)
         {
            case FriendSet.FEATURE_FRIEND_SET:
               result = new FeatureFriendSet(code,index,callback);
               break;
            case FriendSet.NEIGHBOR_FEATURE_FRIEND_SET:
               result = new NeighborFeatureFriendSet(code,index,callback);
               break;
            case FriendSet.ITEM_FEATURE_FRIEND_SET:
               result = new ItemFeatureFriendSet(code,index,callback);
               break;
            case FriendSet.LONELYANIMAL_FEATURE_FRIEND_SET:
               result = new LonelyAnimalFeatureFriendSet(code,index,callback);
               break;
            case FriendSet.MYSTERY_EGG_FRIEND_SET:
               result = new MysteryEggFriendSet(code,index,callback);
               break;
            case FriendSet.VOTING_FEATURE_FRIEND_SET:
               result = new VotingFeatureFriendSet(code,index,callback);
               break;
            default:
               result = new FeatureFriendSet(code,index,callback);
         }
         return result;
      }
      
      public function initializeData() : void
      {
         var className:String = null;
         var friendSetXml:XML = Global.farmGameSettingsManager.getFriendSetXMLByCode(this.code);
         if(!friendSetXml)
         {
            ErrorManager.addError("FriendSet.as, initializeData(), friendSetXml is null, code was \'" + this.code + "\'.");
         }
         else
         {
            className = friendSetXml.dataType[0];
            if(className == FriendSet.LONELYANIMAL_FEATURE_FRIEND_SET)
            {
               TransactionManager.addTransaction(new TInitializeLonelyAnimalFriendSet(this),true);
            }
            else
            {
               TBatchInitializeFriendSets.initialize(this);
            }
         }
      }
      
      public function onInitialize(result:Object) : void
      {
         var uids:Object = null;
         var pending:Array = null;
         var uid:String = null;
         var pendingUid:String = null;
         var data:Array = null;
         if(Boolean(result.uids) && Boolean(result.pending))
         {
            uids = result.uids;
            pending = result.pending;
            this.m_numFriends = 0;
            for(uid in uids)
            {
               data = uid.split("_");
               this.m_friends[data[1]] = parseInt(uids[uid]);
               ++this.m_numFriends;
            }
            for each(pendingUid in pending)
            {
               this.m_pendingFriends.push(pendingUid);
            }
            this.m_hasInitialized = true;
         }
         if(this.m_callback != null)
         {
            this.m_callback(this,result);
         }
         dispatchEvent(new Event(Event.COMPLETE));
      }
      
      public function inviteFriend(uid:String, autoPublish:Boolean = false, customMessage:String = "") : void
      {
         if(autoPublish)
         {
            FarmStatsManager.count("FriendSet_" + this.code,"Invite"," Invite_from_guest_extended","Has_message_" + (customMessage != ""));
            if(Boolean(this.m_pendingFeeds) && !this.m_pendingFeeds.published)
            {
               this.m_pendingFeeds.addTarget(uid);
            }
            else
            {
               this.m_pendingFeeds = null;
               this.m_pendingFeeds = new FriendSetInviteFeed(uid,"nyball2011_finished_recruitment",this.m_code,true,customMessage);
            }
         }
         else
         {
            FarmStatsManager.count("FriendSet_" + this.code,"Invite","Invite_from_guest_normal");
            TransactionManager.addTransaction(new TAddToFriendSet(this.m_code,["_" + String(uid)]));
            this.publishInviteFeedWithoutPermissions(uid);
         }
         this.m_friends[uid] = 0;
         this.m_recentFriends[uid] = GlobalEngine.getCurrentTime();
      }
      
      public function get value() : int
      {
         var uid:* = undefined;
         var total:int = 0;
         for(uid in this.m_friends)
         {
            total += this.m_friends[uid];
         }
         return total;
      }
      
      public function get index() : Number
      {
         return this.m_index;
      }
      
      public function set index(value:Number) : void
      {
         this.m_index = value;
      }
      
      public function get code() : String
      {
         return this.m_code;
      }
      
      public function get initialized() : Boolean
      {
         return this.m_hasInitialized;
      }
      
      public function get friends() : Dictionary
      {
         return this.m_friends;
      }
      
      public function get nonNeighborAcceptedFriends() : Array
      {
         var uid:String = null;
         var neighbors:Array = Global.friendManager.neighborUids;
         var nonNeighbors:Array = new Array();
         for(uid in this.m_friends)
         {
            if(this.m_friends[uid] > 0)
            {
               if(neighbors.indexOf(uid) == -1)
               {
                  nonNeighbors.push(uid);
               }
            }
         }
         return nonNeighbors;
      }
      
      public function get numFriends() : int
      {
         return this.m_numFriends;
      }
      
      public function get numFriendsCompleted() : int
      {
         var uid:String = null;
         var count:int = 0;
         for(uid in this.m_friends)
         {
            if(this.m_friends[uid] > 0)
            {
               count++;
            }
         }
         return count;
      }
      
      public function get completedFriends() : Array
      {
         var uid:String = null;
         var completedFriends:Array = new Array();
         for(uid in this.m_friends)
         {
            if(this.m_friends[uid] > 0)
            {
               completedFriends.push(uid);
            }
         }
         return completedFriends;
      }
      
      public function get pendingFriends() : Array
      {
         return this.m_pendingFriends;
      }
      
      public function get votingFriends() : Array
      {
         var votingFriends:Array = new Array();
         votingFriends.push(new Array());
         votingFriends.push(new Array());
         return votingFriends;
      }
      
      public function votingFriendsByIndex(voteIndex:int) : Array
      {
         return new Array();
      }
      
      public function getDifficultyForLevel(level:int, min:int, max:int) : int
      {
         return max;
      }
      
      public function markSeen() : void
      {
         if(!this.m_seen)
         {
            TransactionManager.addTransaction(new TSetFriendSetSeen(this.m_code),true);
         }
         this.m_pendingFriends = [];
         this.m_seen = true;
      }
      
      public function canRequestFriend(uid:String) : Boolean
      {
         var result:Boolean = true;
         if(Boolean(this.m_recentFriends[uid]) && this.m_recentFriends[uid] > 0)
         {
            result = false;
         }
         return result;
      }
      
      public function publishInviteFeedWithoutPermissions(uid:String) : void
      {
         new FriendSetInviteFeed(uid,"nyball2011_finished_recruitment",this.m_code,false);
      }
      
      public function get className() : String
      {
         return FriendSet.FRIEND_SET;
      }
   }
}

