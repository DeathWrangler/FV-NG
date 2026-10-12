package Widgets.Windows.MOTD
{
   import Engine.Managers.TransactionManager;
   import Transactions.TGenericTransaction;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.TextFields.FarmTextField;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class JuneInnovationPremarketingMOTD extends GenericSingleButtonWidgetMOTD
   {
      
      public static const SERVICE_CLASS:String = "RussiaPremarketingService";
      
      public static const SEEN_FLAG:String = "JuneInnovationPremarketingGrantFlag";
      
      private var m_startBt:FarmAnimatedTextButton;
      
      private var m_applyBt:FarmAnimatedTextButton;
      
      private var m_bodyTextField:FarmTextField;
      
      private var m_body1TextField:FarmTextField;
      
      private var m_body2TextField:FarmTextField;
      
      public function JuneInnovationPremarketingMOTD(displayParams:Object = null)
      {
         super(displayParams);
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         if(m_window.hasOwnProperty("mainWindow"))
         {
            if(m_window.mainWindow.animation_mc["start_bt"])
            {
               addWidget(this.m_startBt = new FarmAnimatedTextButton(m_window.mainWindow.animation_mc["start_bt"],"Wham!",this.onStone0ButtonClick)) as FarmAnimatedTextButton;
               this.m_startBt.visible = true;
            }
            if(m_window.mainWindow.animation_mc["apply_bt"])
            {
               addWidget(this.m_applyBt = new FarmAnimatedTextButton(m_window.mainWindow.animation_mc["apply_bt"],"Apply",this.onStone1ButtonClick)) as FarmAnimatedTextButton;
               this.m_applyBt.visible = false;
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
         if(m_animationMc)
         {
            m_animationMc.element.play();
         }
         m_window.mainWindow.animation_mc.addEventListener(Event.ENTER_FRAME,this.onEnterFrame);
      }
      
      protected function onStone1ButtonClick(event:MouseEvent) : void
      {
         if(!Global.player.getSeenFlag(SEEN_FLAG))
         {
            if(m_animationMc)
            {
               m_animationMc.element.play();
            }
            m_accept_bt.visible = true;
            Global.player.addGift("consume_instagrow","0",2);
            TransactionManager.addTransaction(new TGenericTransaction(SERVICE_CLASS,"juneInnovationGrantReward",this.onGrantReward,[SEEN_FLAG]));
         }
         else
         {
            super.onClose(event);
         }
      }
      
      private function onEnterFrame(event:Event) : void
      {
         if(m_window.mainWindow.animation_mc.currentFrame == 120)
         {
            this.m_applyBt.visible = true;
            m_window.mainWindow.animation_mc.removeEventListener(Event.ENTER_FRAME,this.onEnterFrame);
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

