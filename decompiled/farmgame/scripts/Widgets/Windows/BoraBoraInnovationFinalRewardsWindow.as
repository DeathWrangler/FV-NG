package Widgets.Windows
{
   import Managers.FarmStatsManager;
   import Managers.OrderBoard.BoraBoraInnovationManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.BoraBoraInnovationRewardsPageFrame;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class BoraBoraInnovationFinalRewardsWindow extends FarmWindowWithTutorial
   {
      
      private static const NUM_TUTORIAL_SCENES:int = 7;
      
      private static const FEATURE_NAME:String = "BoraBoraInnovation";
      
      private var m_featureName:String = null;
      
      private var m_showTutorialWithEAPage:Boolean = false;
      
      private var m_pages_frame:BoraBoraInnovationRewardsPageFrame;
      
      private var m_starcount_tf:ZwTextField;
      
      private var m_novice_mc:MovieClip;
      
      private var m_novicehitarea_mc:MovieClip;
      
      private var m_super_mc:MovieClip;
      
      private var m_superhitarea_mc:MovieClip;
      
      private var m_master_mc:MovieClip;
      
      private var m_masterhitarea_mc:MovieClip;
      
      private var m_grandMaster_mc:MovieClip;
      
      private var m_grandMasterhitarea_mc:MovieClip;
      
      private var m_decowhatIsThisBt:FarmAnimatedTextButton;
      
      private var m_tutorialMc:MovieClip;
      
      private const FLAG_FIRST_FTUESEEN:String = "bb_reward_ftue_seen";
      
      private var m_rewardLockoutMc:MovieClip;
      
      public function BoraBoraInnovationFinalRewardsWindow(featureName:String = "BoraBoraInnovation", assetUrl:String = null, showEAPageTutorial:Boolean = false)
      {
         this.m_featureName = featureName;
         this.m_showTutorialWithEAPage = showEAPageTutorial;
         var numOfTutorialPages:int = NUM_TUTORIAL_SCENES;
         super(FEATURE_NAME,assetUrl,numOfTutorialPages);
      }
      
      override protected function postLoadComplete() : void
      {
         var starcounter_mc:MovieClip = null;
         var totalStar:int = 0;
         super.postLoadComplete();
         this.visible = true;
         if(m_window.hasOwnProperty("title_tf"))
         {
            addWidget(new ZwTextField(m_window["title_tf"],"BORA BORA"));
         }
         if(m_window.hasOwnProperty("reward_set_mc"))
         {
            this.m_pages_frame = new BoraBoraInnovationRewardsPageFrame(m_window["reward_set_mc"],FEATURE_NAME);
            this.m_pages_frame.setPagination();
            this.m_pages_frame.visible = true;
         }
         if(m_window.hasOwnProperty("star_counter_mc"))
         {
            starcounter_mc = m_window["star_counter_mc"] as MovieClip;
            totalStar = this.manager.getTotalStars();
            totalStar = totalStar >= 170 ? 170 : totalStar;
            if(starcounter_mc.hasOwnProperty("star_count_tf"))
            {
               addWidget(this.m_starcount_tf = new ZwTextField(starcounter_mc["star_count_tf"],totalStar.toString()));
            }
            starcounter_mc.visible = true;
         }
         if(m_window.hasOwnProperty("consumable_novice_ani_mc"))
         {
            this.m_novice_mc = m_window["consumable_novice_ani_mc"] as MovieClip;
            this.m_novice_mc.visible = false;
         }
         if(m_window.hasOwnProperty("hitarea_novice_mc"))
         {
            this.m_novicehitarea_mc = m_window["hitarea_novice_mc"] as MovieClip;
            this.m_novicehitarea_mc.visible = true;
            this.m_novicehitarea_mc.addEventListener(MouseEvent.MOUSE_OVER,this.onNoviceMouseOver);
            this.m_novicehitarea_mc.addEventListener(MouseEvent.MOUSE_OUT,this.onNoviceMouseOut);
         }
         if(m_window.hasOwnProperty("consumable_super_ani_mc"))
         {
            this.m_super_mc = m_window["consumable_super_ani_mc"] as MovieClip;
            this.m_super_mc.visible = false;
         }
         if(m_window.hasOwnProperty("hitarea_super_mc"))
         {
            this.m_superhitarea_mc = m_window["hitarea_super_mc"] as MovieClip;
            this.m_superhitarea_mc.visible = true;
            this.m_superhitarea_mc.addEventListener(MouseEvent.MOUSE_OVER,this.onExpertMouseOver);
            this.m_superhitarea_mc.addEventListener(MouseEvent.MOUSE_OUT,this.onExpertMouseOut);
         }
         if(m_window.hasOwnProperty("consumable_master_ani_mc"))
         {
            this.m_master_mc = m_window["consumable_master_ani_mc"] as MovieClip;
            this.m_master_mc.visible = false;
         }
         if(m_window.hasOwnProperty("hitarea_master_mc"))
         {
            this.m_masterhitarea_mc = m_window["hitarea_master_mc"] as MovieClip;
            this.m_masterhitarea_mc.visible = true;
            this.m_masterhitarea_mc.addEventListener(MouseEvent.MOUSE_OVER,this.onMasterMouseOver);
            this.m_masterhitarea_mc.addEventListener(MouseEvent.MOUSE_OUT,this.onMasterMouseOut);
         }
         if(m_window.hasOwnProperty("consumable_expert_ani_mc"))
         {
            this.m_grandMaster_mc = m_window["consumable_expert_ani_mc"] as MovieClip;
            this.m_grandMaster_mc.visible = false;
         }
         if(m_window.hasOwnProperty("hitarea_expert_mc"))
         {
            this.m_grandMasterhitarea_mc = m_window["hitarea_expert_mc"] as MovieClip;
            this.m_grandMasterhitarea_mc.visible = true;
            this.m_grandMasterhitarea_mc.addEventListener(MouseEvent.MOUSE_OVER,this.onGrandMasterMouseOver);
            this.m_grandMasterhitarea_mc.addEventListener(MouseEvent.MOUSE_OUT,this.onGrandMasterMouseOut);
         }
         if(m_window.hasOwnProperty("decohowDoesThisWork_mc"))
         {
            addWidget(this.m_decowhatIsThisBt = new FarmAnimatedTextButton(m_window["decohowDoesThisWork_mc"],"",this.onDecoHowDoesThisWorkClick));
            this.m_decowhatIsThisBt.visible = true;
         }
         if(m_window.hasOwnProperty("reward_lockout_mc"))
         {
            this.m_rewardLockoutMc = m_window["reward_lockout_mc"] as MovieClip;
            this.m_rewardLockoutMc.visible = false;
         }
         if(m_window.hasOwnProperty("tutorial_mc"))
         {
            this.m_tutorialMc = m_window["tutorial_mc"] as MovieClip;
            this.m_tutorialMc.visible = false;
            if(this.m_tutorialMc.hasOwnProperty("okay_0_bt"))
            {
               addWidget(new FarmAnimatedTextButton(this.m_tutorialMc["okay_0_bt"],"Okay!",this.onFtueClose));
            }
         }
         if(!Global.player.getSeenFlag(this.FLAG_FIRST_FTUESEEN))
         {
            Global.player.setSeenFlag(this.FLAG_FIRST_FTUESEEN);
            if(this.m_tutorialMc)
            {
               this.m_tutorialMc.visible = true;
            }
         }
      }
      
      private function onDecoHowDoesThisWorkClick(event:Event) : void
      {
         if(this.m_tutorialMc)
         {
            this.m_tutorialMc.visible = true;
            FarmStatsManager.count(FEATURE_NAME,"FTUE","START");
         }
      }
      
      private function onFtueClose(e:Event = null) : void
      {
         if(this.m_tutorialMc)
         {
            this.m_tutorialMc.visible = false;
         }
      }
      
      private function onNoviceMouseOver(e:Event = null) : void
      {
         if(this.m_novice_mc)
         {
            this.m_novice_mc.visible = true;
         }
      }
      
      private function onNoviceMouseOut(e:Event = null) : void
      {
         if(this.m_novice_mc)
         {
            this.m_novice_mc.visible = false;
         }
      }
      
      private function onExpertMouseOver(e:Event = null) : void
      {
         if(this.m_super_mc)
         {
            this.m_super_mc.visible = true;
         }
      }
      
      private function onExpertMouseOut(e:Event = null) : void
      {
         if(this.m_super_mc)
         {
            this.m_super_mc.visible = false;
         }
      }
      
      private function onMasterMouseOver(e:Event = null) : void
      {
         if(this.m_master_mc)
         {
            this.m_master_mc.visible = true;
         }
      }
      
      private function onMasterMouseOut(e:Event = null) : void
      {
         if(this.m_master_mc)
         {
            this.m_master_mc.visible = false;
         }
      }
      
      private function onGrandMasterMouseOver(e:Event = null) : void
      {
         if(this.m_grandMaster_mc)
         {
            this.m_grandMaster_mc.visible = true;
         }
      }
      
      private function onGrandMasterMouseOut(e:Event = null) : void
      {
         if(this.m_grandMaster_mc)
         {
            this.m_grandMaster_mc.visible = false;
         }
      }
      
      private function get manager() : BoraBoraInnovationManager
      {
         return BoraBoraInnovationManager.getInstance(FEATURE_NAME);
      }
      
      override public function close() : void
      {
         if(this.manager.mainWindow)
         {
            this.manager.mainWindow.untintWindow();
            this.manager.mainWindow.enableInput = true;
         }
         super.close();
         FarmStatsManager.count("BoraBoraInnovationFinalRewardsWindow","Rewards_UI","close_window");
      }
   }
}

