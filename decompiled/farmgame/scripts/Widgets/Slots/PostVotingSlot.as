package Widgets.Slots
{
   import Classes.ZItem.FarmItem;
   import Classes.util.FacebookSocialNetwork;
   import Classes.util.ZLocUtils;
   import Engine.Managers.TransactionManager;
   import Managers.FeatureOptionsManager;
   import Managers.TemplateUIUtility;
   import Managers.ToasterManager;
   import Managers.VotingDataManager;
   import Transactions.TGenericTransaction;
   import Transactions.Voting.TBuyVoteItem;
   import Widgets.Buttons.FarmAnimatedCashButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import Widgets.Windows.FarmWindow;
   import Widgets.Windows.IconToasterWindow;
   import flash.display.DisplayObject;
   import flash.events.Event;
   
   public class PostVotingSlot extends GenericTimedSlot
   {
      
      private static const ACTION_POST_FEED:String = "postFeed";
      
      private var m_index:int = -1;
      
      private var m_lastShown:Number;
      
      private var m_isTemplateUIEnabled:Boolean = false;
      
      private var m_featureName:String;
      
      private var m_voteObject:Object;
      
      private var m_askForFeedPostedCallback:Function = null;
      
      protected var m_feedPublishFailCallback:Function;
      
      private const SERVICE_CLASS:String = "VotingService";
      
      private var m_TabIndex:int = 0;
      
      public function PostVotingSlot(element:DisplayObject, parentWindow:FarmWindow, featureName:String, tabIndex:int)
      {
         var buyButton:FarmAnimatedCashButton = null;
         this.m_featureName = featureName;
         this.m_TabIndex = tabIndex;
         this.m_isTemplateUIEnabled = TemplateUIUtility.isTemplateUIEnabled(TemplateUIUtility.COUNTDOWN);
         super(element,parentWindow);
         if(m_element.currentBG_mc != null)
         {
            addWidget(new ZwFrame(m_element.currentBG_mc));
         }
         if(m_element.iconBox_mc != null)
         {
            addWidget(new FarmIcon(m_element.iconBox_mc));
         }
         if(m_element.itemBox_mc != null)
         {
            addWidget(new FarmIcon(m_element.itemBox_mc));
         }
         if(Boolean(!isTemplateUIEnabled()) && Boolean(m_element) && Boolean(m_element["description_tf"]))
         {
            addWidget(new ZwTextField(m_element.description_tf,ZLocUtils.t("HolidayCountdown","HolidayCountdownToGet")));
         }
         if(m_element.buy_bt != null)
         {
            buyButton = getWidget(m_element.buy_bt) as FarmAnimatedCashButton;
            buyButton.text = ZLocUtils.t("Dialogs","PostVotingBuyText");
            buyButton.showPaymentConfirmation = true;
         }
      }
      
      override public function populate(data:Object) : void
      {
         var elementNew:DisplayObject = null;
         var buyButton:FarmAnimatedCashButton = null;
         var itemName:ZwTextField = null;
         this.m_index = uint(data);
         m_item = this.getCurrentItem(null);
         var postVoteObject:Object = {};
         super.populate(postVoteObject);
         if(isTemplateUIEnabled())
         {
            elementNew = m_element.completeBG_mc;
            getWidget(elementNew).visible = true;
         }
         var voteObject:Object = VotingDataManager.getFeatureVoteItemByIndexAndVoteIndex(this.m_featureName,this.m_index,this.m_TabIndex);
         this.m_voteObject = voteObject;
         m_cost = this.m_voteObject.buyCost;
         if(m_element.buy_bt != null)
         {
            buyButton = getWidget(m_element.buy_bt) as FarmAnimatedCashButton;
            buyButton.setAmountText(m_cost.toString());
            buyButton.visible = true;
         }
         if(m_element.itemTitle_tf != null)
         {
            itemName = getWidget(m_element.itemTitle_tf) as ZwTextField;
            if(m_item == null)
            {
               m_item = this.getCurrentItem(null);
            }
            itemName.text = m_item.friendlyTitle;
            itemName.visible = false;
         }
      }
      
      override protected function hasFinishedSlot() : Boolean
      {
         return VotingDataManager.getInstance().isItemCollected(this.m_featureName,m_item.name);
      }
      
      override protected function popNotFinishedSlot() : void
      {
         var itemReward:FarmIcon = null;
         var itemBox:FarmIcon = null;
         var itemRewardIcon:FarmIcon = null;
         super.popNotFinishedSlot();
         if(Boolean(!isTemplateUIEnabled()) && Boolean(m_element) && m_element.itemReward_mc != null)
         {
            itemReward = getWidget(m_element.itemReward_mc) as FarmIcon;
            itemReward.visible = false;
         }
         if(Boolean(isTemplateUIEnabled()) && Boolean(m_element) && Boolean(m_element["itemBox_mc"]))
         {
            itemBox = getWidget(m_element.itemBox_mc) as FarmIcon;
            m_item = this.getCurrentItem(null);
            if(itemBox)
            {
               itemBox.loadIcon(m_item.icon);
               itemBox.visible = true;
            }
         }
         if(Boolean(!isTemplateUIEnabled()) && Boolean(m_element) && m_element.itemReward_mc != null)
         {
            itemRewardIcon = getWidget(m_element.itemReward_mc) as FarmIcon;
            itemRewardIcon.loadIcon(m_item.icon);
            itemRewardIcon.visible = true;
            if(!itemRewardIcon.element["bounds_mc"])
            {
               itemRewardIcon.setIconSize(100,100);
            }
         }
         if(m_element.ask_bt != null)
         {
            getWidget(m_element.ask_bt).visible = true;
         }
      }
      
      override protected function getItemsOwned() : int
      {
         var numCurrentFeeds:int = 0;
         var data:Object = FeatureOptionsManager.getInstance().getFeatureOption(this.m_featureName,FeatureOptionsManager.POST_VOTING_STATE);
         if(Boolean(data) && data.hasOwnProperty(m_item.name))
         {
            numCurrentFeeds = int(data[m_item.name]);
         }
         return numCurrentFeeds;
      }
      
      override protected function getItemsNeeded() : int
      {
         return VotingDataManager.getInstance().getVotesNeededForPrize(this.m_featureName,this.m_index);
      }
      
      override protected function canAskForItem() : Boolean
      {
         return VotingDataManager.getInstance().isAskForFeedsEnabled(this.m_featureName);
      }
      
      override protected function getCurrentItem(data:Object) : FarmItem
      {
         this.m_TabIndex = VotingDataManager.m_selectedTabIndex;
         var voteObject:Object = VotingDataManager.getFeatureVoteItemByIndexAndVoteIndex(this.m_featureName,this.m_index,this.m_TabIndex);
         this.m_voteObject = voteObject;
         return Global.farmGameSettingsManager.getFarmItemByName(this.m_voteObject.name);
      }
      
      override protected function onBuyItemCallback(event:Event) : void
      {
         var itemCost:int = 0;
         var prizeName:String = null;
         var giftItem:FarmItem = null;
         if(m_item != null && Global.player.canBuyCash(m_item.cash,true,m_item.name))
         {
            itemCost = m_cost;
            prizeName = m_item.name;
            TransactionManager.addTransaction(new TBuyVoteItem(this.m_featureName,prizeName,itemCost,null,true),true);
            Global.player.addGift(prizeName,"0",1);
            Global.player.cash -= itemCost;
            VotingDataManager.getInstance().setVoteResults(this.m_featureName,this.m_voteObject.voteIndex,this.m_voteObject.stage);
            if(this.m_voteObject != null)
            {
               VotingDataManager.getInstance().setCollectedItem(this.m_featureName,this.m_voteObject.name);
            }
            m_parentWindow.refreshWindow();
            giftItem = Global.farmGameSettingsManager.getFarmItemByName(prizeName);
            ToasterManager.getInstance().addImmediate(new IconToasterWindow(giftItem.iconUrl,ZLocUtils.t_pk("Dialogs","FindInGiftbox",{"itemName":giftItem.friendlyTitle})));
            m_parentWindow.close();
         }
      }
      
      override protected function onAskCallback(event:Event) : void
      {
         var itemName:String = m_item.name;
         m_parentWindow.tintWindow();
         this.askForFeeds(this.feedsuccessCallback,this.feedFailedCallback);
      }
      
      private function feedsuccessCallback() : void
      {
         var currentTimeInSec:Number = GlobalEngine.serverTime / 1000;
         var strFeatureFlagName:String = "PostVoting" + "_lastAskForFeeds";
         Global.player.setFeatureLastShown(strFeatureFlagName,currentTimeInSec,true);
         m_parentWindow.refreshWindow();
      }
      
      private function feedFailedCallback() : void
      {
         m_parentWindow.refreshWindow();
      }
      
      public function askForFeeds(askForFeedPostedCallback:Function = null, feedPublishFailCallback:Function = null) : void
      {
         var personality:String = null;
         this.m_askForFeedPostedCallback = askForFeedPostedCallback;
         this.m_feedPublishFailCallback = feedPublishFailCallback;
         if(this.canAskForItem())
         {
            if(this.m_TabIndex == 0)
            {
               personality = ZLocUtils.t("Dialogs",this.m_featureName + VotingDataManager.PERSONALITY_ONE_TEXT);
            }
            else
            {
               personality = ZLocUtils.t("Dialogs",this.m_featureName + VotingDataManager.PERSONALITY_TWO_TEXT);
            }
            TransactionManager.addTransaction(new TGenericTransaction(this.SERVICE_CLASS,ACTION_POST_FEED,this.onFeedPostComplete,[this.m_featureName,m_item.name,personality]),true);
         }
         else if(this.m_askForFeedPostedCallback != null)
         {
            this.m_askForFeedPostedCallback();
            this.m_askForFeedPostedCallback = null;
         }
      }
      
      private function onFeedPostComplete(result:Object) : void
      {
         if(Boolean(result) && result.hasOwnProperty("feedData"))
         {
            (GlobalEngine.socialNetwork as FacebookSocialNetwork).publishResultsFromTransaction(result.feedData,this.handleFeedPostReturn);
         }
      }
      
      private function handleFeedPostReturn(success:Boolean) : void
      {
         if(success)
         {
            if(this.m_askForFeedPostedCallback != null)
            {
               this.m_askForFeedPostedCallback();
               this.m_askForFeedPostedCallback = null;
            }
         }
         else if(this.m_feedPublishFailCallback != null)
         {
            this.m_feedPublishFailCallback();
            this.m_feedPublishFailCallback = null;
         }
      }
   }
}

