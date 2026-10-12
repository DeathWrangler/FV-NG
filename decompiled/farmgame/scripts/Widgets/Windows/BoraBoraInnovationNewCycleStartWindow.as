package Widgets.Windows
{
   import Managers.OrderBoard.BoraBoraInnovationManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class BoraBoraInnovationNewCycleStartWindow extends FarmWindow
   {
      
      private var m_cycleStartMc:MovieClip;
      
      private var m_streakMc:MovieClip;
      
      private var m_okatBt:FarmAnimatedTextButton;
      
      private var m_featureName:String;
      
      private const BORABORAINNOVATION_CYCLE_START_FLAG:String = "bbi_cycle_start";
      
      private var m_npcIcon:FarmIcon;
      
      private var m_streak_mc:MovieClip;
      
      private var m_titleTf:ZwTextField;
      
      private var m_npc_dialog_tf:ZwTextField;
      
      private var m_deco_mc:MovieClip;
      
      public function BoraBoraInnovationNewCycleStartWindow(featureName:String, windowAssetRelUrl:String)
      {
         this.m_featureName = featureName;
         super(windowAssetRelUrl);
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         this.visible = true;
         if(m_window.hasOwnProperty("cyclestart_mc"))
         {
            this.m_cycleStartMc = m_window["cyclestart_mc"] as MovieClip;
            this.m_cycleStartMc.visible = true;
            if(this.m_cycleStartMc.hasOwnProperty("deco_mc"))
            {
               this.m_deco_mc = this.m_cycleStartMc["deco_mc"] as MovieClip;
            }
            if(this.m_cycleStartMc.hasOwnProperty("title_tf"))
            {
               addWidget(this.m_titleTf = new ZwTextField(this.m_cycleStartMc["title_tf"],""));
               if(!Global.player.getSeenFlag("bb_npc_names_tutorial"))
               {
                  Global.player.setSeenFlag("bb_npc_names_tutorial");
                  this.m_titleTf.text = this.manager.getCycleNPCNames() + "\'s Wedding";
                  this.m_deco_mc.visible = false;
               }
               else
               {
                  this.m_titleTf.text = this.manager.getCycleNPCNames(true) + "\'s Wedding";
                  this.m_deco_mc.visible = true;
               }
            }
            if(this.m_cycleStartMc.hasOwnProperty("npc_dialog_tf"))
            {
               addWidget(this.m_npc_dialog_tf = new ZwTextField(this.m_cycleStartMc["npc_dialog_tf"],""));
               if(!Global.player.getSeenFlag("bb_cycle_subtext_tutorial"))
               {
                  Global.player.setSeenFlag("bb_cycle_subtext_tutorial");
                  this.m_npc_dialog_tf.text = this.manager.getCycleStartSubtext();
               }
               else
               {
                  this.m_npc_dialog_tf.text = this.manager.getCycleStartSubtext(true);
               }
            }
            if(this.m_cycleStartMc.hasOwnProperty("subheader_tf"))
            {
               addWidget(new ZwTextField(this.m_cycleStartMc["subheader_tf"],"Collect all the stars for the wedding and get 1 additional star as a bonus."));
            }
            if(this.m_cycleStartMc.hasOwnProperty("okay_bt"))
            {
               addWidget(this.m_okatBt = new FarmAnimatedTextButton(this.m_cycleStartMc["okay_bt"],"Okay!",this.onOkayClick));
            }
            if(this.m_cycleStartMc.hasOwnProperty("npc_icon_mc"))
            {
               addWidget(this.m_npcIcon = new FarmIcon(this.m_cycleStartMc["npc_icon_mc"]));
               this.m_npcIcon.loadIcon(this.manager.getCycleStartNPCImage());
               this.m_npcIcon.setIconSize(120,120);
               this.m_npcIcon.visible = true;
            }
            if(this.m_cycleStartMc.hasOwnProperty("streak_mc"))
            {
               this.m_streak_mc = this.m_cycleStartMc["streak_mc"] as MovieClip;
               this.m_streak_mc.visible = true;
            }
         }
      }
      
      private function onOkayClick(e:Event = null) : void
      {
         this.close();
      }
      
      override public function close() : void
      {
         if(this.manager.mainWindow)
         {
            this.manager.mainWindow.untintWindow();
            this.manager.mainWindow.enableInput = true;
            if(!Global.player.getSeenFlag(this.BORABORAINNOVATION_CYCLE_START_FLAG))
            {
               Global.player.setSeenFlag(this.BORABORAINNOVATION_CYCLE_START_FLAG);
               this.manager.mainWindow.showTutorial1();
            }
            else
            {
               this.manager.newCycleStartActions();
            }
         }
         super.close();
      }
      
      private function get manager() : BoraBoraInnovationManager
      {
         return BoraBoraInnovationManager.getInstance(this.m_featureName);
      }
   }
}

