package Widgets.Slots
{
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Managers.FarmStatsManager;
   import Managers.FeatureOptionsManager;
   import Managers.TemplateUIUtility;
   import Managers.TimedSlotGiveawaysManager;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Windows.FarmWindow;
   import Widgets.Windows.TimedGiveawayWindow;
   import ZLocalization.LocalizationObjectToken;
   import flash.display.DisplayObject;
   import flash.events.Event;
   
   public class TimedGiveawaySlot extends GenericTimedSlot
   {
      
      private var m_canUnlockDay:Boolean = false;
      
      private var m_unlockPrice:Number = 0;
      
      public function TimedGiveawaySlot(element:DisplayObject, parentWindow:FarmWindow)
      {
         var textColor:String = null;
         super(element,parentWindow);
         var creditTitleTf:ZwTextField = null;
         if(m_element.creditTitle_tf != null)
         {
            creditTitleTf = addWidget(new ZwTextField(m_element.creditTitle_tf),false) as ZwTextField;
         }
         var giveawayName:String = (m_parentWindow as TimedGiveawayWindow).getFeatureName();
         if(TimedSlotGiveawaysManager.isTemplateUIEnabled(giveawayName) && Boolean(creditTitleTf))
         {
            textColor = TimedSlotGiveawaysManager.getTextColor(giveawayName);
            if(textColor != null && textColor != "")
            {
               TemplateUIUtility.applyTextColor(creditTitleTf,TemplateUIUtility.FARM_STAND,textColor);
            }
         }
      }
      
      override public function populate(data:Object) : void
      {
         var bitmapColor:String = null;
         this.m_canUnlockDay = false;
         super.populate(data);
         var giveawayName:String = (m_parentWindow as TimedGiveawayWindow).getFeatureName();
         if(TimedSlotGiveawaysManager.isTemplateUIEnabled(giveawayName) && Boolean(m_questionMark))
         {
            bitmapColor = TimedSlotGiveawaysManager.getBitmapColor(giveawayName);
            if(bitmapColor != null && bitmapColor != "")
            {
               TemplateUIUtility.applyBackgroundColor(m_questionMark.element as DisplayObject,TemplateUIUtility.FARM_STAND,bitmapColor);
            }
         }
      }
      
      override protected function getCurrentItem(data:Object) : FarmItem
      {
         var result:FarmItem = null;
         if(Boolean(data) && data.hasOwnProperty("name"))
         {
            result = Global.farmGameSettingsManager.getFarmItemByName(data["name"]);
         }
         if(Boolean(data) && data.hasOwnProperty("unlockable"))
         {
            this.m_canUnlockDay = data["unlockable"];
         }
         if(Boolean(data) && data.hasOwnProperty("unlockPrice"))
         {
            this.m_unlockPrice = data["unlockPrice"];
         }
         return result;
      }
      
      override protected function hasFinishedSlot() : Boolean
      {
         var result:Boolean = false;
         var featureOptionMan:FeatureOptionsManager = FeatureOptionsManager.getInstance();
         var giveawayName:String = (m_parentWindow as TimedGiveawayWindow).getFeatureName();
         var giveawayObject:Object = featureOptionMan.getFeatureOption(FeatureOptionsManager.TIMED_GIVEAWAY,giveawayName);
         var giftKey:String = "GiftName" + m_item.name;
         if(Boolean(giveawayObject) && Boolean(giveawayObject.hasOwnProperty(giftKey)) && Boolean(giveawayObject[giftKey]))
         {
            result = true;
         }
         return result;
      }
      
      override protected function popNotFinishedSlot() : void
      {
         var creditNameWidget:ZwTextField = null;
         var creditLocObject:LocalizationObjectToken = null;
         var creditName:String = null;
         super.popNotFinishedSlot();
         if(m_element.creditTitle_tf != null)
         {
            creditNameWidget = getWidget(m_element.creditTitle_tf) as ZwTextField;
            creditLocObject = ZLocUtils.tk_pk(TimedSlotGiveawaysManager.getItemDataByName((m_parentWindow as TimedGiveawayWindow).getFeatureName(),m_item.name)["creditName"]);
            creditName = "";
            if(creditLocObject != null)
            {
               creditName = creditLocObject.getString();
            }
            creditNameWidget.text = creditName;
            creditNameWidget.visible = true;
         }
      }
      
      override protected function popFinishedSlot() : void
      {
         super.popFinishedSlot();
         if(m_element.ask_bt != null && TimedSlotGiveawaysManager.getCurrentObjectName((m_parentWindow as TimedGiveawayWindow).getFeatureName()) == this.m_item.name)
         {
            getWidget(m_element.ask_bt).visible = true;
         }
      }
      
      override protected function shouldShowUnlockedSlot(data:Object) : Boolean
      {
         return Boolean(data["unlocked"]) && Boolean(super.shouldShowUnlockedSlot(data));
      }
      
      override protected function canUnlockDay() : Boolean
      {
         return this.m_canUnlockDay;
      }
      
      override protected function getUnlockPrice() : Number
      {
         return this.m_unlockPrice;
      }
      
      override protected function canAskForItem() : Boolean
      {
         return TimedSlotGiveawaysManager.canAsk((m_parentWindow as TimedGiveawayWindow).getFeatureName());
      }
      
      override protected function showAskButton() : Boolean
      {
         return !TimedSlotGiveawaysManager.isDisabled((m_parentWindow as TimedGiveawayWindow).getFeatureName());
      }
      
      override protected function getItemsOwned() : int
      {
         return TimedSlotGiveawaysManager.getCreditsForGiveawayItem((m_parentWindow as TimedGiveawayWindow).getFeatureName(),this.m_item.name);
      }
      
      override protected function getItemsNeeded() : int
      {
         return TimedSlotGiveawaysManager.getCreditsNeededForGiveawayItem((m_parentWindow as TimedGiveawayWindow).getFeatureName(),this.m_item.name);
      }
      
      override protected function isProrated() : Boolean
      {
         return !this.hasFinishedSlot() && TimedSlotGiveawaysManager.isProrated((m_parentWindow as TimedGiveawayWindow).getFeatureName());
      }
      
      override protected function getProration() : Number
      {
         return Math.max(TimedSlotGiveawaysManager.getMaxProration((m_parentWindow as TimedGiveawayWindow).getFeatureName()),1 - this.getItemsOwned() / this.getItemsNeeded());
      }
      
      override protected function onBuyItemCallback(event:Event) : void
      {
         var featureName:String = null;
         var cashValue:int = getCostForCurrItem();
         if(m_item != null && Global.player.canBuyCash(cashValue,true,m_item.name))
         {
            featureName = (m_parentWindow as TimedGiveawayWindow).getFeatureName();
            FarmStatsManager.count("TimedGiveaway",featureName,"BuyItem",m_item.name);
            TimedSlotGiveawaysManager.buyItem(featureName,m_item.name,cashValue);
            m_parentWindow.close();
         }
         else
         {
            super.onBuyItemCallback(event);
         }
      }
      
      override protected function onAskCallback(event:Event) : void
      {
         if(m_item != null)
         {
            TimedSlotGiveawaysManager.askForItem((m_parentWindow as TimedGiveawayWindow).getFeatureName(),m_item.name);
            FarmStatsManager.count("TimedGiveaway",(m_parentWindow as TimedGiveawayWindow).getFeatureName(),"AskItem",m_item.name);
         }
         super.onAskCallback(event);
      }
      
      override protected function onUnlockCallback(event:Event) : void
      {
         var parentGivWindow:TimedGiveawayWindow = null;
         var featureName:String = null;
         if(m_item != null)
         {
            parentGivWindow = m_parentWindow as TimedGiveawayWindow;
            featureName = parentGivWindow.getFeatureName();
            TimedSlotGiveawaysManager.unlock(featureName,m_item.name,this.m_unlockPrice);
            FarmStatsManager.count("TimedGiveaway",featureName,"UnlockItem",m_item.name);
            parentGivWindow.refreshWindow();
         }
      }
   }
}

