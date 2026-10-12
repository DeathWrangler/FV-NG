package Widgets.Windows.Collections
{
   import Classes.Collections.Collection;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Engine.Managers.TransactionManager;
   import Managers.FarmGameSettingsManager;
   import Transactions.TBuyAllLightningCollectionItems;
   import Transactions.TBuyLightningCollectionItem;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Windows.FarmWindow;
   import flash.events.Event;
   
   public class BuyCollectionsWindow extends FarmWindow
   {
      
      protected var m_itemCode:String;
      
      protected var m_collectionCode:String;
      
      protected var m_refreshCallback:Function;
      
      protected var m_buyAll:Boolean = false;
      
      public function BuyCollectionsWindow(itemCode:String, collectionCode:String, refreshCallback:Function, buyAll:Boolean = false)
      {
         this.m_itemCode = itemCode;
         this.m_collectionCode = collectionCode;
         this.m_refreshCallback = refreshCallback;
         this.m_buyAll = buyAll;
         super("assets/dialogs/FV_ImpulseBuy.swf");
      }
      
      override protected function postLoadComplete() : void
      {
         var cash:String = null;
         addWidget(new ZwFrame(m_window.popupBox_mc));
         var newItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByCode(this.m_itemCode);
         var newCollection:Collection = Global.farmGameSettingsManager.getCollectionByCode(this.m_collectionCode);
         var dialogTextField:ZwTextField = new ZwTextField(m_window.popupBox_mc.popupBox_tf,"");
         var dialogText:String = "";
         if(this.m_buyAll)
         {
            dialogText = ZLocUtils.t("Dialogs","LightningCollectionsBuyAllBody",{
               "item":ZLocUtils.tk_pk(newCollection.friendlyName),
               "coinQuantity":newCollection.getCashBuyAllAmount()
            });
         }
         else
         {
            if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               cash = newItem.getStringFromDataSource("cash");
            }
            else
            {
               cash = newItem.xml.cash;
            }
            dialogText = ZLocUtils.t("Dialogs","LightningCollectionsBuyItemBody",{
               "item":ZLocUtils.tk_pk(newItem.friendlyName),
               "collectionName":ZLocUtils.tk_pk(newCollection.friendlyName),
               "cashQuantity":cash
            });
         }
         dialogTextField.text = dialogText;
         addWidget(dialogTextField);
         addWidget(new FarmAnimatedTextButton(m_window.popupBox_mc.accept_bt,ZLocUtils.t("Dialogs","LightningCollectionsBuyButton"),this.onClickConfirmBuy));
         addWidget(new FarmAnimatedTextButton(m_window.popupBox_mc.cancel_bt,ZLocUtils.t("Dialogs","Cancel"),this.onCloseWindow));
      }
      
      protected function onClickConfirmBuy(event:Event = null) : void
      {
         if(this.m_buyAll)
         {
            TransactionManager.addTransaction(new TBuyAllLightningCollectionItems(this.m_collectionCode));
         }
         else
         {
            TransactionManager.addTransaction(new TBuyLightningCollectionItem(this.m_itemCode));
         }
         this.onCloseWindow(null);
      }
      
      protected function onCloseWindow(event:Event) : void
      {
         this.m_refreshCallback();
         onClose(null);
      }
   }
}

