package Widgets.Slots.FeatureCrafting
{
   import Classes.FeatureCrafting.FeatureCraftingOrder;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Frames.FeatureCrafting.FeatureCraftingGoodSlotContainerFrame;
   import Widgets.Frames.FeatureCrafting.FeatureCraftingOrderDetailsFrame;
   import Widgets.Icons.FarmIcon;
   import Widgets.Tooltips.WidgetTooltip;
   import Widgets.Windows.FeatureCrafting.FeatureCraftingContentsWindow;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.display.SimpleButton;
   import flash.events.MouseEvent;
   
   public class FeatureCraftingOrderSlot extends ZwSlotFrame
   {
      
      private static const ICON_SIZE:int = 100;
      
      protected var m_parentWindow:FeatureCraftingContentsWindow;
      
      protected var m_data:FeatureCraftingOrder;
      
      private var m_icon:FarmIcon;
      
      private var m_readyWidget:ZwWidget;
      
      private var m_effectWidget:ZwWidget;
      
      private var m_completeWidget:ZwWidget;
      
      private var m_detailsTooltip:WidgetTooltip;
      
      private var m_detailsFrame:FeatureCraftingOrderDetailsFrame;
      
      private var m_goodsX1Frame:FeatureCraftingGoodSlotContainerFrame;
      
      private var m_goodsX2Frame:FeatureCraftingGoodSlotContainerFrame;
      
      private var m_goodsX3Frame:FeatureCraftingGoodSlotContainerFrame;
      
      public function FeatureCraftingOrderSlot(element:DisplayObject, useTooltip:Boolean = true)
      {
         var hitWidget:ZwWidget = null;
         super(element);
         if(m_element.icon_mc)
         {
            this.m_icon = addWidget(new FarmIcon(m_element.icon_mc)) as FarmIcon;
            this.m_icon.setIconSize(ICON_SIZE,ICON_SIZE);
            this.m_icon.setSmoothing(true);
         }
         this.m_completeWidget = addWidget(new ZwWidget(m_element.complete_mc)) as ZwWidget;
         this.m_effectWidget = addWidget(new ZwWidget(m_element.effect_mc)) as ZwWidget;
         this.m_readyWidget = addWidget(new ZwWidget(m_element.ready_mc)) as ZwWidget;
         if(m_element.slots1_mc)
         {
            this.m_goodsX1Frame = addWidget(new FeatureCraftingGoodSlotContainerFrame(m_element.slots1_mc)) as FeatureCraftingGoodSlotContainerFrame;
         }
         if(m_element.slots2_mc)
         {
            this.m_goodsX2Frame = addWidget(new FeatureCraftingGoodSlotContainerFrame(m_element.slots2_mc)) as FeatureCraftingGoodSlotContainerFrame;
         }
         if(m_element.slots3_mc)
         {
            this.m_goodsX3Frame = addWidget(new FeatureCraftingGoodSlotContainerFrame(m_element.slots3_mc)) as FeatureCraftingGoodSlotContainerFrame;
         }
         if(m_element.hit_bt)
         {
            hitWidget = addWidget(new ZwWidget(m_element.hit_bt)) as ZwWidget;
            (hitWidget.element as SimpleButton).useHandCursor = false;
            hitWidget.visible = true;
         }
         this.m_detailsFrame = new FeatureCraftingOrderDetailsFrame(m_element.tooltip_mc,this.onAcceptButtonClick,this.onCompleteNowButtonClick) as FeatureCraftingOrderDetailsFrame;
         if(useTooltip)
         {
            this.m_detailsTooltip = new WidgetTooltip(this.m_detailsFrame);
            this.m_detailsTooltip.fixed = true;
            this.m_detailsTooltip.interactive = true;
            attachTooltip(this.m_detailsTooltip);
         }
      }
      
      override public function release() : void
      {
         this.m_parentWindow = null;
         this.m_icon = null;
         this.m_completeWidget = null;
         this.m_effectWidget = null;
         this.m_readyWidget = null;
         this.m_goodsX1Frame = null;
         this.m_goodsX2Frame = null;
         this.m_goodsX3Frame = null;
         this.m_detailsFrame = null;
         super.release();
      }
      
      override public function populate(data:Object) : void
      {
         super.populate(data);
         this.m_data = data as FeatureCraftingOrder;
         if(this.m_data)
         {
            this.refresh();
         }
      }
      
      public function refresh() : void
      {
         var goods:Array = null;
         if(this.m_data)
         {
            if(this.m_icon)
            {
               this.m_icon.loadIcon(this.m_data.helperImageUrl);
               this.m_icon.visible = true;
            }
            goods = this.m_data.requiredGoods();
            if(goods.length == 1)
            {
               if(this.m_goodsX1Frame)
               {
                  this.m_goodsX1Frame.items = goods;
                  this.m_goodsX1Frame.visible = true;
               }
               if(this.m_goodsX2Frame)
               {
                  this.m_goodsX2Frame.visible = false;
               }
               if(this.m_goodsX3Frame)
               {
                  this.m_goodsX3Frame.visible = false;
               }
            }
            else if(goods.length == 2)
            {
               if(this.m_goodsX2Frame)
               {
                  this.m_goodsX2Frame.items = goods;
                  this.m_goodsX2Frame.visible = true;
               }
               if(this.m_goodsX1Frame)
               {
                  this.m_goodsX1Frame.visible = false;
               }
               if(this.m_goodsX3Frame)
               {
                  this.m_goodsX3Frame.visible = false;
               }
            }
            else
            {
               if(this.m_goodsX3Frame)
               {
                  this.m_goodsX3Frame.items = goods;
                  this.m_goodsX3Frame.visible = true;
               }
               if(this.m_goodsX1Frame)
               {
                  this.m_goodsX1Frame.visible = false;
               }
               if(this.m_goodsX2Frame)
               {
                  this.m_goodsX2Frame.visible = false;
               }
            }
            if(this.m_data.isComplete)
            {
               this.m_completeWidget.visible = true;
               this.m_readyWidget.visible = false;
               if(Boolean(this.m_detailsTooltip) && this.m_detailsTooltip == tooltip)
               {
                  detachTooltip();
                  this.m_detailsFrame.visible = false;
               }
            }
            else
            {
               this.m_completeWidget.visible = false;
               this.m_readyWidget.visible = this.m_data.canFillOrder();
               this.m_detailsFrame.populate(this.m_data);
               if(this.m_detailsTooltip)
               {
                  if(this.m_detailsTooltip != tooltip)
                  {
                     attachTooltip(this.m_detailsTooltip);
                  }
               }
               else
               {
                  this.m_detailsFrame.visible = true;
               }
            }
         }
      }
      
      private function onAcceptButtonClick(event:MouseEvent) : void
      {
         if(this.m_data)
         {
            if(this.m_data.fillOrder())
            {
               this.refresh();
               (this.m_effectWidget.element as MovieClip).gotoAndPlay(2);
               this.m_effectWidget.visible = true;
            }
         }
      }
      
      private function onCompleteNowButtonClick(event:MouseEvent) : void
      {
         if(this.m_data)
         {
            if(this.m_data.completeNow())
            {
               this.refresh();
               (this.m_effectWidget.element as MovieClip).gotoAndPlay(2);
               this.m_effectWidget.visible = true;
            }
         }
      }
   }
}

