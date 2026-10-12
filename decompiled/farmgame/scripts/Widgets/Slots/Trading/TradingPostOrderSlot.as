package Widgets.Slots.Trading
{
   import Classes.Friend;
   import Classes.Mastery;
   import Classes.Trading.TradingOrder;
   import Classes.Trading.TradingPostConstants;
   import Classes.Trading.TradingPostManager;
   import Classes.ZItem.FarmItem;
   import Classes.ZItem.HarvestableItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.Market.MarketSlotMasteryFrame;
   import Widgets.Frames.Trading.TradingPostOrderSlotFrame;
   import Widgets.Icons.FarmIcon;
   import Widgets.TextFields.FarmTextField;
   import Widgets.Windows.Trading.TradingPostWindow;
   import flash.display.DisplayObject;
   import flash.events.MouseEvent;
   
   public class TradingPostOrderSlot extends ZwSlotFrame
   {
      
      private var m_data:TradingOrder = null;
      
      private var m_parentSlotFrame:TradingPostOrderSlotFrame;
      
      private var m_parentWindow:TradingPostWindow = null;
      
      private var m_player:Friend = null;
      
      private var m_itemInfoFrame:ZwFrame = null;
      
      private var m_buttonFrame:ZwFrame = null;
      
      private var m_actionMessage:FarmTextField = null;
      
      private var m_completeButton:FarmAnimatedTextButton = null;
      
      private var m_askButton:FarmAnimatedTextButton = null;
      
      private var m_innerInfoFrame:ZwFrame = null;
      
      private var m_itemImage:FarmIcon = null;
      
      private var m_itemNameText:FarmTextField = null;
      
      private var m_costText:FarmTextField = null;
      
      private var m_xpGainedText:FarmTextField = null;
      
      private var m_coinImage:ZwFrame = null;
      
      private var m_xpImage:ZwFrame = null;
      
      private var m_masteryFrame:MarketSlotMasteryFrame = null;
      
      public function TradingPostOrderSlot(element:DisplayObject, parentSlotFrame:TradingPostOrderSlotFrame, parentWindow:TradingPostWindow)
      {
         super(element);
         this.m_parentSlotFrame = parentSlotFrame;
         this.m_parentWindow = parentWindow;
         addWidget(new ZwFrame(m_element.chicklet_mc));
         addWidget(new FarmTextField(m_element.generic_tf));
         addWidget(new FarmIcon(m_element.icon_mc));
         this.m_itemInfoFrame = addWidget(new ZwFrame(m_element.get_mc)) as ZwFrame;
         this.m_buttonFrame = this.m_itemInfoFrame.addWidget(new ZwFrame(m_element.get_mc.ask_mc)) as ZwFrame;
         this.m_actionMessage = this.m_buttonFrame.addWidget(new FarmTextField(m_element.get_mc.ask_mc.generic_tf,ZLocUtils.t("Dialogs","tradingpost_UI_all_done"))) as FarmTextField;
         this.m_completeButton = this.m_buttonFrame.addWidget(new FarmAnimatedTextButton(m_element.get_mc.ask_mc.complete_bt,ZLocUtils.t("Dialogs","tradingpost_UI_complete_order"),this.onCompleteOrder)) as FarmAnimatedTextButton;
         this.m_askButton = this.m_buttonFrame.addWidget(new FarmAnimatedTextButton(m_element.get_mc.ask_mc.ask_bt,ZLocUtils.t("Dialogs","tradingpost_UI_waiting"))) as FarmAnimatedTextButton;
         this.m_innerInfoFrame = this.m_itemInfoFrame.addWidget(new ZwFrame(m_element.get_mc.itemInfo_mc)) as ZwFrame;
         this.m_itemImage = this.m_innerInfoFrame.addWidget(new FarmIcon(m_element.get_mc.itemInfo_mc.icon_mc)) as FarmIcon;
         this.m_itemNameText = this.m_innerInfoFrame.addWidget(new FarmTextField(m_element.get_mc.itemInfo_mc.generic1_tf,"")) as FarmTextField;
         this.m_xpGainedText = this.m_innerInfoFrame.addWidget(new FarmTextField(m_element.get_mc.itemInfo_mc.generic_tf,"",true)) as FarmTextField;
         this.m_costText = this.m_innerInfoFrame.addWidget(new FarmTextField(m_element.get_mc.itemInfo_mc.cost_tf,"",true)) as FarmTextField;
         this.m_coinImage = this.m_itemInfoFrame.addWidget(new ZwFrame(m_element.get_mc.itemInfo_mc.coin_mc)) as ZwFrame;
         this.m_xpImage = this.m_itemInfoFrame.addWidget(new ZwFrame(m_element.get_mc.itemInfo_mc.xp_mc)) as ZwFrame;
         this.m_masteryFrame = addWidget(new MarketSlotMasteryFrame(m_element.get_mc.itemInfo_mc.mastery_mc)) as MarketSlotMasteryFrame;
      }
      
      override public function populate(data:Object) : void
      {
         this.updateSlot(data);
      }
      
      private function updateSlot(data:Object) : void
      {
         var farmItem:FarmItem = null;
         var rewardCoinsMultiplier:Number = NaN;
         var cost:Number = NaN;
         var rewardXpMultiplier:Number = NaN;
         var xpGained:Number = NaN;
         var mastery:Mastery = null;
         this.m_data = data as TradingOrder;
         if(this.m_data != null)
         {
            this.m_player = Global.friendManager.getAppFriendData(this.m_data.ordererId);
            if(null != this.m_player)
            {
               (getWidget(m_element.chicklet_mc) as ZwFrame).visible = true;
               (getWidget(m_element.generic_tf) as ZwTextField).text = this.m_player.name == null ? "" : this.m_player.name;
               (getWidget(m_element.generic_tf) as ZwTextField).visible = true;
               (getWidget(m_element.icon_mc) as FarmIcon).visible = true;
               (getWidget(m_element.icon_mc) as FarmIcon).loadIcon(FarmGameUtil.getFriendIconByUid(this.m_data.ordererId));
               this.m_askButton.text = ZLocUtils.t("Dialogs","tradingpost_UI_waiting");
               this.m_itemInfoFrame.visible = true;
               this.m_itemInfoFrame.enabled = true;
               this.m_buttonFrame.visible = true;
               this.m_buttonFrame.enabled = true;
               this.m_actionMessage.visible = true;
               farmItem = Global.farmGameSettingsManager.getFarmItemByCode(this.m_data.itemCode);
               if(farmItem != null)
               {
                  this.m_itemImage.visible = true;
                  this.m_itemImage.loadIcon(farmItem.icon);
                  this.m_itemImage.setIconSize(55,55);
                  this.m_itemNameText.text = ZLocUtils.tk_pk_asTitle(farmItem.friendlyName);
                  rewardCoinsMultiplier = Number(TradingPostManager.getInstance().getConfigAttr(TradingPostConstants.SETTINGS_TYPE_CROP,"sellerRewardCoinsMultiplier"));
                  cost = rewardCoinsMultiplier * farmItem.cost;
                  this.m_costText.text = "<font color=\'#009922\'>+" + String(cost) + "</font>";
                  rewardXpMultiplier = Number(TradingPostManager.getInstance().getConfigAttr(TradingPostConstants.SETTINGS_TYPE_CROP,"sellerRewardXpMultiplier"));
                  xpGained = farmItem.plantXp * rewardXpMultiplier;
                  this.m_xpGainedText.text = "<font color=\'#009922\'>+" + String(xpGained) + "</font>";
               }
               if(this.m_data.isFilledOrder)
               {
                  this.m_completeButton.visible = true;
                  this.m_askButton.visible = false;
               }
               else
               {
                  this.m_completeButton.visible = false;
                  this.m_askButton.visible = true;
                  this.m_askButton.enabled = false;
                  this.m_actionMessage.text = ZLocUtils.t("Dialogs","tradingpost_UI_waiting_harvest");
                  this.m_askButton.applyGrayOut = true;
               }
               if(farmItem is HarvestableItem)
               {
                  mastery = (farmItem as HarvestableItem).mastery;
                  this.m_masteryFrame.update(mastery.currentLevel + 1,mastery.currentProgress,mastery.totalCropsNeeded);
                  this.m_masteryFrame.visible = true;
               }
            }
            this.populateRewardMode();
         }
      }
      
      override public function release() : void
      {
         super.release();
         this.m_data = null;
         this.m_parentSlotFrame = null;
         this.m_parentWindow = null;
         this.m_player = null;
         this.m_itemInfoFrame = null;
         this.m_buttonFrame = null;
         this.m_actionMessage = null;
         this.m_completeButton = null;
         this.m_askButton = null;
         this.m_innerInfoFrame = null;
         this.m_itemImage = null;
         this.m_itemNameText = null;
         this.m_costText = null;
         this.m_xpGainedText = null;
         this.m_coinImage = null;
         this.m_masteryFrame = null;
         this.m_xpImage = null;
      }
      
      private function onCompleteOrder(event:MouseEvent) : void
      {
         var resultReward:Object = TradingPostManager.getInstance().claimSellerReward(this.m_data);
         var numXP:String = String(resultReward.numXP);
         var numMastery:String = String(resultReward.numMastery);
         var numCoins:String = String(resultReward.numCoins);
         this.m_data.rewardData = resultReward;
         this.populateRewardMode();
      }
      
      private function populateRewardMode() : void
      {
         var rewardData:Object = this.m_data.rewardData;
         if(rewardData != null)
         {
            this.m_actionMessage.text = ZLocUtils.t("Dialogs","tradingpost_UI_completed_order_reward",{
               "numXP":rewardData.numXP,
               "numMastery":rewardData.numMastery,
               "numCoins":rewardData.numCoins
            });
            this.m_completeButton.visible = false;
            this.m_askButton.text = ZLocUtils.t("Dialogs","tradingpost_UI_thank_friend");
            this.m_askButton.callback = this.onThankFriend;
            this.m_askButton.visible = true;
            if(rewardData.hasShared == null || rewardData.hasShared == false)
            {
               this.m_askButton.applyGrayOut = false;
               this.m_askButton.enabled = true;
            }
            else
            {
               this.m_askButton.applyGrayOut = true;
               this.m_askButton.enabled = false;
            }
         }
      }
      
      private function onThankFriend(event:MouseEvent = null) : void
      {
         if(!TradingPostManager.getInstance().hasAutoPublishPermissions() && !Global.player.getSeenSessionFlag(TradingPostConstants.SEEN_TRADING_POST_EXT_PERMISSIONS))
         {
            TradingPostManager.getInstance().showFeatureAutoPublishDialog(this.onThankFriend);
         }
         else
         {
            this.onThankFriendHelper();
         }
      }
      
      private function onThankFriendHelper() : void
      {
         var hasAutoPublish:Boolean = TradingPostManager.getInstance().hasAutoPublishPermissions();
         var buyer:Friend = Global.friendManager.getAppFriendData(this.m_data.ordererId);
         var buyerName:String = "";
         if(buyer != null)
         {
            buyerName = buyer.firstName;
         }
         var bundleData:Object = {
            "buyer":buyerName,
            "user":Global.player.firstName,
            "images":[{
               "href":"{SN_APP_URL}?ref=trading_post_on_built",
               "src":Global.getAssetURL("assets/buildings/building_tradingpost_icon.png")
            }]
         };
         GlobalEngine.socialNetwork.publishFeedStory("tradingpost_ThankFriend",bundleData,[this.m_data.ordererId],false,null,0,false,hasAutoPublish);
         this.m_askButton.enabled = false;
         this.m_askButton.applyGrayOut = true;
         this.m_data.rewardData.hasShared = true;
      }
   }
}

