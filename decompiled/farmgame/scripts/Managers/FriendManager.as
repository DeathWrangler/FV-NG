package Managers
{
   import Classes.Constants.Experiments;
   import Classes.Friend;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Engine.Classes.SocialNetworkUser;
   import Engine.Managers.TransactionManager;
   import Events.FriendManagerEvent;
   import Transactions.TGetFriendsMetaDataForUids;
   import flash.events.EventDispatcher;
   
   public class FriendManager
   {
      
      public static const NEIGHBOR_BCKGND_THANK:String = "_thank";
      
      public static const NEIGHBOR_BCKGND_NEW:String = "_new";
      
      public static const NEIGHBOR_BCKGND_ADD:String = "_add";
      
      public static const NEIGHBOR_BCKGND_ZZZ:String = "_zzz";
      
      public static const NEIGHBOR_BCKGND_HELPER:String = "_helper";
      
      public static const NEIGHBOR_BCKGND_COMMUNITY:String = "_community";
      
      protected var m_unparsedFriends:Array = [];
      
      protected var m_unparsedSNData:Array = [];
      
      protected var m_networkNeighbors:Array = [];
      
      protected var m_networkNeighborUids:Array = [];
      
      protected var m_appFriends:Array = [];
      
      protected var m_appFriendUids:Array = [];
      
      protected var m_nonNetworkNeighbors:Array = [];
      
      protected var m_nonNetworkNeighborUids:Array = [];
      
      protected var m_nonAppNetworkFriends:Array = [];
      
      protected var m_friendBarFriends:Array = [];
      
      protected var m_neighborUids:Array = [];
      
      protected var m_communityNeighbors:Object = {};
      
      protected var m_backendNeighborCount:int = 0;
      
      protected var m_neighborDataSet:Boolean = false;
      
      protected var m_networkDataSet:Boolean = false;
      
      protected var m_appFriendDataSet:Boolean = false;
      
      protected var m_neighborsWithEmailPermission:int = -1;
      
      protected var m_questFriends:Object;
      
      protected var m_usedPhotoContestFriends:Array = null;
      
      protected var m_testFriends:Array = [];
      
      protected var m_compressedString:String;
      
      protected var m_eventDispatcher:EventDispatcher = new EventDispatcher();
      
      public function FriendManager()
      {
         super();
      }
      
      public function getFriendData(uid:String) : Friend
      {
         var idx:int = 0;
         var friend:Friend = null;
         if(this.m_networkNeighbors.length > 0)
         {
            for(idx = 0; idx < this.m_networkNeighbors.length; idx++)
            {
               if(this.m_networkNeighbors[idx].uid == uid)
               {
                  friend = this.m_networkNeighbors[idx];
                  break;
               }
            }
         }
         else if(this.m_neighborDataSet)
         {
            for(idx = 0; idx < this.m_unparsedFriends.length; idx++)
            {
               if(this.m_unparsedFriends[idx].uid == uid)
               {
                  friend = new Friend(this.m_unparsedFriends[idx]);
                  break;
               }
            }
         }
         if(!friend)
         {
            friend = this.getAppFriendData(uid);
         }
         return friend;
      }
      
      public function getFriendObjects(uids:Array) : Array
      {
         var index:Number = NaN;
         var friend:Friend = null;
         var friendObjects:Array = new Array();
         if(uids != null)
         {
            for(index = 0; index < uids.length; index++)
            {
               friend = this.getAppFriendData(uids[index]);
               if(friend == null)
               {
                  friend = this.getNonAppNetworkFriendData(uids[index]);
               }
               friendObjects.push(friend);
            }
         }
         return friendObjects;
      }
      
      public function getAppFriendData(uid:String) : Friend
      {
         var idx:int = 0;
         var friend:Friend = null;
         if(uid == Global.getZyngaUserId())
         {
            friend = this.getZyngaUserFriend();
         }
         else
         {
            for(idx = 0; idx < this.m_appFriends.length; idx++)
            {
               if(this.m_appFriends[idx].uid == uid)
               {
                  friend = this.m_appFriends[idx];
                  break;
               }
            }
         }
         return friend;
      }
      
      public function getNonAppNetworkFriendData(uid:String) : Friend
      {
         var idx:int = 0;
         var friend:Friend = null;
         if(uid == Global.getZyngaUserId())
         {
            friend = this.getZyngaUserFriend();
         }
         else
         {
            for(idx = 0; idx < this.m_nonAppNetworkFriends.length; idx++)
            {
               if(this.m_nonAppNetworkFriends[idx].uid == uid)
               {
                  friend = this.m_nonAppNetworkFriends[idx];
                  break;
               }
            }
         }
         return friend;
      }
      
      public function getZyngaUserFriend() : Friend
      {
         var zyngaSNUser:SocialNetworkUser = new SocialNetworkUser(Global.getZyngaUserId());
         zyngaSNUser.name = ZLocUtils.t("FarmVille","ZyngaUserName");
         zyngaSNUser.firstName = ZLocUtils.t("FarmVille","ZyngaUserName");
         zyngaSNUser.picture = Global.getAssetURL(Global.farmGameSettingsManager.getString("zyngaUserProfilePic"));
         return new Friend(null,zyngaSNUser,true,true);
      }
      
      public function getFriendName(uid:String, firstNameOnly:Boolean = false) : String
      {
         var result:String = "";
         var friend:Friend = this.getAppFriendData(uid);
         if(friend != null)
         {
            if(firstNameOnly)
            {
               result = friend.firstName;
            }
            else
            {
               result = friend.name;
            }
         }
         return result;
      }
      
      public function getFriendGender(uid:String) : String
      {
         var result:String = "";
         var friend:Friend = this.getAppFriendData(uid);
         if(friend != null && null != friend.snUser && null != friend.snUser.gender)
         {
            result = friend.snUser.gender;
         }
         return result;
      }
      
      public function get neighbors() : Array
      {
         return this.m_networkNeighbors;
      }
      
      public function get friendBarFriends() : Array
      {
         return this.m_friendBarFriends;
      }
      
      public function get appFriends() : Array
      {
         return this.m_appFriends;
      }
      
      public function get neighborUids() : Array
      {
         return this.m_neighborUids;
      }
      
      public function get networkNeighborUids() : Array
      {
         return this.m_networkNeighborUids;
      }
      
      public function get nonNetworkNeighborUids() : Array
      {
         return this.m_nonNetworkNeighborUids;
      }
      
      public function get appFriendUids() : Array
      {
         return this.m_appFriendUids;
      }
      
      public function get nonAppNetworkFriends() : Array
      {
         return this.m_nonAppNetworkFriends;
      }
      
      public function initializeFriendsMetaDataForUids(uids:Array, callback:Function = null) : void
      {
         TransactionManager.addTransaction(new TGetFriendsMetaDataForUids(uids,function(result:Object):void
         {
            if(callback != null)
            {
               friendsMetaData = result;
               callback(result);
            }
         }));
      }
      
      public function getQuestFriends(questChainName:String) : Array
      {
         var friends:Array = null;
         var i:int = 0;
         if(null == this.m_questFriends)
         {
            this.m_questFriends = new Object();
         }
         if(null == this.m_questFriends[questChainName])
         {
            friends = new Array();
            for(i = 0; i < this.m_networkNeighbors.length; i++)
            {
               if(null != (this.m_networkNeighbors[i] as Friend).getActiveQuestByChain(questChainName))
               {
                  friends.push(this.m_networkNeighbors[i]);
               }
            }
            this.m_questFriends[questChainName] = friends;
         }
         return this.m_questFriends[questChainName];
      }
      
      public function get neighborCount() : int
      {
         return this.m_backendNeighborCount;
      }
      
      public function get numNeighborBarExperimentFriends() : int
      {
         return this.m_testFriends ? int(this.m_testFriends.length) : 0;
      }
      
      public function countFriendsWithEmailPermission() : Number
      {
         var i:int = 0;
         if(this.m_neighborsWithEmailPermission == -1)
         {
            this.m_neighborsWithEmailPermission = 0;
            for(i = 0; i < this.m_networkNeighbors.length; i++)
            {
               if(this.m_networkNeighbors[i].uid != Global.player.uid)
               {
                  if(this.m_networkNeighbors.hasEmailPermissions)
                  {
                     ++this.m_neighborsWithEmailPermission;
                  }
               }
            }
         }
         return this.m_neighborsWithEmailPermission;
      }
      
      public function getPhotoContestFriends() : Array
      {
         var neighbor:Friend = null;
         if(this.m_usedPhotoContestFriends == null)
         {
            this.m_usedPhotoContestFriends = new Array();
            for each(neighbor in this.neighbors)
            {
               if(neighbor.usedPhotoContest == true)
               {
                  this.m_usedPhotoContestFriends.push(neighbor);
               }
            }
         }
         return this.m_usedPhotoContestFriends.concat();
      }
      
      public function setSNUsers(data:Array) : void
      {
         this.m_networkDataSet = true;
         if(data.length > 0)
         {
            this.m_unparsedSNData = data;
            this.m_unparsedSNData.sortOn("uid",Array.NUMERIC);
         }
         this.parseFriends();
      }
      
      public function setCompressedString(st:String) : void
      {
         this.m_compressedString = st;
         this.setUnparsedFriendData();
      }
      
      public function refreshFriendsData() : void
      {
         if(this.m_compressedString != null)
         {
            this.setUnparsedFriendData(this.m_compressedString);
            this.cleanupData();
            this.m_compressedString = null;
         }
      }
      
      public function setUnparsedFriendData(compressedData:String = "") : void
      {
         var data:Array;
         var playerIdx:int = 0;
         Global.farmTimingModule.start("FriendManager_setUnparsedFriendData");
         data = null;
         try
         {
            data = FarmGameUtil.uncompressAndDecode(compressedData,"FriendManager_setUnparsedFriendData") as Array;
         }
         catch(err:Error)
         {
         }
         this.m_neighborDataSet = true;
         if(Boolean(data) && data.length > 0)
         {
            for(playerIdx = 0; playerIdx < data.length; playerIdx++)
            {
               if(data[playerIdx].uid == null)
               {
                  data.slice(playerIdx,1);
               }
               else
               {
                  data[playerIdx].uid = FarmGameUtil.snuidToUid(data[playerIdx].uid);
               }
            }
            this.m_unparsedFriends = data;
            this.m_unparsedFriends.sortOn("uid",Array.NUMERIC);
         }
         this.parseFriends();
         Global.farmTimingModule.end("FriendManager_setUnparsedFriendData");
      }
      
      public function promoteFriendToNeighbor(friendData:Object) : Friend
      {
         var appFriend:Friend = null;
         var result:Friend = null;
         friendData.uid = FarmGameUtil.snuidToUid(friendData.uid);
         for(var i:int = 0; i < this.m_appFriends.length; i++)
         {
            appFriend = this.m_appFriends[i] as Friend;
            if(appFriend.uid == friendData.uid)
            {
               this.m_appFriends.splice(i,1);
               this.m_networkNeighbors.push(appFriend);
               result = appFriend;
               break;
            }
         }
         this.updateFriendLists();
         this.populateFriendBar();
         return result;
      }
      
      public function set appFriendUids(data:Array) : void
      {
         this.m_appFriendDataSet = true;
         if(Boolean(data) && data.length > 0)
         {
            this.m_appFriendUids = data;
            this.m_appFriendUids.sort(Array.NUMERIC);
         }
         this.parseFriends();
      }
      
      public function set neighborCount(count:int) : void
      {
         this.m_backendNeighborCount = count;
      }
      
      public function set neighborUids(input:Array) : void
      {
         this.m_neighborUids = input;
      }
      
      public function isCommunityNeighbor(uid:String) : Boolean
      {
         var ret:Boolean = false;
         if(this.m_nonNetworkNeighborUids.indexOf(uid) >= 0)
         {
            ret = true;
         }
         return ret;
      }
      
      public function set friendsMetaData(metaDatas:Object) : void
      {
         var key:String = null;
         var uid:String = null;
         var friend:Friend = null;
         for(key in metaDatas)
         {
            uid = metaDatas[key].uid;
            friend = this.getAppFriendData(uid);
            if(friend)
            {
               friend.setMetaData(metaDatas[key]);
            }
         }
      }
      
      private function traceUnparsedSNData() : String
      {
         var i:int = 0;
         var snData:SocialNetworkUser = null;
         var result:String = "";
         if(this.m_unparsedSNData)
         {
            for(i = 0; i < this.m_unparsedSNData.length; i++)
            {
               snData = this.m_unparsedSNData[i];
               result = result + "[SocialNetworkUser uid:" + snData.uid + " name:" + snData.firstName + "]";
            }
         }
         return result;
      }
      
      public function parseFriends() : void
      {
         var dataIdx:int = 0;
         var inDataRange:Boolean = false;
         var snData:SocialNetworkUser = null;
         var friendData:Object = null;
         var isAppFriend:Boolean = false;
         var uid:String = null;
         var max_number:String = null;
         var snDataIdMapping:Object = null;
         var snIdindex:int = 0;
         var snDataIdMappingIndex:String = null;
         var friend:Friend = null;
         if(this.m_neighborDataSet && this.m_networkDataSet && this.m_appFriendDataSet)
         {
            dataIdx = 0;
            inDataRange = dataIdx < this.m_unparsedFriends.length;
            snData = null;
            friendData = null;
            isAppFriend = false;
            uid = "0";
            max_number = String(Number.MAX_VALUE);
            snDataIdMapping = new Object();
            snDataIdMappingIndex = null;
            if(inDataRange)
            {
               for(snIdindex = 0; snIdindex < this.m_unparsedSNData.length; snIdindex++)
               {
                  snDataIdMappingIndex = this.m_unparsedSNData[snIdindex].uid;
                  if(snDataIdMappingIndex)
                  {
                     snDataIdMapping[snDataIdMappingIndex] = snIdindex;
                  }
               }
            }
            while(inDataRange)
            {
               uid = max_number;
               if(inDataRange)
               {
                  uid = this.m_unparsedFriends[dataIdx].uid;
               }
               snData = null;
               friendData = null;
               isAppFriend = false;
               if(snDataIdMapping[uid] != null)
               {
                  snData = this.m_unparsedSNData[snDataIdMapping[uid]];
               }
               friendData = this.m_unparsedFriends[dataIdx];
               dataIdx++;
               if(this.m_appFriendUids.indexOf(uid) != -1)
               {
                  isAppFriend = true;
               }
               if(friendData)
               {
                  friendData.isNeighbor = false;
                  if(this.m_neighborUids.indexOf(uid) != -1)
                  {
                     friendData.isNeighbor = true;
                  }
               }
               friend = new Friend(friendData,snData);
               if(Boolean(friendData) || Boolean(snData) && Boolean(isAppFriend))
               {
                  if(friendData)
                  {
                     if(snData)
                     {
                        this.m_networkNeighbors.push(friend);
                     }
                     else
                     {
                        this.m_nonNetworkNeighbors.push(friend);
                     }
                  }
                  if(isAppFriend || Boolean(friend.isCommunityNeighbor))
                  {
                     this.m_appFriends.push(friend);
                  }
               }
               else
               {
                  this.m_nonAppNetworkFriends.push(friend);
               }
               inDataRange = dataIdx < this.m_unparsedFriends.length;
            }
            this.updateFriendLists();
            if(!this.isInLazyLoadExperiment())
            {
               this.cleanupData();
            }
         }
         this.populateFriendBar();
         this.m_eventDispatcher.dispatchEvent(new FriendManagerEvent(FriendManagerEvent.PARSEFRIENDS_COMPLETE));
      }
      
      private function cleanupData() : void
      {
         this.m_unparsedSNData = null;
         this.m_unparsedFriends = null;
         this.m_neighborDataSet = false;
         this.m_networkDataSet = false;
      }
      
      private function isInLazyLoadExperiment() : Boolean
      {
         var ret:Boolean = false;
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_LAZYLOAD_NEIGHBORBAR) == 1)
         {
            ret = true;
         }
         return ret;
      }
      
      public function registerEventListener(callback:Function) : void
      {
         if(callback != null)
         {
            this.m_eventDispatcher.addEventListener(FriendManagerEvent.PARSEFRIENDS_COMPLETE,callback);
         }
      }
      
      public function unregisterEventListener(callback:Function) : void
      {
         if(callback != null)
         {
            this.m_eventDispatcher.removeEventListener(FriendManagerEvent.PARSEFRIENDS_COMPLETE,callback);
         }
      }
      
      public function getStateString() : String
      {
         var f:Object = null;
         var result:String = "friendBar: ";
         for(var i:int = 0; i < this.m_friendBarFriends.length; i++)
         {
            f = this.m_friendBarFriends[i];
            if(f)
            {
               result = result + f.uid + " ";
            }
         }
         result += "m_networkNeighbors:";
         for(var j:int = 0; j < this.m_networkNeighbors.length; j++)
         {
            f = this.m_networkNeighbors[j];
            if(f)
            {
               result = result + f.uid + " ";
            }
         }
         result += "m_nonNetworkNeighbors:";
         for(var k:int = 0; k < this.m_nonNetworkNeighbors.length; k++)
         {
            f = this.m_networkNeighbors[k];
            if(f)
            {
               result = result + f.uid + " ";
            }
         }
         return result;
      }
      
      protected function updateFriendLists() : void
      {
         var idx:int = 0;
         var inactivExpVariant:int = Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_NEIGHBORS_BAR_INACTIVE);
         this.m_friendBarFriends = this.m_networkNeighbors.concat();
         this.m_friendBarFriends.push(Global.player);
         if(inactivExpVariant > 0)
         {
            this.m_friendBarFriends.sortOn(["inInactiveExp","currentWorldScore","xp"],[Array.DESCENDING,Array.NUMERIC,Array.NUMERIC]);
         }
         else
         {
            this.m_friendBarFriends.sortOn(["currentWorldScore","xp"],[Array.NUMERIC,Array.NUMERIC]);
         }
         FarmStatsManager.count("neighbor_bar","0",String(this.m_friendBarFriends.length));
         this.m_networkNeighbors.sortOn(["currentWorldScore","xp"],[Array.NUMERIC,Array.NUMERIC]);
         this.m_nonNetworkNeighbors.sortOn(["currentWorldScore","xp"],[Array.NUMERIC,Array.NUMERIC]);
         for(idx = 0; idx < this.m_networkNeighbors.length; idx++)
         {
            this.m_networkNeighborUids[idx] = this.m_networkNeighbors[idx].uid;
         }
         for(idx = 0; idx < this.m_nonNetworkNeighbors.length; idx++)
         {
            this.m_nonNetworkNeighborUids[idx] = this.m_nonNetworkNeighbors[idx].uid;
         }
      }
      
      protected function populateFriendBar() : void
      {
         if(this.m_friendBarFriends.length > 0 && Boolean(Global.ui))
         {
            Global.ui.m_friendBar.populateNeighbors(this.m_friendBarFriends);
         }
      }
   }
}

