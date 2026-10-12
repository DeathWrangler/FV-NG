package Widgets.Slots.Collections
{
   import Classes.Collections.Collectible;
   import Classes.Collections.Collection;
   import Classes.util.ZLocUtils;
   import Engine.Managers.TransactionManager;
   import Transactions.TCollectionTradeIn;
   import Widgets.Buttons.Collections.CollectionsAnimatedButton;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.Collections.CollectionsSlotFrame;
   import Widgets.Icons.FarmIcon;
   import Widgets.Tooltips.FarmTextTooltip;
   import flash.display.DisplayObject;
   import flash.events.MouseEvent;
   
   public class CollectionsSlot extends ZwSlotFrame
   {
      
      protected static const NUM_SLOT_ITEMS:int = 6;
      
      protected static const DEFAULT_ICON_HEIGHT:int = 55;
      
      protected static const DEFAULT_ICON_WIDTH:int = 55;
      
      protected var m_collection:Collection = null;
      
      protected var m_parentSlotFrame:CollectionsSlotFrame = null;
      
      public function CollectionsSlot(element:DisplayObject, parentSlotFrame:CollectionsSlotFrame)
      {
         this.m_parentSlotFrame = parentSlotFrame;
         super(element);
         addWidget(new CollectionsAnimatedButton(m_element.tradeIn_bt,this.onTradeInClick));
         addWidget(new ZwTextField(m_element.collectionsTitleGreen_tf));
         addWidget(new ZwTextField(m_element.collectionsTitle_tf));
         addWidget(new ZwWidget(m_element.starsComplete_mc as DisplayObject));
         addWidget(new ZwWidget(m_element.completeBackground_mc as DisplayObject));
         addWidget(new ZwWidget(m_element.incompleteBackground_mc as DisplayObject));
         for(var itemIndex:int = 0; itemIndex < NUM_SLOT_ITEMS; itemIndex++)
         {
            this.createSlotItem(itemIndex + 1);
         }
      }
      
      protected function onTradeInClick(event:MouseEvent) : void
      {
         var collectionCode:String = null;
         var collection:Collection = null;
         var clickedButton:CollectionsAnimatedButton = getWidget(event.currentTarget) as CollectionsAnimatedButton;
         if(clickedButton != null)
         {
            collectionCode = clickedButton.getButtonCode();
            collection = Global.farmGameSettingsManager.getCollectionByCode(collectionCode);
            collection.tradeIn();
            TransactionManager.addTransaction(new TCollectionTradeIn(collectionCode),true);
            this.populate(this.m_collection);
         }
      }
      
      override public function populate(data:Object) : void
      {
         var incompleteBg:ZwWidget = null;
         super.populate(data);
         this.m_collection = data as Collection;
         var tradeInButton:CollectionsAnimatedButton = getWidget(m_element.tradeIn_bt) as CollectionsAnimatedButton;
         tradeInButton.setButtonCode(this.m_collection.code);
         var collectionsTitle:ZwTextField = getWidget(m_element.collectionsTitle_tf) as ZwTextField;
         var collectionsTitleGreen:ZwTextField = getWidget(m_element.collectionsTitleGreen_tf) as ZwTextField;
         var starsComplete:ZwWidget = getWidget(m_element.starsComplete_mc) as ZwWidget;
         var completeBg:ZwWidget = getWidget(m_element.completeBackground_mc) as ZwWidget;
         incompleteBg = getWidget(m_element.incompleteBackground_mc) as ZwWidget;
         if(this.m_collection.isCollectionComplete())
         {
            tradeInButton.visible = true;
            collectionsTitle.visible = false;
            collectionsTitleGreen.text = ZLocUtils.tk_pk_asTitle(this.m_collection.friendlyName);
            collectionsTitleGreen.visible = true;
            starsComplete.visible = true;
            completeBg.visible = true;
            incompleteBg.visible = false;
         }
         else
         {
            tradeInButton.visible = false;
            collectionsTitle.visible = true;
            collectionsTitle.text = ZLocUtils.tk_pk_asTitle(this.m_collection.friendlyName);
            collectionsTitleGreen.visible = false;
            starsComplete.visible = false;
            completeBg.visible = false;
            incompleteBg.visible = true;
         }
         for(var itemIndex:int = 0; itemIndex < NUM_SLOT_ITEMS; itemIndex++)
         {
            this.populateSlotItem(itemIndex);
         }
      }
      
      protected function createSlotItem(collectableIndex:int) : void
      {
         addWidget(new ZwTextField(m_element["itemTitle" + collectableIndex + "_tf"]));
         addWidget(new ZwWidget(m_element["itemBg" + collectableIndex + "_mc"]));
         addWidget(new ZwTextField(m_element["giftAmount" + collectableIndex + "_tf"]));
         addWidget(new ZwWidget(m_element["giftAmountBg" + collectableIndex + "_mc"]));
         addWidget(new ZwTextField(m_element["rare" + collectableIndex + "_tf"]));
         addWidget(new FarmIcon(m_element["icon" + collectableIndex]));
      }
      
      protected function populateSlotItem(collectableIndex:int) : void
      {
         var code:String = null;
         var uiIndex:int = 0;
         var itemTitle:ZwTextField = null;
         var rareField:ZwTextField = null;
         var giftAmountBg:ZwWidget = null;
         var giftAmountField:ZwTextField = null;
         var itemBg:ZwWidget = null;
         var itemIcon:FarmIcon = null;
         var newCollectible:Collectible = this.m_collection.getCollectableByIndex(collectableIndex);
         if(Boolean(newCollectible) && Boolean(newCollectible.item))
         {
            code = newCollectible.code;
            uiIndex = collectableIndex + 1;
            itemTitle = getWidget(m_element["itemTitle" + uiIndex + "_tf"]) as ZwTextField;
            itemTitle.text = ZLocUtils.tk_pk_asTitle(newCollectible.item.friendlyName);
            itemTitle.visible = true;
            rareField = getWidget(m_element["rare" + uiIndex + "_tf"]) as ZwTextField;
            rareField.visible = true;
            rareField.text = ZLocUtils.t_pk(newCollectible.rarityStringFriendlyName);
            giftAmountBg = getWidget(m_element["giftAmountBg" + uiIndex + "_mc"]) as ZwWidget;
            giftAmountBg.visible = true;
            giftAmountField = getWidget(m_element["giftAmount" + uiIndex + "_tf"]) as ZwTextField;
            giftAmountField.visible = true;
            itemBg = getWidget(m_element["itemBg" + uiIndex + "_mc"]) as ZwWidget;
            itemBg.visible = true;
            itemIcon = getWidget(m_element["icon" + uiIndex]) as FarmIcon;
            itemIcon.loadIcon(newCollectible.item.icon);
            itemIcon.visible = true;
            itemIcon.setIconSize(DEFAULT_ICON_WIDTH,DEFAULT_ICON_HEIGHT);
            itemIcon.detachTooltip();
            itemIcon.attachTooltip(new FarmTextTooltip(ZLocUtils.t("Collections",newCollectible.source + "_toolTip")));
            if(null != Global.player.collectionCounters[code] && Global.player.collectionCounters[code] > 0)
            {
               giftAmountField.text = Global.player.collectionCounters[code].toString();
               itemIcon.alpha = 1;
            }
            else
            {
               giftAmountField.text = "0";
               itemIcon.alpha = 0.25;
            }
         }
      }
   }
}

