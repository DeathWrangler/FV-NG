package Widgets.Slots.SocialRaffle
{
   import Classes.SocialRaffle.SocialRaffleConstants;
   import Classes.util.ZLocUtils;
   import Managers.SocialRaffleManager;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.TextFields.FarmTextField;
   import Widgets.Tooltips.FarmTextTooltip;
   import com.greensock.TweenLite;
   import flash.display.DisplayObject;
   
   public class RaffleProgressSlot extends ZwSlotFrame
   {
      
      private var m_numTicketsTextField:FarmTextField = null;
      
      private var m_dayTextField:FarmTextField = null;
      
      private var DAYS_OF_THE_WEEK:Array = null;
      
      private var m_hasAnimated:Boolean = false;
      
      private var m_nameTooltip:FarmTextTooltip = null;
      
      public function RaffleProgressSlot(element:DisplayObject)
      {
         super(element);
         this.DAYS_OF_THE_WEEK = [ZLocUtils.t("FarmGame","Sunday"),ZLocUtils.t("FarmGame","Monday"),ZLocUtils.t("FarmGame","Tuesday"),ZLocUtils.t("FarmGame","Wednesday"),ZLocUtils.t("FarmGame","Thursday"),ZLocUtils.t("FarmGame","Friday"),ZLocUtils.t("FarmGame","Saturday")];
         if(this.element.ticketcount_tf)
         {
            this.m_numTicketsTextField = new FarmTextField(this.element.ticketcount_tf,"");
            addWidget(this.m_numTicketsTextField);
         }
         if(this.element.day_tf)
         {
            this.m_dayTextField = new FarmTextField(this.element.day_tf,"");
            addWidget(this.m_dayTextField,false);
         }
         this.attachTooltip(this.m_nameTooltip = new FarmTextTooltip(""));
      }
      
      override public function release() : void
      {
         TweenLite.killTweensOf(this);
         super.release();
      }
      
      override public function populate(data:Object) : void
      {
         var i:int = 0;
         var namesString:String = null;
         super.populate(data);
         if(this.m_numTicketsTextField)
         {
            if(data["tickets"] != null)
            {
               this.m_numTicketsTextField.text = data["tickets"].toString();
               this.m_numTicketsTextField.visible = true;
            }
         }
         var slotDay:Number = (data["slotNumber"] + data["dayOffset"]) % SocialRaffleConstants.DAYS_PER_WEEK;
         if(this.m_dayTextField)
         {
            this.m_dayTextField.visible = true;
            if(data["slotNumber"] != null)
            {
               this.m_dayTextField.text = this.DAYS_OF_THE_WEEK[slotDay];
               this.m_dayTextField.visible = true;
            }
         }
         if(Boolean(data.names) && data.names.length > 0)
         {
            i = 0;
            namesString = "";
            while(i < data.names.length)
            {
               if(i > 0)
               {
                  namesString += "\n";
               }
               namesString += data.names[i];
               i++;
            }
            this.m_nameTooltip.setText(namesString);
         }
         if(Global.animationState == Global.ANIMATION_STATE_PLAY && !this.m_hasAnimated)
         {
            TweenLite.from(this,2,{
               "delay":0.5 + 0.25 * data["slotNumber"],
               "alpha":0
            });
            this.m_hasAnimated = true;
         }
         var adjustedDay:Number = SocialRaffleManager.getInstance().raffleDataView.getAdjustedDayOfWeek();
         if(data["slotNumber"] > adjustedDay)
         {
            this.m_dayTextField.alpha = 0.5;
            this.m_numTicketsTextField.text = "?";
            this.m_numTicketsTextField.color = 10066329;
         }
      }
   }
}

