package Widgets.Windows
{
   import Managers.AntiqueMuseumV2Manager;
   import Managers.FarmStatsManager;
   import Managers.FeatureOptionsInventoryManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.AntiqueMuseumV2CollectionsFrame;
   import Widgets.Frames.XMASInnovationGiftFrame;
   import Widgets.Icons.FarmIcon;
   import Widgets.Tooltips.FarmTextTooltip;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.utils.Timer;
   
   public class AntiqueMuseumV2CollectionWindow extends FarmWindowWithTutorial
   {
      
      private static const NUM_TUTORIAL_SCENES:int = 2;
      
      private static const FEATURE_NAME:String = "AntiqueMuseumV2";
      
      private static const TIMER_DELAY_MS:int = 1000;
      
      private const TITLE_TF:String = "title_tf";
      
      private const BODY_TF:String = "body_tf";
      
      private const BACK_MC:String = "back_mc";
      
      private const COUNT1_TF:String = "count1_tf";
      
      private const SLOTS_MC:String = "slots_mc";
      
      private const COLLECTION_MC:Array = ["collection0_mc","collection1_mc","collection2_mc"];
      
      private var m_tutorial_mc:MovieClip;
      
      private var m_tutorial_frame:ZwFrame;
      
      private const ANTIQUE_MUSEUM_COLLECTION_FTUE_SEEN:String = "antique_museum_v2_collect_ftue_seen";
      
      private var m_plots:XMASInnovationGiftFrame;
      
      private var m_collectionsFrame:AntiqueMuseumV2CollectionsFrame;
      
      private var m_featureName:String = null;
      
      private var m_travel_bt:FarmAnimatedTextButton;
      
      private var m_rewardPanel_mc:MovieClip;
      
      private var m_rewardPack_mc:MovieClip;
      
      private var m_reward0_mc:MovieClip;
      
      private var m_reward1_mc:MovieClip;
      
      private var m_reward2_mc:MovieClip;
      
      private var m_reward3_mc:MovieClip;
      
      private var m_checkmark0_mc:MovieClip;
      
      private var m_checkmark1_mc:MovieClip;
      
      private var m_checkmark2_mc:MovieClip;
      
      private var m_checkmark3_mc:MovieClip;
      
      private var m_reward_tf:ZwTextField;
      
      private var m_mainWindow:AntiqueMuseumV2MainWindow;
      
      private var m_timer:Timer;
      
      public function AntiqueMuseumV2CollectionWindow(featureName:String, assetPath:String = "")
      {
         this.m_featureName = featureName;
         var numOfTutorialPages:int = NUM_TUTORIAL_SCENES;
         super(featureName,assetPath,numOfTutorialPages);
      }
      
      override protected function postLoadComplete() : void
      {
         var m_bonus0MCtooltip:FarmIcon = null;
         var m_bonus1MCtooltip:FarmIcon = null;
         var m_bonus2MCtooltip:FarmIcon = null;
         var m_bonus3MCtooltip:FarmIcon = null;
         super.postLoadComplete();
         this.populateConsumables();
         if(m_window.hasOwnProperty(this.TITLE_TF))
         {
            m_window[this.TITLE_TF].visible = true;
            m_window[this.TITLE_TF].text = "FOSSIL COLLECTIONS";
         }
         if(m_window.hasOwnProperty("body_tf"))
         {
            m_window["body_tf"].visible = true;
            m_window["body_tf"].text = "Complete a fossil to place it on your farm";
         }
         if(m_window.hasOwnProperty(this.BACK_MC))
         {
            m_window[this.BACK_MC].visible = true;
         }
         if(m_window.hasOwnProperty("collections_mc"))
         {
            this.m_collectionsFrame = new AntiqueMuseumV2CollectionsFrame(m_window["collections_mc"],this,this.m_featureName);
            this.m_collectionsFrame.visible = true;
         }
         if(m_window.hasOwnProperty("travel_bt"))
         {
            this.m_travel_bt = new FarmAnimatedTextButton(m_window["travel_bt"],"Sure!",this.onClickBack);
            if(this.manager.isFeatureCompleted())
            {
               this.m_travel_bt.text = "Okay";
            }
            this.m_travel_bt.visible = true;
            this.m_travel_bt.enabled = true;
         }
         if(m_window.hasOwnProperty("tutorial1_mc"))
         {
            this.m_tutorial_mc = m_window["tutorial1_mc"] as MovieClip;
            this.m_tutorial_frame = addWidget(new ZwFrame(this.m_tutorial_mc),false) as ZwFrame;
            if(this.m_tutorial_mc.hasOwnProperty("okay1_bt"))
            {
               this.m_tutorial_frame.addWidget(new FarmAnimatedTextButton(this.m_tutorial_mc["okay1_bt"],"Great!",this.howDoesThisWorkFrameSwitch));
               this.m_tutorial_mc["okay1_bt"].visible = true;
            }
            this.m_tutorial_mc.visible = false;
         }
         if(m_window.hasOwnProperty("reward_pack"))
         {
            this.m_rewardPack_mc = m_window.reward_pack as MovieClip;
            this.m_rewardPack_mc.visible = true;
         }
         if(m_window.hasOwnProperty("reward_panel"))
         {
            this.m_rewardPanel_mc = m_window.reward_panel as MovieClip;
            this.m_rewardPanel_mc.visible = true;
            if(this.m_rewardPanel_mc.hasOwnProperty("checkmark_0_mc"))
            {
               this.m_checkmark0_mc = this.m_rewardPanel_mc.checkmark_0_mc as MovieClip;
               this.m_checkmark0_mc.visible = this.manager.isMilestoneAchieved(0);
            }
            if(this.m_rewardPanel_mc.hasOwnProperty("checkmark_1_mc"))
            {
               this.m_checkmark1_mc = this.m_rewardPanel_mc.checkmark_1_mc as MovieClip;
               this.m_checkmark1_mc.visible = this.manager.isMilestoneAchieved(1);
            }
            if(this.m_rewardPanel_mc.hasOwnProperty("checkmark_2_mc"))
            {
               this.m_checkmark2_mc = this.m_rewardPanel_mc.checkmark_2_mc as MovieClip;
               this.m_checkmark2_mc.visible = this.manager.isMilestoneAchieved(2);
            }
            if(this.m_rewardPanel_mc.hasOwnProperty("checkmark_3_mc"))
            {
               this.m_checkmark3_mc = this.m_rewardPanel_mc.checkmark_3_mc as MovieClip;
               this.m_checkmark3_mc.visible = this.manager.isMilestoneAchieved(3);
            }
            if(this.m_rewardPanel_mc.hasOwnProperty("reward_0"))
            {
               this.m_reward0_mc = this.m_rewardPanel_mc.reward_0 as MovieClip;
               this.m_reward0_mc.visible = true;
               m_bonus0MCtooltip = new FarmIcon(this.m_reward0_mc);
               m_bonus0MCtooltip.attachTooltip(new FarmTextTooltip("Complete 1 fossil to win a Blue Jacket Unicorn."));
            }
            if(this.m_rewardPanel_mc.hasOwnProperty("reward_1"))
            {
               this.m_reward1_mc = this.m_rewardPanel_mc.reward_1 as MovieClip;
               this.m_reward1_mc.visible = true;
               m_bonus1MCtooltip = new FarmIcon(this.m_reward1_mc);
               m_bonus1MCtooltip.attachTooltip(new FarmTextTooltip("Complete 3 fossil to win a Canadian Maple Pegasus."));
            }
            if(this.m_rewardPanel_mc.hasOwnProperty("reward_2"))
            {
               this.m_reward2_mc = this.m_rewardPanel_mc.reward_2 as MovieClip;
               this.m_reward2_mc.visible = true;
               m_bonus2MCtooltip = new FarmIcon(this.m_reward2_mc);
               m_bonus2MCtooltip.attachTooltip(new FarmTextTooltip("Complete 6 fossil to win a Traditional Canadian Pegacorn."));
            }
            if(this.m_rewardPanel_mc.hasOwnProperty("reward_3"))
            {
               this.m_reward3_mc = this.m_rewardPanel_mc.reward_3 as MovieClip;
               this.m_reward3_mc.visible = true;
               m_bonus3MCtooltip = new FarmIcon(this.m_reward3_mc);
               m_bonus3MCtooltip.attachTooltip(new FarmTextTooltip("Complete 9 fossil to win a Natural History Museum."));
            }
            if(this.m_rewardPanel_mc.hasOwnProperty("rewards_tf"))
            {
               this.m_reward_tf = new ZwTextField(this.m_rewardPanel_mc.rewards_tf,"Rewards");
               this.m_reward_tf.visible = true;
            }
         }
         if(m_window.hasOwnProperty(this.BODY_TF))
         {
            m_window[this.BODY_TF].visible = true;
            if(this.manager.isFeatureCompleted())
            {
               m_window[this.BODY_TF].text = "Congrats! Your fossils are now complete";
            }
            else
            {
               m_window[this.BODY_TF].text = "Complete a fossil to place it on your farm!";
            }
         }
         if(!this.manager.isFeatureCompleted())
         {
            if(!Global.player.getSeenFlag(this.ANTIQUE_MUSEUM_COLLECTION_FTUE_SEEN))
            {
               Global.player.setSeenFlag(this.ANTIQUE_MUSEUM_COLLECTION_FTUE_SEEN);
               this.howDoesThisWorkClick(null);
            }
         }
      }
      
      private function howDoesThisWorkClick(event:Event) : void
      {
         if(this.m_tutorial_frame)
         {
            (this.m_tutorial_frame.element as MovieClip).gotoAndStop(1);
            this.m_tutorial_frame.visible = true;
            FarmStatsManager.count(AntiqueMuseumV2Manager.FEATURE_NAME,"FTUE_Collection","START");
         }
      }
      
      public function onClickBack(e:Event) : void
      {
         this.close();
      }
      
      override public function refreshWindow() : void
      {
      }
      
      private function populateConsumables() : void
      {
         var featureOptInvObject:FeatureOptionsInventoryManager = FeatureOptionsInventoryManager.getInstance();
      }
      
      override protected function onTutorialOkayButtonClick(event:MouseEvent) : void
      {
         if(tutorialSceneNumber < totalScenes && Boolean(this.m_tutorial_frame))
         {
            ++tutorialSceneNumber;
            preSwitchChanges(tutorialSceneNumber);
            (this.m_tutorial_frame.element as MovieClip).gotoAndStop(tutorialSceneNumber);
         }
         else
         {
            this.m_tutorial_mc.visible = false;
         }
      }
      
      private function howDoesThisWorkFrameSwitch(event:Event = null) : void
      {
         var totalFrames:int = int(this.m_tutorial_frame.element.totalFrames);
         var currentFrame:int = int(this.m_tutorial_frame.element.currentFrame);
         if(currentFrame + 1 <= totalFrames)
         {
            (this.m_tutorial_frame.element as MovieClip).gotoAndStop(currentFrame + 1);
         }
         else
         {
            this.m_tutorial_frame.visible = false;
         }
      }
      
      private function get manager() : AntiqueMuseumV2Manager
      {
         return AntiqueMuseumV2Manager.getInstance(FEATURE_NAME);
      }
      
      override public function close() : void
      {
         if(this.manager.m_mainWindow)
         {
            this.manager.m_mainWindow.untintWindow();
            this.manager.m_mainWindow.enableInput = true;
         }
         if(this.m_timer)
         {
            this.m_timer.stop();
            this.m_timer = null;
         }
         super.close();
      }
   }
}

