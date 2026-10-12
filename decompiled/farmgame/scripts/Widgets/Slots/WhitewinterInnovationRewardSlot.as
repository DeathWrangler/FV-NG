package Widgets.Slots
{
   import Classes.ZItem.FarmItem;
   import Managers.WhitewinterInnovationManager;
   import Widgets.Buttons.FarmAnimatedCashButton;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import Widgets.Tooltips.FarmTextTooltip;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   
   public class WhitewinterInnovationRewardSlot extends ZwSlotFrame
   {
      
      private static const ICON_SIZE:int = 100;
      
      public static const SERVICE_CLASS:String = "ActionDrivenService";
      
      protected var m_data:Object;
      
      private var m_presentWidget:ZwWidget;
      
      private var m_icon:FarmIcon;
      
      private var m_tickMark:MovieClip;
      
      private var m_grant:MovieClip;
      
      private var m_grantDateTf:ZwTextField;
      
      private var m_counttf:ZwTextField = null;
      
      private var m_buyButton:FarmAnimatedCashButton = null;
      
      private var m_slotIndex:int;
      
      private var m_hitWidget:FarmIcon;
      
      public function WhitewinterInnovationRewardSlot(element:DisplayObject)
      {
         super(element);
         getWidget(this.m_icon = new FarmIcon(m_element.icon_mc));
         this.m_icon.setIconSize(ICON_SIZE,ICON_SIZE);
         this.m_icon.setSmoothing(true);
         addWidget(this.m_presentWidget = new ZwWidget(m_element.present_mc),false);
         getWidget(this.m_hitWidget = new FarmIcon(m_element.hover_mc));
         if(m_element.checkmark_mc)
         {
            this.m_tickMark = m_element.checkmark_mc as MovieClip;
            this.m_tickMark.visible = false;
         }
         if(m_element.grant_mc)
         {
            this.m_grant = m_element.grant_mc as MovieClip;
            this.m_grant.visible = false;
         }
         if(m_element.hasOwnProperty("date_tf"))
         {
            addWidget(this.m_grantDateTf = new ZwTextField(m_element.date_tf));
         }
      }
      
      override public function release() : void
      {
         this.m_data = null;
         this.m_icon = null;
         this.m_presentWidget = null;
         this.m_counttf = null;
         super.release();
      }
      
      public function get manager() : WhitewinterInnovationManager
      {
         return WhitewinterInnovationManager.getInstance();
      }
      
      override public function populate(data:Object) : void
      {
         var item:FarmItem = null;
         var element:MovieClip = null;
         super.populate(data);
         this.m_data = data;
         this.m_slotIndex = this.m_data["rewardSlotNumber"];
         if(this.m_data)
         {
            item = Global.farmGameSettingsManager.getFarmItemByName(this.m_data["rewardName"]);
            if(item)
            {
               this.m_icon.loadIcon(item.iconUrl);
               element = m_element as MovieClip;
               if(this.manager.isrewardRedeemed(this.m_slotIndex))
               {
                  this.m_icon.visible = true;
                  this.m_icon.alpha = 1;
                  this.m_hitWidget.detachTooltip();
                  this.m_hitWidget.attachTooltip(new FarmTextTooltip(item.friendlyTitle));
                  if(this.manager.getLastEarnedRewardIndex() == this.m_slotIndex && this.manager.isShowGrantMC())
                  {
                     this.m_grant.visible = true;
                  }
                  element.gotoAndStop(1);
               }
               else if(this.manager.isGiftAvailableForRedeem(this.m_slotIndex))
               {
                  element.gotoAndStop(element.totalFrames);
                  this.m_icon.visible = true;
                  this.m_hitWidget.detachTooltip();
                  this.m_hitWidget.attachTooltip(new FarmTextTooltip(item.friendlyTitle));
               }
               else if(this.manager.isrewardInEarnedState(this.m_slotIndex))
               {
                  if(this.manager.getLastEarnedRewardIndex() == this.m_slotIndex && this.manager.isShowGrantMC())
                  {
                     this.m_grant.visible = true;
                     this.m_grantDateTf.text = "Opens on " + this.getRewardGrantDate(this.m_slotIndex);
                     this.m_grantDateTf.visible = true;
                  }
                  this.m_hitWidget.detachTooltip();
                  this.m_hitWidget.attachTooltip(new FarmTextTooltip("Opens on " + this.getRewardGrantDate(this.m_slotIndex)));
                  this.m_tickMark.visible = true;
                  this.m_presentWidget.visible = true;
                  element.gotoAndStop(1);
               }
               else
               {
                  element.gotoAndStop(1);
                  this.m_presentWidget.visible = true;
                  this.m_icon.detachTooltip();
               }
            }
         }
      }
      
      private function getRewardGrantDate(m_slotIndex:int) : String
      {
         var result:String = null;
         var date:String = this.manager.checkrewardDate(m_slotIndex);
         if(date == "12/25/2017")
         {
            result = "25th Dec";
         }
         else if(date == "01/01/2018")
         {
            result = "1st Jan";
         }
         else if(date == "01/05/2018")
         {
            result = "5th Jan";
         }
         return result;
      }
   }
}

