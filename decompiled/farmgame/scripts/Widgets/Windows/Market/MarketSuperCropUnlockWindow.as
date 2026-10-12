package Widgets.Windows.Market
{
   import Classes.Constants.MFSConstants;
   import Classes.Constants.SuperCropConstants;
   import Classes.FeatureDataObjects.FriendSet;
   import Classes.FeatureDataObjects.SuperCropFriendSet;
   import Classes.Friend;
   import Classes.FriendSetGoal;
   import Classes.Mastery;
   import Classes.SuperCropRequirement;
   import Classes.ZItem.FarmItem;
   import Classes.ZItem.HarvestableItem;
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.UI;
   import Engine.Managers.StatsManager;
   import Engine.Managers.TransactionManager;
   import Events.GenericPopupEvent;
   import Managers.MFSRequestManager;
   import Transactions.TCompleteFriendSet;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.Market.MarketSlotMasteryFrame;
   import Widgets.Icons.FarmIcon;
   import Widgets.Tooltips.Market.MarketTooltip;
   import Widgets.Windows.FarmWindow;
   import flash.display.DisplayObject;
   import flash.events.Event;
   
   public class MarketSuperCropUnlockWindow extends FarmWindow
   {
      
      private static const ICON_SIZE:int = 50;
      
      private static const SUPER_CROPS_DIALOG_KINGDOM:String = "supercrop_unlock";
      
      protected var m_superCrop:HarvestableItem = null;
      
      protected var m_baseCrop:HarvestableItem = null;
      
      private var m_plantCallback:Function;
      
      private var m_closeCallback:Function;
      
      private var m_friendSet:SuperCropFriendSet = null;
      
      private var m_body:ZwFrame;
      
      private var m_baseCropMastered:Boolean;
      
      private var m_shouldPopulateFromFriendSet:Boolean = false;
      
      private var m_completeButton:FarmAnimatedTextButton;
      
      private var m_askButton:FarmAnimatedTextButton;
      
      private var m_buyWaitWindow:GenericPopup = null;
      
      private var m_loadWaitWindow:GenericPopup = null;
      
      public function MarketSuperCropUnlockWindow(crop:HarvestableItem, baseCrop:HarvestableItem, plantCallback:Function = null, closeCallback:Function = null, initializedFriendSet:SuperCropFriendSet = null)
      {
         this.m_superCrop = crop;
         this.m_baseCrop = baseCrop;
         this.m_closeCallback = closeCallback;
         this.m_plantCallback = plantCallback;
         var mastery:Mastery = this.m_baseCrop.mastery;
         this.m_baseCropMastered = false;
         if(this.m_baseCrop.hasMastery)
         {
            if(mastery.hasAllMasteries())
            {
               this.m_baseCropMastered = true;
            }
         }
         if(this.m_baseCropMastered)
         {
            if(Boolean(initializedFriendSet) && initializedFriendSet.initialized)
            {
               this.m_friendSet = initializedFriendSet;
            }
            else
            {
               this.m_friendSet = new SuperCropFriendSet(SuperCropConstants.SUPERCROP_UNLOCK_FRIEND_SET,this.m_superCrop.code,this.onGetFriendSetData);
               this.m_friendSet.initializeData();
            }
         }
         super("assets/dialogs/FV_SuperCrops.swf",true,true);
      }
      
      private function onGetFriendSetData(friendSet:FriendSet, result:Object) : void
      {
         if(null != this.m_loadWaitWindow)
         {
            this.m_loadWaitWindow.close();
            this.m_loadWaitWindow = null;
         }
         if(this.m_shouldPopulateFromFriendSet)
         {
            if(Boolean(result) && Boolean(result.error) && result.error == "alreadyUnlocked")
            {
               this.m_friendSet = null;
               this.populateFromGoal();
            }
            else if(Boolean(result) && Boolean(result.error) && result.error == "notMastered")
            {
               this.populateNotMastered();
            }
            else
            {
               this.populateFromFriendSet();
            }
         }
      }
      
      private function populateNotMastered() : void
      {
         this.m_shouldPopulateFromFriendSet = false;
         var superCropRequirement:SuperCropRequirement = this.m_superCrop.getRequirement("SuperCropRequirement") as SuperCropRequirement;
         var mastery:Mastery = this.m_baseCrop.mastery;
         this.m_body = addWidget(new ZwFrame(m_window.bodyMaster_mc)) as ZwFrame;
         this.m_body.addWidget(new ZwTextField(m_window.bodyMaster_mc.generic_0_tf,ZLocUtils.t("Dialogs","SuperCrops_Unlock_MasterCrop_Title",{"item":ZLocUtils.tk_pk(this.m_baseCrop.friendlyName)})));
         this.m_body.addWidget(new ZwTextField(m_window.bodyMaster_mc.generic_1_tf,ZLocUtils.t("Dialogs","SuperCrops_Unlock_MasterCrop_Progress",{
            "quantity":mastery.currentLevel + 1,
            "maximum":3
         })));
         this.m_body.addWidget(new ZwTextField(m_window.bodyMaster_mc.generic_2_tf,ZLocUtils.t("Dialogs","SuperCrops_Unlock_MasterCrop_Body",{"item":ZLocUtils.tk_pk(this.m_baseCrop.friendlyName)})));
         this.m_body.addWidget(new ZwTextField(m_window.bodyMaster_mc.generic_3_tf,ZLocUtils.t("Dialogs","SuperCrops_Unlock_AskFriends_Progress_Short",{"maximum":superCropRequirement.friendsRequired})));
         var tempIcon:FarmIcon = this.m_body.addWidget(new FarmIcon(m_window.bodyMaster_mc.icon_mc,this.m_baseCrop.iconUrl)) as FarmIcon;
         tempIcon.setIconSize(ICON_SIZE,ICON_SIZE);
         var masterStars:ZwFrame = this.m_body.addWidget(new ZwFrame(m_window.bodyMaster_mc.masteryLevel_mc)) as ZwFrame;
         masterStars.attachTooltip(new MarketTooltip(ZLocUtils.t("Dialogs","SuperCrops_Unlock_MasterStars")));
         var masteryFrame:MarketSlotMasteryFrame = this.m_body.addWidget(new MarketSlotMasteryFrame(m_window.bodyMaster_mc.mastery_mc)) as MarketSlotMasteryFrame;
         masteryFrame.update(mastery.currentLevel + 1,mastery.currentProgress,mastery.totalCropsNeeded);
         this.m_body.addWidget(new FarmAnimatedTextButton(m_window.bodyMaster_mc.plant_bt,ZLocUtils.t("Dialogs","SuperCrops_Unlock_PlantNow"),this.onPlantButtonClick));
         this.m_body.addWidget(new ZwTextField(m_window.bodyMaster_mc.cost_tf,String(this.m_baseCrop.cost)));
         this.m_body.addWidget(new ZwFrame(m_window.bodyMaster_mc.lock_mc));
      }
      
      private function populateFromGoal() : void
      {
         var superCropRequirement:SuperCropRequirement = null;
         var frame:ZwFrame = null;
         if(this.m_shouldPopulateFromFriendSet && null != this.m_body && null != this.m_completeButton)
         {
            this.m_shouldPopulateFromFriendSet = false;
            superCropRequirement = this.m_superCrop.getRequirement("SuperCropRequirement") as SuperCropRequirement;
            this.m_body.addWidget(new ZwTextField(m_window.bodyUnlock_mc.generic_2_tf,ZLocUtils.t("Dialogs","SuperCrops_Unlock_AskFriends_Progress",{
               "maximum1":superCropRequirement.friendsRequired,
               "quantity":superCropRequirement.friendsRequired,
               "maximum2":superCropRequirement.friendsRequired
            })));
            frame = new ZwFrame(this.m_completeButton.element as DisplayObject);
            frame.addWidget(new ZwTextField(this.m_completeButton.element.generic_1_tf,"0"));
            if(this.m_askButton)
            {
               this.m_askButton.applyGrayOut = true;
               this.m_askButton.visible = true;
               this.m_askButton.enabled = false;
            }
            if(this.m_completeButton)
            {
               this.m_completeButton.applyGrayOut = true;
               this.m_completeButton.visible = true;
               this.m_completeButton.enabled = false;
            }
            Global.player.unlockSuperCrop(this.m_superCrop.code);
         }
      }
      
      private function populateFromFriendSet() : void
      {
         var frame:ZwFrame = null;
         var friends:Array = null;
         var element:DisplayObject = null;
         var friend:Friend = null;
         var iconUrl:String = null;
         var index:int = 0;
         if(this.m_shouldPopulateFromFriendSet && this.m_friendSet.initialized && null != this.m_body && null != this.m_completeButton)
         {
            this.m_shouldPopulateFromFriendSet = false;
            this.m_body.addWidget(new ZwTextField(m_window.bodyUnlock_mc.generic_2_tf,ZLocUtils.t("Dialogs","SuperCrops_Unlock_AskFriends_Progress",{
               "maximum1":this.m_friendSet.friendGoal,
               "quantity":this.m_friendSet.numFriendsCompleted,
               "maximum2":this.m_friendSet.friendGoal
            })));
            frame = new ZwFrame(this.m_completeButton.element as DisplayObject);
            frame.addWidget(new ZwTextField(this.m_completeButton.element.generic_1_tf,String(this.getCompletionCost())));
            friends = this.m_friendSet.completedFriends;
            if(this.m_askButton)
            {
               this.m_askButton.visible = true;
            }
            if(this.m_completeButton)
            {
               this.m_completeButton.visible = true;
            }
            for(index = 0; index < this.m_friendSet.friendGoal; index++)
            {
               switch(index)
               {
                  case 0:
                     element = m_window.bodyUnlock_mc.slot_0_mc;
                     break;
                  case 1:
                     element = m_window.bodyUnlock_mc.slot_1_mc;
                     break;
                  case 2:
                     element = m_window.bodyUnlock_mc.slot_2_mc;
                     break;
                  case 3:
                     element = m_window.bodyUnlock_mc.slot_3_mc;
                     break;
                  case 4:
                     element = m_window.bodyUnlock_mc.slot_4_mc;
                     break;
                  default:
                     element = m_window.bodyUnlock_mc.slot_5_mc;
               }
               friend = Global.friendManager.getAppFriendData(friends[index]);
               if(friend != null)
               {
                  iconUrl = friend.snUser.picture;
               }
               else
               {
                  iconUrl = null;
               }
               this.m_body.addWidget(new FarmIcon(element,iconUrl));
            }
         }
      }
      
      override protected function postLoadComplete() : void
      {
         var tempIcon:FarmIcon = null;
         var masterStars:ZwFrame = null;
         var dialogString:String = null;
         var frame:ZwFrame = null;
         var popUpMessage:String = null;
         StatsManager.count("dialog",SuperCropConstants.SUPERCROP_COUNTER,SUPER_CROPS_DIALOG_KINGDOM,"view");
         var mastery:Mastery = this.m_baseCrop.mastery;
         var masterSign:FarmItem = null;
         super.postLoadComplete();
         addWidget(new FarmIcon(m_window.icon_0_mc,this.m_superCrop.iconUrl));
         if(this.m_superCrop.hasMastery)
         {
            masterSign = Global.farmGameSettingsManager.getFarmItemByName(this.m_superCrop.mastery.finalGift);
         }
         if(null != masterSign)
         {
            addWidget(new FarmIcon(m_window.icon_1_mc,masterSign.iconUrl));
         }
         else
         {
            addWidget(new FarmIcon(m_window.icon_1_mc,this.m_superCrop.iconUrl));
         }
         addWidget(new ZwTextField(m_window.title_0_tf,ZLocUtils.t("Dialogs","SuperCrops_Unlock_Header")));
         addWidget(new ZwTextField(m_window.title_1_tf,ZLocUtils.tk_pk_asTitle(this.m_baseCrop.friendlyName)));
         dialogString = ZLocUtils.t("Dialogs","SuperCrops_Unlock_Title1") + "\n" + ZLocUtils.t("Dialogs","SuperCrops_Unlock_Title2",{"item":ZLocUtils.tk_pk(this.m_superCrop.friendlyName)});
         addWidget(new ZwTextField(m_window.body_0_tf,dialogString));
         addWidget(new FarmAnimatedTextButton(m_window.cancel_bt,ZLocUtils.t("Dialogs","SuperCrops_Unlock_Close"),this.onClose));
         if(!this.m_baseCropMastered)
         {
            this.populateNotMastered();
         }
         else
         {
            this.m_body = addWidget(new ZwFrame(m_window.bodyUnlock_mc)) as ZwFrame;
            this.m_body.addWidget(new ZwTextField(m_window.bodyUnlock_mc.generic_0_tf,ZLocUtils.t("Dialogs","SuperCrops_Unlock_MasterCrop_Title",{"item":ZLocUtils.tk_pk(this.m_baseCrop.friendlyName)})));
            this.m_body.addWidget(new ZwTextField(m_window.bodyUnlock_mc.generic_1_tf,ZLocUtils.t("Dialogs","SuperCrops_Unlock_MasterCrop_Progress",{
               "quantity":3,
               "maximum":3
            })));
            masterStars = this.m_body.addWidget(new ZwFrame(m_window.bodyUnlock_mc.masteryLevel_mc)) as ZwFrame;
            masterStars.attachTooltip(new MarketTooltip(ZLocUtils.t("Dialogs","SuperCrops_Unlock_MasterStars")));
            this.m_askButton = this.m_body.addWidget(new FarmAnimatedTextButton(m_window.bodyUnlock_mc.ask_bt,ZLocUtils.t("Dialogs","SuperCrops_Unlock_AskFriends"),this.onAskButtonClick)) as FarmAnimatedTextButton;
            this.m_completeButton = this.m_body.addWidget(new FarmAnimatedTextButton(m_window.bodyUnlock_mc.buy_bt,"",this.onBuyButtonClick)) as FarmAnimatedTextButton;
            frame = new ZwFrame(this.m_completeButton.element as DisplayObject);
            frame.addWidget(new ZwTextField(this.m_completeButton.element.generic_0_tf,ZLocUtils.t("Dialogs","SuperCrops_Unlock_Complete")));
            if(this.m_friendSet == null)
            {
               this.populateFromGoal();
            }
            else if(this.m_friendSet.initialized)
            {
               this.m_shouldPopulateFromFriendSet = true;
               this.populateFromFriendSet();
            }
            else
            {
               this.m_completeButton.visible = false;
               this.m_askButton.visible = false;
               this.m_shouldPopulateFromFriendSet = true;
               popUpMessage = "\n\n" + ZLocUtils.t("Dialogs","SuperCrops_Load_Wait_Prompt");
               this.m_loadWaitWindow = new GenericPopup(popUpMessage,GenericPopup.TYPE_MODAL,null,GenericPopup.GENERIC_ASSET,"",false,true);
               UI.displayPopup(this.m_loadWaitWindow,false);
            }
         }
      }
      
      private function onBuyButtonClick(event:Event) : void
      {
         StatsManager.count("dialog",SuperCropConstants.SUPERCROP_COUNTER,SUPER_CROPS_DIALOG_KINGDOM,"unlock");
         var itemName:String = ZLocUtils.tk_pk_asTitlePlural(this.m_superCrop.friendlyName);
         var popUpMessage:String = ZLocUtils.t("Dialogs","SuperCrops_Buy_Prompt",{
            "quantity":this.getCompletionCost(),
            "item":itemName
         });
         var dialog:GenericPopup = new GenericPopup(popUpMessage,GenericPopup.TYPE_ACCEPTCANCEL,this.onBuyClose,GenericPopup.GENERIC_ASSET,"",false,true);
         UI.displayPopup(dialog,false);
      }
      
      private function getCompletionCost() : int
      {
         var friendsRequired:int = this.m_friendSet.friendGoal - this.m_friendSet.numFriendsCompleted;
         var friendGoal:FriendSetGoal = Global.farmGameSettingsManager.getFriendSetGoalByCode(SuperCropConstants.SUPERCROP_UNLOCK_FRIEND_SET);
         var costPerFriend:int = friendGoal.buySlotCash;
         return int(friendsRequired * costPerFriend);
      }
      
      private function onBuyClose(evt:GenericPopupEvent) : void
      {
         var popUpMessage:String = null;
         var cost:int = this.getCompletionCost();
         if(evt.button == GenericPopup.ACCEPT)
         {
            if(Global.player.canBuyCash(cost,true))
            {
               popUpMessage = "\n\n" + ZLocUtils.t("Dialogs","SuperCrops_Buy_Wait_Prompt");
               this.m_buyWaitWindow = new GenericPopup(popUpMessage,GenericPopup.TYPE_MODAL,null,GenericPopup.GENERIC_ASSET,"",false,true);
               UI.displayPopup(this.m_buyWaitWindow,false);
               TransactionManager.addTransaction(new TCompleteFriendSet(this.m_friendSet,this.onBuyComplete));
            }
         }
      }
      
      private function onBuyComplete() : void
      {
         Global.player.unlockSuperCrop(this.m_superCrop.code);
         var successMessage:String = ZLocUtils.t("Dialogs","SuperCrops_Buy_Success",{"item":ZLocUtils.tk_pk(this.m_superCrop.friendlyName)});
         if(null != this.m_buyWaitWindow)
         {
            this.m_buyWaitWindow.close();
         }
         this.close();
         var dialog:GenericPopup = new GenericPopup(successMessage,GenericPopup.TYPE_OK);
         UI.displayPopup(dialog,false);
      }
      
      private function onAskButtonClick(event:Event) : void
      {
         var id:int = this.m_friendSet.index;
         MFSRequestManager.getInstance().makeFriendSetRequest(this.m_superCrop.name,"SuperCrops",SuperCropConstants.SUPERCROP_UNLOCK_FRIEND_SET,id,MFSConstants.SOURCE_DIALOG_CLICKED,"dialog",SuperCropConstants.SUPERCROP_COUNTER,SUPER_CROPS_DIALOG_KINGDOM,"ask_friends");
         this.close();
      }
      
      private function onPlantButtonClick(event:Event) : void
      {
         StatsManager.count("dialog",SuperCropConstants.SUPERCROP_COUNTER,SUPER_CROPS_DIALOG_KINGDOM,"plant_now");
         if(this.m_plantCallback != null)
         {
            this.m_plantCallback(this.m_baseCrop);
         }
         this.close();
      }
      
      override protected function onClose(event:Event) : void
      {
         StatsManager.count("dialog",SuperCropConstants.SUPERCROP_COUNTER,SUPER_CROPS_DIALOG_KINGDOM,"close");
         this.close();
      }
      
      override public function close() : void
      {
         this.m_shouldPopulateFromFriendSet = false;
         if(this.m_closeCallback != null)
         {
            this.m_closeCallback();
         }
         super.close();
      }
      
      override protected function release() : void
      {
         this.m_superCrop = null;
         this.m_baseCrop = null;
         this.m_plantCallback = null;
         this.m_closeCallback = null;
         super.release();
      }
   }
}

