package Widgets.Slots.CraftingBasket
{
   import Classes.util.ZLocUtils;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import flash.display.DisplayObject;
   import flash.events.Event;
   
   public class CraftingBasketDifficultySlot extends ZwSlotFrame
   {
      
      public static const CURRENCY_ITEM:String = "currencyItem";
      
      public static const REWARD_COLLECTION_ITEMS:String = "rewardCollectionItems";
      
      private var m_featureParentName:String;
      
      private var m_basketName:String;
      
      private var m_difficultyLevel:int;
      
      private var m_callback:Function;
      
      private var m_totalSpend:ZwTextField;
      
      private var m_continueButton:FarmAnimatedTextButton;
      
      private var m_isRecommended:Boolean;
      
      private var m_isLevelComplete:Boolean;
      
      private var m_staticData:Object;
      
      public function CraftingBasketDifficultySlot(element:DisplayObject, basketName:String, parentBasketName:String, difficultyLevel:int, callback:Function, isRecommended:Boolean, isLevelComplete:Boolean, isGameStarted:Boolean)
      {
         super(element);
         this.m_difficultyLevel = difficultyLevel;
         this.m_basketName = basketName;
         this.m_featureParentName = parentBasketName;
         this.m_callback = callback;
         this.m_isRecommended = isRecommended;
         this.m_isLevelComplete = isLevelComplete;
         this.loadStaticData();
         if(m_element.title_tf)
         {
            addWidget(new ZwTextField(m_element.title_tf,ZLocUtils.t("Dialogs",this.m_featureParentName + "_slot" + difficultyLevel + "_title")));
         }
         if(m_element.copy_tf)
         {
            addWidget(new ZwTextField(m_element.copy_tf,ZLocUtils.t("Dialogs",this.m_featureParentName + "_slot_body",{
               "itemquantity":this.m_staticData.itemQuantity,
               "consumablequantity":this.m_staticData.itemsCurrencyWorth,
               "currency~":this.m_staticData.currency
            })));
         }
         if(Boolean(m_element.recommend_mc) && Boolean(m_element.recommend_mc.recommend_tf))
         {
            addWidget(new ZwWidget(m_element.recommend_mc),this.m_isRecommended);
            addWidget(new ZwTextField(m_element.recommend_mc.recommend_tf,ZLocUtils.t("Dialogs",this.m_featureParentName + "_slot_recommended")));
         }
         if(m_element.counttext_tf)
         {
            addWidget(this.m_totalSpend = new ZwTextField(m_element.counttext_tf,ZLocUtils.t("Dialogs",this.m_featureParentName + "_slot_spend")));
         }
         if(m_element.count_tf)
         {
            addWidget(this.m_totalSpend = new ZwTextField(m_element.count_tf,"x" + this.m_staticData.itemsCurrencyWorth));
         }
         if(m_element.hasOwnProperty("checkmark_mc"))
         {
            m_element.checkmark_mc.visible = this.m_isLevelComplete;
         }
         addWidget(this.m_continueButton = new FarmAnimatedTextButton(m_element.redeem_bt,"Lets go!",this.onContinue));
         if(isGameStarted)
         {
            this.m_continueButton.text = "Switch!";
         }
      }
      
      private function loadStaticData() : void
      {
         var itemXML:XML = null;
         var itemInfo:Object = null;
         this.m_staticData = new Object();
         this.m_staticData.collectionItems = new Array();
         this.m_staticData.itemQuantity = 0;
         this.m_staticData.itemsCurrencyWorth = 0;
         var featureXML:XML = Global.farmGameSettingsManager.getFeatureXML(this.m_basketName);
         if(featureXML != null)
         {
            this.m_staticData.currencyItemName = featureXML.currencyItem.@name.toString();
            for each(itemXML in featureXML.rewardCollection.item)
            {
               itemInfo = {};
               itemInfo.name = String(itemXML.@name);
               itemInfo.exchangeCurrency = String(itemXML.@exchangeCurrencyItem);
               itemInfo.exchangeQty = int(itemXML.@exchangeQty);
               this.m_staticData.currency = itemInfo.exchangeCurrency;
               ++this.m_staticData.itemQuantity;
               this.m_staticData.itemsCurrencyWorth += itemInfo.exchangeQty;
               this.m_staticData.collectionItems.push(itemInfo);
            }
         }
      }
      
      override public function release() : void
      {
         this.m_continueButton = null;
         this.m_totalSpend = null;
         super.release();
      }
      
      public function onContinue(event:Event) : void
      {
         this.m_callback(this.m_difficultyLevel);
      }
   }
}

