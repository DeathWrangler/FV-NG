package Widgets.Slots.LESet
{
   import Engine.Managers.StatsManager;
   import Widgets.Buttons.FarmAnimatedCashButton;
   import Widgets.Core.Base.ZwBaseWidget;
   import Widgets.Frames.GenericSlotContainerFrame;
   import Widgets.Slots.ItemPurchaseSlot;
   import Widgets.TextFields.FarmTextField;
   import Widgets.Windows.FarmWindow;
   import Widgets.Windows.Market.MarketWindow;
   import flash.display.DisplayObject;
   import flash.events.Event;
   
   public class LERecommendationSurfacingSlot extends ItemPurchaseSlot
   {
      
      private var m_buyBt:FarmAnimatedCashButton;
      
      private var m_saleTf:FarmTextField;
      
      private var m_saleMc:ZwBaseWidget;
      
      private var m_itemSource:String = "recs_neighbor_bar";
      
      public function LERecommendationSurfacingSlot(element:DisplayObject, window:FarmWindow)
      {
         super(element,window);
         addWidget(this.m_buyBt = new FarmAnimatedCashButton(m_element.buy_bt,"","00",this.onBuyCallback,false,false,true));
         if(Boolean(m_element.sale_mc) && Boolean(m_element.sale_mc.cost_tf))
         {
            addWidget(this.m_saleTf = new FarmTextField(m_element.sale_mc.cost_tf,""));
            addWidget(this.m_saleMc = new ZwBaseWidget(m_element.sale_mc));
         }
      }
      
      override protected function onBuyCallback(event:Event) : void
      {
         var parentSlotContainerFrame:GenericSlotContainerFrame = null;
         var marketWindow:MarketWindow = null;
         var price:int = getItemPrice();
         var slotNum:String = "";
         var pageNum:String = "";
         if(Global.player.canBuyCash(price))
         {
            m_farmItem.onBuy(m_farmItem.name);
            if(name.split("_")[1])
            {
               slotNum = this.name.split("_")[1];
            }
            parentSlotContainerFrame = parent as GenericSlotContainerFrame;
            if(parentSlotContainerFrame != null)
            {
               pageNum = parentSlotContainerFrame.pageNumber.toString();
            }
            marketWindow = m_parentWindow as MarketWindow;
            if(marketWindow != null)
            {
               marketWindow.checkAndRepopMarketWindow(m_farmItem);
            }
            StatsManager.count(this.m_itemSource,"buy_click",m_farmItem.name,price.toString(),pageNum,slotNum);
            m_parentWindow.close();
         }
      }
      
      public function setItemSource(statsLocation:String) : void
      {
         this.m_itemSource = statsLocation;
      }
      
      override protected function setupBuyButton() : void
      {
         if(m_farmItem)
         {
            this.m_buyBt.visible = true;
         }
      }
      
      override protected function setupPrice() : void
      {
         if(m_farmItem)
         {
            if(m_farmItem.hasSale)
            {
               if(Boolean(this.m_saleMc) && Boolean(this.m_saleTf))
               {
                  this.m_saleTf.text = m_farmItem.cash.toString();
                  this.m_saleTf.visible = true;
                  this.m_saleMc.visible = true;
               }
               this.m_buyBt.setAmountText(m_farmItem.saleCash.toString());
            }
            else
            {
               this.m_buyBt.setAmountText(m_farmItem.cash.toString());
               if(this.m_saleMc)
               {
                  this.m_saleMc.visible = false;
               }
            }
         }
      }
      
      override public function release() : void
      {
         this.m_buyBt = null;
         super.release();
      }
   }
}

