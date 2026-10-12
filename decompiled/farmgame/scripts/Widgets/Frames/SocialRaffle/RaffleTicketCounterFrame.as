package Widgets.Frames.SocialRaffle
{
   import Classes.util.ZLocUtils;
   import Managers.SocialRaffleManager;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import flash.display.DisplayObject;
   
   public final class RaffleTicketCounterFrame extends ZwFrame
   {
      
      private var m_ticketCounterTextField:ZwTextField;
      
      private var m_ticketTitleTextField:ZwTextField;
      
      private var m_ticketSubtitleTextField:ZwTextField;
      
      public function RaffleTicketCounterFrame(element:DisplayObject)
      {
         super(element);
         this.setupFrame(element);
      }
      
      public function updateTicketCount() : void
      {
         this.m_ticketCounterTextField.text = SocialRaffleManager.getInstance().userRaffleTickets.length.toString();
      }
      
      private function setupFrame(element:DisplayObject) : void
      {
         this.m_ticketCounterTextField = new ZwTextField(this.element.ticketcounter_tf);
         addWidget(this.m_ticketCounterTextField);
         this.updateTicketCount();
         this.m_ticketTitleTextField = new ZwTextField(this.element.tickettitle_tf,ZLocUtils.t("Dialogs","socialrafflebuilding_game_tickettitle"));
         addWidget(this.m_ticketTitleTextField);
         var ticketCount:Number = SocialRaffleManager.getInstance().userRaffleTickets.length;
         var ticketText:String = ZLocUtils.t("Dialogs","socialrafflebuilding_game_ticketsubtitle",{"ticket_word":ZLocUtils.tk("Dialogs","ticket_word","",ticketCount)});
         this.m_ticketSubtitleTextField = new ZwTextField(this.element.ticketsubtitle_tf,ticketText);
         addWidget(this.m_ticketSubtitleTextField);
      }
   }
}

