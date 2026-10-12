package Widgets.Slots.Trading
{
   import Classes.Friend;
   import Classes.Trading.UserTradingOfferings;
   import Classes.util.FarmGameUtil;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.Trading.TradingPostGoodSlotFrame;
   import Widgets.Frames.Trading.TradingPostUserSlotFrame;
   import Widgets.Icons.FarmIcon;
   import Widgets.TextFields.FarmTextField;
   import Widgets.Windows.Trading.TradingPostWindow;
   import flash.display.DisplayObject;
   
   public class TradingPostUserSlot extends ZwSlotFrame
   {
      
      private var m_userId:String = "-1";
      
      private var m_data:UserTradingOfferings = null;
      
      private var m_parentSlotFrame:TradingPostUserSlotFrame;
      
      private var m_parentWindow:TradingPostWindow = null;
      
      private var m_player:Friend = null;
      
      public function TradingPostUserSlot(element:DisplayObject, parentSlotFrame:TradingPostUserSlotFrame, parentWindow:TradingPostWindow)
      {
         super(element);
         this.m_parentSlotFrame = parentSlotFrame;
         this.m_parentWindow = parentWindow;
         addWidget(new FarmTextField(m_element.generic_tf));
         addWidget(new FarmIcon(m_element.icon_mc));
         addWidget(new TradingPostGoodSlotFrame(m_element.get_mc,parentWindow));
      }
      
      override public function populate(data:Object) : void
      {
         this.updateSlot(data as UserTradingOfferings);
      }
      
      private function updateSlot(data:UserTradingOfferings) : void
      {
         var items:Array = null;
         this.m_data = data;
         if(Boolean(this.m_data != null) && Boolean(this.m_data.sellerId) && Boolean(this.m_data.itemsForOrder))
         {
            this.m_userId = this.m_data["sellerId"];
            if(this.m_userId != "0")
            {
               this.m_player = Global.friendManager.getAppFriendData(this.m_userId);
               if(null != this.m_player)
               {
                  (getWidget(m_element.generic_tf) as ZwTextField).text = this.m_player.name;
                  (getWidget(m_element.generic_tf) as ZwTextField).visible = true;
                  (getWidget(m_element.icon_mc) as FarmIcon).visible = true;
                  (getWidget(m_element.icon_mc) as FarmIcon).loadIcon(FarmGameUtil.getFriendIconByUid(this.m_userId));
                  items = this.m_data.itemsForOrder.concat(this.m_data.itemsForSale);
                  items = items.concat(this.m_data.getUnfilledOrderTradingGoods(Global.player.uid));
                  items.sortOn("isClaimable",[Array.DESCENDING]);
                  (getWidget(m_element.get_mc) as TradingPostGoodSlotFrame).update(items);
                  (getWidget(m_element.get_mc) as TradingPostGoodSlotFrame).enabled = true;
                  (getWidget(m_element.get_mc) as TradingPostGoodSlotFrame).visible = true;
               }
            }
         }
      }
      
      override public function release() : void
      {
         super.release();
         this.m_data = null;
         this.m_parentSlotFrame = null;
         this.m_parentWindow = null;
         this.m_player = null;
      }
   }
}

