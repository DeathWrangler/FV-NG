package Widgets.Windows
{
   import Classes.Constants.WorldsConstants;
   import Classes.Constants.ZLocConstants;
   import Classes.util.MovieClipUtils;
   import Classes.util.ZLocUtils;
   import Managers.FarmStatsManager;
   import Managers.TurtleInnovationManager;
   import Managers.WorldSeasonsManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.TurtleInnovationGiftFrame;
   import Widgets.Tooltips.FarmTextTooltip;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class TurtleInnovationCollectionWindow extends FarmWindowWithTutorial
   {
      
      private static const TIMER_DELAY_MS:int = 1000;
      
      private const TITLE_TF:String = "title_tf";
      
      private const BODY_TF:String = "body_tf";
      
      private const BACK_MC:String = "back_mc";
      
      private const COUNT1_TF:String = "count1_tf";
      
      private const SLOTS_MC:String = "slots_mc";
      
      private const WHATISTHIS_MC:String = "whatisthis_mc";
      
      private const REGION1_BONUS:String = "regionBonus1";
      
      private const REGION2_BONUS:String = "regionBonus2";
      
      private const HIGHLIGHT_R2:String = "highlightR2";
      
      private const TEXT_WHATISTHIS:String = "HowDoesThisWork";
      
      private const COLLECTION_MC:Array = ["collection0_mc","collection1_mc","collection2_mc"];
      
      private const TURTLE_EA_TUT_SEEN_FLAG:String = "TurtleEATutSeenFlag";
      
      private const TEXT_TITLE:String = "_ChristmasUIWindow_Title";
      
      private var m_collectionFrame:TurtleInnovationGiftFrame;
      
      private var m_featureName:String = null;
      
      private var m_featureNameForCollectionTut:String = this.m_featureName + "_CollectionTut";
      
      private var m_numTutScenes:int = 3;
      
      private var m_r2Highlight:ZwWidget;
      
      private var m_regionBonus1:ZwFrame;
      
      private var m_bonus1CheckMark:ZwWidget;
      
      private var m_regionBonus2:ZwFrame;
      
      private var m_bonus2CheckMark:ZwWidget;
      
      private var m_turtleInnovationManager:TurtleInnovationManager = TurtleInnovationManager.getInstance();
      
      public function TurtleInnovationCollectionWindow(featureName:String, assetPath:String = "")
      {
         this.m_featureName = featureName;
         if(WorldSeasonsManager.getInstance().isEAUser(WorldsConstants.WORLD_ID_TURTLEISLAND) && !Global.player.getSeenFlag(this.TURTLE_EA_TUT_SEEN_FLAG))
         {
            Global.player.setSeenFlag(this.TURTLE_EA_TUT_SEEN_FLAG);
            this.m_numTutScenes = 4;
            this.m_turtleInnovationManager.grantEARewards();
         }
         super(this.m_featureNameForCollectionTut,assetPath,this.m_numTutScenes,true,true);
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         if(m_window.hasOwnProperty(this.TITLE_TF))
         {
            m_window[this.TITLE_TF].visible = true;
            m_window[this.TITLE_TF].text = "Elemental Collections";
         }
         if(m_window.hasOwnProperty("body_tf"))
         {
            m_window["body_tf"].visible = true;
            m_window["body_tf"].text = "Use Elemental Stones to finish your Collections!";
         }
         if(m_window.hasOwnProperty(this.SLOTS_MC))
         {
            this.m_collectionFrame = new TurtleInnovationGiftFrame(m_window[this.SLOTS_MC],this.m_featureName,this);
            this.m_collectionFrame.visible = true;
            addWidget(this.m_collectionFrame,true);
         }
         if(m_window.hasOwnProperty(this.WHATISTHIS_MC))
         {
            addWidget(new FarmAnimatedTextButton(m_window[this.WHATISTHIS_MC],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.TEXT_WHATISTHIS),this.howDoesThisWorkClick));
         }
         if(m_window.hasOwnProperty(this.HIGHLIGHT_R2))
         {
            addWidget(this.m_r2Highlight = new ZwWidget(m_window[this.HIGHLIGHT_R2]));
         }
         if(m_window.hasOwnProperty(this.REGION1_BONUS))
         {
            addWidget(this.m_regionBonus1 = new ZwFrame(m_window[this.REGION1_BONUS]));
            if(Boolean(m_window[this.REGION1_BONUS].hasOwnProperty("name_tf")) && Boolean(m_window[this.REGION1_BONUS].hasOwnProperty("checkmark_mc")))
            {
               this.m_regionBonus1.addWidget(new ZwTextField(m_window[this.REGION1_BONUS]["name_tf"],"Elemental Shard Pegacorn"));
               this.m_regionBonus1.addWidget(this.m_bonus1CheckMark = new ZwWidget(m_window[this.REGION1_BONUS]["checkmark_mc"]),false);
            }
            this.m_regionBonus1.attachTooltip(new FarmTextTooltip("Finish the Fire, Water, Earth, Air, Lava and Storm Collections to win the Elemental Shard Pegacorn."));
            MovieClipUtils.recursivePlay(this.m_regionBonus1.element as MovieClip);
            if(this.m_turtleInnovationManager.isR2Unlocked())
            {
               this.m_regionBonus1.visible = false;
            }
         }
         if(m_window.hasOwnProperty(this.REGION2_BONUS))
         {
            addWidget(this.m_regionBonus2 = new ZwFrame(m_window[this.REGION2_BONUS]));
            if(Boolean(m_window[this.REGION2_BONUS].hasOwnProperty("name_tf")) && Boolean(m_window[this.REGION2_BONUS].hasOwnProperty("checkmark_mc")))
            {
               this.m_regionBonus2.addWidget(new ZwTextField(m_window[this.REGION2_BONUS]["name_tf"],"Elemental Balance Pegacorn"));
               this.m_regionBonus2.addWidget(this.m_bonus2CheckMark = new ZwWidget(m_window[this.REGION2_BONUS]["checkmark_mc"]) as ZwWidget,false);
            }
            this.m_regionBonus2.attachTooltip(new FarmTextTooltip("Finish the Yin and Yang Collections to win the Elemental Balance Pegacorn."));
            if(!this.m_turtleInnovationManager.isR2Unlocked())
            {
               this.m_regionBonus2.visible = false;
            }
         }
         if(!this.m_turtleInnovationManager.isR2Unlocked())
         {
            this.m_r2Highlight.visible = false;
            this.m_regionBonus2.visible = false;
         }
         else
         {
            MovieClipUtils.recursivePlay(this.m_regionBonus2.element as MovieClip);
         }
         if(Boolean(this.m_bonus1CheckMark) && this.m_turtleInnovationManager.isBonusRedeemedForRegion(1))
         {
            this.m_bonus1CheckMark.visible = true;
         }
         if(Boolean(this.m_bonus2CheckMark) && this.m_turtleInnovationManager.isBonusRedeemedForRegion(2))
         {
            this.m_bonus2CheckMark.visible = true;
         }
      }
      
      override public function refreshWindow() : void
      {
         super.refreshWindow();
         if(this.m_collectionFrame)
         {
            this.m_collectionFrame.refresh();
         }
      }
      
      public function showR2Highlight() : void
      {
         if(TurtleInnovationManager.getInstance().isR2Unlocked())
         {
            this.m_r2Highlight.visible = true;
            this.m_regionBonus2.visible = true;
            this.m_regionBonus1.visible = false;
            MovieClipUtils.recursivePlay(this.m_regionBonus2.element as MovieClip);
         }
      }
      
      public function hideR2Highlight() : void
      {
         if(TurtleInnovationManager.getInstance().isR2Unlocked())
         {
            this.m_r2Highlight.visible = false;
            this.m_regionBonus2.visible = false;
            this.m_regionBonus1.visible = true;
            MovieClipUtils.recursivePlay(this.m_regionBonus1.element as MovieClip);
         }
      }
      
      private function howDoesThisWorkClick(event:Event) : void
      {
         totalScenes = 3;
         showTutorial();
      }
      
      override protected function onClose(event:Event) : void
      {
         super.onClose(event);
         this.m_turtleInnovationManager.m_turtleCollectionWindow.refreshWindow();
         FarmStatsManager.count("tenguann_collections_ui","redeem_ui_close");
      }
   }
}

