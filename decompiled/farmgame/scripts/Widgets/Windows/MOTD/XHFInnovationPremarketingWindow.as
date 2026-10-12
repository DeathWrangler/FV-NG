package Widgets.Windows.MOTD
{
   import Classes.util.MovieClipUtils;
   import Engine.Managers.TransactionManager;
   import Transactions.TGenericTransaction;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwBaseWidget;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.TextFields.ZwTextField;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   
   public class XHFInnovationPremarketingWindow extends GenericSingleButtonWidgetMOTD
   {
      
      public static const SERVICE_CLASS:String = "HalloweenInnovation2019PremarketingService";
      
      public static const REWARD_GRANTED_FLAG:String = "HalloweenInnovation2019PremarketingGrantFlag";
      
      public static const HELP_FLAG:String = "XHF_HelpFlag";
      
      private static const ITEM_NAME:String = "consume_instagrow";
      
      private static const ITEM_QTY:int = 2;
      
      private var m_title_tf:ZwTextField;
      
      private var m_body_tf:ZwTextField;
      
      private var m_body2_tf:ZwTextField;
      
      private var m_sizeMc:ZwWidget;
      
      private var m_set:int = 0;
      
      private var select0_mc:MovieClip;
      
      private var select1_mc:MovieClip;
      
      private var select2_mc:MovieClip;
      
      private var select3_mc:MovieClip;
      
      private var slots_mc:MovieClip;
      
      private var m_selectBt:FarmAnimatedTextButton;
      
      private var m_Timer:Timer;
      
      public function XHFInnovationPremarketingWindow(displayParams:Object = null)
      {
         super(displayParams);
      }
      
      override protected function postLoadComplete() : void
      {
         MovieClipUtils.recursivePlay(m_window);
         if(m_window.hasOwnProperty("mainWindow"))
         {
            addWidget(new ZwBaseWidget(m_window.mainWindow));
            if(m_window.mainWindow["title_tf"])
            {
               this.m_title_tf = addWidget(new ZwTextField(m_window.mainWindow["title_tf"])) as ZwTextField;
               this.m_title_tf.visible = true;
            }
            if(m_window.mainWindow["body_tf"])
            {
               this.m_body_tf = addWidget(new ZwTextField(m_window.mainWindow["body_tf"])) as ZwTextField;
               this.m_body_tf.visible = true;
            }
            if(m_window.mainWindow["animation_mc"])
            {
               m_animationMc = addWidget(new ZwWidget(m_window.mainWindow.animation_mc),true) as ZwWidget;
               m_animationMc.element.play();
            }
            if(m_window.mainWindow["animation_two_mc"])
            {
               m_animationTwoMc = addWidget(new ZwWidget(m_window.mainWindow.animation_two_mc),true) as ZwWidget;
               m_animationTwoMc.element.stop();
            }
            if(m_window.mainWindow["accept_bt"])
            {
               m_accept_bt = addWidget(new FarmAnimatedTextButton(m_window.mainWindow.accept_bt,"Sure, Lets Candy!!",this.onAccept)) as FarmAnimatedTextButton;
               m_accept_bt.visible = true;
               m_accept_bt.enabled = false;
            }
         }
         if(m_window.hasOwnProperty("size_mc"))
         {
            this.m_sizeMc = addWidget(new ZwWidget(m_window.size_mc),true) as ZwWidget;
         }
         this.startTimer();
      }
      
      private function startTimer() : void
      {
         this.m_Timer = new Timer(4000);
         this.m_Timer.addEventListener(TimerEvent.TIMER,this.onWaitTimer);
         this.m_Timer.start();
      }
      
      private function onWaitTimer(event:TimerEvent) : void
      {
         m_accept_bt.enabled = true;
      }
      
      private function onGrantReward(result:Object) : void
      {
         if(result.success)
         {
            Global.player.addGift(ITEM_NAME,"0",ITEM_QTY);
            Global.player.setSeenFlag(REWARD_GRANTED_FLAG);
         }
      }
      
      private function grantReward() : void
      {
         if(!Global.player.getSeenFlag(REWARD_GRANTED_FLAG))
         {
            TransactionManager.addTransaction(new TGenericTransaction(SERVICE_CLASS,"grantReward",this.onGrantReward));
         }
      }
      
      override protected function onAccept(event:MouseEvent) : void
      {
         if(!Global.player.getSeenFlag(HELP_FLAG))
         {
            Global.player.setSeenFlag(HELP_FLAG);
            this.grantReward();
         }
         if(m_accept_bt.text != "Awesome")
         {
            m_accept_bt.text = "Awesome";
            m_animationMc.visible = false;
            m_animationTwoMc.visible = true;
            (m_animationTwoMc.element as MovieClip).play();
         }
         else
         {
            super.close();
         }
      }
   }
}

