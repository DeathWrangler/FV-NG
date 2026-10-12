package Widgets.Windows.DuckPond
{
   import Classes.Constants.MFSConstants;
   import Classes.DucklingAnimal;
   import Classes.FeatureDataObjects.FriendSet;
   import Classes.FeatureDataObjects.ItemFeatureFriendSet;
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Display.GenericIconPopup;
   import Display.GenericPopup;
   import Display.GenericXMLDialog;
   import Display.ImpulseBuy;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Events.GenericPopupEvent;
   import Events.ImpulseBuyEvent;
   import Managers.FarmStatsManager;
   import Managers.MFSRequestManager;
   import Transactions.TChooseFriendSetReward;
   import Transactions.TCompleteFriendSet;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.DuckPond.DuckGameFriendSlotFrame;
   import Widgets.Frames.DuckPond.DuckGameRewardSlotFrame;
   import Widgets.Frames.ObjectPreviewFrame;
   import Widgets.Windows.FarmWindow;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class DuckGameWindow extends FarmWindow
   {
      
      public var ducklingGameId:Number = 0;
      
      public var itemFeatureFriendSet:ItemFeatureFriendSet = null;
      
      public var worldId:Number = -1;
      
      public var itemFeatureFriendResult:Object = null;
      
      public var totalFriendsRequired:Number = 7;
      
      public var friendsRequired:Number = 7;
      
      public var featureDays:Number = 7;
      
      public var daysLeft:Number = 7;
      
      public var buyCostCash:Number = 1;
      
      public var rewardCode:String = "";
      
      public var itemName:String = "";
      
      public var thankYouRewardLinkHash:Object = {};
      
      private var m_startTime:Number = 0;
      
      private var m_refreshComplete:Boolean = false;
      
      private var m_finalFriendReceiveTime:Number;
      
      private var m_shareRewardLink:String = "";
      
      private var m_askButton:FarmAnimatedTextButton = null;
      
      private var m_buyButton:FarmAnimatedTextButton = null;
      
      private var m_whatIsThisButton:FarmAnimatedTextButton = null;
      
      private var m_congratulationsText:ZwTextField = null;
      
      private var m_congratulationsWindow:ZwFrame = null;
      
      private var m_congratulationsNameText:ZwTextField = null;
      
      private var m_objectPreviewFrame:ObjectPreviewFrame = null;
      
      private var m_tutorial:ZwFrame = null;
      
      private var m_buyDialog:GenericPopup = null;
      
      private var m_impulseBuyDialog:ImpulseBuy = null;
      
      private var m_friendSlotFrame:DuckGameFriendSlotFrame;
      
      private var m_rewardSlotFrame:DuckGameRewardSlotFrame;
      
      public function DuckGameWindow(data:Object)
      {
         this.worldId = data.worldId;
         this.ducklingGameId = data.ducklingGameId;
         this.itemName = data.itemName;
         super("assets/dialogs/FV_DuckPond_Game.swf");
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         addWidget(new ZwTextField(m_window.header_tf,ZLocUtils.t("Dialogs","DuckGame_Title")));
         this.m_congratulationsText = new ZwTextField(m_window.generic0_tf,ZLocUtils.t("Dialogs","DuckGame_Congratulations",[this.totalFriendsRequired]));
         addWidget(this.m_congratulationsText,false);
         this.m_askButton = new FarmAnimatedTextButton(m_window.ask_bt,ZLocUtils.t("Dialogs","DuckGame_Ask"),this.onAskClick);
         addWidget(this.m_askButton,false);
         this.m_buyButton = new FarmAnimatedTextButton(m_window.buy_bt,ZLocUtils.t("Dialogs","DuckGame_Buy"),this.onBuyClick);
         addWidget(this.m_buyButton,false);
         this.m_whatIsThisButton = new FarmAnimatedTextButton(m_window.whatisthis_bt,ZLocUtils.t("Dialogs","DuckGame_HowDoesThisWork"),this.howDoesThisWorkClick);
         addWidget(this.m_whatIsThisButton);
         this.m_friendSlotFrame = new DuckGameFriendSlotFrame(m_window.friends_mc,[],this);
         addWidget(this.m_friendSlotFrame);
         this.m_rewardSlotFrame = new DuckGameRewardSlotFrame(m_window.bottom_mc,[],this);
         addWidget(this.m_rewardSlotFrame);
         if(!Global.player.getSeenFlag("ducklingGameTutorial"))
         {
            this.m_tutorial = new ZwFrame(m_window.tutorial_mc);
            this.m_tutorial.addWidget(new ZwTextField(m_window.tutorial_mc.generic0_tf,ZLocUtils.t("Dialogs","DuckGame_Tutorial1")));
            this.m_tutorial.addWidget(new ZwTextField(m_window.tutorial_mc.generic1_tf,ZLocUtils.t("Dialogs","DuckGame_Tutorial2")));
            this.m_tutorial.addWidget(new FarmAnimatedTextButton(m_window.tutorial_mc.okay_bt,ZLocUtils.t("Dialogs","DuckGame_Okay"),this.onOkayClick));
            addWidget(this.m_tutorial);
            this.m_tutorial.element.play();
            Global.player.setSeenFlag("ducklingGameTutorial");
         }
         this.m_congratulationsWindow = new ZwFrame(m_window.congrats_mc);
         this.m_congratulationsWindow.addWidget(new ZwTextField(m_window.congrats_mc.title_tf,ZLocUtils.t("Dialogs","DuckGame_Chose1")));
         this.m_congratulationsWindow.addWidget(new ZwTextField(m_window.congrats_mc.generic0_tf,ZLocUtils.t("Dialogs","DuckGame_Chose2")));
         this.m_congratulationsNameText = new ZwTextField(m_window.congrats_mc.name_tf);
         this.m_congratulationsWindow.addWidget(this.m_congratulationsNameText);
         this.m_congratulationsWindow.addWidget(new ZwTextField(m_window.congrats_mc.generic1_tf,ZLocUtils.t("Dialogs","DuckGame_Chose3")));
         this.m_congratulationsWindow.addWidget(new FarmAnimatedTextButton(m_window.congrats_mc.share_bt,ZLocUtils.t("Dialogs","DuckGame_Share"),this.onShareClick));
         addWidget(this.m_congratulationsWindow,false);
         this.featureSetRefresh();
      }
      
      override protected function release() : void
      {
         super.release();
         this.m_askButton = null;
         this.m_buyButton = null;
         this.m_whatIsThisButton = null;
         this.m_congratulationsText = null;
         this.m_congratulationsWindow = null;
         this.m_congratulationsNameText = null;
         this.m_objectPreviewFrame = null;
         this.m_tutorial = null;
         this.m_buyDialog = null;
         this.m_impulseBuyDialog = null;
         this.m_objectPreviewFrame = null;
         this.m_friendSlotFrame = null;
         this.m_rewardSlotFrame = null;
      }
      
      public function featureSetRefresh() : void
      {
         this.itemFeatureFriendSet = FriendSet.factory(DucklingAnimal.DUCKLING_GAME_FRIEND_SET_CODE,this.ducklingGameId,this.featureSetUpdate) as ItemFeatureFriendSet;
         this.itemFeatureFriendSet.initializeData();
      }
      
      private function featureSetUpdate(itemFeatureFriendSetIn:FriendSet, result:Object) : void
      {
         var friendData:Array = null;
         var boughtFriendCount:int = 0;
         var _uid:String = null;
         var numHelpers:int = 0;
         var countTemp:* = 0;
         var calcTime:Number = NaN;
         var rewardData:Array = null;
         var numDays:Number = NaN;
         var code:String = null;
         if(m_window != null)
         {
            this.itemFeatureFriendSet = itemFeatureFriendSetIn as ItemFeatureFriendSet;
            this.itemFeatureFriendResult = result;
            friendData = [];
            boughtFriendCount = Math.max(Math.min(int(this.itemFeatureFriendResult.boughtFriendCount),this.totalFriendsRequired),0);
            for(_uid in this.itemFeatureFriendResult.uids)
            {
               if(friendData.length < this.totalFriendsRequired && this.itemFeatureFriendResult.uids[_uid] == "1")
               {
                  friendData.push({"uid":_uid.replace("_","")});
               }
            }
            numHelpers = int(friendData.length);
            countTemp = boughtFriendCount;
            while(friendData.length < this.totalFriendsRequired)
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
            this.m_friendSlotFrame.setData(friendData);
            this.friendsRequired = Math.max(0,7 - (boughtFriendCount + numHelpers));
            this.buyCostCash = this.friendsRequired * 3;
            this.m_finalFriendReceiveTime = this.itemFeatureFriendResult.finalFriendReceiveTime;
            this.m_startTime = this.itemFeatureFriendResult.startTime;
            calcTime = this.m_finalFriendReceiveTime > 0 ? this.m_finalFriendReceiveTime : int(GlobalEngine.serverTime / 1000);
            this.daysLeft = Math.max(0,this.featureDays - (calcTime - this.m_startTime) / FarmGameUtil.NUM_SECS_IN_DAY);
            if(this.daysLeft < 1)
            {
               this.friendsRequired = 0;
            }
            if(this.friendsRequired == 0)
            {
               if(numHelpers < 4)
               {
                  this.m_congratulationsText.text = ZLocUtils.t("Dialogs","DuckGame_FewFriends");
               }
               else if(this.daysLeft < 1)
               {
                  this.m_congratulationsText.text = ZLocUtils.t("Dialogs","DuckGame_GoodJob",{"quantity":numHelpers});
               }
               else
               {
                  this.m_congratulationsText.text = ZLocUtils.t("Dialogs","DuckGame_Congratulations",{"quantity":numHelpers});
               }
               this.m_congratulationsText.visible = true;
               this.m_askButton.visible = false;
               this.m_buyButton.visible = false;
            }
            else
            {
               this.m_congratulationsText.visible = false;
               this.m_askButton.visible = true;
               this.m_buyButton.visible = true;
            }
            rewardData = [];
            numDays = 0;
            for(code in this.itemFeatureFriendResult.availableRewards)
            {
               numDays = Number(this.itemFeatureFriendResult.availableRewards[code]);
               rewardData[numDays - 1] = {"itemCode":code};
            }
            rewardData = rewardData.reverse();
            this.m_rewardSlotFrame.setData(rewardData);
            this.m_friendSlotFrame.refresh();
            this.m_rewardSlotFrame.featureSetUpdate();
         }
         this.m_refreshComplete = true;
      }
      
      override protected function onClose(event:Event) : void
      {
         var keepDialog:GenericIconPopup = null;
         var ducklingItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(this.itemName);
         if(ducklingItem != null && (this.m_refreshComplete && this.m_buyButton.visible == false) && this.rewardCode == "")
         {
            keepDialog = new GenericIconPopup(ZLocUtils.t("Dialogs","Duckling_Keep_Forever",{"item":ZLocUtils.tk_pk(ducklingItem.friendlyName)}),GenericPopup.TYPE_ACCEPTCANCEL,this.onKeepForeverCallback,ducklingItem.icon);
            UI.displayPopup(keepDialog,false);
         }
         super.onClose(event);
      }
      
      private function onKeepForeverCallback(event:GenericPopupEvent) : void
      {
         var worldObjId:Number = NaN;
         var delegateCallback:Function = null;
         if(event.button == GenericPopup.ACCEPT)
         {
            worldObjId = this.worldId;
            delegateCallback = function(result:Object):void
            {
               var ducklingObj:DucklingAnimal = Global.world.getObjectById(worldObjId) as DucklingAnimal;
               if(ducklingObj != null)
               {
                  ducklingObj.keepForever();
               }
            };
            TransactionManager.addTransaction(new TChooseFriendSetReward(this.itemFeatureFriendSet,this.worldId,"",delegateCallback),true);
            FarmStatsManager.count("duck_pond_feature","duckling_ui_dialog","keep_forever",this.itemName);
         }
         super.close();
      }
      
      public function update() : void
      {
         var calcTime:Number = NaN;
         if(this.m_rewardSlotFrame)
         {
            calcTime = this.m_finalFriendReceiveTime > 0 ? this.m_finalFriendReceiveTime : GlobalEngine.serverTime / 1000;
            this.daysLeft = Math.max(0,this.featureDays - (calcTime - this.m_startTime) / FarmGameUtil.NUM_SECS_IN_DAY);
            this.m_rewardSlotFrame.update();
         }
      }
      
      public function setDuckChosen(itemCode:String, result:Object) : void
      {
         var obj:Object = null;
         var farmItem:FarmItem = null;
         this.rewardCode = itemCode;
         this.m_shareRewardLink = result.rewardLink;
         if(result.thankYouRewardLinks)
         {
            for each(obj in result.thankYouRewardLinks)
            {
               this.thankYouRewardLinkHash[obj.uid] = obj.rewardLink;
            }
         }
         if(this.m_congratulationsWindow)
         {
            if(this.m_objectPreviewFrame)
            {
               this.m_congratulationsWindow.removeWidget(this.m_objectPreviewFrame);
               this.m_objectPreviewFrame = null;
            }
            farmItem = Global.farmGameSettingsManager.getFarmItemByCode(itemCode);
            if(farmItem)
            {
               this.m_objectPreviewFrame = new ObjectPreviewFrame(m_window.congrats_mc.loader_mc,farmItem,null,[5]);
               this.m_congratulationsWindow.addWidget(this.m_objectPreviewFrame);
               this.m_congratulationsNameText.text = ZLocUtils.tk_pk_asTitle(farmItem.friendlyName);
               this.m_congratulationsWindow.visible = true;
            }
         }
         if(this.m_rewardSlotFrame)
         {
            this.m_rewardSlotFrame.visible = false;
            this.m_rewardSlotFrame.featureSetUpdate();
         }
         if(this.m_friendSlotFrame)
         {
            this.m_friendSlotFrame.refresh();
         }
      }
      
      private function howDoesThisWorkClick(event:MouseEvent) : void
      {
         var msg:String = ZLocUtils.t("Dialogs","DuckGame_HowDoesThisWorkMessage",{"quantity":this.totalFriendsRequired});
         var dialog:GenericXMLDialog = new GenericXMLDialog(null,null,null,null,NaN,NaN,msg,null,false,"Okay",null,null,null,null,GenericXMLDialog.NUM_DIALOG_WIDTH_MEDIUM);
         UI.displayPopup(dialog,false);
      }
      
      private function onAskClick(event:MouseEvent) : void
      {
         if(this.m_tutorial != null)
         {
            this.m_tutorial.visible = false;
         }
         this.updateDucklingAttemptedProgress();
         MFSRequestManager.getInstance().makeFriendSetRequest(this.itemName,"DucklingGame","FS02",this.ducklingGameId,MFSConstants.SOURCE_DIALOG_CLICKED,"duck_pond_feature","duckling_ui_dialog","ask_for_help");
      }
      
      private function onOkayClick(event:MouseEvent) : void
      {
         if(this.m_tutorial != null)
         {
            this.m_tutorial.visible = false;
         }
      }
      
      private function onShareClick(event:MouseEvent) : void
      {
         var bundleData:Object = null;
         var messageType:String = null;
         FarmStatsManager.count("dialog","wall_to_wall-duckpond-duckling_game_thanks","Share");
         this.m_congratulationsWindow.visible = false;
         this.m_rewardSlotFrame.visible = true;
         var farmItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByCode(this.rewardCode);
         if(farmItem)
         {
            bundleData = {
               "reward_name":farmItem.friendlyName,
               "reward_link":this.m_shareRewardLink,
               "images":[{
                  "href":"{SN_APP_URL}" + this.m_shareRewardLink,
                  "src":farmItem.icon
               }]
            };
            messageType = "DuckGameFinished";
            GlobalEngine.socialNetwork.publishFeedStory(messageType,bundleData,[],false);
         }
         FarmStatsManager.count("duck_pond_feature","duckling_ui_dialog","on_share_click");
      }
      
      private function onBuyClick(event:MouseEvent) : void
      {
         var popUpMessage:String = null;
         this.m_buyButton.enabled = false;
         if(Global.player.cash >= this.buyCostCash)
         {
            popUpMessage = ZLocUtils.t("Dialogs","DuckGame_BuyMessage",{"quantity":this.buyCostCash});
            this.m_buyDialog = new GenericPopup(popUpMessage,GenericPopup.TYPE_ACCEPTCANCEL,this.onBuyClose);
            UI.displayPopup(this.m_buyDialog,false);
         }
         else
         {
            this.m_impulseBuyDialog = UI.displayImpulseBuyPopup(ImpulseBuy.TYPE_MARKET_CASH,"impulseBuyPopup",this.buyCostCash,"duckgame");
            if(this.m_impulseBuyDialog != null)
            {
               this.m_impulseBuyDialog.addEventListener(ImpulseBuyEvent.CANCEL,this.onImpulseBuyCancel);
            }
         }
      }
      
      private function onBuyClose(evt:GenericPopupEvent) : void
      {
         if(evt.button == GenericPopup.ACCEPT)
         {
            this.updateDucklingAttemptedProgress();
            TransactionManager.addTransaction(new TCompleteFriendSet(this.itemFeatureFriendSet,this.featureSetRefresh),true);
            this.m_buyDialog = null;
            FarmStatsManager.count("duck_pond_feature","duckling_ui_dialog","grow_now","accept");
         }
         else
         {
            this.m_buyButton.enabled = true;
            FarmStatsManager.count("duck_pond_feature","duckling_ui_dialog","grow_now","cancel");
         }
      }
      
      private function updateDucklingAttemptedProgress() : void
      {
         var ducklingObj:DucklingAnimal = Global.world.getObjectById(this.worldId) as DucklingAnimal;
         if(ducklingObj)
         {
            ducklingObj.attemptedProgress();
         }
      }
      
      private function onImpulseBuyCancel(event:ImpulseBuyEvent) : void
      {
         if(this.m_impulseBuyDialog)
         {
            this.m_impulseBuyDialog.removeEventListener(ImpulseBuyEvent.CANCEL,this.onImpulseBuyCancel);
            this.m_impulseBuyDialog = null;
         }
      }
      
      public function set buttonsEnabled(newState:Boolean) : void
      {
         this.m_rewardSlotFrame.chooseButtonsEnabled = newState;
      }
   }
}

