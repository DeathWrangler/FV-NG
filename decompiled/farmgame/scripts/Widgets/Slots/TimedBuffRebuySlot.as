package Widgets.Slots
{
   import Classes.util.ObjectUtil;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Windows.FarmWindow;
   import flash.display.DisplayObject;
   
   public class TimedBuffRebuySlot extends ItemPurchaseSlot
   {
      
      private static const TIMED_BUFF_PREVIEW_SIZE:int = 70;
      
      public function TimedBuffRebuySlot(element:DisplayObject, parentWindow:FarmWindow)
      {
         super(element,parentWindow);
      }
      
      override protected function previewSize() : int
      {
         return TIMED_BUFF_PREVIEW_SIZE;
      }
      
      override protected function setupPrice() : void
      {
         var itemPrice:String = null;
         if(ObjectUtil.pathExists(m_element,new Array("buy_bt","price_tf")))
         {
            if(m_price)
            {
               removeWidget(m_price);
               m_price = null;
            }
            itemPrice = getItemPrice().toString();
            m_price = addWidget(new ZwTextField(m_element.buy_bt.price_tf,itemPrice)) as ZwTextField;
         }
      }
   }
}

