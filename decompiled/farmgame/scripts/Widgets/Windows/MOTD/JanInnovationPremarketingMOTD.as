package Widgets.Windows.MOTD
{
   import Engine.Managers.TransactionManager;
   import Transactions.TGenericTransaction;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.TextFields.FarmTextField;
   import flash.events.MouseEvent;
   
   public class JanInnovationPremarketingMOTD extends GenericSingleButtonWidgetMOTD
   {
      
      public static const SERVICE_CLASS:String = "WinterPremarketingService";
      
      public static const SEEN_FLAG:String = "JanInnovationPremarketingGrantFlag";
      
      private var m_startBt:FarmAnimatedTextButton;
      
      private var m_bodyTextField:FarmTextField;
      
      private var m_body1TextField:FarmTextField;
      
      private var m_body2TextField:FarmTextField;
      
      public function JanInnovationPremarketingMOTD(displayParams:Object = null)
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
               addWidget(this.m_startBt = new FarmAnimatedTextButton(m_window.mainWindow.animation_mc["start_bt"],"Stomp, Stomp!",this.onStone0ButtonClick)) as FarmAnimatedTextButton;
               this.m_startBt.visible = true;
            }
            m_accept_bt.visible = false;
            if(m_animationMc)
            {
               m_animationMc.element.stop();
            }
            if(m_window.mainWindow.animation_mc["body_tf"])
            {
               this.m_bodyTextField = new FarmTextField(m_window.mainWindow.animation_mc.body_tf,"Ciao, Amico! Start stomping these juicy grapes to fill up the meter and see what happens!");
               addWidget(this.m_bodyTextField);
            }
            if(m_window.mainWindow.animation_mc["body1_tf"])
            {
               this.m_body1TextField = new FarmTextField(m_window.mainWindow.animation_mc.body1_tf,"Magnifico, Look at what you\'ve won!");
               addWidget(this.m_body1TextField,false);
            }
            if(m_window.mainWindow.animation_mc["body2_tf"])
            {
               this.m_body2TextField = new FarmTextField(m_window.mainWindow.animation_mc.body2_tf,"Watch out for more Romping and Stomping in The Grape Escape! starting 15th January, 2018");
               addWidget(this.m_body2TextField,false);
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
            if(Boolean(this.m_bodyTextField) && Boolean(this.m_body1TextField) && Boolean(this.m_body2TextField))
            {
               this.m_bodyTextField.visible = false;
               this.m_body1TextField.visible = true;
               this.m_body2TextField.visible = true;
            }
            Global.player.addGift("pony_tinselmaned");
            TransactionManager.addTransaction(new TGenericTransaction(SERVICE_CLASS,"janInnovationGrantReward",this.onGrantReward,[SEEN_FLAG]));
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

