package Widgets.Windows.Breeding
{
   import Classes.Constants.WorldsConstants;
   import Classes.FeatureDataObjects.FriendSet;
   import Classes.FeatureDataObjects.MysteryEggFriendSet;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Engine.Managers.TransactionManager;
   import Managers.FarmStatsManager;
   import Transactions.TCancelFriendReward;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.Breeding.MutableAnimalEggRewardFrame;
   import Widgets.Frames.Breeding.MutableAnimalEggSlotFrame;
   import Widgets.Windows.FarmWindow;
   import flash.events.Event;
   
   public class MutableAnimalEggThankYouWindow extends FarmWindow
   {
      
      private var m_adultItemCode:String;
      
      private var m_friendSetIndex:int;
      
      public var m_mysteryEggFriendSet:MysteryEggFriendSet;
      
      private var m_friendSlotFrame:MutableAnimalEggSlotFrame = null;
      
      private var m_rewardLink:String;
      
      private var m_itemFeatureFriendResult:Object = null;
      
      public var m_totalFriendsSlots:Number = 6;
      
      private var m_feedAction:String;
      
      public function MutableAnimalEggThankYouWindow(data:Object)
      {
         this.m_adultItemCode = data.adultCode;
         this.m_friendSetIndex = data.fsId;
         this.m_rewardLink = data.rewardLink;
         this.m_feedAction = data.feedAction;
         var eggWindowAssetURL:String = "assets/dialogs/FV_animal_eggThank.swf";
         switch(Global.worldManager.currentWorldType)
         {
            case WorldsConstants.WORLD_ID_WINTER_WONDERLAND:
               eggWindowAssetURL = "assets/dialogs/FV_animal_wintereggThank.swf";
               break;
            case WorldsConstants.WORLD_ID_HAWAII:
               eggWindowAssetURL = "assets/dialogs/FV_animal_islandeggThank.swf";
         }
         super(eggWindowAssetURL);
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         addWidget(new ZwTextField(m_window.title_tf,ZLocUtils.t("Dialogs","Congrats")));
         addWidget(new ZwTextField(m_window.generic_0_tf,ZLocUtils.t("Dialogs","AviaryEggThankText1")));
         var item:FarmItem = Global.farmGameSettingsManager.getFarmItemByCode(this.m_adultItemCode);
         addWidget(new ZwTextField(m_window.name_tf,ZLocUtils.tk_pk_asTitle(item.friendlyName)));
         addWidget(new MutableAnimalEggRewardFrame(m_window.congrats_mc,this.m_adultItemCode,this,this.m_rewardLink,this.m_feedAction));
         FarmStatsManager.count("dialog","egg_complete","View");
      }
      
      public function featureSetRefresh() : void
      {
         this.m_mysteryEggFriendSet = FriendSet.factory(MysteryEggFriendSet.MYSTERY_EGG_CODE,this.m_friendSetIndex,this.featureSetUpdate) as MysteryEggFriendSet;
         this.m_mysteryEggFriendSet.initializeData();
      }
      
      private function featureSetUpdate(itemFeatureFriendSetIn:FriendSet, result:Object) : void
      {
         var _uid:String = null;
         var numHelpers:int = 0;
         var countTemp:* = 0;
         this.m_mysteryEggFriendSet = itemFeatureFriendSetIn as MysteryEggFriendSet;
         this.m_itemFeatureFriendResult = result;
         var friendData:Array = [];
         var extraFriendsHelp:int = 0;
         var boughtFriendCount:int = Math.max(Math.min(int(this.m_itemFeatureFriendResult.boughtFriendCount),this.m_totalFriendsSlots),0);
         for(_uid in this.m_itemFeatureFriendResult.uids)
         {
            if(friendData.length < this.m_totalFriendsSlots && this.m_itemFeatureFriendResult.uids[_uid] == "1")
            {
               friendData.push({"uid":_uid.replace("_","")});
            }
         }
         numHelpers = int(friendData.length);
         countTemp = boughtFriendCount;
         while(friendData.length < this.m_totalFriendsSlots)
         {
            if(countTemp > 0)
            {
               friendData.push({"uid":"bought"});
               countTemp--;
            }
            else
            {
               friendData.push({"uid":""});
            }
         }
         extraFriendsHelp = friendData.length - this.m_totalFriendsSlots;
         this.m_friendSlotFrame.setData(friendData);
         this.m_friendSlotFrame.refresh();
         this.m_friendSlotFrame.updateExtraHelpers(extraFriendsHelp);
      }
      
      override protected function onClose(event:Event) : void
      {
         FarmStatsManager.count("dialog","egg_complete","X");
         TransactionManager.addTransaction(new TCancelFriendReward([this.m_rewardLink]));
         super.onClose(event);
      }
   }
}

