package Widgets.Windows.LonelyAnimal
{
   import Classes.Constants.Experiments;
   import Classes.FeatureDataObjects.FriendSet;
   import Classes.FeatureDataObjects.LonelyAnimalFeatureFriendSet;
   import Classes.LonelyAnimal;
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.GenericXMLDialog;
   import Display.ImpulseBuy;
   import Display.UI;
   import Engine.Managers.LoadingManager;
   import Engine.Managers.TransactionManager;
   import Events.GenericPopupEvent;
   import Events.ImpulseBuyEvent;
   import Managers.FarmStatsManager;
   import Transactions.TCompleteFriendSet;
   import Transactions.TLonelyAnimalFeedPost;
   import Transactions.TMarkLonelyAnimalFriendSet;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwBaseWidget;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.LonelyAnimal.LonelyAnimalFriendSlotFrame;
   import Widgets.TextFields.FarmTextField;
   import Widgets.Windows.FarmWindow;
   import com.troyer.widget.MT4DManager;
   import com.troyer.widget.event.WidgetControllerEvent;
   import flash.display.Loader;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class LonelyAnimalWindow extends FarmWindow
   {
      
      public static const FEED_POST_FREQUENCY_FLAG:String = "lonelyAnimalFeedPost";
      
      private static const LONELY_ANIMAL_FEED_POST_COOLDOWN_DEFAULT:int = 14400;
      
      private static const LONELY_ANIMAL_REQUEST_FLOW_VARIANT:int = 1;
      
      private static const LONELY_ANIMAL_FEED_FLOW_VARIANT:int = 2;
      
      public var m_itemFeatureFriendSet:LonelyAnimalFeatureFriendSet = null;
      
      private var m_fsId:Number = -1;
      
      private var m_lonelyAnimal:LonelyAnimal;
      
      public var m_itemFeatureFriendResult:Object = null;
      
      public var m_itemName:String = "";
      
      public var m_friendlyName:String = "";
      
      public var m_totalFriendsRequired:Number = 5;
      
      public var m_friendsRequired:Number = 5;
      
      public var featureDays:Number = 3;
      
      public var m_daysLeft:Number = 3;
      
      private var m_buyCostCash:Number = 20;
      
      private var m_startTime:Number = 0;
      
      private var m_refreshComplete:Boolean = false;
      
      private var m_finalFriendReceiveTime:Number;
      
      private var m_askButton:FarmAnimatedTextButton = null;
      
      private var m_buyButton:FarmAnimatedTextButton = null;
      
      private var m_whatIsThisButton:FarmAnimatedTextButton = null;
      
      private var m_checkMark:ZwBaseWidget = null;
      
      private var m_descriptionText:ZwTextField = null;
      
      private var m_countdown:ZwTextField = null;
      
      private var m_tutorial:ZwFrame = null;
      
      private var m_buyDialog:GenericPopup = null;
      
      private var m_optOutDialog:GenericPopup = null;
      
      private var m_impulseBuyDialog:ImpulseBuy = null;
      
      private var m_friendSlotFrame:LonelyAnimalFriendSlotFrame;
      
      private var m_statsKey:String;
      
      public function LonelyAnimalWindow(data:Object)
      {
         this.m_fsId = data.fsId;
         this.m_itemName = data.itemName;
         this.m_lonelyAnimal = data.lonelyAnimal;
         super("assets/dialogs/FV_LonelyAnimal_Game.swf");
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         if(!Global.player.getSeenSessionFlag(LonelyAnimal.LONELY_ANIMAL_MADE_PROGRESS))
         {
            this.m_statsKey = "first_main_dialog";
            Global.player.setSeenSessionFlag(LonelyAnimal.LONELY_ANIMAL_MADE_PROGRESS);
         }
         else
         {
            this.m_statsKey = "return_main_dialog";
         }
         var item:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(this.m_itemName);
         this.m_friendlyName = item.friendlyName;
         addWidget(new ZwTextField(m_window.header_tf,ZLocUtils.t("Dialogs","LonelyAnimal_Title")));
         this.m_descriptionText = new ZwTextField(m_window.generic0_tf,ZLocUtils.t("Dialogs","LonelyAnimal_DialogText",{
            "animalName":ZLocUtils.tk_pk_asTitle(this.m_friendlyName),
            "numRequiredFriends":this.m_totalFriendsRequired,
            "animalName2":ZLocUtils.tk_pk_asTitle(this.m_friendlyName)
         }));
         addWidget(this.m_descriptionText);
         this.m_countdown = new ZwTextField(m_window.timeLeft_tf,"");
         addWidget(this.m_countdown);
         var popupCooldown:int = Global.flashHotParams["LONELY_ANIMAL_FEED_POST_COOLDOWN"] != null ? int(Global.flashHotParams["LONELY_ANIMAL_FEED_POST_COOLDOWN"]) : LONELY_ANIMAL_FEED_POST_COOLDOWN_DEFAULT;
         var lastPopupSeen:int = Global.player.getFeatureLastShown(FEED_POST_FREQUENCY_FLAG);
         var currentTime:int = GlobalEngine.serverTime / 1000;
         var timeSinceLastSeen:int = currentTime - lastPopupSeen;
         var eosVariant:int = Global.eosManager.getEosVariant(Experiments.EXPERIMENT_LONELY_ANIMAL_CREW);
         if(timeSinceLastSeen < popupCooldown)
         {
            this.m_askButton = new FarmAnimatedTextButton(m_window.ask_bt,ZLocUtils.t("Dialogs","Posted"),this.onAskClick);
            this.m_askButton.toggleClickableButton(false);
         }
         else
         {
            this.m_askButton = new FarmAnimatedTextButton(m_window.ask_bt,ZLocUtils.t("Dialogs","Ask"),this.onAskClick);
         }
         addWidget(this.m_askButton,false);
         this.m_buyButton = new FarmAnimatedTextButton(m_window.buy_bt,ZLocUtils.t("Dialogs","craftingWorkshop_recipeIndicator_desc"),this.onBuyClick);
         addWidget(this.m_buyButton,false);
         this.m_whatIsThisButton = new FarmAnimatedTextButton(m_window.whatisthis_bt,ZLocUtils.t("Dialogs","DuckGame_HowDoesThisWork"),this.howDoesThisWorkClick);
         addWidget(this.m_whatIsThisButton);
         this.m_friendSlotFrame = new LonelyAnimalFriendSlotFrame(m_window.friends_mc,[],this);
         addWidget(this.m_friendSlotFrame);
         addWidget(new ZwBaseWidget(m_window.icon_mc));
         this.setImage(item.getIconUrlFromActiveData());
         this.m_checkMark = addWidget(new ZwBaseWidget(m_window.checkmark_mc)) as ZwBaseWidget;
         this.m_checkMark.visible = false;
         var checkBox:FarmAnimatedButton = addWidget(new FarmAnimatedButton(m_window.checkbox2_mc,this.onCheckboxClick)) as FarmAnimatedButton;
         var checkBoxText:FarmTextField = addWidget(new FarmTextField(m_window.checkBox_tf,ZLocUtils.t("Dialogs","LonelyAnimal_HelpNextTime"))) as FarmTextField;
         FarmStatsManager.count("lonely_animal_crew_feature",this.m_statsKey,"impression");
         this.featureSetRefresh();
      }
      
      private function setImage(url:String = "") : void
      {
         var icon:Loader = null;
         icon = LoadingManager.load(url,function(event:Event):void
         {
            var dispObj:* = undefined;
            if(Boolean(icon) && Boolean(icon.content))
            {
               dispObj = icon.content;
               m_window.icon_mc.addChild(dispObj);
            }
         });
      }
      
      override protected function release() : void
      {
         super.release();
      }
      
      private function onCheckboxClick(event:Event) : void
      {
         this.m_checkMark.visible = true;
         this.enabled = false;
         var item:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(this.m_itemName);
         var popUpMessage:String = ZLocUtils.t("Dialogs","LonelyAnimal_DialogRemove",{"animalName":ZLocUtils.tk_pk_asTitle(item.friendlyName)});
         this.m_optOutDialog = new GenericPopup(popUpMessage,GenericPopup.TYPE_ACCEPTCANCEL,this.onOptOutClose);
         UI.displayPopup(this.m_optOutDialog,false);
      }
      
      private function onOptOutClose(event:GenericPopupEvent) : void
      {
         this.enabled = true;
         this.m_checkMark.visible = false;
         this.m_optOutDialog = null;
         if(event.button == GenericPopup.ACCEPT)
         {
            FarmStatsManager.count("lonely_animal_crew_feature",this.m_statsKey,"opt_out_box","accept");
            Global.player.setFeatureLastShown(LonelyAnimal.LONELY_ANIMAL_SEEN_FLAG,GlobalEngine.currentTime,false);
            TransactionManager.addTransaction(new TMarkLonelyAnimalFriendSet(this.m_itemFeatureFriendSet,TMarkLonelyAnimalFriendSet.LONELY_ANIMAL_PROGRESS_END));
            this.m_lonelyAnimal.hideAnimal();
         }
         else
         {
            FarmStatsManager.count("lonely_animal_crew_feature",this.m_statsKey,"opt_out_box","cancel");
         }
      }
      
      override public function close() : void
      {
         FarmStatsManager.count("lonely_animal_crew_feature",this.m_statsKey,"close_button");
         super.close();
      }
      
      private function howDoesThisWorkClick(event:MouseEvent) : void
      {
         var msg:String = ZLocUtils.t("Dialogs","LonelyAnimal_HowDoesThisWorkMessage",{"quantity":this.m_totalFriendsRequired});
         var dialog:GenericXMLDialog = new GenericXMLDialog(null,null,null,null,NaN,NaN,msg,null,false,"Okay",null,null,null,null,GenericXMLDialog.NUM_DIALOG_WIDTH_MEDIUM);
         UI.displayPopup(dialog,false);
      }
      
      public function featureSetRefresh() : void
      {
         this.m_itemFeatureFriendSet = FriendSet.factory(LonelyAnimal.LONELY_ANIMAL_FRIENDSET_CODE,this.m_fsId,this.featureSetUpdate) as LonelyAnimalFeatureFriendSet;
         this.m_itemFeatureFriendSet.initializeData();
      }
      
      private function featureSetUpdate(itemFeatureFriendSetIn:FriendSet, result:Object) : void
      {
         var friendData:Array = null;
         var boughtFriendCount:int = 0;
         var _uid:String = null;
         var numHelpers:int = 0;
         var countTemp:* = 0;
         var calcTime:Number = NaN;
         var hoursLeft:Number = NaN;
         if(m_window != null)
         {
            this.m_itemFeatureFriendSet = itemFeatureFriendSetIn as LonelyAnimalFeatureFriendSet;
            this.m_itemFeatureFriendResult = result;
            friendData = [];
            boughtFriendCount = Math.max(Math.min(int(this.m_itemFeatureFriendResult.boughtFriendCount),this.m_totalFriendsRequired),0);
            for(_uid in this.m_itemFeatureFriendResult.uids)
            {
               if(friendData.length < this.m_totalFriendsRequired && this.m_itemFeatureFriendResult.uids[_uid] == "1")
               {
                  friendData.push({"uid":_uid.replace("_","")});
               }
            }
            numHelpers = int(friendData.length);
            countTemp = boughtFriendCount;
            while(friendData.length < this.m_totalFriendsRequired)
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
            this.m_friendsRequired = Math.max(0,this.m_totalFriendsRequired - (boughtFriendCount + numHelpers));
            this.m_buyCostCash = this.m_friendsRequired * 4;
            this.m_finalFriendReceiveTime = this.m_itemFeatureFriendResult.finalFriendReceiveTime;
            this.m_startTime = this.m_itemFeatureFriendResult.startTime;
            calcTime = this.m_finalFriendReceiveTime > 0 ? this.m_finalFriendReceiveTime : int(GlobalEngine.serverTime / 1000);
            this.m_daysLeft = Math.round(Math.max(0,this.featureDays - (calcTime - this.m_startTime) / FarmGameUtil.NUM_SECS_IN_DAY));
            hoursLeft = Math.round(Math.max(0,this.featureDays * 24 - (calcTime - this.m_startTime) / FarmGameUtil.NUM_SECS_IN_HOUR));
            if(this.m_daysLeft > 1)
            {
               this.m_countdown.text = ZLocUtils.t("Dialogs","LonelyAnimal_DialogDaysLeft",{"daysLeft":this.m_daysLeft});
            }
            else
            {
               this.m_countdown.text = ZLocUtils.t("Dialogs","LonelyAnimal_DialogHoursLeft",{"hoursLeft":hoursLeft});
            }
            if(calcTime <= 0 || this.m_friendsRequired == 0)
            {
               this.m_descriptionText.visible = true;
               this.m_askButton.visible = false;
               this.m_buyButton.visible = false;
               this.m_lonelyAnimal.hideAnimal();
               if(calcTime > 0)
               {
                  UI.displayPopup(new LonelyAnimalCompletionWindow(true,this.m_itemFeatureFriendSet,this.m_lonelyAnimal,0),false);
               }
               else
               {
                  UI.displayPopup(new LonelyAnimalCompletionWindow(false,this.m_itemFeatureFriendSet,this.m_lonelyAnimal,this.m_buyCostCash),false);
               }
               this.close();
            }
            else
            {
               this.m_descriptionText.visible = true;
               this.m_askButton.visible = true;
               this.m_buyButton.visible = true;
               this.m_friendSlotFrame.setData(friendData);
               this.m_friendSlotFrame.refresh();
            }
            if(this.m_lonelyAnimal.progressState == TMarkLonelyAnimalFriendSet.LONELY_ANIMAL_PROGRESS_NEW)
            {
               this.m_lonelyAnimal.progressState = TMarkLonelyAnimalFriendSet.LONELY_ANIMAL_PROGRESS_STARTED;
               TransactionManager.addTransaction(new TMarkLonelyAnimalFriendSet(this.m_itemFeatureFriendSet,TMarkLonelyAnimalFriendSet.LONELY_ANIMAL_PROGRESS_STARTED));
            }
         }
         this.m_refreshComplete = true;
      }
      
      private function onAskClick(event:MouseEvent) : void
      {
         if(this.m_tutorial != null)
         {
            this.m_tutorial.visible = false;
         }
         this.updateLonelyAnimalAttemptedProgress();
         TransactionManager.addTransaction(new TLonelyAnimalFeedPost(this.m_itemName,this.m_friendlyName,this.m_itemFeatureFriendSet.index),true);
         this.close();
      }
      
      private function onBuyClick(event:MouseEvent) : void
      {
         var popUpMessage:String = null;
         this.m_buyButton.enabled = false;
         var item:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(this.m_itemName);
         if(Global.player.cash >= this.m_buyCostCash)
         {
            popUpMessage = ZLocUtils.t("Dialogs","LonelyAnimal_DialogBuy",{
               "animalName":ZLocUtils.tk_pk_asTitle(item.friendlyName),
               "quantity":this.m_buyCostCash
            });
            this.m_buyDialog = new GenericPopup(popUpMessage,GenericPopup.TYPE_ACCEPTCANCEL,this.onBuyClose);
            UI.displayPopup(this.m_buyDialog,false);
         }
         else
         {
            this.m_impulseBuyDialog = UI.displayImpulseBuyPopup(ImpulseBuy.TYPE_MARKET_CASH,"impulseBuyPopup",this.m_buyCostCash,item.type);
            if(this.m_impulseBuyDialog != null)
            {
               this.m_impulseBuyDialog.addEventListener(ImpulseBuyEvent.CANCEL,this.onImpulseBuyCancel);
            }
            else
            {
               MT4DManager.getInstance().addEventListener(WidgetControllerEvent.DIALOG_DESTROY,this.onImpulseBuyCancel);
            }
         }
      }
      
      private function onBuyClose(evt:GenericPopupEvent) : void
      {
         if(evt.button == GenericPopup.ACCEPT)
         {
            this.updateLonelyAnimalAttemptedProgress();
            TransactionManager.addTransaction(new TCompleteFriendSet(this.m_itemFeatureFriendSet,this.featureSetRefresh),true);
            this.m_buyDialog = null;
            FarmStatsManager.count("fv_cash_buy","animal",this.m_itemName,"" + this.m_buyCostCash);
            FarmStatsManager.count("lonely_animal_crew_feature",this.m_statsKey,"get_it_now","accept");
         }
         else
         {
            this.m_buyButton.enabled = true;
            FarmStatsManager.count("lonely_animal_crew_feature",this.m_statsKey,"get_it_now","cancel");
         }
      }
      
      private function onImpulseBuyCancel(event:Event) : void
      {
         if(this.m_impulseBuyDialog)
         {
            this.m_buyButton.enabled = true;
            this.m_impulseBuyDialog.removeEventListener(ImpulseBuyEvent.CANCEL,this.onImpulseBuyCancel);
            this.m_impulseBuyDialog = null;
         }
         else
         {
            this.m_buyButton.enabled = true;
            MT4DManager.getInstance().removeEventListener(WidgetControllerEvent.DIALOG_DESTROY,this.onImpulseBuyCancel);
         }
      }
      
      private function updateLonelyAnimalAttemptedProgress() : void
      {
         this.m_lonelyAnimal.updateItemFeatureFriendSet(this.m_itemFeatureFriendSet);
      }
      
      public function get itemName() : String
      {
         return this.m_itemName;
      }
      
      public function get friendsRequired() : Number
      {
         return this.m_friendsRequired;
      }
      
      public function get rewardCode() : String
      {
         var farmItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(this.m_itemName);
         return farmItem.code;
      }
   }
}

