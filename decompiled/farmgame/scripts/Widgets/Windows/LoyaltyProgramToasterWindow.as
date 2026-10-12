package Widgets.Windows
{
   import Classes.util.ZLocUtils;
   import Managers.LoyaltyProgramManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Constants.Market.Currency;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   
   public class LoyaltyProgramToasterWindow extends FeedPostCompleteToasterWindow
   {
      
      private var m_earnedStatusPoints:String;
      
      private var m_MouseOver:Boolean = false;
      
      public function LoyaltyProgramToasterWindow(earnedPoints:String)
      {
         this.m_earnedStatusPoints = earnedPoints;
         this.addEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver);
         this.addEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut);
         super("Loyalty",null,null,"assets/dialogs/FV_LoyaltyProgram_FeedComplete.swf");
      }
      
      override protected function postLoadComplete() : void
      {
         var statusPoints:String = null;
         super.postLoadComplete();
         if("accept_bt" in m_window)
         {
            addWidget(new FarmAnimatedTextButton(m_window.accept_bt,"Open Market",this.openMarket));
         }
         if(m_copy1TextField)
         {
            statusPoints = Global.player.getWorldCurrencyTotal(Currency.COST_STATUS_POINTS).toString();
            m_copy1TextField.text = ZLocUtils.t("Dialogs","LoyaltyToaster_status",{
               "earnedPoints":this.m_earnedStatusPoints,
               "statusPoints":statusPoints
            });
         }
      }
      
      private function onMouseOut(e:Event) : void
      {
         this.m_MouseOver = false;
         close();
      }
      
      private function onMouseOver(e:Event) : void
      {
         this.m_MouseOver = true;
      }
      
      override protected function onTimer(event:TimerEvent) : void
      {
         if(!this.m_MouseOver)
         {
            close();
         }
      }
      
      private function openMarket(event:Event) : void
      {
         close();
         LoyaltyProgramManager.redeemStatusPoints();
      }
   }
}

