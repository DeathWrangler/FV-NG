package Transactions.NeighborActions
{
   import Classes.FeedTroughBuilding;
   import Classes.Friend;
   import Classes.VisitorManager;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Display.GenericIconPopup;
   import Display.GenericPopup;
   import Display.UI;
   import Engine.Classes.WorldObject;
   import Engine.Managers.TransactionManager;
   import Events.GenericPopupEvent;
   import Managers.FarmStatsManager;
   import Transactions.TCancelFriendReward;
   
   public class TDepositNeighborAnimalFeed extends TBaseNeighborAction
   {
      
      private var m_rewardLink:String = "";
      
      private var m_jackpotAmount:int = 0;
      
      private var m_itemWon:FarmItem = null;
      
      public function TDepositNeighborAnimalFeed(object:WorldObject)
      {
         super(object);
      }
      
      override public function perform() : void
      {
         signedCall("NeighborActionService.depositAnimalFeed",m_hostId);
      }
      
      override protected function onComplete(result:Object) : void
      {
         var iconPath:String = null;
         var key:String = null;
         var itemName:String = null;
         var friend:Friend = null;
         var friendGender:String = null;
         var popup:GenericIconPopup = null;
         super.onComplete(result);
         if(result)
         {
            iconPath = Global.farmGameSettingsManager.getImageByName("animalfeedtrough_feed","icon");
            if(result.goldYield > 0)
            {
               Global.player.gold += result.goldYield;
               Global.selectedAvatar.displayStatus(ZLocUtils.t("FarmGame","Status_ObjectSold",{"coinNum":result.goldYield}));
               UI.displayPopup(new GenericIconPopup(ZLocUtils.t("Dialogs","AnimalFeedNeighborNoJackpot",{"coinQuantity":result.goldYield}),GenericPopup.TYPE_OK,null,iconPath));
               FarmStatsManager.count(FeedTroughBuilding.ANIMAL_FEED_TROUGH_COUNTER,VisitorManager.NEIGHBOR_VISIT_COUNTER,"got_consolation");
            }
            else if(result.rewardLink)
            {
               this.m_rewardLink = result.rewardLink;
               FarmStatsManager.count(FeedTroughBuilding.ANIMAL_FEED_TROUGH_COUNTER,VisitorManager.NEIGHBOR_VISIT_COUNTER,"got_jackpot");
               var _loc8_:int = 0;
               var _loc9_:* = result.rewardPackage;
               for(key in _loc9_)
               {
                  this.m_jackpotAmount = result.rewardPackage[key];
                  this.m_itemWon = Global.farmGameSettingsManager.getFarmItemByName(key);
                  itemName = this.m_itemWon.friendlyName;
                  friend = Global.friendManager.getFriendData(m_hostId);
                  friendGender = Global.friendManager.getFriendGender(m_hostId);
                  popup = new GenericIconPopup(ZLocUtils.t("Dialogs","AnimalFeedNeighborJackpot",{
                     "user":ZLocUtils.tn(friend.firstName,ZLocUtils.tg(friendGender)),
                     "quantityTotal":this.m_jackpotAmount,
                     "item":ZLocUtils.tk_pk(itemName)
                  }),GenericPopup.TYPE_SHARE,this.onShare,this.m_itemWon.icon);
                  popup.setTrackerKey("animal_trough-neighbor_visit_jackpot");
                  UI.displayPopup(popup);
                  Global.player.addGift(this.m_itemWon.name,"0",this.m_jackpotAmount);
               }
            }
         }
      }
      
      protected function onShare(event:GenericPopupEvent) : void
      {
         var params:Object = null;
         if(event.button == GenericPopup.ACCEPT)
         {
            params = {};
            params.images = [{
               "src":this.m_itemWon.icon,
               "href":"{SN_APP_URL}" + this.m_rewardLink
            }];
            params.neighborName = Global.friendManager.getFriendData(m_hostId).firstName;
            params.numBags = this.m_jackpotAmount;
            params.itemName = this.m_itemWon.friendlyName;
            params.reward_link = this.m_rewardLink;
            GlobalEngine.socialNetwork.publishFeedStory("FeedTroughBuildingShareJackpot",params,[],false);
         }
         else
         {
            TransactionManager.addTransaction(new TCancelFriendReward([this.m_rewardLink]),true);
         }
      }
   }
}

