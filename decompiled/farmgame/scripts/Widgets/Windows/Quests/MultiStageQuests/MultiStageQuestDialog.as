package Widgets.Windows.Quests.MultiStageQuests
{
   import Classes.Quest.FarmQuest;
   import Classes.Quest.FarmQuestSettingsInit;
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.GenericPopupTitle;
   import Display.TutorialUI;
   import Display.UI;
   import Engine.Managers.ErrorManager;
   import Managers.FarmStatsManager;
   import Managers.TemplateUIUtility;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwBaseWidget;
   import Widgets.Icons.FarmIcon;
   import Widgets.TextFields.FarmTextField;
   import Widgets.Windows.FarmWindow;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.system.ApplicationDomain;
   import flash.utils.getDefinitionByName;
   
   public class MultiStageQuestDialog extends FarmWindow
   {
      
      private static const CUSTOM_INTRO_WIDGET_PACKAGE:String = "Widgets.Windows.Quests.MultiStageQuests.";
      
      private static const INTRO_WIDGETS:Array = [StoryBookIntroWidget];
      
      private var m_stageContent:ZwBaseWidget;
      
      private var m_intro:ZwBaseWidget = null;
      
      private var m_currentStageQuest:FarmQuest;
      
      private var m_stageNumber:int;
      
      private var m_numStages:int = 0;
      
      private var m_title:FarmTextField = null;
      
      private var m_description:FarmTextField = null;
      
      private var m_description2:FarmTextField = null;
      
      private var m_extraWaitingText:FarmTextField = null;
      
      private var m_timeLeft:FarmTextField = null;
      
      private var m_whatIsThisButton:FarmAnimatedTextButton;
      
      private var m_textColor:String = null;
      
      private var m_dailogBackground:String = null;
      
      private var m_animatedScene:String = null;
      
      private const ASSET_WHATISTHIS:String = "assets/dialogs/Asia/FV_xas_genericpopup.swf";
      
      public function MultiStageQuestDialog(currentStageQuest:FarmQuest, stage:int, url:String, textColor:String = null, dailogBackground:String = null, animatedScene:String = null)
      {
         super(url);
         this.m_stageNumber = stage;
         this.m_currentStageQuest = currentStageQuest;
         this.m_textColor = textColor;
         this.m_dailogBackground = dailogBackground;
         this.m_animatedScene = animatedScene;
      }
      
      public function isTemplateUIEnabled() : Boolean
      {
         return Boolean(this.m_textColor) && Boolean(this.m_dailogBackground) && Boolean(this.m_animatedScene);
      }
      
      public function get textColor() : String
      {
         return this.m_textColor;
      }
      
      public function get dailogBackground() : String
      {
         return this.m_dailogBackground;
      }
      
      public function get animatedScene() : String
      {
         return this.m_animatedScene;
      }
      
      override public function centerPopup(pAbsolutePos:Point = null) : void
      {
         var bounds:Rectangle = null;
         super.centerPopup(pAbsolutePos);
         var shouldRecenterKey:String = "multiStageQuestDialog_" + this.m_currentStageQuest.chain + "_reCenterWindow";
         var shouldRecenter:Boolean = Global.farmGameSettingsManager.getString(shouldRecenterKey,"true") == "true";
         if(shouldRecenter)
         {
            bounds = m_window.getBounds(m_window);
            this.x -= bounds.left;
            this.y -= bounds.top;
         }
      }
      
      override protected function postLoadComplete() : void
      {
         var questRewardsItemCodes:Array = null;
         var indicatorString:String = null;
         super.postLoadComplete();
         this.m_title = addWidget(new FarmTextField(m_window.title_tf)) as FarmTextField;
         if(m_window.description_tf)
         {
            this.m_description = addWidget(new FarmTextField(m_window.description_tf)) as FarmTextField;
         }
         if("description2_tf" in m_window)
         {
            this.m_description2 = addWidget(new FarmTextField(m_window.description2_tf)) as FarmTextField;
         }
         if(Boolean(m_window.waiting_mc) && Boolean(m_window.waiting_mc.generic_tf))
         {
            this.m_extraWaitingText = addWidget(new FarmTextField(m_window.waiting_mc.generic_tf)) as FarmTextField;
         }
         if(m_window.timer_tf)
         {
            this.m_timeLeft = addWidget(new FarmTextField(m_window.timer_tf)) as FarmTextField;
         }
         if(this.isTemplateUIEnabled())
         {
            TemplateUIUtility.applyDropShadowFilter(this.m_title,TemplateUIUtility.ESCAPADE,this.textColor);
            TemplateUIUtility.applyTextScaling(this.m_title,TemplateUIUtility.ESCAPADE);
            TemplateUIUtility.applyTextColor(this.m_description,TemplateUIUtility.ESCAPADE,this.textColor);
            TemplateUIUtility.applyTextColor(this.m_description2,TemplateUIUtility.ESCAPADE,this.textColor);
            if(m_window["loader_mc"])
            {
               addWidget(new FarmIcon(m_window.loader_mc,this.dailogBackground));
            }
            questRewardsItemCodes = this.buildQuestRewardItemCodes();
            this.addProgressWidgets(questRewardsItemCodes);
         }
         else
         {
            this.m_whatIsThisButton = addWidget(new FarmAnimatedTextButton(m_window.getChildByName("whatisthis_mc") as MovieClip,"What is this?",this.onWhatIsThisClick)) as FarmAnimatedTextButton;
            this.m_numStages = 0;
            indicatorString = "stage" + (this.m_numStages + 1) + "_indicator_mc";
            while(m_window.hasOwnProperty(indicatorString))
            {
               addWidget(new ZwBaseWidget(m_window.getChildByName(indicatorString)));
               ++this.m_numStages;
               indicatorString = "stage" + (this.m_numStages + 1) + "_indicator_mc";
            }
         }
         this.refreshUI();
      }
      
      private function buildQuestRewardItemCodes() : Array
      {
         var questName:String = null;
         var quest:FarmQuest = null;
         var questRewards:Vector.<Object> = null;
         var farmReward:Object = null;
         var questRewardsItemCodes:Array = new Array();
         var lengthOfEscapadeQuestChains:int = 26;
         for(var questIndex:int = 1; questIndex < lengthOfEscapadeQuestChains; questIndex++)
         {
            questName = this.m_currentStageQuest.chain + "-01-0";
            if(questIndex < 10)
            {
               questName += "0";
            }
            questName += String(questIndex);
            quest = FarmQuestSettingsInit.getInstance().getItemByName(questName) as FarmQuest;
            if(quest)
            {
               questRewards = quest.farmRewards;
               if(questRewards)
               {
                  for each(farmReward in questRewards)
                  {
                     questRewardsItemCodes.push(farmReward.value);
                  }
               }
            }
         }
         return questRewardsItemCodes;
      }
      
      private function addProgressWidgets(rewardItemCodes:Array) : void
      {
         var stageItem:FarmItem = null;
         this.m_numStages = 1;
         while(m_window.hasOwnProperty("stage" + this.m_numStages + "_indicator_mc"))
         {
            stageItem = Global.farmGameSettingsManager.getFarmItemByCode(rewardItemCodes[this.m_numStages - 1]);
            addWidget(new MultiStageQuestProgressBarWidget(m_window.getChildByName("stage" + this.m_numStages + "_indicator_mc"),this.m_numStages,stageItem,this));
            ++this.m_numStages;
         }
         --this.m_numStages;
      }
      
      public function setNewStage(farmQuest:FarmQuest, stage:int) : void
      {
         this.m_currentStageQuest = farmQuest;
         this.m_stageNumber = stage;
         if(m_window)
         {
            this.refreshUI();
         }
      }
      
      private function refreshUI() : void
      {
         var windowClassName:String = null;
         var windowClass:Class = null;
         var timeLeftSeconds:Number = NaN;
         var timeLeftString:String = null;
         if(this.m_stageContent != null)
         {
            removeWidget(this.m_stageContent);
         }
         if(this.m_intro != null)
         {
            removeWidget(this.m_intro);
         }
         var hasIntro:Boolean = false;
         if(m_window.hasOwnProperty("intro_mc") && this.m_currentStageQuest.shouldShowIntro())
         {
            if(this.m_currentStageQuest.customIntroWidget != null)
            {
               windowClassName = CUSTOM_INTRO_WIDGET_PACKAGE + this.m_currentStageQuest.customIntroWidget;
               if(ApplicationDomain.currentDomain.hasDefinition(windowClassName))
               {
                  windowClass = getDefinitionByName(windowClassName) as Class;
                  this.m_intro = addWidget(new windowClass(m_window["intro_mc"],this.m_currentStageQuest,this,this.m_stageNumber)) as ZwBaseWidget;
               }
            }
            else
            {
               this.m_intro = addWidget(new StageIntroWidget(m_window["intro_mc"],this.m_currentStageQuest,this,this.m_stageNumber)) as ZwBaseWidget;
            }
            this.m_intro.addEventListener(Event.CLOSE,this.onIntroClick);
            hasIntro = true;
         }
         var stageContent:ZwBaseWidget = MultiStageQuestWidgetFactory.getStageUI(this.m_currentStageQuest,m_window,this,this.m_stageNumber);
         if(stageContent != null)
         {
            this.m_stageContent = addWidget(stageContent);
            this.m_title.text = ZLocUtils.t("Quests",this.m_currentStageQuest.textBundle + "_Title");
            timeLeftSeconds = (this.m_currentStageQuest.expirationTime - GlobalEngine.serverTime) / FarmGameUtil.NUM_MSECS_IN_SECOND;
            if(timeLeftSeconds < 0)
            {
               timeLeftSeconds = 0;
            }
            timeLeftString = FarmGameUtil.toFriendlyTime(timeLeftSeconds);
            if(this.m_description2 != null)
            {
               this.m_description2.text = ZLocUtils.t("Quests",this.m_currentStageQuest.textBundle + "_Body2");
            }
            if(this.m_stageContent is StageWaitingWidget)
            {
               this.m_description.text = ZLocUtils.t("Quests",this.m_currentStageQuest.textBundle + "_Body",{"timeLeft":timeLeftString});
               if(this.m_extraWaitingText)
               {
                  this.m_extraWaitingText.visible = true;
                  this.m_extraWaitingText.text = ZLocUtils.t("Dialogs","MultiStageQuest_" + this.m_currentStageQuest.chain + "_ExtraWaitingText");
               }
               this.m_timeLeft.visible = false;
               this.refreshStageIndicators(true);
            }
            else
            {
               if(this.m_timeLeft)
               {
                  this.m_timeLeft.visible = true;
                  this.m_timeLeft.text = ZLocUtils.t("Dialogs","MultiStageQuestGeneric_TimeLeft",{"timeLeft":timeLeftString});
               }
               if(this.m_description)
               {
                  this.m_description.text = ZLocUtils.t("Quests",this.m_currentStageQuest.textBundle + "_Body");
               }
               if(this.m_extraWaitingText)
               {
                  this.m_extraWaitingText.visible = false;
               }
               this.refreshStageIndicators(false);
            }
         }
         else
         {
            ErrorManager.addError("MultiStageQuestWidgetFactory.getStageUI returned a null value");
         }
         if(hasIntro)
         {
            this.m_stageContent.visible = false;
            this.m_timeLeft.visible = false;
         }
      }
      
      public function onIntroClick(event:Event) : void
      {
         this.m_intro.removeEventListener(Event.CLOSE,this.onIntroClick);
         this.m_stageContent.visible = true;
         this.m_timeLeft.visible = !(this.m_stageContent is StageWaitingWidget);
      }
      
      private function refreshStageIndicators(onWaitingStage:Boolean) : void
      {
         var currentStageNumber:int = 0;
         var stageIndicator:MultiStageQuestProgressBarWidget = null;
         var i:int = 0;
         var stageIndicatorElement:MovieClip = null;
         var localizationKey:String = null;
         if(this.isTemplateUIEnabled())
         {
            for(currentStageNumber = 1; currentStageNumber <= this.m_numStages; currentStageNumber++)
            {
               stageIndicator = getWidget(m_window["stage" + currentStageNumber + "_indicator_mc"]) as MultiStageQuestProgressBarWidget;
               if(stageIndicator)
               {
                  stageIndicator.locked = false;
                  if(currentStageNumber > this.m_stageNumber)
                  {
                     stageIndicator.locked = true;
                  }
                  if(onWaitingStage || currentStageNumber < this.m_stageNumber || currentStageNumber > this.m_stageNumber)
                  {
                     stageIndicator.active = false;
                  }
                  else
                  {
                     stageIndicator.active = true;
                  }
               }
            }
         }
         else
         {
            for(i = 1; i <= this.m_numStages; i++)
            {
               stageIndicatorElement = m_window["stage" + i + "_indicator_mc"];
               if(stageIndicatorElement != null)
               {
                  localizationKey = "MultiStageQuest_" + this.m_currentStageQuest.chain + "_stage" + i + "Indicator";
                  if(stageIndicatorElement.hasOwnProperty("textfieldouter_mc"))
                  {
                     stageIndicatorElement.textfieldouter_mc.name_tf.text = ZLocUtils.t("Dialogs",localizationKey);
                  }
                  if(i == this.m_stageNumber && onWaitingStage)
                  {
                     stageIndicatorElement.gotoAndStop(3);
                  }
                  else if(i == this.m_stageNumber)
                  {
                     stageIndicatorElement.gotoAndStop(1);
                  }
                  else if(i < this.m_stageNumber)
                  {
                     stageIndicatorElement.gotoAndStop(3);
                  }
                  else if(i > this.m_stageNumber)
                  {
                     stageIndicatorElement.gotoAndStop(2);
                  }
               }
            }
         }
      }
      
      private function onWhatIsThisClick(event:MouseEvent) : void
      {
         var dialog:GenericPopupTitle = null;
         var questChain:String = this.m_currentStageQuest.chain;
         FarmStatsManager.count("fv_multistage",questChain,"how_work","impression");
         var showTutorialKey:String = "multiStageQuestDialog_" + questChain + "_showTutorial";
         var showTutorial:Boolean = Global.farmGameSettingsManager.getString(showTutorialKey,"true") == "true";
         if(showTutorial)
         {
            enableInput = false;
            TutorialUI.displayBundleTutorialWindow("Dialogs",questChain,"assets/dialogs/4d_elements/" + questChain + "/" + questChain,false,this.onTutorialClose);
         }
         else
         {
            dialog = new GenericPopupTitle(ZLocUtils.t("Quests",this.m_currentStageQuest.textBundle + "_Title"),ZLocUtils.t("Dialogs","MultiStageQuest_" + questChain + "_whatIsThisText"),true,GenericPopup.TYPE_OK,this.onCloseWhatIsThis,this.ASSET_WHATISTHIS);
            dialog.setAcceptTextName("OkButton");
            UI.displayPopup(dialog,false);
         }
      }
      
      private function onTutorialClose() : void
      {
         enableInput = true;
         FarmStatsManager.count("fv_multistage",this.m_currentStageQuest.chain,"how_work","close");
      }
      
      private function onCloseWhatIsThis(event:Event) : void
      {
         FarmStatsManager.count("fv_multistage",this.m_currentStageQuest.chain,"how_work","close");
      }
   }
}

