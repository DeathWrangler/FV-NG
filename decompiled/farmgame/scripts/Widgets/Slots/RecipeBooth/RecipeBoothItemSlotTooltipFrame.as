package Widgets.Slots.RecipeBooth
{
   import Classes.ZItem.FarmItem;
   import Widgets.Buttons.FarmAnimatedCashButton;
   import Widgets.Core.Frames.ZwFrame;
   import flash.display.DisplayObject;
   import flash.events.MouseEvent;
   
   public final class RecipeBoothItemSlotTooltipFrame extends ZwFrame
   {
      
      private var m_itemName:String;
      
      private var m_buyCallback:Function;
      
      private var m_buyButton:FarmAnimatedCashButton;
      
      public function RecipeBoothItemSlotTooltipFrame(element:DisplayObject, buyCallback:Function)
      {
         this.m_buyCallback = buyCallback;
         super(element);
         this.m_buyButton = addWidget(new FarmAnimatedCashButton(m_element.buy_bt,"Buy Now!","00",this.onBuyButtonClick)) as FarmAnimatedCashButton;
      }
      
      override public function release() : void
      {
         this.m_buyButton = null;
         this.m_buyCallback = null;
         super.release();
      }
      
      public function populate(itemName:String) : void
      {
         this.m_itemName = itemName;
         var item:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(this.m_itemName);
         if(Boolean(item) && item.buyableWithCash())
         {
            this.m_buyButton.setAmountText(String(item.cash));
            this.m_buyButton.enabled = true;
            this.m_buyButton.visible = true;
         }
         else
         {
            this.m_buyButton.enabled = false;
            this.m_buyButton.visible = false;
         }
      }
      
      private function onBuyButtonClick(event:MouseEvent) : void
      {
         if(this.m_buyButton.enabled)
         {
            if(this.m_buyCallback != null)
            {
               this.m_buyCallback(event);
            }
         }
      }
   }
}

