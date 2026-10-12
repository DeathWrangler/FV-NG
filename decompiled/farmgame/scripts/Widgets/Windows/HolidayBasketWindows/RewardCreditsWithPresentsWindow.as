package Widgets.Windows.HolidayBasketWindows
{
   import Classes.FeaturePresent;
   import Classes.RewardCreditsBuilding;
   import Classes.RewardCreditsBuildingWithPresents;
   import Classes.util.ZLocUtils;
   import Display.FriendSelector;
   import Display.GenericPopup;
   import Display.UI;
   import Engine.Classes.SocialNetworkUser;
   import Engine.Managers.TransactionManager;
   import Events.CloseEvent;
   import Managers.FarmStatsManager;
   import Managers.FeaturePresentsManager;
   import Transactions.TSendFeaturePresent;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Events.ZwToggleEvent;
   import Widgets.Core.Toggles.ZwVisibilityToggle;
   import Widgets.Frames.CreditsBuilding.PresentsSlotFrame;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class RewardCreditsWithPresentsWindow extends RewardCreditsWindow
   {
      
      private var m_presentsSlotFrame:PresentsSlotFrame = null;
      
      private var m_presentsTabSelected:Boolean = false;
      
      private var m_useMultiFriendSelector:Boolean = false;
      
      public var m_friendSelector:FriendSelector = null;
      
      public var m_holidayTreeCongratsWindow:HolidayTreeCongratsWindow = null;
      
      public var m_numToSend:int = 0;
      
      protected var m_presentsToggle:ZwVisibilityToggle = null;
      
      public function RewardCreditsWithPresentsWindow(building:RewardCreditsBuilding, buildingClassName:String, dialogAssetUrl:String, showWhatIsThisOnLoad:Boolean = false, showRedeemableItemOnLoad:Object = null, useMultiFriendSelector:Boolean = true)
      {
         super(building,buildingClassName,dialogAssetUrl,showWhatIsThisOnLoad,showRedeemableItemOnLoad);
         this.m_presentsTabSelected = RewardCreditsBuildingWithPresents(building).showStoragePresentsTabOnLoad;
         this.m_useMultiFriendSelector = useMultiFriendSelector;
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         var inventoryBtn:FarmAnimatedTextButton = new FarmAnimatedTextButton(m_window.inventory_bt,ZLocUtils.t(LOC_BUNDLE,m_buildingClassName + "_Inventory"),this.inventoryButtonStatsTrack,true);
         addWidget(inventoryBtn);
         this.m_presentsSlotFrame = new PresentsSlotFrame(m_window.inventory_mc,this.openPresentCallback,m_buildingClassName);
         this.m_presentsSlotFrame.items = FeaturePresentsManager.getInstance().featurePresents;
         addWidget(this.m_presentsSlotFrame);
         this.m_presentsToggle = new ZwVisibilityToggle(inventoryBtn,this.m_presentsSlotFrame);
         m_toggleManager.addToggle(this.m_presentsToggle,this.m_presentsTabSelected);
         this.m_presentsToggle.addEventListener(ZwToggleEvent.TOGGLE,this.onPresentsTabToggled);
      }
      
      private function onPresentsTabToggled(event:Event) : void
      {
         var placeMessage:String = null;
         if(FeaturePresentsManager.getInstance().featurePresents.length <= 0)
         {
            placeMessage = ZLocUtils.t("Dialogs",this.m_building.getCreditsFeatureName() + "_NoPresentsToClaim");
            UI.displayPopup(new GenericPopup(placeMessage,GenericPopup.TYPE_OK),false);
         }
      }
      
      private function openPresentCallback(present:FeaturePresent) : void
      {
         FeaturePresentsManager.getInstance().openPresent(this.m_building,present);
         this.close();
      }
      
      public function inventoryButtonStatsTrack(event:Event) : void
      {
         FarmStatsManager.count(m_buildingClassName,"open_inventory");
      }
      
      override protected function getRedeemCallBack() : Function
      {
         var result:Function = null;
         if(this.m_useMultiFriendSelector)
         {
            result = this.onMultiUserCompleteCallback;
         }
         return result;
      }
      
      private function onMultiUserCompleteCallback() : void
      {
         if(this.m_holidayTreeCongratsWindow == null)
         {
            this.m_holidayTreeCongratsWindow = new HolidayTreeCongratsWindow(Global.farmGameSettingsManager.getFarmItemByName(m_itemToBuy.name),this.onOkayClick,int(m_itemToBuy.sendPresentLimit));
            this.m_holidayTreeCongratsWindow.addEventListener(CloseEvent.CLOSE,this.onHolidayTreeCongratsWindowClose);
            UI.displayPopup(this.m_holidayTreeCongratsWindow);
            UI.stopPopups(true);
         }
      }
      
      private function onHolidayTreeCongratsWindowClose(event:Event) : void
      {
         if(this.m_holidayTreeCongratsWindow)
         {
            this.m_holidayTreeCongratsWindow.removeEventListener(CloseEvent.CLOSE,this.onHolidayTreeCongratsWindowClose);
            this.m_holidayTreeCongratsWindow = null;
            UI.stopPopups(false);
         }
      }
      
      private function onOkayClick() : void
      {
         if(this.m_friendSelector == null)
         {
            this.m_numToSend = Math.min(Global.friendManager.appFriendUids.length,int(m_itemToBuy.sendPresentLimit));
            this.m_friendSelector = new FriendSelector(false,0,0,false,this.onSendClick,Global.farmGameSettingsManager.getFarmItemByName(m_itemToBuy.name),Global.friendManager.appFriends);
            this.m_friendSelector.setCongratulations(m_buildingClassName + "_FriendSelectorSendPresents");
            this.m_friendSelector.setTitle(m_buildingClassName + "_FriendSelectorChooseNeighbors",{"quantity":this.m_numToSend});
            UI.displayPopup(this.m_friendSelector);
         }
      }
      
      private function onSendClick(sendButton:MovieClip) : void
      {
         this.m_friendSelector.disableSendButtons();
         this.m_friendSelector.setHasSent(sendButton);
         var user:SocialNetworkUser = sendButton.snUser;
         var transaction:TSendFeaturePresent = new TSendFeaturePresent(m_building,user.uid,user.name,m_itemToBuy.name,this.onSendCompleteCallback);
         TransactionManager.addTransaction(transaction,true);
         --this.m_numToSend;
         if(this.m_numToSend > 0)
         {
            this.m_friendSelector.setTitle(m_buildingClassName + "_FriendSelectorChooseNeighbors",{"quantity":Math.min(Global.friendManager.appFriendUids.length,this.m_numToSend)});
         }
         else
         {
            this.m_friendSelector.closeDialog();
            this.m_friendSelector.close();
         }
      }
      
      private function onSendCompleteCallback(friendId:Number, friendName:String) : void
      {
         this.m_friendSelector.enableSendButtons();
         var bundleData:Object = {
            "friendname":friendName,
            "images":[{
               "href":"{SN_APP_URL}",
               "src":Global.getAssetURL(RewardCreditsBuildingWithPresents(m_building).getSendPresentFeedIconUrl())
            }]
         };
         var messageType:String = m_buildingClassName + "_SendPresent";
         GlobalEngine.socialNetwork.publishFeedStory(messageType,bundleData,[friendId],false);
      }
      
      override protected function release() : void
      {
         super.release();
         this.m_presentsToggle.removeEventListener(ZwToggleEvent.TOGGLE,this.onPresentsTabToggled);
         this.m_presentsToggle = null;
         this.m_presentsSlotFrame = null;
      }
   }
}

