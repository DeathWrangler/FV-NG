package Widgets.Frames.AvatarEditor
{
   import Classes.Avatar.AvatarItem;
   import Classes.util.ZLocUtils;
   import Engine.Utilities;
   import Widgets.Constants.Market.Currency;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.FarmSlotContainerFrame;
   import Widgets.Slots.AvatarEditor.AvatarReceiptSlot;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   
   public class AvatarReceiptSlotFrame extends FarmSlotContainerFrame
   {
      
      private var m_cashTextField:ZwTextField;
      
      private var m_coinsTextField:ZwTextField;
      
      public function AvatarReceiptSlotFrame(element:MovieClip)
      {
         super(element);
         addWidget(new ZwTextField(m_element.generic_tf,ZLocUtils.t("Dialogs","AvatarEditorWindow_Receipt_Title")));
         addWidget(new ZwTextField(m_element.generic2_tf,ZLocUtils.t("Dialogs","AvatarEditorWindow_Receipt_Total")));
         addWidget(new ZwWidget(m_element.cashIcon_mc));
         addWidget(new ZwWidget(m_element.coinIcon_mc));
         this.m_cashTextField = addWidget(new ZwTextField(m_element.cashCost_tf)) as ZwTextField;
         this.m_coinsTextField = addWidget(new ZwTextField(m_element.coinCost_tf)) as ZwTextField;
      }
      
      public function get items() : Array
      {
         return m_slotData;
      }
      
      public function set items(items:Array) : void
      {
         m_slotData = items;
         this.refresh();
      }
      
      override protected function createSlot(slotElement:DisplayObject) : ZwSlotFrame
      {
         return new AvatarReceiptSlot(slotElement);
      }
      
      override protected function setupData() : void
      {
      }
      
      override public function refresh() : void
      {
         var item:AvatarItem = null;
         super.refresh();
         var cash:int = 0;
         var coins:int = 0;
         if(m_slotData != null)
         {
            for each(item in m_slotData)
            {
               switch(item.market)
               {
                  case Currency.COINS:
                     coins += item.cost;
                     break;
                  case Currency.CASH:
                     cash += item.cost;
               }
            }
         }
         this.m_cashTextField.text = Utilities.formatNumber(cash);
         this.m_coinsTextField.text = Utilities.formatNumber(coins);
      }
      
      override public function release() : void
      {
         this.m_cashTextField = null;
         this.m_coinsTextField = null;
         super.release();
      }
   }
}

