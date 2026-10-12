package Widgets.Slots.AvatarEditor
{
   import Classes.Avatar.AvatarItem;
   import Classes.util.ZLocUtils;
   import Engine.Utilities;
   import Widgets.Constants.Market.Currency;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import flash.display.DisplayObject;
   
   public class AvatarReceiptSlot extends ZwSlotFrame
   {
      
      private var m_data:AvatarItem;
      
      private var m_emptyFrame:ZwFrame;
      
      private var m_itemFrame:ZwFrame;
      
      private var m_nameTextField:ZwTextField;
      
      private var m_cashTextField:ZwTextField;
      
      private var m_coinsTextField:ZwTextField;
      
      private var m_cashIcon:ZwWidget;
      
      private var m_coinsIcon:ZwWidget;
      
      public function AvatarReceiptSlot(element:DisplayObject)
      {
         super(element);
         this.m_emptyFrame = addWidget(new ZwFrame(m_element.recieptCellEmpty_mc)) as ZwFrame;
         this.m_itemFrame = addWidget(new ZwFrame(m_element.recieptCellFull_mc)) as ZwFrame;
         this.m_nameTextField = this.m_itemFrame.addWidget(new ZwTextField(m_element.recieptCellFull_mc.generic_tf)) as ZwTextField;
         this.m_cashIcon = addWidget(new ZwWidget(m_element.recieptCellFull_mc.cashIcon_mc)) as ZwWidget;
         this.m_coinsIcon = addWidget(new ZwWidget(m_element.recieptCellFull_mc.coinIcon_mc)) as ZwWidget;
         this.m_cashTextField = this.m_itemFrame.addWidget(new ZwTextField(m_element.recieptCellFull_mc.cashCost_tf)) as ZwTextField;
         this.m_coinsTextField = this.m_itemFrame.addWidget(new ZwTextField(m_element.recieptCellFull_mc.coinCost_tf)) as ZwTextField;
      }
      
      override public function populate(data:Object) : void
      {
         super.populate(data);
         this.m_data = data as AvatarItem;
         if(this.m_data)
         {
            this.m_itemFrame.visible = true;
            this.m_cashIcon.visible = true;
            this.m_coinsIcon.visible = true;
            this.m_nameTextField.text = ZLocUtils.tk_pk_asTitle(this.m_data.friendlyName);
            switch(this.m_data.market)
            {
               case Currency.COINS:
                  this.m_cashTextField.text = String(0);
                  this.m_coinsTextField.text = Utilities.formatNumber(this.m_data.cost);
                  break;
               case Currency.CASH:
                  this.m_cashTextField.text = Utilities.formatNumber(this.m_data.cost);
                  this.m_coinsTextField.text = String(0);
            }
         }
         else
         {
            this.m_emptyFrame.visible = true;
         }
      }
      
      public function get data() : AvatarItem
      {
         return this.m_data;
      }
      
      override public function release() : void
      {
         this.m_data = null;
         this.m_emptyFrame = null;
         this.m_itemFrame = null;
         this.m_nameTextField = null;
         this.m_cashIcon = null;
         this.m_coinsIcon = null;
         this.m_cashTextField = null;
         this.m_coinsTextField = null;
         super.release();
      }
   }
}

