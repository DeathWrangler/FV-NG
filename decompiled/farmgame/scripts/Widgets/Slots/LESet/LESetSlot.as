package Widgets.Slots.LESet
{
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Widgets.Buttons.FarmAnimatedCashButton;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Frames.LESet.LESetSlotContainerFrame;
   import Widgets.Icons.FarmIcon;
   import flash.display.DisplayObject;
   import flash.events.MouseEvent;
   
   public class LESetSlot extends ZwSlotFrame
   {
      
      private var m_callbacks:Object;
      
      private var m_data:Object;
      
      private var m_icon:FarmIcon;
      
      private var m_toolTip:ZwWidget;
      
      private var m_buyBtn:FarmAnimatedCashButton;
      
      private var m_checkMrk:ZwWidget;
      
      private var m_container:LESetSlotContainerFrame;
      
      private const ICON_SIZE:int = 100;
      
      public function LESetSlot(element:DisplayObject, container:LESetSlotContainerFrame)
      {
         super(element);
         if(m_element.itemslot_mc)
         {
            this.m_icon = addWidget(new FarmIcon(m_element.itemslot_mc)) as FarmIcon;
            this.m_icon.setIconSize(this.ICON_SIZE,this.ICON_SIZE);
         }
         if(m_element.buyitembtn_mc)
         {
            addWidget(this.m_buyBtn = new FarmAnimatedCashButton(m_element.buyitembtn_mc,ZLocUtils.t("Dialogs","LESetBonus_Price"),"",this.onBuyClick,false,false,true));
         }
         if(m_element.checkmark_mc)
         {
            this.m_checkMrk = new ZwWidget(m_element.checkmark_mc);
            addWidget(this.m_checkMrk);
         }
         if(m_element.itemtooltip_mc)
         {
            this.m_toolTip = new ZwWidget(m_element.itemtooltip_mc);
            addWidget(this.m_toolTip);
         }
         this.m_container = container;
      }
      
      override public function populate(data:Object) : void
      {
         super.populate(data);
         this.m_data = data["item"] as FarmItem;
         this.m_buyBtn.text = ZLocUtils.t("Dialogs","LESetBonus_Price",{"price":this.m_data.realCashCost});
         if(this.m_data)
         {
            this.m_icon.clearScale();
            this.m_icon.loadIcon(this.m_data.iconUrl);
            this.m_icon.visible = true;
            this.m_buyBtn.enabled = true;
            this.m_buyBtn.visible = true;
            if(data.owned != true)
            {
               this.m_checkMrk.visible = false;
               this.m_icon.alpha = 1;
            }
            else
            {
               this.m_checkMrk.visible = true;
               this.m_icon.alpha = 0.5;
            }
         }
         else
         {
            this.m_icon.visible = false;
            this.m_buyBtn.enabled = false;
            this.m_buyBtn.visible = false;
            this.m_checkMrk.visible = false;
         }
      }
      
      public function get Icon() : FarmIcon
      {
         return this.m_icon;
      }
      
      public function onBuyClick(evt:MouseEvent) : void
      {
         var successfulPurchase:Boolean = this.m_container.onSlotBuy(this);
         if(successfulPurchase == true)
         {
            this.m_checkMrk.visible = true;
         }
      }
   }
}

