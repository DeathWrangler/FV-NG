package Classes
{
   import Classes.Quest.PrerequisiteUtility;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Managers.FarmGameSettingsManager;
   import Managers.FarmStatsManager;
   import Managers.FeatureOptionsManager;
   import Managers.RewardCardsManager;
   import Managers.ToasterManager;
   import Transactions.TRedeemRewardCardsItem;
   import Transactions.TRefreshGifts;
   import Widgets.Windows.IconTitleToasterWindow;
   import Widgets.Windows.Market.MarketWindow;
   import Widgets.Windows.RewardCards.RewardCardsCongratulationsWindow;
   import Widgets.Windows.RewardCards.RewardCardsToasterWindow;
   import flash.events.Event;
   
   public class RewardCard
   {
      
      public static const REWARD_METHOD_RANDOM:String = "random";
      
      public static const REWARD_METHOD_USER:String = "user";
      
      public static const REWARD_METHOD_USER_NOW:String = "user-now";
      
      private var m_prereqs:Array;
      
      private var m_name:String;
      
      private var m_freeCredits:int = 0;
      
      private var m_credits:int = 0;
      
      private var m_rewardMethodType:String;
      
      private var m_rewardMaxPrice:int;
      
      private var m_purchasePrereqs:Array;
      
      private var m_purchaseMinPrice:int;
      
      private var m_rewardPrereqs:Array;
      
      private var m_rewardNames:Array = null;
      
      private var m_purchaseItemNames:Array = null;
      
      public function RewardCard(xml:XML)
      {
         var freeCredits:XMLList = null;
         var freeCredit:XML = null;
         var reward:XMLList = null;
         var method:XML = null;
         super();
         if(xml.prereqs)
         {
            this.m_prereqs = PrerequisiteUtility.parseXmlNodePrereqs(xml.prereqs.children());
         }
         if(xml.attribute("name"))
         {
            this.m_name = xml.attribute("name").toString();
         }
         if(xml.credits)
         {
            this.m_credits = xml.credits;
         }
         if(xml.freeCredits)
         {
            freeCredits = xml.freeCredits as XMLList;
            for each(freeCredit in freeCredits.freeCredit)
            {
               if(Global.farmGameSettingsManager.checkPrereqNode(freeCredit) == true)
               {
                  this.m_freeCredits = freeCredit.count;
                  break;
               }
            }
         }
         if(Boolean(xml.reward) && Boolean(xml.reward.chooseMethods))
         {
            reward = xml.reward as XMLList;
            if(reward.prereqs)
            {
               this.m_rewardPrereqs = PrerequisiteUtility.parseXmlNodePrereqs(reward.prereqs.children());
            }
            if(reward.maxPrice)
            {
               this.m_rewardMaxPrice = reward.maxPrice;
            }
            for each(method in reward.chooseMethods.method)
            {
               if(Global.farmGameSettingsManager.checkPrereqNode(method) == true)
               {
                  this.m_rewardMethodType = method.attribute("type");
                  break;
               }
            }
         }
         if(xml.purchase != null)
         {
            if(xml.purchase.prereqs != null)
            {
               this.m_purchasePrereqs = PrerequisiteUtility.parseXmlNodePrereqs(xml.purchase.prereqs.children());
            }
            if(xml.purchase.minPrice != null)
            {
               this.m_purchaseMinPrice = xml.purchase.minPrice;
            }
         }
      }
      
      public static function isInRedeemBlacklist(item:FarmItem) : Boolean
      {
         var redeemBlackList:Array = null;
         var itemName:String = null;
         var result:Boolean = false;
         var redeemBlackListStr:String = Global.flashHotParams["REWARDCARDS_REDEEM_BLACKLIST"];
         if(redeemBlackListStr)
         {
            redeemBlackList = redeemBlackListStr.split(",");
            for each(itemName in redeemBlackList)
            {
               if(item.name == itemName)
               {
                  result = true;
                  break;
               }
            }
         }
         return result;
      }
      
      public function get credits() : int
      {
         return this.m_credits;
      }
      
      public function get freeCredits() : int
      {
         return this.m_freeCredits;
      }
      
      public function isValidReward(farmItem:FarmItem) : Boolean
      {
         var result:Boolean = false;
         if(farmItem != null && PrerequisiteUtility.arePrerequisitesMet(this.m_rewardPrereqs,farmItem))
         {
            result = true;
         }
         if(result == true)
         {
            result = farmItem.realCashCost <= this.rewardMaxPrice;
         }
         if(result == true)
         {
            result = !isInRedeemBlacklist(farmItem);
         }
         return result;
      }
      
      public function get purchaseCount() : int
      {
         var index:int = 0;
         var purchases:Array = new Array();
         var value:Object = FeatureOptionsManager.getInstance().getFeatureOption(FeatureOptionsManager.REWARD_CARDS,this.name);
         var purchaseCreditCount:int = 0;
         if(value != null)
         {
            purchases = value as Array;
            for(index = 0; index < purchases.length; index++)
            {
               if("currentCreditWeight" in purchases[index])
               {
                  purchaseCreditCount += purchases[index]["currentCreditWeight"] as int;
               }
               else
               {
                  purchaseCreditCount += 1;
               }
            }
         }
         return purchaseCreditCount;
      }
      
      public function get purchaseMinPrice() : int
      {
         var purhcaseMinPriceRuntimeName:String = "REWARDCARDS_PURCHASE_MIN_PRICE_" + this.name;
         return Global.flashHotParams[purhcaseMinPriceRuntimeName] != null ? int(Global.flashHotParams[purhcaseMinPriceRuntimeName]) : this.m_purchaseMinPrice;
      }
      
      public function get rewardMaxPrice() : int
      {
         var rewardMaxPriceRuntimeName:String = "REWARDCARDS_REWARD_MAX_PRICE_" + this.name;
         return Global.flashHotParams[rewardMaxPriceRuntimeName] != null ? int(Global.flashHotParams[rewardMaxPriceRuntimeName]) : this.m_rewardMaxPrice;
      }
      
      public function resetPurchaseCount() : void
      {
         var sliceIndex:int = 0;
         var index:int = 0;
         var useCount:int = 0;
         var currentCreditWeight:int = 0;
         var purchases:Array = new Array();
         var value:Object = FeatureOptionsManager.getInstance().getFeatureOption(FeatureOptionsManager.REWARD_CARDS,this.name);
         if(value != null)
         {
            purchases = value as Array;
            if(this.purchaseCount == this.m_credits - this.m_freeCredits)
            {
               FeatureOptionsManager.getInstance().setFeatureOption(FeatureOptionsManager.REWARD_CARDS,this.name,new Array());
            }
            else if(this.purchaseCount > this.m_credits - this.m_freeCredits)
            {
               sliceIndex = -1;
               index = 0;
               useCount = this.m_credits - this.m_freeCredits;
               while(index < purchases.length && useCount > 0)
               {
                  currentCreditWeight = "currentCreditWeight" in purchases[index] ? purchases[index]["currentCreditWeight"] as int : 1;
                  if(useCount < currentCreditWeight)
                  {
                     purchases[index]["currentCreditWeight"] = currentCreditWeight - useCount;
                     break;
                  }
                  sliceIndex = index;
                  useCount -= currentCreditWeight;
                  index++;
               }
               if(sliceIndex >= 0)
               {
                  purchases = purchases.slice(sliceIndex + 1);
               }
               FeatureOptionsManager.getInstance().setFeatureOption(FeatureOptionsManager.REWARD_CARDS,this.name,purchases);
            }
         }
      }
      
      private function initializeRewardNames() : void
      {
         var items:Array = null;
         var farmItem:FarmItem = null;
         if(this.m_rewardNames == null)
         {
            this.m_rewardNames = new Array();
            items = Global.farmGameSettingsManager.getFarmItemsArray(FarmGameSettingsManager.TYPE_LIMITED);
            for each(farmItem in items)
            {
               if(this.isValidReward(farmItem))
               {
                  this.m_rewardNames.push(farmItem.name);
               }
            }
         }
      }
      
      private function initializePurchaseNames() : void
      {
         var items:Array = null;
         var farmItem:FarmItem = null;
         if(this.m_purchaseItemNames == null)
         {
            this.m_purchaseItemNames = new Array();
            items = Global.farmGameSettingsManager.getFarmItemsArray(FarmGameSettingsManager.TYPE_LIMITED);
            for each(farmItem in items)
            {
               if(PrerequisiteUtility.arePrerequisitesMet(this.m_purchasePrereqs,farmItem))
               {
                  this.m_purchaseItemNames.push(farmItem.name);
               }
            }
         }
      }
      
      public function get name() : String
      {
         return this.m_name;
      }
      
      public function passesPrereqs() : Boolean
      {
         return PrerequisiteUtility.arePrerequisitesMet(this.m_prereqs);
      }
      
      public function onPurchaseUpdate(newValue:Object) : void
      {
         var purchases:Array = null;
         var congratsDialog:RewardCardsCongratulationsWindow = null;
         var rewardCardsToaster:RewardCardsToasterWindow = null;
         if(newValue != null)
         {
            if(this.purchaseCount + this.m_freeCredits >= this.m_credits)
            {
               if(this.m_rewardMethodType == REWARD_METHOD_USER || this.m_rewardMethodType == REWARD_METHOD_USER_NOW)
               {
                  congratsDialog = new RewardCardsCongratulationsWindow(this.m_name,this.onCongratulationsAccept);
                  UI.displayPopup(congratsDialog,false,"RewardCardsCongratulationsWindow",true);
               }
               else if(this.m_rewardMethodType == REWARD_METHOD_RANDOM)
               {
                  this.redeemItem();
               }
            }
            else if(newValue.length > 0 && RewardCardsManager.getInstance().getShowToaster())
            {
               RewardCardsManager.getInstance().setShowToaster(false);
               rewardCardsToaster = new RewardCardsToasterWindow(this.m_name);
               rewardCardsToaster.isPauseable = false;
               ToasterManager.getInstance().add(rewardCardsToaster);
            }
         }
      }
      
      private function onCongratulationsAccept(event:Event = null) : void
      {
         if(this.m_rewardMethodType == REWARD_METHOD_USER)
         {
            this.openMarketForRedeem();
         }
         else if(this.m_rewardMethodType == REWARD_METHOD_USER_NOW)
         {
            this.openMarketForRedeem(true);
         }
         else if(this.m_rewardMethodType == REWARD_METHOD_RANDOM)
         {
            this.openMarketForPurchase();
         }
      }
      
      public function openMarketForRedeem(hideCloseButton:Boolean = false) : void
      {
         if(this.m_rewardNames == null)
         {
            this.initializeRewardNames();
         }
         UI.closeMarketDialog();
         UI.displayMiniMarketDialog(this.m_rewardNames,UI.MARKET_CONTEXT_UNKNOWN,"seed",null,true,false,hideCloseButton);
      }
      
      public function openMarketForPurchase() : void
      {
         var type:String = this.m_name;
         var subtype:String = "all";
         switch(type)
         {
            case "tree":
               type = "seed";
               subtype = "tree";
         }
         UI.closeMarketDialog();
         UI.displayMarketDialog("rewrd_cards",type,null,subtype,null,null,null,null,-1,null,MarketWindow.REWARDS_CARDS_ITEM);
      }
      
      public function isRedeemable(farmItem:FarmItem = null) : Boolean
      {
         var result:Boolean = false;
         if(this.purchaseCount + this.m_freeCredits >= this.m_credits)
         {
            if(this.m_rewardMethodType == REWARD_METHOD_USER || this.m_rewardMethodType == REWARD_METHOD_USER_NOW)
            {
               if(farmItem != null)
               {
                  if(this.isValidReward(farmItem))
                  {
                     result = true;
                  }
               }
            }
            else if(this.m_rewardMethodType == REWARD_METHOD_RANDOM)
            {
               if(farmItem == null)
               {
                  result = true;
               }
            }
         }
         return result;
      }
      
      public function redeemItem(farmItem:FarmItem = null) : void
      {
         var itemCode:String = null;
         if((this.m_rewardMethodType == REWARD_METHOD_USER || this.m_rewardMethodType == REWARD_METHOD_USER_NOW) && farmItem != null)
         {
            itemCode = farmItem.code;
            FarmStatsManager.count(RewardCardsManager.REWARD_CARDS_COUNTER,"redemption","market",farmItem.name,farmItem.cash.toString());
         }
         TransactionManager.addTransaction(new TRedeemRewardCardsItem(this.onRedeemComplete,itemCode));
         this.resetPurchaseCount();
      }
      
      private function onRedeemComplete(result:Object) : void
      {
         var farmItem:FarmItem = null;
         var titleText:String = null;
         var messageText:String = null;
         var genericItemToaster:IconTitleToasterWindow = null;
         var itemName:String = null;
         var congratsDialog:RewardCardsCongratulationsWindow = null;
         var itemCode:String = result.redeemedItem;
         if(itemCode != null)
         {
            if(this.m_rewardMethodType == REWARD_METHOD_USER || this.m_rewardMethodType == REWARD_METHOD_USER_NOW)
            {
               farmItem = Global.farmGameSettingsManager.getFarmItemByCode(itemCode);
               if(farmItem != null)
               {
                  FarmStatsManager.count(RewardCardsManager.REWARD_CARDS_COUNTER,"thank_you_toaster","look_now",this.m_name);
                  titleText = ZLocUtils.t("Dialogs","RewardCardsToasterTitle");
                  messageText = ZLocUtils.t("Dialogs","RewardCardsToasterBody",{"itemName":ZLocUtils.tk_pk_asTitle(farmItem.friendlyName)});
                  genericItemToaster = new IconTitleToasterWindow(titleText,messageText,farmItem.icon,"assets/dialogs/FV_Craft_BannerAd.swf",1,null,function(event:Event = null):void
                  {
                     FarmStatsManager.count(RewardCardsManager.REWARD_CARDS_COUNTER,"thank_you_toaster","look_now",m_name);
                     openMarketForPurchase();
                  },50);
                  ToasterManager.getInstance().add(genericItemToaster);
               }
            }
            else if(this.m_rewardMethodType == REWARD_METHOD_RANDOM)
            {
               itemName = Global.farmGameSettingsManager.getFarmItemNameByCode(itemCode);
               congratsDialog = new RewardCardsCongratulationsWindow(this.m_name,this.onCongratulationsAccept,itemName);
               UI.displayPopup(congratsDialog,false,"RewardCardsCongratulationsWindow",true);
            }
            TransactionManager.addTransaction(new TRefreshGifts(),false);
         }
      }
   }
}

