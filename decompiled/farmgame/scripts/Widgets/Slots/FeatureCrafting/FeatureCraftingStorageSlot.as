package Widgets.Slots.FeatureCrafting
{
   import Classes.Constants.ZLocConstants;
   import Classes.FeatureCrafting.FeatureCraftingGood;
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.UI;
   import Events.GenericPopupEvent;
   import Managers.TemplateUIUtility;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Constants.Market.Currency;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import Widgets.Windows.FeatureCrafting.FeatureCraftingNumberSelectionWindow;
   import Widgets.Windows.FeatureCrafting.FeatureCraftingStorageWindow;
   import flash.display.DisplayObject;
   import flash.events.MouseEvent;
   
   public class FeatureCraftingStorageSlot extends ZwSlotFrame
   {
      
      private static const ICON_SIZE:int = 50;
      
      private var m_data:FeatureCraftingGood;
      
      private var m_icon:FarmIcon;
      
      private var m_nameTextField:ZwTextField;
      
      private var m_countTextField:ZwTextField;
      
      private var m_sellButton:FarmAnimatedTextButton;
      
      private var m_sellQuantity:int;
      
      private var m_location:String = "";
      
      public function FeatureCraftingStorageSlot(element:DisplayObject, location:String = "")
      {
         super(element);
         this.m_location = location;
         this.m_icon = addWidget(new FarmIcon(m_element.icon_mc)) as FarmIcon;
         this.m_icon.setIconSize(ICON_SIZE,ICON_SIZE);
         this.m_nameTextField = addWidget(new ZwTextField(m_element.title_tf," ")) as ZwTextField;
         if(this.m_location != "" && TemplateUIUtility.isTemplateUIEnabled(TemplateUIUtility.EXPANSION,this.m_location))
         {
            TemplateUIUtility.applyExpansionGlowFilter(m_element.title_tf);
         }
         this.m_countTextField = addWidget(new ZwTextField(m_element.itemCount_tf," ")) as ZwTextField;
         this.m_sellButton = addWidget(new FarmAnimatedTextButton(m_element.remove_bt,"Sell",this.onSellButtonClick)) as FarmAnimatedTextButton;
      }
      
      override public function release() : void
      {
         this.m_icon = null;
         this.m_nameTextField = null;
         this.m_countTextField = null;
         this.m_sellButton = null;
         super.release();
      }
      
      override public function populate(data:Object) : void
      {
         super.populate(data);
         this.m_data = data as FeatureCraftingGood;
         if(this.m_data)
         {
            this.refresh();
         }
      }
      
      public function refresh() : void
      {
         if(this.m_data)
         {
            this.m_icon.loadIcon(this.m_data.iconUrl());
            this.m_icon.visible = true;
            this.m_countTextField.text = this.m_data.inventoryCount.toString();
            this.m_countTextField.visible = true;
            this.m_nameTextField.text = this.m_data.friendlyTitle;
            this.m_nameTextField.visible = true;
            this.m_sellButton.visible = true;
         }
      }
      
      private function onSellButtonClick(event:MouseEvent) : void
      {
         var parentWindow:FeatureCraftingStorageWindow = null;
         var textBundle:Object = null;
         var dialogOptions:Object = null;
         if(this.m_sellButton.enabled)
         {
            parentWindow = getAncestorByClassType(FeatureCraftingStorageWindow) as FeatureCraftingStorageWindow;
            parentWindow.enableInput = false;
            if(this.m_data.inventoryCount > 1)
            {
               textBundle = {};
               textBundle[FeatureCraftingNumberSelectionWindow.TEXT_KEY_TITLE] = ZLocUtils.t(ZLocConstants.PKG_FEATURE_CRAFTING,"NumberSelectionWindow_SellTitle");
               textBundle[FeatureCraftingNumberSelectionWindow.TEXT_KEY_ACCEPT_BUTTON] = ZLocUtils.t(ZLocConstants.PKG_FEATURE_CRAFTING,"NumberSelectionWindow_SellAccept");
               dialogOptions = {};
               dialogOptions[FeatureCraftingNumberSelectionWindow.OPTION_KEY_STARTING_QUANTITY] = 1;
               UI.displayPopup(new FeatureCraftingNumberSelectionWindow(this.m_data,this.m_data.inventoryCount,1,this.onAmountSelectionWindowAccept,this.onAmountSelectionWindowCancel,textBundle,dialogOptions),false);
            }
            else
            {
               this.onAmountSelectionWindowAccept(1);
            }
         }
      }
      
      private function onAmountSelectionWindowCancel() : void
      {
         var parentWindow:FeatureCraftingStorageWindow = getAncestorByClassType(FeatureCraftingStorageWindow) as FeatureCraftingStorageWindow;
         parentWindow.enableInput = true;
      }
      
      private function onAmountSelectionWindowAccept(quantity:int) : void
      {
         var yield:String = null;
         var replacements:Object = null;
         var message:String = null;
         var friendlyNameText:String = this.m_data.friendlyTitle;
         if(quantity > 0)
         {
            this.m_sellQuantity = quantity;
            yield = this.m_data.getSellPrice(quantity) + " " + ZLocUtils.t("FarmGame",Currency.COINS);
            replacements = {
               "quantity":quantity,
               "item":this.m_data.friendlyTitle,
               "yieldsString":yield
            };
            message = ZLocUtils.t("FarmGame","SellMultipleObjectSpecific",replacements);
            UI.displayMessageWithHtml(message,GenericPopup.TYPE_YESNO,this.onConfirmSell,"FeatureCraftingStorageSellConfirmation",true);
         }
      }
      
      private function onConfirmSell(event:GenericPopupEvent) : void
      {
         var parentWindow:FeatureCraftingStorageWindow = getAncestorByClassType(FeatureCraftingStorageWindow) as FeatureCraftingStorageWindow;
         parentWindow.enableInput = true;
         if(event.button == GenericPopup.ACCEPT)
         {
            this.m_data.removeFromInventory(this.m_sellQuantity);
            this.m_sellQuantity = 0;
            if(this.m_data.inventoryCount <= 0)
            {
               parentWindow.refresh();
            }
            else
            {
               parentWindow.refreshCount();
               this.refresh();
            }
         }
      }
   }
}

