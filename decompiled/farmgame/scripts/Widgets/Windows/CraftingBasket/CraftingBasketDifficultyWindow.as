package Widgets.Windows.CraftingBasket
{
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.UI;
   import Events.GenericPopupEvent;
   import Managers.CraftingBasketDifficultyLevelManager;
   import Managers.FarmStatsManager;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Slots.CraftingBasket.CraftingBasketDifficultySlot;
   import Widgets.Windows.FarmWindow;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class CraftingBasketDifficultyWindow extends FarmWindow
   {
      
      private static const NUM_TUTORIAL_SCENES:int = 4;
      
      private static const FTUE_FLAG:String = "ftue";
      
      private static const REDEEM_ADDITIONAL_DAYS:int = 2;
      
      private static const STATS_KINGDOM_WINDOW_NAME:String = "difficulty_screen";
      
      private static const STATS_PHYLUM_VIEW:String = "view";
      
      private var m_featureName:String;
      
      private var m_DifficultyManagerObject:CraftingBasketDifficultyLevelManager;
      
      private var m_difficultyLevel:int;
      
      private var m_tutorialButton:FarmAnimatedTextButton;
      
      private var m_titleTextField:ZwTextField;
      
      private var m_subtitleTextField:ZwTextField;
      
      private var m_whatisthisBtn:FarmAnimatedButton;
      
      private var m_ftue:MovieClip = null;
      
      private var m_difficultyFrame:ZwFrame;
      
      private var m_tutorialScene:int;
      
      private var m_currentChosenLevel:int;
      
      private var m_difficultyButtons:Array = new Array();
      
      private var m_levelTextFields:Array = new Array();
      
      private var m_recommendtext:ZwTextField;
      
      private var m_recommend:ZwWidget;
      
      private var m_checkMarks:Array = new Array();
      
      private var m_menagerieLevelsText:Array = new Array();
      
      private var m_menagerieLevelRewards:Array = new Array();
      
      private var m_menagerieTotalPrize:Array = new Array();
      
      public function CraftingBasketDifficultyWindow(windowURL:String, featureName:String)
      {
         this.m_featureName = featureName;
         super(windowURL);
      }
      
      override protected function postLoadComplete() : void
      {
         var difficultySlot:CraftingBasketDifficultySlot = null;
         super.postLoadComplete();
         this.m_DifficultyManagerObject = new CraftingBasketDifficultyLevelManager(this.m_featureName);
         this.initMenagerieText();
         if(m_window.whatisthis_mc)
         {
            addWidget(this.m_whatisthisBtn = new FarmAnimatedButton(m_window.whatisthis_mc,this.onWhatIsThisClick));
         }
         if(m_window.time_tf)
         {
            addWidget(new ZwTextField(m_window.time_tf,this.getExpiryDateText()));
         }
         if(m_window.note_tf)
         {
            addWidget(new ZwTextField(m_window.note_tf,ZLocUtils.t("Dialogs",this.m_featureName + "_diff_note")));
         }
         addWidget(this.m_titleTextField = new ZwTextField(m_window.title_tf,ZLocUtils.t("Dialogs",this.m_featureName + "_difficultytitle")));
         addWidget(this.m_subtitleTextField = new ZwTextField(m_window.copy_tf,this.getSubtitleText()));
         if(Boolean(m_window.count_mc) && Boolean(m_window.count_mc.count_tf))
         {
            m_window.count_mc.visible = false;
            if(this.m_DifficultyManagerObject.isGameStarted())
            {
               m_window.count_mc.visible = true;
               addWidget(new ZwTextField(m_window.count_mc.count_tf,"x" + this.getCurrency().toString()));
            }
         }
         var firstTimeSeenFlag:String = this.m_featureName + "difficulty" + FTUE_FLAG;
         if(!Global.player.getSeenFlag(firstTimeSeenFlag))
         {
            this.setupFTUE();
            this.showFTUE();
         }
         var recommendedLevel:int = this.m_DifficultyManagerObject.recommendedDifficultyLevel;
         this.m_currentChosenLevel = recommendedLevel;
         addWidget(new FarmAnimatedTextButton(m_window.select_bt_0,this.m_menagerieLevelsText[0],this.onSelectLevel0));
         addWidget(new FarmAnimatedTextButton(m_window.select_bt_1,this.m_menagerieLevelsText[1],this.onSelectLevel1));
         addWidget(new FarmAnimatedTextButton(m_window.select_bt_2,this.m_menagerieLevelsText[2],this.onSelectLevel2));
         addWidget(this.m_difficultyButtons[0] = new FarmAnimatedTextButton(m_window.button_0_mc,this.m_menagerieLevelsText[0],null));
         addWidget(this.m_difficultyButtons[1] = new FarmAnimatedTextButton(m_window.button_1_mc,this.m_menagerieLevelsText[1],null));
         addWidget(this.m_difficultyButtons[2] = new FarmAnimatedTextButton(m_window.button_2_mc,this.m_menagerieLevelsText[2],null));
         addWidget(this.m_checkMarks[0] = new ZwWidget(m_window.checkmark_0_mc),false);
         addWidget(this.m_checkMarks[1] = new ZwWidget(m_window.checkmark_1_mc),false);
         addWidget(this.m_checkMarks[2] = new ZwWidget(m_window.checkmark_2_mc),false);
         this.setCheckMark();
         this.setButtonActiveState(recommendedLevel);
         addWidget(this.m_difficultyFrame = new ZwFrame(m_window.slot_mc)) as ZwFrame;
         addWidget(this.m_levelTextFields[0] = new ZwTextField(m_window.slot_mc.title1_tf,this.m_menagerieLevelsText[recommendedLevel]));
         addWidget(this.m_levelTextFields[1] = new ZwTextField(m_window.slot_mc.copy1_tf,"Earn " + this.m_menagerieLevelRewards[recommendedLevel] + " Rewards!"));
         addWidget(this.m_levelTextFields[2] = new ZwTextField(m_window.slot_mc.count1_tf,"x" + this.m_menagerieTotalPrize[recommendedLevel]));
         addWidget(new ZwTextField(m_window.slot_mc.counttext_tf,ZLocUtils.t("Dialogs",this.m_featureName + "_slot_spend")));
         addWidget(new FarmAnimatedTextButton(m_window.redeem_bt,"Select and Play!",this.onSelectLevel));
         if(Boolean(m_window.reco_mc) && Boolean(m_window.reco_mc.reco_tf))
         {
            this.m_recommend = addWidget(new ZwWidget(m_window.reco_mc),true) as ZwWidget;
            this.m_recommendtext = addWidget(new ZwTextField(m_window.reco_mc.reco_tf,ZLocUtils.t("Dialogs",this.m_featureName + "_slot_recommended"))) as ZwTextField;
            this.refreshLevelTexts(this.m_currentChosenLevel);
         }
         var i:int = 0;
         while(i < this.m_DifficultyManagerObject.difficultyLevels && m_window["slot_mc"]["slot_" + i + "_mc"] != null)
         {
            difficultySlot = new CraftingBasketDifficultySlot(m_window["slot_mc"]["slot_" + i + "_mc"],this.m_featureName + "_" + i,this.m_featureName,i,this.onSelectLevel,recommendedLevel == i ? true : false,false,this.m_DifficultyManagerObject.isGameStarted());
            this.m_difficultyFrame.addWidget(difficultySlot);
            i++;
         }
      }
      
      private function getSubtitleText() : String
      {
         return this.m_DifficultyManagerObject.isFeatureInActivePeriod() ? ZLocUtils.t("Dialogs",this.m_featureName + "_diff_subtitle") : ZLocUtils.t("Dialogs",this.m_featureName + "_diff_subtitle_notActive");
      }
      
      private function initMenagerieText() : void
      {
         this.m_menagerieLevelsText = [ZLocUtils.t("Dialogs",this.m_featureName + "_slot0" + "_title"),ZLocUtils.t("Dialogs",this.m_featureName + "_slot1" + "_title"),ZLocUtils.t("Dialogs",this.m_featureName + "_slot2" + "_title")];
         this.m_menagerieLevelRewards = [ZLocUtils.t("Dialogs",this.m_featureName + "_0" + "_menagerie_level_reward_count"),ZLocUtils.t("Dialogs",this.m_featureName + "_1" + "_menagerie_level_reward_count"),ZLocUtils.t("Dialogs",this.m_featureName + "_2" + "_menagerie_level_reward_count")];
         this.m_menagerieTotalPrize = [ZLocUtils.t("Dialogs",this.m_featureName + "_0_total_prize"),ZLocUtils.t("Dialogs",this.m_featureName + "_1_total_prize"),ZLocUtils.t("Dialogs",this.m_featureName + "_2_total_prize")];
      }
      
      private function refreshMenagrieMap(recommendedLevel:int) : void
      {
         this.hideMenagerieMap(m_window.map_mc);
         switch(recommendedLevel)
         {
            case 0:
               m_window.map_mc.mapSmall_mc.visible = true;
               break;
            case 1:
               m_window.map_mc.mapMedium_mc.visible = true;
               break;
            case 2:
               m_window.map_mc.mapBig_mc.visible = true;
         }
      }
      
      private function refreshLevelTexts(choosenlevel:int) : void
      {
         if(choosenlevel != this.m_DifficultyManagerObject.recommendedDifficultyLevel)
         {
            this.m_recommend.visible = false;
            this.m_recommendtext.visible = false;
         }
         else
         {
            this.m_recommend.visible = true;
            this.m_recommendtext.visible = true;
         }
         this.m_levelTextFields[0].text = this.m_menagerieLevelsText[choosenlevel];
         this.m_levelTextFields[1].text = "Earn " + this.m_menagerieLevelRewards[choosenlevel] + " Rewards!";
         this.m_levelTextFields[2].text = "x" + this.m_menagerieTotalPrize[choosenlevel];
      }
      
      private function hideMenagerieMap(map:MovieClip) : void
      {
         map.mapSmall_mc.visible = false;
         map.mapMedium_mc.visible = false;
         map.mapBig_mc.visible = false;
      }
      
      private function setupFTUE() : void
      {
         this.m_ftue = m_window.tutorial_mc as MovieClip;
         if(this.m_ftue)
         {
            this.m_ftue.visible = false;
            if(this.m_tutorialButton == null && this.m_ftue.hasOwnProperty("okay_bt"))
            {
               addWidget(this.m_tutorialButton = new FarmAnimatedTextButton(this.m_ftue.okay_bt,ZLocUtils.t("Dialogs","Okay"),this.onFTUEOkBtnClick));
            }
         }
      }
      
      private function getExpiryDateText() : String
      {
         return FarmGameUtil.getFeatureExpiryDateText(this.m_DifficultyManagerObject.endDate,"Generic_ExpiryText",CraftingBasketDifficultyLevelManager.REDEEM_ADDITIONAL_DAYS);
      }
      
      private function getCurrency() : int
      {
         return this.m_DifficultyManagerObject.getCurrency();
      }
      
      private function showFTUE() : void
      {
         if(!this.m_ftue)
         {
            this.setupFTUE();
         }
         this.m_tutorialScene = 1;
         this.m_ftue.gotoAndStop(this.m_tutorialScene);
         this.m_tutorialButton.text = ZLocUtils.t("Dialogs","Okay");
         this.m_ftue.visible = true;
         FarmStatsManager.count(this.m_featureName,"FTUE","start");
      }
      
      private function onFTUEOkBtnClick(event:Event) : void
      {
         var firstTimeSeenFlag:String = null;
         if(this.m_tutorialScene++ < NUM_TUTORIAL_SCENES)
         {
            (this.m_ftue as MovieClip).play();
            if(this.m_tutorialScene == NUM_TUTORIAL_SCENES)
            {
               this.m_tutorialButton.text = ZLocUtils.t("Dialogs",this.m_featureName + "_tutorialDone");
            }
         }
         else
         {
            firstTimeSeenFlag = this.m_featureName + "difficulty" + FTUE_FLAG;
            Global.player.setSeenFlag(firstTimeSeenFlag);
            this.m_ftue.visible = false;
            FarmStatsManager.count(this.m_featureName,"FTUE","end");
         }
      }
      
      private function onSelectLevel0(difficultyLevel:int) : void
      {
         this.m_currentChosenLevel = 0;
         this.setButtonActiveState(0);
         this.refreshLevelTexts(0);
      }
      
      private function onSelectLevel1(difficultyLevel:int) : void
      {
         this.m_currentChosenLevel = 1;
         this.setButtonActiveState(1);
         this.refreshLevelTexts(1);
      }
      
      private function onSelectLevel2(difficultyLevel:int) : void
      {
         this.m_currentChosenLevel = 2;
         this.setButtonActiveState(2);
         this.refreshLevelTexts(2);
      }
      
      private function setButtonActiveState(difficultyLevel:int) : void
      {
         var btn:FarmAnimatedTextButton = null;
         for each(btn in this.m_difficultyButtons)
         {
            btn.visible = false;
         }
         this.m_difficultyButtons[difficultyLevel].visible = true;
      }
      
      private function setCheckMark() : void
      {
         for(var i:int = 0; i < this.m_checkMarks.length; i++)
         {
            this.m_checkMarks[i].visible = this.m_DifficultyManagerObject.isRewardLevelComplete(i) ? true : false;
         }
      }
      
      private function onSelectLevel(event:Event) : void
      {
         var confirmationText:String = null;
         var lastChosenLevel:int = this.m_DifficultyManagerObject.getPreviousDifficultyLevel();
         if(lastChosenLevel == this.m_currentChosenLevel)
         {
            confirmationText = ZLocUtils.t("Dialogs",this.m_featureName + "_same_level_confirmation_text");
            UI.displayMessage(confirmationText,GenericPopup.TYPE_ACCEPTCANCEL,this.onAcceptDifficultyLevelConfirmation,"",true,true);
         }
         else
         {
            this.acceptDifficultyLevelConfirmation();
         }
      }
      
      private function onWhatIsThisClick(event:Event) : void
      {
         this.showFTUE();
      }
      
      private function onAcceptDifficultyLevelConfirmation(event:GenericPopupEvent) : void
      {
         if(event.button == GenericPopup.ACCEPT)
         {
            this.acceptDifficultyLevelConfirmation();
         }
      }
      
      private function acceptDifficultyLevelConfirmation() : void
      {
         close();
         this.m_DifficultyManagerObject.setDifficultyLevelAndCraftingWindow(this.m_currentChosenLevel);
         CraftingBasketDifficultyLevelManager.loading = true;
      }
      
      override protected function release() : void
      {
         this.m_subtitleTextField = null;
         this.m_titleTextField = null;
         this.m_whatisthisBtn = null;
         this.m_tutorialButton = null;
         this.m_ftue = null;
         this.m_difficultyFrame = null;
         this.m_difficultyButtons = null;
         this.m_levelTextFields = null;
         this.m_checkMarks = null;
         this.m_menagerieLevelsText = null;
         this.m_menagerieLevelRewards = null;
         this.m_menagerieTotalPrize = null;
         super.release();
      }
   }
}

