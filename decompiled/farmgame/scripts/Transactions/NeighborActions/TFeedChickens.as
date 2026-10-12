package Transactions.NeighborActions
{
   import Classes.ChickenCoopBuilding;
   import Classes.Friend;
   import Classes.VisitorManager;
   import Classes.ZItem.BuildingItem;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Display.GenericIconPopup;
   import Display.GenericPopup;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Events.GenericPopupEvent;
   import Managers.FarmStatsManager;
   import Transactions.TCancelFriendReward;
   import Transactions.TGiftGive;
   
   public class TFeedChickens extends TBaseNeighborAction
   {
      
      protected var m_feedResult:Object = null;
      
      public function TFeedChickens(chickenCoop:ChickenCoopBuilding)
      {
         m_actionType = "feedchickens";
         super(chickenCoop);
      }
      
      override protected function onComplete(result:Object) : void
      {
         var mysteryEggName:String = null;
         var namePattern:RegExp = null;
         super.onComplete(result);
         if(result.harvestItem != null)
         {
            this.m_feedResult = result;
            mysteryEggName = result.harvestItem;
            namePattern = /_/;
            mysteryEggName = "mystery" + mysteryEggName.replace(namePattern,"");
            Global.player.addGift(mysteryEggName);
            this.showEggDialog();
         }
         else
         {
            this.showNoEggDialog();
         }
      }
      
      private function showEggDialog() : void
      {
         var hostName:String = "";
         var hostGender:String = "";
         var host:Friend = Global.friendManager.getFriendData(Global.worldManager.getVisiting());
         if(host)
         {
            hostName = host.firstName;
            hostGender = host.snUser.gender;
         }
         else
         {
            hostName = VisitorManager.getInstance().visitedUserName;
         }
         var buildingName:String = ((m_object as ChickenCoopBuilding).getItem() as BuildingItem).buildingName;
         var harvestItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(this.m_feedResult.harvestItem);
         var message:GenericPopup = new GenericIconPopup(ZLocUtils.t("Dialogs",buildingName + "FeedShareEgg",{
            "user":ZLocUtils.tn(hostName,ZLocUtils.tg(hostGender)),
            "items":ZLocUtils.tk_pk(harvestItem.friendlyName)
         }),GenericPopup.TYPE_SHARE,this.onConfirmShareEgg,harvestItem.icon);
         message.setTrackerKey("chickencoop-egg_friend");
         UI.displayPopup(message);
      }
      
      private function showNoEggDialog() : void
      {
         var hostName:String = "";
         var hostGender:String = "";
         var host:Friend = Global.friendManager.getFriendData(Global.worldManager.getVisiting());
         if(host)
         {
            hostName = host.firstName;
            hostGender = host.snUser.gender;
         }
         else
         {
            hostName = VisitorManager.getInstance().visitedUserName;
         }
         var buildingName:String = ((m_object as ChickenCoopBuilding).getItem() as BuildingItem).buildingName;
         var message:GenericPopup = new GenericIconPopup(ZLocUtils.t("Dialogs",buildingName + "FeedNoEgg",{"user":ZLocUtils.tn(hostName,ZLocUtils.tg(hostGender))}),GenericPopup.TYPE_OK,null,Global.getAssetURL("assets/hud/FV_Main_ChickFeed_Icon_Lrg.png"),true);
         message.setAcceptTextName("Okay");
         UI.displayPopup(message);
      }
      
      private function onConfirmShareEgg(event:GenericPopupEvent) : void
      {
         var harvestItem:FarmItem = null;
         var hostName:String = null;
         var bundleData:Object = null;
         var emailData:Object = null;
         if(event.button == GenericPopup.ACCEPT)
         {
            harvestItem = Global.farmGameSettingsManager.getFarmItemByName(this.m_feedResult.harvestItem);
            hostName = VisitorManager.getInstance().visitedUserName;
            if(harvestItem != null)
            {
               bundleData = {
                  "item_name":harvestItem.friendlyName,
                  "friend_name":hostName,
                  "reward_link":this.m_feedResult.rewardLink,
                  "images":[{
                     "href":"{SN_APP_URL}" + this.m_feedResult.rewardLink,
                     "src":harvestItem.icon
                  }]
               };
               GlobalEngine.socialNetwork.publishFeedStory("FriendFoundMysteryEgg",bundleData,[],false);
               emailData = {
                  "item_name":harvestItem.friendlyName,
                  "reward_link":this.m_feedResult.rewardLink
               };
               TransactionManager.addTransaction(new TGiftGive("FriendFoundMysteryEgg",emailData,[]));
            }
            FarmStatsManager.count("chickencoop","shares_egg");
         }
         else
         {
            TransactionManager.addTransaction(new TCancelFriendReward([this.m_feedResult.rewardLink]));
            FarmStatsManager.count("chickencoop","cancels");
         }
      }
   }
}

