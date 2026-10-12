package Widgets.Slots
{
   import Classes.ZItem.FarmItem;
   import Managers.FarmStatsManager;
   import Managers.TurtleInnovationManager;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Buttons.FarmAnimatedCashButton;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Icons.FarmIcon;
   import Widgets.Tooltips.FarmTextTooltip;
   import flash.display.DisplayObject;
   import flash.events.MouseEvent;
   
   public class TurtleRewardsDetailSlot extends ZwSlotFrame
   {
      
      private static const ICON_WIDTH:int = 100;
      
      private static const ICON_HEIGHT:int = 100;
      
      private var m_toolTip:FarmTextTooltip;
      
      private var m_buyBtn:FarmAnimatedCashButton;
      
      private var m_iconMc:FarmIcon;
      
      private var m_iconPreview:FarmAnimatedButton;
      
      private var m_checkMark:ZwWidget;
      
      private var m_item:FarmItem;
      
      private var m_collectionName:String;
      
      private var m_itemSwf:String;
      
      public function TurtleRewardsDetailSlot(element:DisplayObject)
      {
         super(element);
         if(m_element.bt_buy)
         {
            this.m_buyBtn = new FarmAnimatedCashButton(m_element.bt_buy,"Buy","0",this.onBuyButtonClick) as FarmAnimatedCashButton;
            addWidget(this.m_buyBtn);
         }
         if(m_element.hasOwnProperty("checkmark_mc"))
         {
            addWidget(this.m_checkMark = new ZwWidget(m_element.checkmark_mc),false);
         }
         if(m_element.hasOwnProperty("icon_mc"))
         {
            addWidget(this.m_iconMc = new FarmIcon(m_element.icon_mc),false);
         }
         if(m_element.hasOwnProperty("preview_mc"))
         {
            addWidget(this.m_iconPreview = new FarmAnimatedButton(m_element.preview_mc,this.onPreviewClick));
         }
      }
      
      public function update(item:FarmItem, collectionName:String, itemSwf:String = null) : void
      {
         var isRewardRedeemed:Boolean = false;
         this.m_item = item;
         this.m_collectionName = collectionName;
         this.m_itemSwf = itemSwf;
         if(this.m_item)
         {
            if(this.m_iconMc)
            {
               this.m_iconMc.loadIcon(item.iconUrl);
               this.m_iconMc.setIconHeight(ICON_HEIGHT);
               this.m_iconMc.setIconWidth(ICON_WIDTH);
               this.m_iconMc.visible = true;
            }
            isRewardRedeemed = TurtleInnovationManager.getInstance().isCollectionItemRedeemed(this.m_collectionName,item.name);
            if(this.m_buyBtn)
            {
               this.m_buyBtn.setAmountText(item.cash.toString());
               this.m_buyBtn.visible = isRewardRedeemed;
            }
            if(this.m_checkMark)
            {
               this.m_checkMark.visible = isRewardRedeemed;
            }
         }
      }
      
      override public function release() : void
      {
         super.release();
         this.m_toolTip = null;
      }
      
      public function onBuyButtonClick(event:MouseEvent) : void
      {
         TurtleInnovationManager.getInstance().buyItem(this.m_item,this.m_collectionName);
      }
      
      public function onPreviewClick(event:MouseEvent) : void
      {
         TurtleInnovationManager.getInstance().showPreviewWindow(this.m_item,this.m_itemSwf);
         FarmStatsManager.count("tenguann_collections_ui","item_preview",this.m_collectionName,this.m_item.name);
      }
   }
}

