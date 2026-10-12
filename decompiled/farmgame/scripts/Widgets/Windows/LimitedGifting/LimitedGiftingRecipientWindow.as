package Widgets.Windows.LimitedGifting
{
   import Classes.Friend;
   import Classes.ImageLoader;
   import Classes.ZItem.FarmItem;
   import Classes.util.PaymentUtil;
   import Classes.util.ZLocUtils;
   import Engine.Managers.TransactionManager;
   import Managers.FarmStatsManager;
   import Managers.FeatureConfigManager;
   import Managers.TemplateUIUtility;
   import Managers.ToasterManager;
   import Transactions.TGetFriendsDataForUids;
   import Transactions.TLimitedGiftingSend;
   import Transactions.TRefreshBalance;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.LimitedGifting.LimitedGiftingRecipientItemSlotFrame;
   import Widgets.Icons.FarmIcon;
   import Widgets.Windows.FarmWindow;
   import flash.display.DisplayObject;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.net.URLRequest;
   import flash.net.navigateToURL;
   
   public class LimitedGiftingRecipientWindow extends FarmWindow
   {
      
      private static const GIFT_ICON_SIZE:int = 100;
      
      private static const PROFILE_PICTURE_SIZE:int = 52;
      
      private static const TOP_FRIENDS_NUMBER:int = 4;
      
      private var m_extraData:Object;
      
      private var m_featureName:String;
      
      private var m_senders:Array;
      
      private var m_sendersFriendObject:Array;
      
      private var m_senderConfig:FeatureConfigManager;
      
      private var m_featureConfig:FeatureConfigManager;
      
      private var m_buyButton:FarmAnimatedTextButton;
      
      private var m_costText:ZwTextField;
      
      private var m_genericText:ZwTextField;
      
      private var m_giftingSlotFrame:LimitedGiftingRecipientItemSlotFrame;
      
      private var m_giftItems:Array;
      
      private var m_isGiftingWithChoice:Boolean;
      
      protected var m_loadingSpinner:ZwWidget = null;
      
      private var m_bgLoader:ImageLoader = null;
      
      private var m_bgIcon:DisplayObject = null;
      
      private var m_npcUrl:String;
      
      private var m_npcLoader:ImageLoader = null;
      
      private var m_npcIcon:DisplayObject = null;
      
      public function LimitedGiftingRecipientWindow(extraData:Object)
      {
         var itemCode:String = null;
         var windowAssetRelUrl:String = null;
         this.m_giftItems = new Array();
         this.m_extraData = extraData;
         this.m_featureName = extraData.featureName + "Recipient";
         if(extraData.itemCodes != null && extraData.itemCodes.length > 0)
         {
            this.m_isGiftingWithChoice = true;
         }
         else
         {
            this.m_isGiftingWithChoice = false;
         }
         for each(itemCode in extraData.itemCodes)
         {
            this.m_giftItems.push([Global.farmGameSettingsManager.getFarmItemByCode(itemCode),extraData.itemCodeAmounts[itemCode]]);
         }
         this.m_senders = extraData.senders;
         this.m_senderConfig = FeatureConfigManager.getFeatureConfiguration(extraData.featureName);
         this.m_featureConfig = FeatureConfigManager.getFeatureConfiguration(this.m_featureName);
         this.m_npcUrl = this.m_featureConfig.getStringConstant("npcUrl");
         if(this.m_isGiftingWithChoice)
         {
            windowAssetRelUrl = this.m_featureConfig.getStringConstant("recipientUIUrlChoice");
         }
         else
         {
            windowAssetRelUrl = this.m_featureConfig.getStringConstant("recipientUIUrl");
         }
         super(windowAssetRelUrl);
         var bgPath:String = this.m_featureConfig.getStringConstant("mainWindowBackgroundImage");
         if(bgPath != null)
         {
            this.m_bgLoader = ImageLoader.getInstance(Global.getAssetURL(bgPath));
            this.m_bgLoader.getContent(this.onBgLoad);
         }
         if(this.m_npcUrl != null)
         {
            this.m_npcLoader = ImageLoader.getInstance(Global.getAssetURL(this.m_npcUrl));
            this.m_npcLoader.getContent(this.onNpcLoad);
         }
      }
      
      private function onBgLoad(dispObj:DisplayObject, info:Object = null) : void
      {
         this.m_bgIcon = dispObj;
      }
      
      private function onNpcLoad(dispObj:DisplayObject, info:Object = null) : void
      {
         this.m_npcIcon = dispObj;
      }
      
      override protected function onLoadComplete(event:Event) : void
      {
         super.onLoadComplete(event);
         TransactionManager.addTransaction(new TGetFriendsDataForUids(this.m_senders,this.setSendersFriendObjectArray),true);
         addWidget(new ZwTextField(m_window.title_tf,ZLocUtils.t("Dialogs",this.m_featureName + "_title")));
         if(TemplateUIUtility.isTemplateUIEnabled(TemplateUIUtility.EXPANSION,this.m_featureConfig.getStringConstant("location")))
         {
            TemplateUIUtility.applyExpansionTextColor(m_window.title_tf);
            TemplateUIUtility.applyExpansionBevelFilter(m_window.title_tf);
            TemplateUIUtility.applyExpansionDropShadowFilter(m_window.title_tf);
         }
         addWidget(this.m_genericText = new ZwTextField(m_window.generic_tf,"Please wait while we load the senders data"));
         if(m_window.mc_loader)
         {
            this.m_loadingSpinner = addWidget(new ZwWidget(m_window.mc_loader)) as ZwWidget;
         }
         if(m_window.to_text)
         {
            m_window.to_text.visible = false;
         }
         if(m_window.from_text)
         {
            m_window.from_text.visible = false;
         }
         if(Boolean(m_window.mc_NPC) && Boolean(this.m_npcIcon))
         {
            m_window.mc_NPC.addChild(this.m_npcIcon);
            m_window.mc_NPC.visible = true;
         }
      }
      
      private function populateDataOnLoad() : void
      {
         var acceptText:String = null;
         var farmIcon:FarmIcon = null;
         var friend:Friend = null;
         var profilePic:FarmIcon = null;
         var extraFriendsCount:int = 0;
         if(this.m_loadingSpinner)
         {
            this.m_loadingSpinner.visible = false;
         }
         if(m_window.to_text)
         {
            if(TemplateUIUtility.isTemplateUIEnabled(TemplateUIUtility.EXPANSION,this.m_featureConfig.getStringConstant("location")))
            {
               TemplateUIUtility.applyExpansionGlowFilter(m_window.to_text);
            }
            m_window.to_text.visible = true;
         }
         if(m_window.from_text)
         {
            if(TemplateUIUtility.isTemplateUIEnabled(TemplateUIUtility.EXPANSION,this.m_featureConfig.getStringConstant("location")))
            {
               TemplateUIUtility.applyExpansionGlowFilter(m_window.from_text);
            }
            m_window.from_text.visible = true;
         }
         FarmStatsManager.count("dialog",this.m_extraData.featureName,"view","recipient",this.m_senders.length.toString());
         var giftItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(this.m_featureConfig.getStringConstant("giftableItem"));
         if(TemplateUIUtility.isTemplateUIEnabled(TemplateUIUtility.EXPANSION,this.m_featureConfig.getStringConstant("location")))
         {
            TemplateUIUtility.applyExpansionGlowFilter(m_window.name_tf);
         }
         addWidget(new ZwTextField(m_window.name_tf,Global.player.name));
         this.m_genericText.text = ZLocUtils.t("Dialogs",this.m_featureName + "_description");
         if(Boolean(m_window.body1_tf) && this.m_featureName != "BirthdayPaidGifting")
         {
            addWidget(new ZwTextField(m_window.body1_tf,ZLocUtils.t("Dialogs",this.m_featureName + "_body1")));
         }
         if(Boolean(m_window.info_bt) && this.m_featureName != "BirthdayPaidGifting")
         {
            addWidget(new FarmAnimatedTextButton(m_window.info_bt,ZLocUtils.t("Dialogs",this.m_featureName + "_ClickHereText"),this.onMoreInfoClick));
         }
         var giftingCurrency:String = this.m_senderConfig.getStringConstant("giftingCurrency");
         if(giftingCurrency == null)
         {
            giftingCurrency = LimitedGiftingWindow.GIFTING_FC;
         }
         if(Boolean(this.m_senderConfig.isFeatureVisible()) && Boolean(m_window.buy_bt) && giftingCurrency == LimitedGiftingWindow.GIFTING_FC)
         {
            addWidget(this.m_buyButton = new FarmAnimatedTextButton(m_window.buy_bt,"",null));
            addWidget(this.m_costText = new ZwTextField(m_window.buy_bt.cost_tf));
            this.updateButtonText();
         }
         else if(m_window.okay_bt)
         {
            acceptText = ZLocUtils.t("Dialogs",this.m_featureName + "_accept") != "" ? ZLocUtils.t("Dialogs",this.m_featureName + "_accept") : ZLocUtils.t("Dialogs","Okay");
            addWidget(new FarmAnimatedTextButton(m_window.okay_bt,acceptText,onClose));
         }
         if(this.m_isGiftingWithChoice)
         {
            if(m_window.hasOwnProperty("slots_mc"))
            {
               this.m_giftingSlotFrame = new LimitedGiftingRecipientItemSlotFrame(m_window.slots_mc,false,null);
               this.m_giftingSlotFrame.items = this.m_giftItems;
               addWidget(this.m_giftingSlotFrame);
               this.m_giftingSlotFrame.centerSlots();
            }
         }
         else if(m_window.hasOwnProperty("icon_mc"))
         {
            farmIcon = new FarmIcon(m_window.icon_mc,"");
            farmIcon.loadIcon(giftItem.icon);
            farmIcon.setIconSize(GIFT_ICON_SIZE,GIFT_ICON_SIZE);
            farmIcon.visible = true;
            addWidget(farmIcon);
         }
         var topFriends:String = "";
         var i:int = 0;
         while(i <= TOP_FRIENDS_NUMBER && i < this.m_sendersFriendObject.length)
         {
            friend = this.m_sendersFriendObject[i];
            if(friend != null)
            {
               topFriends += friend.name.substring(0,friend.firstName.length + 2) + ".";
               if(m_window.hasOwnProperty("fbIcon" + i.toString() + "_mc"))
               {
                  profilePic = new FarmIcon(m_window["fbIcon" + i.toString() + "_mc"]);
                  profilePic.loadIcon(friend.picture);
                  profilePic.setIconSize(PROFILE_PICTURE_SIZE,PROFILE_PICTURE_SIZE);
                  addWidget(profilePic);
               }
               if(i + 1 < this.m_senders.length && i + 1 <= TOP_FRIENDS_NUMBER)
               {
                  topFriends += ", ";
               }
            }
            i++;
         }
         addWidget(new ZwTextField(m_window.name2_tf,topFriends));
         if(this.m_senders.length > TOP_FRIENDS_NUMBER + 1)
         {
            extraFriendsCount = this.m_senders.length - TOP_FRIENDS_NUMBER - 1;
            if(extraFriendsCount == 1)
            {
               addWidget(new ZwTextField(m_window.generic2_tf,ZLocUtils.t("Dialogs","limitedGifting_recipientExtraFriend")));
            }
            else
            {
               addWidget(new ZwTextField(m_window.generic2_tf,ZLocUtils.t("Dialogs","limitedGifting_recipientExtraFriends",{"extraFriends":extraFriendsCount})));
            }
         }
         if(m_window.hasOwnProperty("title_fc_mc"))
         {
            addWidget(new FarmIcon(m_window.title_fc_mc));
         }
         if(m_window.hasOwnProperty("mc_AnimalFrame") && Boolean(this.m_bgIcon))
         {
            m_window.addChildAt(this.m_bgIcon,m_window.getChildIndex(m_window.mc_AnimalFrame));
         }
      }
      
      protected function onMoreInfoClick(event:MouseEvent) : void
      {
         var url:String = ZLocUtils.t("Dialogs",this.m_featureName + "_ClickHereUrl");
         navigateToURL(new URLRequest(url),"_blank");
      }
      
      private function updateButtonText() : void
      {
         var requiredCash:int = 0;
         var gift:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(this.m_senderConfig.getStringConstant("giftableItem"));
         if(this.m_senders.length > 0)
         {
            requiredCash = gift.cash * this.m_senders.length;
            this.m_costText.text = requiredCash.toString();
            this.m_buyButton.enabled = true;
            this.m_buyButton.visible = true;
            if(Global.player.cash >= requiredCash)
            {
               this.m_buyButton.callback = this.onSendGift;
               this.m_buyButton.text = ZLocUtils.t("Dialogs","limitedGiftingSendBack");
            }
            else
            {
               this.m_buyButton.callback = this.inAppPurchase;
               this.m_buyButton.text = ZLocUtils.t("Dialogs","limitedGiftingNotEnoughCash");
            }
         }
         else
         {
            this.m_costText.text = gift.cash.toString();
            this.m_buyButton.enabled = false;
            this.m_buyButton.text = ZLocUtils.t("Dialogs","limitedGiftingBuyAndSend");
         }
      }
      
      private function onSendGift(event:Event) : void
      {
         var gift:FarmItem = null;
         var recipient:Number = NaN;
         var senders:Array = null;
         var i:int = 0;
         if(this.m_senderConfig.isFeatureVisible())
         {
            gift = Global.farmGameSettingsManager.getFarmItemByName(this.m_senderConfig.getStringConstant("giftableItem"));
            FarmStatsManager.count("fv_buyableGift","send_gift",gift.name,gift.cash.toString());
            FarmStatsManager.count("dialog",this.m_extraData.featureName,"recipient",this.m_senders.length.toString());
            Global.player.cash -= gift.cash * this.m_senders.length;
            for each(recipient in this.m_senders)
            {
               Global.player.setSeenSessionFlag(LimitedGiftingWindow.LIMITED_GIFTING_FLAG + recipient);
            }
            senders = new Array();
            for(i = 0; i < this.m_senders.length; i++)
            {
               senders.push(String(this.m_senders[i]));
            }
            TransactionManager.addTransaction(new TLimitedGiftingSend(this.m_senderConfig.featureName,senders,this.sendSuccessToaster),true);
         }
         close();
      }
      
      private function setSendersFriendObjectArray(result:Object) : void
      {
         var key:String = null;
         var friend:Friend = null;
         this.m_sendersFriendObject = new Array();
         for(key in result)
         {
            friend = new Friend(result[key]);
            friend.picture = result[key].pic_square;
            this.m_sendersFriendObject.push(friend);
         }
         this.populateDataOnLoad();
      }
      
      private function sendSuccessToaster(result:Object) : void
      {
         var rewardName:String = this.m_senderConfig.getStringConstant("appreciationItem");
         var gift:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(this.m_senderConfig.getStringConstant("giftableItem"));
         FarmStatsManager.count("fv_buyableGift","transaction_complete",gift.name,gift.cash.toString());
         Global.player.addGift(rewardName);
         ToasterManager.getInstance().add(new LimitedGiftingSendToasterWindow(rewardName,this.m_senderConfig.featureName));
      }
      
      private function inAppPurchase(event:Event) : void
      {
         var gift:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(this.m_senderConfig.getStringConstant("giftableItem"));
         var numFriends:int = int(this.m_senders.length);
         FarmStatsManager.count("fv_buyableGift","not_enough_cash",gift.name,gift.cash.toString());
         FarmStatsManager.count("dialog",this.m_featureName,"click",numFriends.toString());
         FarmStatsManager.count("dialog",this.m_featureName,"insufficient",numFriends.toString());
         PaymentUtil.instance.addCashToCart(LimitedGiftingWindow.getCashPackage(gift.cash * numFriends),"LimitedGifting_" + this.m_senderConfig.featureName,this.onSuccessGetMoreCash);
      }
      
      protected function onSuccessGetMoreCash(orderId:String, status:String) : void
      {
         TransactionManager.addTransaction(new TRefreshBalance(this.balanceRefreshed),true);
      }
      
      protected function balanceRefreshed(result:Object) : void
      {
         this.updateButtonText();
      }
   }
}

