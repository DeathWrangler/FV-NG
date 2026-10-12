package Managers
{
   import Classes.Constants.MFSConstants;
   import Classes.FeatureBuilding;
   import Classes.SocialRaffle.SocialRaffleConstants;
   import Classes.SocialRaffle.SocialRaffleDataView;
   import Classes.SocialRaffle.SocialRaffleReward;
   import Classes.UGC.UGCTwoIconImage;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Display.GenericIconPopup;
   import Display.GenericPopup;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Events.GenericPopupEvent;
   import Transactions.SocialRaffle.TBuyRaffleTickets;
   import Transactions.SocialRaffle.TFinishRewardFlow;
   import Transactions.SocialRaffle.TGetRaffleData;
   import Transactions.SocialRaffle.TGrantRaffleReward;
   import Transactions.SocialRaffle.TSetSeenRaffleHelpers;
   import Transactions.TSetFriendSetProgress;
   import flash.geom.Rectangle;
   import flash.utils.Dictionary;
   
   public final class SocialRaffleManager
   {
      
      private static var m_initialized:Boolean = false;
      
      private static var m_instance:SocialRaffleManager = null;
      
      private var m_raffleDataView:SocialRaffleDataView = null;
      
      private var m_userRaffleTickets:Array;
      
      private var m_losingRaffleTickets:Array;
      
      private const DAYS_PER_WEEK:int = 7;
      
      private var m_initCallback:Function = null;
      
      private var m_tempData:Object = {};
      
      public function SocialRaffleManager()
      {
         super();
         if(!m_initialized)
         {
            m_initialized = true;
            return;
         }
         throw new Error("Error: Instantiation failed: Use SocialRaffleManager.getInstance() instead of new.");
      }
      
      public static function getInstance() : SocialRaffleManager
      {
         if(m_instance == null)
         {
            m_instance = new SocialRaffleManager();
         }
         return m_instance;
      }
      
      public function init(raffleData:Object) : void
      {
         this.m_raffleDataView = new SocialRaffleDataView(raffleData);
         this.generateRaffleTickets();
         this.updateBuilding();
         if(this.m_initCallback != null)
         {
            this.m_initCallback(this.raffleDataView);
         }
      }
      
      private function updateBuilding(hideIndicator:Boolean = false) : void
      {
         var worldObject:FeatureBuilding = null;
         var worldObjects:Array = Global.world.getObjectsByName("socialrafflebuilding");
         for each(worldObject in worldObjects)
         {
            worldObject.drawDisplayObject();
            if(worldObject.arrowIndicator != null)
            {
               if(hideIndicator)
               {
                  worldObject.arrowIndicator.hide();
               }
               else
               {
                  worldObject.arrowIndicator.show();
               }
            }
         }
         if(this.isRaffleComplete())
         {
            this.setBuildingState(SocialRaffleConstants.BUILDING_STATE_LIGHTS);
         }
         else
         {
            this.setBuildingState(SocialRaffleConstants.BUILDING_STATE_ACTIVE);
         }
      }
      
      public function setBuildingState(state:String = "built_0") : void
      {
         var worldObject:FeatureBuilding = null;
         var worldObjects:Array = Global.world.getObjectsByName("socialrafflebuilding");
         for each(worldObject in worldObjects)
         {
            worldObject.setState(state);
         }
      }
      
      public function isRaffleComplete() : Boolean
      {
         var raffleState:String = null;
         var isRaffleComplete:Boolean = false;
         if(this.m_raffleDataView != null)
         {
            raffleState = this.m_raffleDataView.raffleState;
            if(raffleState == SocialRaffleConstants.STATE_REWARD_CLAIMED || raffleState == SocialRaffleConstants.STATE_REWARD_READY_TO_CLAIM)
            {
               if(this.m_raffleDataView.grantedRewards != null && this.m_raffleDataView.grantedRewards.length > 0)
               {
                  isRaffleComplete = true;
               }
            }
         }
         return isRaffleComplete;
      }
      
      private function displayStorageDialog() : void
      {
         var worldObject:FeatureBuilding = null;
         var worldObjects:Array = Global.world.getObjectsByName("socialrafflebuilding");
         var _loc3_:int = 0;
         var _loc4_:* = worldObjects;
         for each(worldObject in _loc4_)
         {
            worldObject.displayStorageDialog();
         }
      }
      
      public function handleHUDClick() : void
      {
         var worldObjects:Array = Global.world.getObjectsByName("socialrafflebuilding");
         if(Boolean(worldObjects) && worldObjects.length > 0)
         {
            this.displayStorageDialog();
         }
      }
      
      public function reloadData(callback:Function) : void
      {
         var localCallback:Function = function(raffleData:Object):void
         {
            init(raffleData);
            if(callback != null)
            {
               updateBuilding();
               callback();
            }
         };
         TransactionManager.addTransaction(new TGetRaffleData(localCallback),true);
      }
      
      public function get raffleDataView() : SocialRaffleDataView
      {
         return this.m_raffleDataView;
      }
      
      public function setMadeProgress() : void
      {
         if(this.m_raffleDataView != null)
         {
            TransactionManager.addTransaction(new TSetFriendSetProgress(this.m_raffleDataView.friendSetCode,this.m_raffleDataView.currentSet),false);
         }
      }
      
      public function setSeenRaffleHelpers() : void
      {
         TransactionManager.addTransaction(new TSetSeenRaffleHelpers(),false);
      }
      
      public function applyRaffleTicketEffect(numTickets:Number) : void
      {
         var farmItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByName("socialraffleticket");
         var statusMessage:String = ZLocUtils.t("FarmGame","Status_ApplyRaffleTickets",{
            "numTickets":numTickets,
            "ticket_word":ZLocUtils.tk("Dialogs","ticket_word","",numTickets)
         });
         var rect:Rectangle = Global.stage.getRect(Global.stage.parent);
         var centerX:Number = Global.stage.stageWidth / 2;
         var centerY:Number = Global.stage.stageHeight / 2 - 150;
         UI.displayStatus(statusMessage,centerX,centerY,farmItem.icon);
      }
      
      public function buyRaffleTickets(numTickets:Number) : void
      {
         if(this.m_raffleDataView != null)
         {
            this.m_raffleDataView.updateBoughtTickets(numTickets);
            Global.player.cash -= numTickets * SocialRaffleConstants.DEFAULT_TICKET_PRICE;
            TransactionManager.addTransaction(new TBuyRaffleTickets(numTickets),true);
            FarmStatsManager.count(SocialRaffleConstants.STATS_COUNTER,"buy_ticket",String(numTickets));
         }
      }
      
      public function grantReward(raffleIndex:Number, callback:Function = null) : void
      {
         var localCallback:Function = function(result:Object):void
         {
            var raffleDataView:Object = null;
            var grantedRewards:Array = null;
            var raffleReward:SocialRaffleReward = null;
            if(result.success)
            {
               raffleDataView = SocialRaffleManager.getInstance().raffleDataView;
               grantedRewards = raffleDataView.grantedRewards;
               raffleReward = grantedRewards[raffleIndex];
               Global.player.addGift(raffleReward.itemName,"0",raffleReward.qty);
               raffleReward.hasProcessed = true;
            }
            if(callback != null)
            {
               callback();
            }
         };
         TransactionManager.addTransaction(new TGrantRaffleReward(raffleIndex,localCallback),true);
      }
      
      public function finishRewardFlow(callback:Function = null, wonPrizes:Boolean = true) : void
      {
         var localCallback:Function;
         this.m_raffleDataView = null;
         this.updateBuilding(true);
         localCallback = function(raffleData:Object):void
         {
            init(raffleData);
            m_tempData.wonPrizes = wonPrizes;
            m_tempData.endRaffleRewardLink = raffleData.endRaffleRewardLink;
            prepareShareFeed();
            if(callback != null)
            {
               callback();
            }
         };
         TransactionManager.addTransaction(new TFinishRewardFlow(localCallback),true);
      }
      
      protected function prepareShareFeed() : void
      {
         var raffleItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByName("socialraffleticket");
         var grandPrize:SocialRaffleReward = this.m_raffleDataView.grandPrize;
         var prizeItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(grandPrize.itemName);
         this.m_tempData.prizeItem = prizeItem;
         this.m_tempData.ugcImage = new UGCTwoIconImage(UserContentManager.FEATURE_SOCIAL_RAFFLE,raffleItem,prizeItem,this.displayShareDialog);
      }
      
      private function displayShareDialog(rewardData:Object) : void
      {
         var dialogText:String = "";
         if(this.m_tempData.wonPrizes)
         {
            dialogText = ZLocUtils.t("Dialogs","socialrafflebuilding_complete_win");
         }
         else
         {
            dialogText = ZLocUtils.t("Dialogs","socialrafflebuilding_complete_lose");
         }
         this.m_tempData.imagePath = rewardData.imagePath;
         UI.displayPopup(new GenericIconPopup(dialogText,GenericPopup.TYPE_SHARECANCEL,this.onShare,rewardData.imagePath),false);
      }
      
      private function onShare(event:GenericPopupEvent) : void
      {
         var feedImage:String = null;
         var bundleData:Object = null;
         var messageType:String = null;
         if(event.button == GenericPopup.ACCEPT)
         {
            feedImage = this.m_tempData.imagePath;
            bundleData = {
               "images":[{
                  "href":"{SN_APP_URL}?ref=raffle_game_over_free_ticket",
                  "src":feedImage
               }],
               "user":Global.player.firstName,
               "reward_link":this.m_tempData.endRaffleRewardLink,
               "itemName":ZLocUtils.tk_pk_asTitle(this.m_tempData.prizeItem.friendlyName)
            };
            messageType = "SocialRaffleGameOverFreeTicket";
            GlobalEngine.socialNetwork.publishFeedStory(messageType,bundleData,[],false);
         }
         this.displayStorageDialog();
         this.m_tempData = {};
      }
      
      public function askForCrew(method:String) : void
      {
         var featureName:String = null;
         var friendSetCode:String = null;
         var currentFriendSet:Number = NaN;
         var numFriendsToday:Number = NaN;
         if(this.m_raffleDataView != null)
         {
            featureName = SocialRaffleConstants.REQUESTS_FEATURE_NAME;
            friendSetCode = this.m_raffleDataView.friendSetCode;
            currentFriendSet = this.m_raffleDataView.currentSet;
            numFriendsToday = this.m_raffleDataView.friendAcceptsForToday.length;
            MFSRequestManager.getInstance().makeFriendSetRequest("socialraffleticket",featureName,friendSetCode,currentFriendSet,MFSConstants.SOURCE_DIALOG_CLICKED,SocialRaffleConstants.STATS_COUNTER,"crew","ask",String(numFriendsToday));
         }
      }
      
      public function set initCallback(funcInitCallback:Function) : void
      {
         this.m_initCallback = funcInitCallback;
      }
      
      public function get userRaffleTickets() : Array
      {
         return this.m_userRaffleTickets;
      }
      
      public function updateNumGivenTickets(value:Number) : void
      {
         if(this.m_raffleDataView != null)
         {
            this.m_raffleDataView.numGivenTickets += value;
         }
      }
      
      public function selectUserTicket(friendUid:String) : Object
      {
         var bFound:Boolean = false;
         var nRemainingToCheck:* = 0;
         var result:Object = null;
         var iSelectedTicket:int = this.m_userRaffleTickets.length * Math.random();
         if(iSelectedTicket >= this.m_userRaffleTickets.length)
         {
            iSelectedTicket = 0;
         }
         if(friendUid.length > 0)
         {
            bFound = false;
            nRemainingToCheck = int(this.m_userRaffleTickets.length);
            while(!bFound && nRemainingToCheck > 0)
            {
               if(this.m_userRaffleTickets[iSelectedTicket].uid == friendUid)
               {
                  bFound = true;
               }
               else
               {
                  nRemainingToCheck--;
                  if(++iSelectedTicket >= this.m_userRaffleTickets.length)
                  {
                     iSelectedTicket = 0;
                  }
               }
            }
         }
         return this.m_userRaffleTickets[iSelectedTicket];
      }
      
      public function removeLosingTicket() : Object
      {
         var result:Object = null;
         var iSelectedTicket:int = this.m_losingRaffleTickets.length * Math.random();
         if(iSelectedTicket >= this.m_losingRaffleTickets.length)
         {
            iSelectedTicket = 0;
         }
         result = this.m_losingRaffleTickets[iSelectedTicket];
         this.m_losingRaffleTickets.splice(iSelectedTicket,1);
         return result;
      }
      
      private function generateTicketNumber(lastTicket:int) : int
      {
         return int(lastTicket + 1 + int(Math.random() * SocialRaffleConstants.TICKET_SELECT_RANGE));
      }
      
      private function generateRaffleTickets() : void
      {
         var iBoughtTicket:int = 0;
         var iFriendTicket:int = 0;
         var arrFriend:Array = null;
         var nBoughtTicket:int = 0;
         var nFriendTicket:int = 0;
         var nBoughtOrFriend:int = 0;
         var boughtFraction:Number = NaN;
         var iBoughtOrFriend:int = 0;
         var iSelected:int = 0;
         var low:int = 0;
         var high:int = 0;
         var range:int = 0;
         var mid:int = 0;
         var dateInMsAsString:String = this.m_raffleDataView.userStartTime.toString();
         var lsbDateDigits:String = dateInMsAsString.substr(dateInMsAsString.length - 2);
         var ticketBase:int = int(lsbDateDigits);
         if(ticketBase > 90)
         {
            ticketBase -= 90;
         }
         if(ticketBase < 10)
         {
            ticketBase += 10;
         }
         ticketBase *= 10000;
         var firstTicket:int = ticketBase + int(Math.random() * 10000);
         var lastTicket:int = firstTicket;
         var usedNumbers:Dictionary = new Dictionary();
         this.m_userRaffleTickets = new Array();
         for(var iNumGivenTicket:int = 0; iNumGivenTicket < this.m_raffleDataView.numGivenTickets; iNumGivenTicket++)
         {
            lastTicket = this.generateTicketNumber(lastTicket);
            usedNumbers[lastTicket] = true;
            this.m_userRaffleTickets.push({
               "uid":Global.player.uid,
               "number":lastTicket.toString()
            });
         }
         for(var iDay:int = 0; iDay < this.DAYS_PER_WEEK; iDay++)
         {
            iBoughtTicket = 0;
            iFriendTicket = 0;
            arrFriend = this.m_raffleDataView.friendAccepts[iDay];
            nBoughtTicket = int(this.m_raffleDataView.boughtTickets[iDay]);
            nFriendTicket = 0;
            if(arrFriend != null)
            {
               nFriendTicket = int(arrFriend.length);
            }
            nBoughtOrFriend = nBoughtTicket + nFriendTicket;
            boughtFraction = Number(nBoughtTicket) / Number(nBoughtOrFriend);
            for(iBoughtOrFriend = 0; iBoughtOrFriend < nBoughtOrFriend; iBoughtOrFriend++)
            {
               if(iBoughtTicket < nBoughtTicket && Math.random() < boughtFraction || iFriendTicket >= nFriendTicket)
               {
                  lastTicket = this.generateTicketNumber(lastTicket);
                  usedNumbers[lastTicket] = true;
                  this.m_userRaffleTickets.push({
                     "uid":"FC",
                     "day":iDay,
                     "number":lastTicket.toString()
                  });
                  iBoughtTicket++;
               }
               else
               {
                  lastTicket = this.generateTicketNumber(lastTicket);
                  usedNumbers[lastTicket] = true;
                  this.m_userRaffleTickets.push({
                     "uid":arrFriend[iFriendTicket],
                     "day":iDay,
                     "number":lastTicket.toString()
                  });
                  iFriendTicket++;
               }
            }
         }
         this.m_losingRaffleTickets = new Array();
         while(this.m_losingRaffleTickets.length < this.m_raffleDataView.grantedRewards.length * 3)
         {
            iSelected = int(Math.random() * this.m_userRaffleTickets.length);
            if(iSelected + 1 >= this.m_userRaffleTickets.length)
            {
               lastTicket = this.generateTicketNumber(lastTicket);
               usedNumbers[lastTicket] = true;
               this.m_losingRaffleTickets.push({
                  "uid":"GENERIC",
                  "number":lastTicket.toString()
               });
            }
            else
            {
               low = int(this.m_userRaffleTickets[iSelected].number);
               high = int(this.m_userRaffleTickets[iSelected + 1].number);
               range = high - low;
               if(range > 1)
               {
                  mid = low + 1 + Math.random() * (range - 1);
                  if(mid >= high)
                  {
                     mid = high - 1;
                  }
                  if(usedNumbers[mid] == null)
                  {
                     usedNumbers[mid] = true;
                     this.m_losingRaffleTickets.push({
                        "uid":"GENERIC",
                        "number":mid.toString()
                     });
                  }
               }
            }
         }
      }
   }
}

