package Widgets.Slots
{
   import Classes.ZItem.FarmItem;
   import Managers.FarmStatsManager;
   import Managers.OrderBoard.HalloweenInnovationManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Frames.ObjectPreviewFrame;
   import Widgets.Icons.FarmIcon;
   import Widgets.Tooltips.FarmTextTooltip;
   import Widgets.Windows.HalloweenUSARedeemWindow;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class HalloweenUSARedeemSlot extends ZwSlotFrame
   {
      
      private const CHECKMARK_MC:String = "checkmark_mc";
      
      private var m_data:Object;
      
      protected var m_item:FarmItem = null;
      
      private var m_featureName:String;
      
      private const TRADE_BT:String = "trade_bt";
      
      private var m_slotIndex:Number = 0;
      
      private var m_redeemButton:FarmAnimatedTextButton;
      
      protected var m_iconPreview:ObjectPreviewFrame;
      
      private var m_parentWindow:HalloweenUSARedeemWindow;
      
      private var m_consumable_mc:MovieClip;
      
      private const CONSUMABLE_MC:String = "consumable_mc";
      
      private var m_checkMark:MovieClip = null;
      
      private const COUNT_TF:String = "count_tf";
      
      public function HalloweenUSARedeemSlot(element:DisplayObject, featureName:String, parentWindow:HalloweenUSARedeemWindow)
      {
         super(element);
         this.m_featureName = featureName;
         this.m_parentWindow = parentWindow;
         if(m_element.slot_icon_mc != null)
         {
            addWidget(new FarmIcon(m_element.slot_icon_mc));
         }
         if(m_element.hasOwnProperty(this.CHECKMARK_MC))
         {
            this.m_checkMark = m_element[this.CHECKMARK_MC] as MovieClip;
            this.m_checkMark.visible = false;
         }
         if(m_element.hasOwnProperty(this.TRADE_BT))
         {
            this.m_redeemButton = new FarmAnimatedTextButton(m_element[this.TRADE_BT],"Redeem",this.onRedeemItem);
            this.m_redeemButton.visible = true;
            this.m_redeemButton.enabled = true;
         }
      }
      
      override public function populate(data:Object) : void
      {
         var itemBox:FarmIcon = null;
         var attachedToolTip:FarmTextTooltip = null;
         this.m_data = data;
         this.m_slotIndex = this.m_data.rewardSlotNumber;
         this.m_item = Global.farmGameSettingsManager.getFarmItemByCode(this.m_data.rewardCode);
         if(Boolean(m_element) && Boolean(m_element["slot_icon_mc"]))
         {
            itemBox = getWidget(m_element["slot_icon_mc"]) as FarmIcon;
            if(itemBox)
            {
               itemBox.loadIcon(this.m_item.icon);
               itemBox.visible = true;
               attachedToolTip = itemBox.tooltip as FarmTextTooltip;
               if(attachedToolTip)
               {
                  itemBox.detachTooltip();
               }
               itemBox.attachTooltip(new FarmTextTooltip(this.m_item.friendlyTitle));
            }
         }
      }
      
      private function onRedeemItem(event:Event) : void
      {
         FarmStatsManager.count("RockPaperShivers","Market_UI","redeem_click",this.m_item.name);
         HalloweenInnovationManager.getInstance(this.m_featureName).redeemCouponItem(this.m_item.code,this.m_parentWindow);
         this.m_parentWindow.close();
      }
   }
}

