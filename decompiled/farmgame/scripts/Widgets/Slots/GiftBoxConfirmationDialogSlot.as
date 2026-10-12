package Widgets.Slots
{
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Icons.FarmIcon;
   import Widgets.TextFields.FarmTextField;
   import flash.display.DisplayObject;
   import flash.events.Event;
   import flash.events.FocusEvent;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   
   public class GiftBoxConfirmationDialogSlot extends ZwSlotFrame
   {
      
      private static const MAX_NUM_CHAR:int = 5;
      
      private var m_data:Object;
      
      private var m_count:FarmTextField;
      
      private var m_downArrow:FarmAnimatedButton;
      
      private var m_upArrow:ZwWidget;
      
      private var m_itemName:FarmTextField;
      
      private var m_icon:FarmIcon;
      
      private var m_quantitySelected:int;
      
      private var m_onQuantitySelectionChangeCallBack:Function;
      
      private var m_staticCount:FarmTextField;
      
      public function GiftBoxConfirmationDialogSlot(element:DisplayObject, data:Object, onQuantitySelectionChangeCallBack:Function)
      {
         super(element);
         this.m_data = data;
         this.m_onQuantitySelectionChangeCallBack = onQuantitySelectionChangeCallBack;
         this.loadUI();
         this.quantitySelected = this.m_data.quantity;
      }
      
      private function loadUI() : void
      {
         if(!this.m_data.hasOwnProperty("farmItem"))
         {
            this.m_data.farmItem = Global.farmGameSettingsManager.getFarmItemByName(this.m_data.name);
            if(this.m_data.farmItem == null)
            {
               this.m_data.farmItem = Global.farmGameSettingsManager.getFarmItemByCode(this.m_data.code);
            }
         }
         this.m_itemName = addWidget(new FarmTextField(m_element.title_tf,this.m_data.farmItem.friendlyTitle)) as FarmTextField;
         if(!this.m_data.hasOwnProperty("quantity"))
         {
            this.m_data.quantity = 0;
            if(this.m_data.hasOwnProperty("group"))
            {
               this.m_data.quantity = 1;
            }
         }
         this.m_count = addWidget(new FarmTextField(m_element.itemCount_tf,String(this.m_data.quantity))) as FarmTextField;
         this.m_count.element.addEventListener(FocusEvent.FOCUS_OUT,this.onFocusOut);
         this.m_staticCount = addWidget(new FarmTextField(m_element.itemCountDisp_tf,String(this.m_data.quantity))) as FarmTextField;
         m_element.itemCount_tf.addEventListener(KeyboardEvent.KEY_DOWN,this.reportKeyDown);
         m_element.itemCount_tf.addEventListener(KeyboardEvent.KEY_UP,this.reportKeyUp);
         this.m_icon = addWidget(new FarmIcon(m_element.icon_mc)) as FarmIcon;
         this.m_icon.loadIcon(this.m_data.farmItem.icon);
         this.m_icon.visible = true;
         this.m_icon.setIconSize(24,24);
         this.m_downArrow = addWidget(new FarmAnimatedButton(m_element.downArrow_mc,this.onDownArrowClicked)) as FarmAnimatedButton;
         this.m_upArrow = addWidget(new FarmAnimatedButton(m_element.upArrow_mc,this.onUpArrowClicked)) as FarmAnimatedButton;
      }
      
      private function onFocusOut(ev:Event) : void
      {
         if(this.m_count.text == "")
         {
            this.m_count.text = "0";
         }
      }
      
      public function isTextFieldEmpty() : Boolean
      {
         return this.m_count.text == "";
      }
      
      public function setTextField(value:String) : void
      {
         this.m_count.text = value;
         if(isNaN(Number(this.m_count.text)))
         {
            this.quantitySelected = int(value);
         }
      }
      
      private function reportKeyDown(event:KeyboardEvent) : void
      {
      }
      
      private function reportKeyUp(event:KeyboardEvent) : void
      {
         if(this.m_count.text != "" && (isNaN(Number(this.m_count.text)) || String(parseInt(this.m_count.text)) != this.m_count.text || int(this.m_count.text) > this.m_data.quantity || int(this.m_count.text) < 0 || this.m_count.text.length > MAX_NUM_CHAR))
         {
            this.m_count.text = String(this.quantitySelected);
         }
         else if(this.m_count.text == "")
         {
            this.quantitySelected = 0;
         }
         else
         {
            this.quantitySelected = Number(this.m_count.text);
         }
      }
      
      private function updateUI() : void
      {
         this.m_count.text = String(this.quantitySelected);
      }
      
      private function onDownArrowClicked(ev:MouseEvent) : void
      {
         if(this.quantitySelected == 0)
         {
            if(this.m_data.hasOwnProperty("quantity"))
            {
               this.quantitySelected = this.m_data.quantity;
            }
         }
         else
         {
            --this.quantitySelected;
         }
         this.updateUI();
      }
      
      private function set quantitySelected(value:int) : void
      {
         this.m_onQuantitySelectionChangeCallBack(value - this.m_quantitySelected);
         this.m_quantitySelected = value;
         if(this.m_quantitySelected == this.m_data.quantity)
         {
            this.m_upArrow.enabled = false;
         }
         else
         {
            this.m_upArrow.enabled = true;
         }
      }
      
      private function onUpArrowClicked(ev:MouseEvent) : void
      {
         ++this.quantitySelected;
         this.updateUI();
      }
      
      public function getQuantitySelected() : int
      {
         return this.quantitySelected;
      }
      
      private function get quantitySelected() : int
      {
         return this.m_quantitySelected;
      }
      
      override public function release() : void
      {
         this.m_data = null;
         this.m_count = null;
         this.m_downArrow = null;
         this.m_upArrow = null;
         this.m_icon = null;
         super.release();
      }
   }
}

