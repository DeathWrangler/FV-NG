package Widgets.Slots
{
   import Classes.Constants.ZLocConstants;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Managers.ExchangeManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import Widgets.Windows.ExchangeSelectorWindow;
   import Widgets.Windows.FarmWindow;
   import flash.display.DisplayObject;
   import flash.events.MouseEvent;
   
   public class ExchangeSelectorSlot extends ZwSlotFrame
   {
      
      private static var m_manager:ExchangeManager = null;
      
      private var m_featureName:String = "";
      
      private var m_parentWindow:ExchangeSelectorWindow = null;
      
      private var m_windowState:String = null;
      
      private var m_item:FarmItem = null;
      
      private var m_quantity:int = 0;
      
      private var m_toAdd:int = 0;
      
      public function ExchangeSelectorSlot(element:DisplayObject, parentWindow:FarmWindow)
      {
         super(element);
         this.m_parentWindow = parentWindow as ExchangeSelectorWindow;
         this.m_featureName = this.m_parentWindow.getFeatureName();
         m_manager = ExchangeManager.getInstance();
         if(m_element.hasOwnProperty("itemName_tf"))
         {
            addWidget(new ZwTextField(m_element.itemName_tf));
         }
         if(m_element.hasOwnProperty("amount_tf"))
         {
            addWidget(new ZwTextField(m_element.amount_tf));
         }
         if(m_element.hasOwnProperty("icon_mc"))
         {
            addWidget(new FarmIcon(m_element.icon_mc));
         }
         if(m_element.hasOwnProperty("checked_mc"))
         {
            addWidget(new ZwWidget(m_element.checked_mc));
         }
         if(m_element.hasOwnProperty("accept_bt"))
         {
            addWidget(new FarmAnimatedTextButton(m_element.accept_bt,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"ExchangeSelect"),this.acceptSelectCallback));
         }
      }
      
      override public function populate(data:Object) : void
      {
         var itemWidget:ZwTextField = null;
         var iconWidget:FarmIcon = null;
         var isSelected:Boolean = false;
         var acceptButtonWidget:FarmAnimatedTextButton = null;
         super.populate(data);
         this.m_windowState = this.m_parentWindow.getState();
         this.m_quantity = 0;
         this.m_item = data as FarmItem;
         if(this.m_windowState == ExchangeManager.ADD_STATE)
         {
            this.m_quantity = m_manager.getQuantityOwned(this.m_featureName,this.m_item.code);
         }
         if(m_element.hasOwnProperty("itemName_tf"))
         {
            itemWidget = getWidget(m_element.itemName_tf) as ZwTextField;
            itemWidget.text = this.m_item.friendlyTitle;
            itemWidget.visible = true;
         }
         if(m_element.hasOwnProperty("icon_mc"))
         {
            iconWidget = getWidget(m_element.icon_mc) as FarmIcon;
            iconWidget.loadIcon(this.m_item.iconUrl);
            iconWidget.visible = true;
         }
         if(this.m_windowState == ExchangeManager.SELECT_STATE)
         {
            isSelected = m_manager.isThisItemSelected(this.m_featureName,this.m_item.name);
            if(m_element.hasOwnProperty("amount_tf"))
            {
               getWidget(m_element.amount_tf).visible = false;
            }
            if(m_element.hasOwnProperty("checked_mc"))
            {
               getWidget(m_element.checked_mc).visible = isSelected;
            }
            if(m_element.hasOwnProperty("accept_bt"))
            {
               acceptButtonWidget = getWidget(m_element.accept_bt) as FarmAnimatedTextButton;
               acceptButtonWidget.text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"ExchangeSelect");
               acceptButtonWidget.visible = true;
            }
         }
         else if(this.m_windowState == ExchangeManager.ADD_STATE)
         {
            if(m_element.hasOwnProperty("checked_mc"))
            {
               getWidget(m_element.checked_mc).visible = false;
            }
            this.setupQuantities();
         }
      }
      
      private function setupQuantities() : void
      {
         var amountWidget:ZwTextField = null;
         var acceptWidget:FarmAnimatedTextButton = null;
         var clickable:Boolean = false;
         if(m_element.hasOwnProperty("amount_tf"))
         {
            amountWidget = getWidget(m_element.amount_tf) as ZwTextField;
            amountWidget.text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"ExchangeAmountSlot",{"quantity":this.m_quantity});
            amountWidget.visible = true;
         }
         if(m_element.hasOwnProperty("accept_bt"))
         {
            this.m_toAdd = Math.min(this.m_quantity,m_manager.getTradeInNumberNeeded(this.m_featureName),Global.flashHotParams["DEFAULT_BUSHEL_ADD_TEMPRT"]);
            acceptWidget = getWidget(m_element.accept_bt) as FarmAnimatedTextButton;
            acceptWidget.text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"ExchangeAdd",{"quantity":this.m_toAdd});
            acceptWidget.visible = true;
            clickable = this.m_toAdd != 0;
            acceptWidget.toggleClickableButton(clickable);
         }
      }
      
      public function acceptSelectCallback(event:MouseEvent) : void
      {
         if(this.m_windowState == ExchangeManager.SELECT_STATE)
         {
            m_manager.selectOutputItem(this.m_featureName,this.m_item.name);
         }
         else if(this.m_windowState == ExchangeManager.ADD_STATE)
         {
            m_manager.addInputItem(this.m_featureName,this.m_item.name,this.m_toAdd);
         }
         this.m_parentWindow.refreshWindow();
      }
   }
}

