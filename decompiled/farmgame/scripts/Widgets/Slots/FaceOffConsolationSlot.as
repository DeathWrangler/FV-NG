package Widgets.Slots
{
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Display.ImpulseBuy;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Managers.FarmGameSettingsManager;
   import Transactions.TGenericTransaction;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Core.Base.ZwBaseWidget;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.ObjectPreviewFrame;
   import Widgets.Icons.FarmIcon;
   import Widgets.Windows.FaceOffWindow;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.text.TextField;
   
   public class FaceOffConsolationSlot extends ZwSlotFrame
   {
      
      public static const DEFAULT_TRANSACTION_SERVICE:String = "FaceOffService";
      
      private var m_item:FarmItem;
      
      private var m_window:FaceOffWindow;
      
      public function FaceOffConsolationSlot(element:MovieClip, itemName:String, window:FaceOffWindow)
      {
         super(element);
         this.m_window = window;
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            this.m_item = Global.farmGameSettingsManager.getFarmItemByName(itemName);
         }
         else
         {
            this.m_item = new FarmItem(Global.farmGameSettingsManager.getItemXMLByName(itemName));
         }
         if(m_element["back_mc"])
         {
            addWidget(new ZwBaseWidget(m_element.back_mc));
         }
         if(Boolean(m_element["image_mc"]) && Boolean(this.m_item))
         {
            addWidget(new ObjectPreviewFrame(m_element.image_mc,this.m_item));
         }
         if(Boolean(m_element["itemTitle_tf"]) && Boolean(this.m_item))
         {
            addWidget(new ZwTextField(m_element.itemTitle_tf,ZLocUtils.tk_pk_asTitle(this.m_item.friendlyName)));
         }
         if(Boolean(m_element["header_tf"]) && Boolean(this.m_item))
         {
            addWidget(new ZwTextField(m_element.header_tf,"Consolation Prize"));
         }
         if(Boolean(m_element["buy_bt"]) && Boolean(this.m_item))
         {
            (m_element.buy_bt["cost_tf"] as TextField).text = this.m_item.cash.toString();
            addWidget(new FarmAnimatedButton(m_element.buy_bt,this.buyButtonClicked));
         }
      }
      
      public function updateItem(item:String) : void
      {
         var newItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(item);
         if(Boolean(m_element) && Boolean(m_element.image_mc) && Boolean(getWidget(m_element.image_mc)))
         {
            removeWidget(m_element.image_mc);
            addWidget(new FarmIcon(m_element.image_mc,newItem.icon));
            this.m_item = newItem;
         }
         var textField:ZwTextField = getWidget(m_element.itemTitle_tf) as ZwTextField;
         if(textField)
         {
            textField.text = ZLocUtils.tk_pk_asTitle(this.m_item.friendlyName);
         }
         if(m_element.buy_bt["cost_tf"])
         {
            (m_element.buy_bt["cost_tf"] as TextField).text = this.m_item.cash.toString();
         }
      }
      
      public function getItemName() : String
      {
         return this.m_item.name;
      }
      
      public function buyButtonTransactionComplete(event:Event) : void
      {
      }
      
      public function buyButtonClicked(event:Event) : void
      {
         if(Global.player.cash >= this.m_item.cash)
         {
            TransactionManager.addTransaction(new TGenericTransaction(DEFAULT_TRANSACTION_SERVICE,"buyFaceOffItem",this.buyButtonTransactionComplete,[this.m_item.name]));
            this.m_item.onBuy(this.m_item.name);
            this.m_window.close();
         }
         else
         {
            UI.displayImpulseBuyPopup(ImpulseBuy.TYPE_MARKET_CASH,"impulseBuyPopup",this.m_item.cash,this.m_item.type);
         }
      }
   }
}

