package Widgets.Windows.Amex
{
   import Classes.util.ZLocUtils;
   import Display.TutorialUI;
   import Managers.FarmStatsManager;
   import Managers.FeatureOptionsManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Windows.FarmWindow;
   import flash.events.Event;
   
   public class AmexTreeStatusWindow extends FarmWindow
   {
      
      private static const AFFILIATE_DATA_FEATURE_KEY:String = "affiliateData";
      
      public static const AMEX_TREE_CONVERT_SEEN_FLAG:String = "amextree_convert";
      
      public static const AMEX_TREE_MAKEGOOD_SEEN_FLAG:String = "amextree_makegood";
      
      private static const AMEX_TREE_ID:String = "amextree";
      
      private static const AMEX_TREE_SIGNUP:String = "REGISTRATION";
      
      private static const AMEX_TREE_CONVERT:String = "ROLLOVER";
      
      private static const AMEX_TREE_ACTIVATE:String = "ACTIVATION";
      
      private static const AMEX_TREE_PURCHASE:String = "PURCHASE";
      
      private static const AMEX_TREE_FUND:String = "FUND";
      
      private static const AMEX_TREE_ALL_PHASES_COMPLETE:String = "finished";
      
      private static const PHASE_TO_TREE_INDEX:Object = {
         "REGISTRATION":1,
         "ROLLOVER":1,
         "ACTIVATION":2,
         "PURCHASE":3,
         "finished":3
      };
      
      private const TREE_ANIMATION_START_FRAME:int = 2;
      
      private const CPA_LINKS:Object = {
         "REGISTRATION":"https://www.serve.com/farmville",
         "ROLLOVER":"https://www.serve.com/farmville",
         "ACTIVATION":"https://secure.serve.com/Login",
         "PURCHASE":"https://secure.serve.com/Login",
         "finished":"https://www.serve.com/zynga"
      };
      
      private var m_treeFrames:Array = [];
      
      public function AmexTreeStatusWindow()
      {
         super(null);
      }
      
      protected static function getCurrentPhase() : String
      {
         var phases:Array = null;
         var phase:String = null;
         var currentFeatureData:Object = FeatureOptionsManager.getInstance().getFeatureOption(AFFILIATE_DATA_FEATURE_KEY,AMEX_TREE_ID);
         if(currentFeatureData)
         {
            if(isConvertedUser())
            {
               phases = [AMEX_TREE_CONVERT,AMEX_TREE_ACTIVATE,AMEX_TREE_PURCHASE];
            }
            else
            {
               phases = [AMEX_TREE_SIGNUP,AMEX_TREE_ACTIVATE,AMEX_TREE_PURCHASE];
            }
            for each(phase in phases)
            {
               if(!currentFeatureData.hasOwnProperty(phase) || !currentFeatureData[phase])
               {
                  return phase;
               }
            }
            return AMEX_TREE_ALL_PHASES_COMPLETE;
         }
         return AMEX_TREE_SIGNUP;
      }
      
      public static function isConvertedUser() : Boolean
      {
         return Global.player.getSeenFlag(AMEX_TREE_CONVERT_SEEN_FLAG);
      }
      
      public static function getPhaseAsInt() : int
      {
         return phaseStringToTreeIndex(getCurrentPhase());
      }
      
      protected static function phaseStringToTreeIndex(phase:String) : int
      {
         return PHASE_TO_TREE_INDEX.hasOwnProperty(phase) ? int(PHASE_TO_TREE_INDEX[phase]) : 0;
      }
      
      override public function show() : void
      {
         close();
         AmexTreeIframeNotification.conditionallyShowNotification();
      }
      
      override protected function postLoadComplete() : void
      {
         var treesFrame:ZwFrame = null;
         var bonus_mc:ZwFrame = null;
         var currentPhase:String = getCurrentPhase();
         var currentTreeIndexShown:int = phaseStringToTreeIndex(currentPhase);
         var currentTextIndexShown:String = this.phaseStringToTextIndex(currentPhase).toString();
         addWidget(new ZwFrame(m_window.BG_mc));
         if(this.isPhaseComplete(AMEX_TREE_FUND) == false && currentTreeIndexShown > phaseStringToTreeIndex(AMEX_TREE_SIGNUP))
         {
            addWidget(bonus_mc = new ZwFrame(m_window.bonus_mc));
            bonus_mc.addWidget(new ZwTextField(bonus_mc.element.farmCash_tf,"130"));
            bonus_mc.addWidget(new FarmAnimatedTextButton(bonus_mc.element.go_bt,ZLocUtils.t("Dialogs","amextreeMain_goNow"),this.onGetCash));
            FarmStatsManager.count("serve_tree","bonus_panel","view");
         }
         treesFrame = addWidget(new ZwFrame(m_window.trees_mc)) as ZwFrame;
         for(var treeIter:int = 0; treesFrame.element.hasOwnProperty("tree_0" + treeIter.toString() + "_mc"); treeIter++)
         {
            this.m_treeFrames.push(treesFrame.addWidget(new ZwFrame(treesFrame.element["tree_0" + treeIter.toString() + "_mc"])) as ZwFrame);
         }
         if(isConvertedUser() && treesFrame.element.hasOwnProperty("tree_01_convert_mc"))
         {
            (this.m_treeFrames[1] as ZwFrame).visible = false;
            this.m_treeFrames[1] = treesFrame.addWidget(new ZwFrame(treesFrame.element["tree_01_convert_mc"])) as ZwFrame;
         }
         if(this.m_treeFrames.length > currentTreeIndexShown)
         {
            (this.m_treeFrames[currentTreeIndexShown] as ZwFrame).element.gotoAndPlay(this.TREE_ANIMATION_START_FRAME);
         }
         var bodyTextKey:String = "amextreeMain_body_signup_phase" + currentTextIndexShown;
         var subHeadTextKey:String = "amextreeMain_subhead_signup_phase" + currentTextIndexShown;
         if(isConvertedUser())
         {
            bodyTextKey = "amextreeMain_body_convert_phase" + currentTextIndexShown;
            subHeadTextKey = "amextreeMain_subhead_convert_phase" + currentTextIndexShown;
         }
         addWidget(new ZwTextField(m_window.body_tf,ZLocUtils.t("Dialogs",bodyTextKey)));
         addWidget(new ZwTextField(m_window.subHead_tf,ZLocUtils.t("Dialogs",subHeadTextKey)));
         addWidget(new ZwTextField(m_window.title_tf,ZLocUtils.t("Dialogs","amextreeMain_title")));
         if(m_window.hasOwnProperty("blueTree_txt"))
         {
            addWidget(new ZwTextField(m_window.blueTree_txt,"7"));
         }
         addWidget(new ZwTextField(m_window.greenTree_txt,"150"));
         addWidget(new ZwTextField(m_window.pinkTree_txt,"13"));
         addWidget(new ZwTextField(m_window.yellowTree_txt,"650"));
         addWidget(new FarmAnimatedTextButton(m_window.getCash_bt,ZLocUtils.t("Dialogs","amextreeMain_getCash_phase" + currentTextIndexShown),this.onGetCash));
         addWidget(new FarmAnimatedTextButton(m_window.whatisthis_mc,ZLocUtils.t("Dialogs","WhatIsThis"),this.onWhatIsThisClick));
         FarmStatsManager.count("serve_tree","progression_dialog","view","stage_" + currentTreeIndexShown.toString());
         if(!Global.player.getSeenFlag("amextree_tutorial"))
         {
            TutorialUI.displayAmexTreeWindow(false,null);
            Global.player.setSeenFlag("amextree_tutorial");
         }
      }
      
      override protected function onClose(event:Event) : void
      {
         FarmStatsManager.count("serve_tree","progression_dialog","cancel");
         super.onClose(event);
      }
      
      private function onWhatIsThisClick(even:Event) : void
      {
         FarmStatsManager.count("serve_tree","info","view");
         TutorialUI.displayAmexTreeWindow(false,null);
      }
      
      protected function isPhaseComplete(phase:String) : Boolean
      {
         var currentFeatureData:Object = FeatureOptionsManager.getInstance().getFeatureOption(AFFILIATE_DATA_FEATURE_KEY,AMEX_TREE_ID);
         var result:Boolean = false;
         if(currentFeatureData)
         {
            result = currentFeatureData.hasOwnProperty(phase) && Boolean(currentFeatureData[phase]);
         }
         return result;
      }
      
      protected function phaseStringToTextIndex(phase:String) : int
      {
         var PHASE_TO_TEXT_INDEX:Object = {
            "REGISTRATION":1,
            "ROLLOVER":1,
            "ACTIVATION":2,
            "PURCHASE":3,
            "finished":4
         };
         return PHASE_TO_TEXT_INDEX.hasOwnProperty(phase) ? int(PHASE_TO_TEXT_INDEX[phase]) : 0;
      }
      
      protected function onBonusGetCash(event:Event) : void
      {
         var activeLink:String = null;
         var signLink:String = "https://secure.serve.com/login?extlink=us-serve-zynga15-progression-new-addmoney-201205";
         var convertLink:String = "https://secure.serve.com/login?extlink=us-serve-zynga15-progression-conv-addmoney-201205";
         if(isConvertedUser())
         {
            activeLink = convertLink;
         }
         else
         {
            activeLink = signLink;
         }
         FarmStatsManager.count("serve_tree","bonus_panel","link");
         GlobalEngine.socialNetwork.redirect(activeLink,null,"_blank",false);
      }
      
      public function getAmexTreeLink() : String
      {
         var zyngaInfo:String = "?zgid=63&zguid=" + Global.player.thirdPartyID;
         var convertParams:Array = [zyngaInfo + "&extlink=us-serve-zynga15-progression1-conv-landing-201206&OfferCode=Zynga_A_Roll","?extlink=us-serve-zynga15-progression2-conv-activate-201206","?extlink=us-serve-zynga15-progression3-conv-balance-201206","?extlink=us-serve-zynga15-progression4-conv-microsite-201206"];
         var signParams:Array = [zyngaInfo + "&extlink=us-serve-zynga15-progression1-landing-201206&OfferCode=Zyn_A_Reg","?extlink=us-serve-zynga15-progression2-new-activate-201206","?extlink=us-serve-zynga15-progression3-new-balance-201206","?extlink=us-serve-zynga15-progression4-new-microsite-201206"];
         var activeParams:Array = isConvertedUser() ? convertParams : signParams;
         var currentPhase:String = getCurrentPhase();
         var currentPhaseNum:int = currentPhase == AMEX_TREE_ALL_PHASES_COMPLETE ? 3 : int(phaseStringToTreeIndex(currentPhase) - 1);
         return this.CPA_LINKS[currentPhase] + activeParams[currentPhaseNum];
      }
      
      protected function onGetCash(event:Event) : void
      {
         var link:String = this.getAmexTreeLink();
         var currentTreeIndexShown:String = phaseStringToTreeIndex(getCurrentPhase()).toString();
         FarmStatsManager.count("serve_tree","progression_dialog","link","stage_" + currentTreeIndexShown);
         GlobalEngine.socialNetwork.redirect(link,null,"_blank",false);
      }
   }
}

