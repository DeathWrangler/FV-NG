package Widgets.Windows
{
   import Classes.Constants.ZLocConstants;
   import Classes.util.MovieClipUtils;
   import Classes.util.ZLocUtils;
   import Managers.FarmStatsManager;
   import Managers.FeatureOptionsInventoryManager;
   import Managers.TurtleInnovationManager;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.TurtleInnovationShrineFrame;
   import Widgets.TextFields.FarmTextField;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class TurtleInnovationWindow extends FarmWindowWithTutorial
   {
      
      private static const NUM_TUTORIAL_SCENES:int = 5;
      
      protected var m_featureName:String;
      
      private var m_shrineFrame:TurtleInnovationShrineFrame;
      
      private var m_r2Text:FarmTextField;
      
      private const TITLE_TF:String = "title_tf";
      
      private const NAME_TF:String = "name_tf";
      
      private const SLOTS_MC:String = "slots_mc";
      
      private const WHATISTHIS_MC:String = "whatisthis_mc";
      
      private const PREMARKETING_MC:String = "premarketing_mc";
      
      private const NPC_MC:String = "npc_mc";
      
      private const PREMARKETING_SEEN_FLAG:String = "TurtleInnovationPremarketingFlag";
      
      private const OKAY_BT:String = "okay_bt";
      
      private var m_premarketing_mc:ZwFrame;
      
      private var m_npc_mc:ZwFrame;
      
      private const TEXT_WHATISTHIS:String = "HowDoesThisWork";
      
      public function TurtleInnovationWindow(featureName:String, assetPath:String = "")
      {
         this.m_featureName = featureName;
         super(this.m_featureName,assetPath,NUM_TUTORIAL_SCENES);
      }
      
      override protected function postLoadComplete() : void
      {
         var preMarketingFeatureUserCount:int = 0;
         MovieClipUtils.recursivePlay(m_window);
         if(m_window.hasOwnProperty(this.NPC_MC))
         {
            this.m_npc_mc = addWidget(new ZwFrame(m_window[this.NPC_MC]),true) as ZwFrame;
         }
         super.postLoadComplete();
         if(m_window.hasOwnProperty(this.PREMARKETING_MC) && !Global.player.getSeenFlag(this.PREMARKETING_SEEN_FLAG))
         {
            preMarketingFeatureUserCount = FeatureOptionsInventoryManager.getInstance().getCountByName(TurtleInnovationManager.PM_FEATURE_CURRENCY_NAME);
            if(preMarketingFeatureUserCount >= TurtleInnovationManager.CONSUMABLE_REQUIRED)
            {
               this.m_premarketing_mc = addWidget(new ZwFrame(m_window[this.PREMARKETING_MC]),false) as ZwFrame;
               if(m_window[this.PREMARKETING_MC].hasOwnProperty([this.OKAY_BT]))
               {
                  this.m_premarketing_mc.addWidget(new FarmAnimatedTextButton(m_window[this.PREMARKETING_MC][this.OKAY_BT],"Awesome",this.onOkayBtnClick));
               }
            }
         }
         if(m_window.hasOwnProperty(this.TITLE_TF))
         {
            addWidget(new ZwTextField(m_window[this.TITLE_TF],"Elemental Harmony"));
         }
         if(m_window.hasOwnProperty(this.NAME_TF))
         {
            addWidget(this.m_r2Text = new FarmTextField(m_window[this.NAME_TF],"More Shrines available for Unlock on 8th May"),false);
         }
         if(m_window.hasOwnProperty(this.WHATISTHIS_MC))
         {
            addWidget(new FarmAnimatedTextButton(m_window[this.WHATISTHIS_MC],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.TEXT_WHATISTHIS),this.howDoesThisWorkClick));
         }
         if(m_window.hasOwnProperty(this.SLOTS_MC))
         {
            this.m_shrineFrame = new TurtleInnovationShrineFrame(m_window[this.SLOTS_MC],this.m_featureName);
            addWidget(this.m_shrineFrame);
         }
         if(TurtleInnovationManager.getInstance().iaAnyCollectionRedeemable())
         {
            if(m_window["bt_redeemCollection"])
            {
               m_window["bt_redeemCollection"].visible = true;
               (m_window["bt_redeemCollection"] as MovieClip).gotoAndStop(1);
               addWidget(new FarmAnimatedButton(m_window["bt_redeemCollection"],this.onRedeemClicked));
            }
         }
         else if(m_window["bt_viewCollection"])
         {
            m_window["bt_viewCollection"].visible = true;
            (m_window["bt_viewCollection"] as MovieClip).gotoAndStop(1);
            addWidget(new FarmAnimatedButton(m_window["bt_viewCollection"],this.onRedeemClicked));
         }
         if(m_window["highlightR2"])
         {
            if(TurtleInnovationManager.getInstance().isR2Unlocked())
            {
               (m_window["highlightR2"] as MovieClip).visible = true;
               this.m_r2Text.visible = false;
            }
            else
            {
               (m_window["highlightR2"] as MovieClip).visible = false;
               this.m_r2Text.visible = true;
            }
         }
      }
      
      private function onRedeemClicked(event:Event) : void
      {
         FarmStatsManager.count("tenguann_innovation_mainui","redeem_click");
         TurtleInnovationManager.getInstance().showCollectionUI();
      }
      
      private function onOkayBtnClick(event:Event) : void
      {
         this.m_premarketing_mc.visible = false;
      }
      
      override protected function showTutorial() : void
      {
         this.m_npc_mc.visible = false;
         if(this.m_premarketing_mc)
         {
            this.m_premarketing_mc.visible = false;
         }
         super.showTutorial();
      }
      
      override protected function hideTutorial() : void
      {
         (m_tutorial.element as MovieClip).stop();
         m_tutorial.visible = false;
         this.m_npc_mc.visible = true;
         if(Boolean(this.m_premarketing_mc) && !Global.player.getSeenFlag(this.PREMARKETING_SEEN_FLAG))
         {
            Global.player.setSeenFlag(this.PREMARKETING_SEEN_FLAG);
            this.m_premarketing_mc.visible = true;
            MovieClipUtils.recursivePlay(this.m_premarketing_mc.element as MovieClip);
         }
      }
      
      override protected function onTutorialOkayButtonClick(event:MouseEvent) : void
      {
         this.m_npc_mc.visible = false;
         super.onTutorialOkayButtonClick(event);
      }
      
      public function playHarvestanimation(animationMc:String, count:int) : void
      {
         var alternateDoober:String = null;
         if(animationMc)
         {
            if(count == 1)
            {
               (m_window[animationMc] as MovieClip).visible = true;
               (m_window[animationMc] as MovieClip).play();
            }
            else
            {
               alternateDoober = TurtleInnovationManager.DOOBER_ANIMATION_MAP[animationMc];
               if(m_window[alternateDoober])
               {
                  (m_window[alternateDoober] as MovieClip).visible = true;
                  (m_window[alternateDoober] as MovieClip).play();
                  (m_window[animationMc] as MovieClip).visible = true;
                  (m_window[animationMc] as MovieClip).play();
               }
            }
         }
      }
      
      override public function refreshWindow() : void
      {
         super.refreshWindow();
         this.m_shrineFrame.refresh();
      }
      
      private function howDoesThisWorkClick(event:Event) : void
      {
         this.showTutorial();
      }
      
      override protected function onClose(event:Event) : void
      {
         FarmStatsManager.count("tenguann_innovation_mainui","main_ui_close");
         close();
      }
   }
}

