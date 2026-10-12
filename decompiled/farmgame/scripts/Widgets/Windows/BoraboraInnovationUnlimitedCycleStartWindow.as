package Widgets.Windows
{
   import Classes.ZItem.FarmItem;
   import Managers.OrderBoard.BoraBoraInnovationManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class BoraboraInnovationUnlimitedCycleStartWindow extends FarmWindow
   {
      
      private static const OFFSET_OPF_Y:int = -30;
      
      protected var m_featureName:String = null;
      
      private var m_reward:FarmItem = null;
      
      private var m_callback:Function = null;
      
      protected var m_title_tf:ZwTextField = null;
      
      private var m_subtitle1_tf:ZwTextField;
      
      private var m_subtitle2_tf:ZwTextField;
      
      private var m_rewardicon:FarmIcon;
      
      private var m_isMilestone:Boolean;
      
      private var m_awesome_bt:FarmAnimatedTextButton;
      
      private var m_reward_frame:MovieClip;
      
      private var m_finalRewardMc:MovieClip;
      
      private var m_cycleRepearMC:MovieClip;
      
      private var m_speechMc:MovieClip;
      
      public function BoraboraInnovationUnlimitedCycleStartWindow(featureName:String, dialogAsset:String)
      {
         super(dialogAsset,true,true);
         this.m_featureName = featureName;
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         if(m_window.hasOwnProperty("cycle_repeat_mc"))
         {
            this.m_cycleRepearMC = m_window["cycle_repeat_mc"] as MovieClip;
            this.m_cycleRepearMC.visible = true;
            if(this.m_cycleRepearMC.hasOwnProperty("okay_bt"))
            {
               addWidget(this.m_awesome_bt = new FarmAnimatedTextButton(this.m_cycleRepearMC["okay_bt"],"Okay!",this.onOkayBtClick));
               this.m_awesome_bt.visible = true;
            }
            if(this.m_cycleRepearMC.hasOwnProperty("speechbuble_mc"))
            {
               this.m_speechMc = this.m_cycleRepearMC["speechbuble_mc"] as MovieClip;
               this.m_speechMc.visible;
            }
            if(this.m_cycleRepearMC.hasOwnProperty("subheader_tf"))
            {
               addWidget(new ZwTextField(this.m_cycleRepearMC["subheader_tf"],"Continue planning wedding in these themes to win all the Star Milestone and Best Bonus Rewards !"));
            }
         }
      }
      
      private function onOkayBtClick(e:Event = null) : void
      {
         super.close();
         if(this.manager.mainWindow)
         {
            this.manager.mainWindow.untintWindow();
            this.manager.mainWindow.enableInput = true;
            this.manager.showScreenShotWindow();
         }
      }
      
      private function get manager() : BoraBoraInnovationManager
      {
         return BoraBoraInnovationManager.getInstance(this.m_featureName);
      }
   }
}

