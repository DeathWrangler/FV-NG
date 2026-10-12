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
   
   public class XIDInnovationPremarketingWindow extends GenericSingleButtonWidgetMOTD
   {
      
      public static const SERVICE_CLASS:String = "IrelandInnovationPremarketingService";
      
      public static const REWARD_GRANTED_FLAG:String = "IrelandInnovationPremarketing_GrantFlag";
      
      public static const HELP_FLAG:String = "XID_HelpFlag";
      
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
      
      public function XIDInnovationPremarketingWindow(displayParams:Object = null)
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
               this.m_title_tf = addWidget(new ZwTextField(m_window.mainWindow["title_tf"],"Goodwill Shire!")) as ZwTextField;
               this.m_title_tf.visible = true;
            }
            if(m_window.mainWindow["body_tf"])
            {
               this.m_body_tf = addWidget(new ZwTextField(m_window.mainWindow["body_tf"],"Help townsfolk and rise up in power to rule the Kingdom!")) as ZwTextField;
               this.m_body_tf.visible = true;
            }
            if(m_window.mainWindow["animation_mc"])
            {
               m_animationMc = addWidget(new ZwWidget(m_window.mainWindow.animation_mc),true) as ZwWidget;
               m_animationMc.element.stop();
            }
            if(m_window.mainWindow["accept_bt"])
            {
               m_accept_bt = addWidget(new FarmAnimatedTextButton(m_window.mainWindow.accept_bt,"Help!",this.onAccept)) as FarmAnimatedTextButton;
               m_accept_bt.visible = true;
            }
         }
         if(m_window.hasOwnProperty("size_mc"))
         {
            this.m_sizeMc = addWidget(new ZwWidget(m_window.size_mc),true) as ZwWidget;
         }
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
            m_accept_bt.text = "Awesome";
            (m_animationMc.element as MovieClip).gotoAndStop(60);
            Global.player.setSeenFlag(HELP_FLAG);
            this.grantReward();
         }
         else
         {
            super.close();
         }
      }
   }
}

