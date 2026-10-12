package Widgets.Windows
{
   import Classes.Constants.StatsTrackingConstants;
   import Classes.Constants.ZLocConstants;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Engine.Managers.StatsManager;
   import Managers.DreamFishPremarketingManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.TextFields.ZwTextField;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class DreamFishPremarketingWindow extends FarmWindowWithTutorial
   {
      
      private static const NUM_TUTORIAL_SCENES:int = 4;
      
      private static const INNOVATION_FEATURE_SEEN_FLAG:String = "DreamFishPremarketing_Tutorial";
      
      private const TITLE_SUFFIX:String = "_title";
      
      private const HEADER_SUFFIX:String = "_header";
      
      private const HEADER2_SUFFIX:String = "_header2";
      
      private const SUBTITLE1_PRE_EA_SUFFIX:String = "_subtitle1_preEA";
      
      private const SUBTITLE1_PRE_EA_ONCOMPLETE_SUFFIX:String = "_subtitle1_preEA_onComplete";
      
      private const SUBTITLE1_POST_EA_ONCOMPLETE_SUFFIX:String = "_subtitle1_postEA";
      
      private const SUBTITLE1_POST_EA_INCOMPLETE_SUFFIX:String = "_subtitle1_postEA_inComplete";
      
      private const SUBTITLE2_SUFFIX_PRE_EA:String = "_subtitle2_preEA";
      
      private const SUBTITLE2_PRE_EA_ONCOMPLETE_SUFFIX:String = "_subtitle2_preEA_onComplete";
      
      private const SUBTITLE2_POST_EA_ONCOMPLETE_SUFFIX:String = "_subtitle2_postEA_onComplete";
      
      private const SUBTITLE2_POST_EA_INCOMPLETE_SUFFIX:String = "_subtitle2_postEA_inComplete";
      
      private const ASK_BTN_TEXT:String = "_ask_button_text";
      
      private const TRAVEL_BTN_TEXT:String = "Travel!";
      
      private const TITLE_TF:String = "title_tf";
      
      private const WHATISTHIS_MC:String = "whatisthis_mc";
      
      private const HEADER_TF:String = "name_tf";
      
      private const SUBTITLE1_TF:String = "subtitle1_tf";
      
      private const SUBTITLE2_TF:String = "subtitle2_tf";
      
      private const ASK_BT:String = "ask_bt";
      
      private const TRAVEL_BT:String = "travel_bt";
      
      private const COUNT_TF:String = "count_tf";
      
      private const CHECK_MC:String = "check_mc";
      
      private const CONSUMABLE_MC:String = "consumable_mc";
      
      private const EA_MC:String = "EA_mc";
      
      private const ANIMATION_MC:String = "animation_mc";
      
      private const POSTER_MC:String = "poster_mc";
      
      private var m_askBtn:FarmAnimatedTextButton = null;
      
      private var m_travelBtn:FarmAnimatedTextButton = null;
      
      private var m_tutorialBtn:FarmAnimatedTextButton = null;
      
      private var m_checkMark:ZwWidget;
      
      private var m_consumableMc:ZwWidget;
      
      private var m_animationMc:MovieClip;
      
      private var m_posterMc:MovieClip;
      
      private var m_eaIcon:ZwWidget;
      
      private var m_counterTF:ZwTextField;
      
      private var m_headerTF:ZwTextField;
      
      private var m_subtitle1TF:ZwTextField;
      
      private var m_subtitle2TF:ZwTextField;
      
      private var m_state:int;
      
      private var m_featureName:String;
      
      public function DreamFishPremarketingWindow(featureName:String, assetURL:String)
      {
         this.m_featureName = featureName;
         super(this.m_featureName,assetURL,NUM_TUTORIAL_SCENES,true,true);
         this.m_state = this.manager.state;
      }
      
      override protected function postLoadComplete() : void
      {
         var daysLeft:int = 0;
         var dayString:String = null;
         if(m_window.hasOwnProperty(this.TITLE_TF))
         {
            addWidget(new ZwTextField(m_window[this.TITLE_TF],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + this.TITLE_SUFFIX)));
         }
         if(m_window.hasOwnProperty(this.HEADER_TF))
         {
            addWidget(this.m_headerTF = new ZwTextField(m_window[this.HEADER_TF],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + this.HEADER_SUFFIX)));
         }
         if(m_window.hasOwnProperty(this.SUBTITLE1_TF))
         {
            daysLeft = this.manager.getDaysLeft();
            dayString = "Day" + (daysLeft > 1 ? "s" : "");
            addWidget(this.m_subtitle1TF = new ZwTextField(m_window[this.SUBTITLE1_TF],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + this.SUBTITLE1_PRE_EA_SUFFIX,{
               "quantity":daysLeft,
               "days":dayString
            })));
         }
         if(m_window.hasOwnProperty(this.SUBTITLE2_TF))
         {
            addWidget(this.m_subtitle2TF = new ZwTextField(m_window[this.SUBTITLE2_TF],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + this.SUBTITLE2_SUFFIX_PRE_EA)));
         }
         if(m_window.hasOwnProperty(this.ASK_BT))
         {
            addWidget(this.m_askBtn = new FarmAnimatedTextButton(m_window[this.ASK_BT],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + this.ASK_BTN_TEXT),this.onAskButtonClick),true);
         }
         if(m_window.hasOwnProperty(this.TRAVEL_BT))
         {
            addWidget(this.m_travelBtn = new FarmAnimatedTextButton(m_window[this.TRAVEL_BT],this.TRAVEL_BTN_TEXT,this.onTravelButtonClick),false);
         }
         if(m_window.hasOwnProperty(this.COUNT_TF))
         {
            addWidget(this.m_counterTF = new ZwTextField(m_window[this.COUNT_TF],this.manager.playerTicketCount.toString() + "/" + DreamFishPremarketingManager.MAX_TICKET_COUNT));
         }
         if(m_window.hasOwnProperty(this.CHECK_MC))
         {
            addWidget(this.m_checkMark = new ZwWidget(m_window[this.CHECK_MC]),false);
         }
         if(m_window.hasOwnProperty(this.CONSUMABLE_MC))
         {
            addWidget(this.m_consumableMc = new ZwWidget(m_window[this.CONSUMABLE_MC]));
         }
         if(m_window.hasOwnProperty(this.WHATISTHIS_MC))
         {
            addWidget(this.m_tutorialBtn = new FarmAnimatedTextButton(m_window[this.WHATISTHIS_MC],"Tutorial",this.howDoesThisWorkClick));
         }
         if(m_window.hasOwnProperty(this.EA_MC))
         {
            addWidget(this.m_eaIcon = new ZwWidget(m_window[this.EA_MC]));
         }
         if(m_window.hasOwnProperty(this.ANIMATION_MC))
         {
            this.m_animationMc = m_window[this.ANIMATION_MC] as MovieClip;
            this.m_animationMc.visible = false;
         }
         if(m_window.hasOwnProperty(this.POSTER_MC))
         {
            this.m_posterMc = m_window[this.POSTER_MC] as MovieClip;
            this.m_posterMc.visible = true;
         }
         this.setFeatureTextAndButtons();
         this.refreshAskButton();
         super.postLoadComplete();
      }
      
      public function setFeatureTextAndButtons() : void
      {
         var daysLeft:int = 0;
         var dayString:String = null;
         switch(this.m_state)
         {
            case DreamFishPremarketingManager.PRE_EA_INCOMPLETE:
               if(m_window.hasOwnProperty(this.ANIMATION_MC))
               {
                  this.m_animationMc.visible = true;
                  this.m_animationMc.play();
               }
               if(m_window.hasOwnProperty(this.POSTER_MC))
               {
                  this.m_posterMc.visible = false;
               }
               break;
            case DreamFishPremarketingManager.PRE_EA_COMPLETE:
               this.m_checkMark.visible = true;
               this.m_askBtn.visible = false;
               daysLeft = this.manager.getDaysLeft();
               dayString = "Day" + (daysLeft > 1 ? "s" : "");
               this.m_subtitle1TF.text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + this.SUBTITLE1_PRE_EA_ONCOMPLETE_SUFFIX,{
                  "quantity":daysLeft,
                  "days":dayString
               });
               this.m_subtitle2TF.text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + this.SUBTITLE2_PRE_EA_ONCOMPLETE_SUFFIX);
               this.m_tutorialBtn.visible = false;
               break;
            case DreamFishPremarketingManager.POST_EA_INCOMPLETE:
               this.m_askBtn.visible = false;
               if(m_window.hasOwnProperty(this.ANIMATION_MC))
               {
                  this.m_animationMc.visible = true;
                  this.m_animationMc.play();
               }
               if(m_window.hasOwnProperty(this.POSTER_MC))
               {
                  this.m_posterMc.visible = false;
               }
               this.m_travelBtn.visible = true;
               this.m_counterTF.visible = false;
               this.m_consumableMc.visible = true;
               this.m_headerTF.text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + this.HEADER2_SUFFIX);
               this.m_subtitle1TF.text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + this.SUBTITLE1_POST_EA_INCOMPLETE_SUFFIX);
               this.m_subtitle2TF.text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + this.SUBTITLE2_POST_EA_INCOMPLETE_SUFFIX);
               break;
            case DreamFishPremarketingManager.POST_EA_COMPLETE:
               this.m_checkMark.visible = true;
               this.m_posterMc.visible = true;
               this.m_askBtn.visible = false;
               this.m_travelBtn.visible = true;
               this.m_headerTF.text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + this.HEADER2_SUFFIX);
               this.m_subtitle1TF.text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + this.SUBTITLE1_POST_EA_ONCOMPLETE_SUFFIX);
               this.m_subtitle2TF.text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + this.SUBTITLE2_POST_EA_ONCOMPLETE_SUFFIX);
               this.m_tutorialBtn.visible = false;
               break;
            case DreamFishPremarketingManager.POST_EA_EXPANSION_INCOMPLETE_NOT_RAMPED:
               this.m_travelBtn.visible = true;
               if(m_window.hasOwnProperty(this.ANIMATION_MC))
               {
                  this.m_animationMc.visible = true;
                  this.m_animationMc.play();
               }
               if(m_window.hasOwnProperty(this.POSTER_MC))
               {
                  this.m_posterMc.visible = false;
               }
               this.m_travelBtn.text = "Okay!";
               this.m_askBtn.visible = false;
               this.m_headerTF.text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + this.HEADER2_SUFFIX);
               this.m_subtitle1TF.text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + this.SUBTITLE1_POST_EA_INCOMPLETE_SUFFIX);
               this.m_subtitle2TF.text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + this.SUBTITLE2_POST_EA_INCOMPLETE_SUFFIX);
               break;
            case DreamFishPremarketingManager.POST_EA_EXPANSION_COMPLETE_NOT_RAMPED:
               this.m_checkMark.visible = true;
               if(m_window.hasOwnProperty(this.POSTER_MC))
               {
                  this.m_posterMc.visible = true;
               }
               this.m_travelBtn.text = "Okay!";
               this.m_askBtn.visible = false;
               this.m_travelBtn.visible = true;
               this.m_headerTF.text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + this.HEADER2_SUFFIX);
               this.m_subtitle1TF.text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + this.SUBTITLE1_POST_EA_ONCOMPLETE_SUFFIX);
               this.m_subtitle2TF.text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + this.SUBTITLE2_POST_EA_ONCOMPLETE_SUFFIX);
               this.m_tutorialBtn.visible = false;
         }
      }
      
      public function onAskButtonClick(e:Event) : void
      {
         if(this.m_askBtn.enabled)
         {
            this.m_askBtn.enabled = false;
            this.manager.askForTickets();
            this.refreshAskButton();
         }
      }
      
      public function onTravelButtonClick(e:Event) : void
      {
         this.count(StatsTrackingConstants.CLICK_TRAVEL);
         this.close();
         if(!(this.m_state == DreamFishPremarketingManager.POST_EA_EXPANSION_COMPLETE_NOT_RAMPED || this.m_state == DreamFishPremarketingManager.POST_EA_EXPANSION_INCOMPLETE_NOT_RAMPED))
         {
            if(Global.worldManager.currentWorldType != this.manager.WORLD_TYPE)
            {
               Global.hud.travelNameDisplay.showNewTravelWindow();
            }
         }
      }
      
      override protected function onClose(event:Event) : void
      {
         close();
         this.count(StatsTrackingConstants.CLOSE);
      }
      
      private function howDoesThisWorkClick(event:Event) : void
      {
         showTutorial();
      }
      
      public function refreshAskButton() : void
      {
         var timeRemaining:Array = null;
         var xPostTimeRemaining:int = this.manager.getThrottleTimeRemaining(DreamFishPremarketingManager.FEED_NAME);
         if(xPostTimeRemaining > 0)
         {
            timeRemaining = FarmGameUtil.parseTimeLeft(xPostTimeRemaining);
            if(timeRemaining[1] !== 0 || timeRemaining[2] !== 0)
            {
               FarmGameUtil.disableButtonAndShowTooltip(this.m_askBtn,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"asksnowflake_timeleft",{
                  "hrs":timeRemaining[1],
                  "min":timeRemaining[2]
               }));
            }
            else
            {
               FarmGameUtil.disableButtonAndShowTooltip(this.m_askBtn,"Ask again in " + timeRemaining[3] + " seconds");
            }
         }
         else
         {
            this.m_askBtn.enabled = true;
            this.m_askBtn.detachTooltip();
         }
      }
      
      protected function get manager() : DreamFishPremarketingManager
      {
         return DreamFishPremarketingManager.instance(DreamFishPremarketingManager.FEATURE_NAME);
      }
      
      private function count(phylum:String, zclass:String = "") : void
      {
         StatsManager.count(this.m_featureName,StatsTrackingConstants.MAIN_UI,phylum,zclass);
      }
      
      override protected function release() : void
      {
         this.m_askBtn = null;
         this.m_checkMark = null;
         this.m_travelBtn = null;
         this.m_counterTF = null;
         this.m_subtitle1TF = null;
         this.m_subtitle2TF = null;
         this.m_eaIcon = null;
         this.m_consumableMc = null;
         super.release();
      }
   }
}

