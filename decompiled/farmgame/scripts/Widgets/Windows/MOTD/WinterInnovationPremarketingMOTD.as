package Widgets.Windows.MOTD
{
   import Engine.Managers.TransactionManager;
   import Transactions.TGenericTransaction;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import flash.events.MouseEvent;
   
   public class WinterInnovationPremarketingMOTD extends GenericSingleButtonWidgetMOTD
   {
      
      public static const SERVICE_CLASS:String = "WinterPremarketingService";
      
      public static const SEEN_FLAG:String = "WinterPremarketingGrantFlag";
      
      private var m_sendBt:FarmAnimatedTextButton;
      
      public function WinterInnovationPremarketingMOTD(displayParams:Object = null)
      {
         super(displayParams);
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         if(m_window.hasOwnProperty("mainWindow"))
         {
            if(m_window.mainWindow.animation_mc.letter_mc["send_bt"])
            {
               addWidget(this.m_sendBt = new FarmAnimatedTextButton(m_window.mainWindow.animation_mc.letter_mc["send_bt"],"Select",this.onStone0ButtonClick)) as FarmAnimatedTextButton;
               this.m_sendBt.visible = true;
            }
            m_accept_bt.visible = false;
            if(m_animationMc)
            {
               m_animationMc.element.stop();
            }
         }
      }
      
      protected function onStone0ButtonClick(event:MouseEvent) : void
      {
         if(!Global.player.getSeenFlag(SEEN_FLAG))
         {
            if(m_animationMc)
            {
               m_animationMc.element.play();
            }
            m_accept_bt.visible = true;
            Global.player.addGift("consume_turbo_charger","0",3);
            TransactionManager.addTransaction(new TGenericTransaction(SERVICE_CLASS,"grantReward",this.onGrantReward));
         }
      }
      
      private function onGrantReward(result:Object) : void
      {
         if(result.success)
         {
            Global.player.setSeenFlag(SEEN_FLAG);
         }
      }
   }
}

