package Widgets.Windows.Breeding
{
   import Classes.FeatureBuilding;
   import Classes.breeding.AnimalBreedingSession;
   import Classes.breeding.AnimalBreedingSkillState;
   import Classes.breeding.MutableAnimalState;
   import Classes.util.ZLocUtils;
   import Display.GenericIconPopup;
   import Display.GenericPopup;
   import Display.UI;
   import Engine.Managers.StatsManager;
   import Events.BreedingXpGrantEvent;
   import Events.GenericPopupEvent;
   import Managers.FarmStatsManager;
   import Managers.breeding.AnimalBreedingManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Buttons.ZwButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.Managers.ZwToggleManager;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Core.Toggles.ZwVisibilityToggle;
   import Widgets.Frames.Breeding.BreedingGeneFrame;
   import Widgets.Frames.Breeding.BreedingLevelUpAnimation;
   import Widgets.Frames.Breeding.BreedingLoseFrame;
   import Widgets.Frames.Breeding.BreedingMatingFrame;
   import Widgets.Frames.Breeding.BreedingMilestoneAnimation;
   import Widgets.Frames.Breeding.BreedingProgressFrame;
   import Widgets.Frames.Breeding.BreedingRenderFrame;
   import Widgets.Frames.Breeding.BreedingWinFrame;
   import Widgets.Frames.Breeding.BreedingXpMeter;
   import Widgets.Frames.GenericExpandSlotFrame;
   import Widgets.ProgressBars.BreedingXpProgressBar;
   import Widgets.Tooltips.FarmTextTooltip;
   import Widgets.Windows.FarmWindow;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class BreedingWindow extends FarmWindow
   {
      
      private static const PIGPEN_FEATURE_NAME:String = "pigpenv2";
      
      protected var m_penMatingFrame:BreedingMatingFrame = null;
      
      protected var m_renderFrame:BreedingRenderFrame = null;
      
      protected var m_penGeneFrame:BreedingGeneFrame = null;
      
      protected var m_penProgressFrame:BreedingProgressFrame = null;
      
      protected var m_expandFrame:GenericExpandSlotFrame = null;
      
      protected var m_penWinFrame:BreedingWinFrame = null;
      
      protected var m_penLoseFrame:BreedingLoseFrame = null;
      
      protected var m_building:FeatureBuilding = null;
      
      protected var m_toggleManager:ZwToggleManager = null;
      
      protected var m_featureName:String = "";
      
      protected var m_xpMeter:BreedingXpMeter = null;
      
      protected var m_xpProgressBar:BreedingXpProgressBar = null;
      
      protected var m_levelupAnimation:BreedingLevelUpAnimation = null;
      
      protected var m_milestoneAnimation:BreedingMilestoneAnimation = null;
      
      protected var m_xpToastAnimationFrame:ZwFrame = null;
      
      protected var m_xpToastPointsText:ZwTextField = null;
      
      protected var m_skillState:AnimalBreedingSkillState = Global.player.getBreedingSkillStateForFeature(this.m_building.getItem().name);
      
      public function BreedingWindow(building:FeatureBuilding, assetUrl:String, featureName:String)
      {
         this.m_building = building;
         this.m_featureName = featureName;
         super(assetUrl);
      }
      
      protected function showOnboardingDialogs() : void
      {
         if(!Global.player.getSeenFlag("patInheritMktg"))
         {
            Global.player.setSeenFlag("patInheritMktg");
            StatsManager.count("dialog","breed_pattern_inheritance_50","view");
            UI.showMessage(ZLocUtils.t("Dialogs","BreedingNewInheritanceMarketingBody"),UI.BUTTON_LAYOUT_OK,ZLocUtils.t("Dialogs","BreedingNewInheritanceMarketingTitle"),"assets/dialogs/FV_Support/FV_BreedingLevels/popup_patternChance.png",false);
         }
         if(!Global.player.getSeenFlag("patGuarMktg"))
         {
            Global.player.setSeenFlag("patGuarMktg");
            StatsManager.count("dialog","breeding_guar_pattern_1time","view");
            UI.showMessage(ZLocUtils.t("Dialogs","BreedingPatternGuaranteeMarketingBody"),UI.BUTTON_LAYOUT_OK,ZLocUtils.t("Dialogs","BreedingPatternGuaranteeMarketingTitle"),"assets/dialogs/FV_Support/FV_BreedingLevels/popup_guaranteedPattern.png",false);
         }
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         this.showOnboardingDialogs();
         addWidget(new ZwTextField(m_window.title_tf,ZLocUtils.t("Dialogs",this.m_featureName + "_Title")));
         addWidget(new FarmAnimatedTextButton(m_window.whatisthis_bt,ZLocUtils.t("Dialogs",this.m_featureName + "_HowDoesThisWork"),this.howDoesThisWorkCallback));
         this.setUpMatingWindow();
         this.m_xpProgressBar = addWidget(new BreedingXpProgressBar(m_window.progressBar_mc)) as BreedingXpProgressBar;
         this.m_xpProgressBar.setupProgressBarForLevel(this.m_skillState,this.m_skillState.featureName);
         AnimalBreedingManager.getInstance().addEventListener(BreedingXpGrantEvent.BREEDING_XP_GRANT,this.onXpGrant);
         this.m_levelupAnimation = addWidget(new BreedingLevelUpAnimation(m_window.levelupAnimation_mc,this.m_skillState.featureName)) as BreedingLevelUpAnimation;
         this.m_milestoneAnimation = addWidget(new BreedingMilestoneAnimation(m_window.milestoneAnimation_mc)) as BreedingMilestoneAnimation;
         this.m_xpMeter = addWidget(new BreedingXpMeter(m_window.xpMeter_mc)) as BreedingXpMeter;
         this.m_xpMeter.setupMeterBarForLevel(this.m_skillState,this.m_skillState.featureName);
         this.m_xpMeter.levelupAnimation = this.m_levelupAnimation;
         this.m_xpMeter.milestoneAnimation = this.m_milestoneAnimation;
         this.m_xpToastAnimationFrame = new ZwFrame(m_window.frame_inventory_mc.xpAwardAnimation_mc);
         var holderFrame:ZwFrame = new ZwFrame(this.m_xpToastAnimationFrame.element.pigPointsUnit_mc);
         holderFrame.addWidget(new ZwTextField(holderFrame.element.breeding_tf,ZLocUtils.t("Dialogs",this.m_featureName + "_pointsName")));
         this.m_xpToastPointsText = holderFrame.addWidget(new ZwTextField(holderFrame.element.points_tf,ZLocUtils.t("Dialogs",this.m_featureName + "_pointsNumber",{"points":0}))) as ZwTextField;
         this.m_xpToastAnimationFrame.addWidget(holderFrame);
         addWidget(this.m_xpToastAnimationFrame);
         this.setupMeterTooltips();
         this.setupTabFrames();
         this.m_penWinFrame = new BreedingWinFrame(m_window.frame_inventory_mc.win_mc,this);
         addWidget(this.m_penWinFrame,false);
         this.m_penLoseFrame = new BreedingLoseFrame(m_window.frame_inventory_mc.lose_mc,this);
         addWidget(this.m_penLoseFrame,false);
         this.m_window.x += 18;
      }
      
      public function getFeatureName() : String
      {
         return this.m_featureName;
      }
      
      protected function setUpMatingWindow() : void
      {
         this.m_penMatingFrame = new BreedingMatingFrame(m_window.frame_inventory_mc.breed_mc,this);
         addWidget(this.m_penMatingFrame,false);
      }
      
      protected function getExpansionData() : Array
      {
         var result:Array = new Array();
         var itemData:Array = this.m_building.expand.getExpandSlotData();
         if(itemData)
         {
            result = itemData;
         }
         return result;
      }
      
      override protected function release() : void
      {
         super.release();
         if(this.m_xpToastAnimationFrame != null && this.m_xpToastAnimationFrame.element != null)
         {
            (this.m_xpToastAnimationFrame.element as MovieClip).removeEventListener(Event.ENTER_FRAME,this.onToastEnterFrame);
         }
         AnimalBreedingManager.getInstance().removeEventListener(BreedingXpGrantEvent.BREEDING_XP_GRANT,this.onXpGrant);
         this.m_building = null;
         this.m_penMatingFrame = null;
         this.m_expandFrame = null;
         this.m_penGeneFrame = null;
         this.m_renderFrame = null;
         this.m_toggleManager = null;
         this.m_xpMeter = null;
         this.m_xpProgressBar = null;
         this.m_penProgressFrame = null;
         this.m_xpToastAnimationFrame = null;
         this.m_xpToastPointsText = null;
      }
      
      protected function onClickExpand() : void
      {
         var message:String = null;
         var dialog:GenericIconPopup = null;
         var seenFlag:String = "expand" + this.building.bldgName + this.building.storageLevel;
         if(!Global.player.getSeenFlag(seenFlag) && this.building.expand.hasNextExpansion())
         {
            message = ZLocUtils.t("Dialogs",this.building.bldgName + "ExpandMessage");
            dialog = new GenericIconPopup(message,GenericPopup.TYPE_SHARECANCEL,this.onShareExpansion,this.building.getItem().icon);
            UI.displayPopup(dialog,false);
            Global.player.setSeenFlag(seenFlag);
            FarmStatsManager.count(this.m_featureName,this.m_featureName + "_expansion","expansion_started","time_" + this.building.storageLevel);
         }
      }
      
      protected function onShareExpansion(event:GenericPopupEvent) : void
      {
         var hrefUrl:String = null;
         var bundleData:Object = null;
         if(event.button == GenericPopup.ACCEPT)
         {
            hrefUrl = "gifts.php?giftRecipient=" + Global.player.snUser.uid;
            bundleData = {
               "images":[{
                  "href":"{SN_APP_URL}" + hrefUrl,
                  "src":this.building.getItem().icon
               }],
               "reward_link":hrefUrl
            };
            GlobalEngine.socialNetwork.publishFeedStory(this.m_featureName + "ExpandAsk",bundleData,[],false);
         }
      }
      
      public function get building() : FeatureBuilding
      {
         return this.m_building;
      }
      
      protected function howDoesThisWorkCallback(event:MouseEvent) : void
      {
      }
      
      public function displayWinWindow(mutableAnimalState:MutableAnimalState) : void
      {
         this.m_penWinFrame.displayWindow(mutableAnimalState);
      }
      
      public function displayLoseWindow() : void
      {
         this.m_penLoseFrame.visible = true;
      }
      
      public function displayMatingWindow(breedingSession:AnimalBreedingSession) : void
      {
         var maxLimit:Number = NaN;
         breedingSession.suiteSlot = AnimalBreedingManager.getInstance().findFreeSlot(breedingSession);
         if(breedingSession.suiteSlot >= 0)
         {
            if(AnimalBreedingManager.getInstance().canBreed(breedingSession.owner,true))
            {
               this.m_penMatingFrame.loadData(breedingSession);
               this.m_penMatingFrame.visible = true;
            }
            else
            {
               maxLimit = AnimalBreedingManager.getInstance().getMaxAnimalsCount(this.m_building.getItemName());
               UI.displayMessage(ZLocUtils.t("Dialogs",this.m_featureName + "_Reached_Limit",{"quantity":maxLimit}),0,null,"",true);
            }
         }
         else
         {
            UI.displayMessage(ZLocUtils.t("Dialogs",this.m_featureName + "_No_Free_Slots"),0,null,"",true);
         }
      }
      
      public function displayPostBreedingWindow(result:Object, breedingSession:AnimalBreedingSession) : void
      {
         var mutableState:MutableAnimalState = null;
         if(result != null && result.reward != null && result.reward.mutableState != null)
         {
            this.m_penWinFrame.visible = true;
            mutableState = MutableAnimalState.createFromPhpString("",result.reward.mutableState);
            this.m_penWinFrame.displayWindow(mutableState);
            FarmStatsManager.count(this.m_featureName,"breeding","lamb_born",mutableState.gender,mutableState.statsHSV + ":T:" + Global.animalBreedingSettings.getPatternTrait(this.building.getItem().name,mutableState.pattern));
         }
         else
         {
            this.m_penLoseFrame.visible = true;
            this.m_penLoseFrame.displayWindow(breedingSession);
            FarmStatsManager.count(this.m_featureName,"breeding","breed_failed");
         }
      }
      
      public function onBeginBreed(breedSession:AnimalBreedingSession) : void
      {
         var patternGuarantee:String;
         this.toggleUI(false);
         AnimalBreedingManager.getInstance().beginBreed(breedSession,function(result:Object):void
         {
            toggleUI(true);
         });
         patternGuarantee = breedSession.patternGuarantee == true ? "guar_pattern" : "no_guar_pattern";
         FarmStatsManager.count(this.m_featureName,"breeding","started",String(breedSession.numPotions),patternGuarantee);
      }
      
      public function onXpGrant(event:BreedingXpGrantEvent) : void
      {
         var xpGranted:int = event.xpGranted;
         this.m_xpProgressBar.addXp(xpGranted);
         this.m_xpMeter.checkMilestoneCompletion(event.rewardsGranted);
         this.m_xpMeter.updateText();
         if(this.m_penProgressFrame != null)
         {
            this.m_penProgressFrame.update();
         }
         this.m_xpToastAnimationFrame.visible = true;
         this.m_xpToastPointsText.text = ZLocUtils.t("Dialogs",this.m_featureName + "_pointsNumber",{"points":xpGranted});
         (this.m_xpToastAnimationFrame.element as MovieClip).addEventListener(Event.ENTER_FRAME,this.onToastEnterFrame);
         (this.m_xpToastAnimationFrame.element as MovieClip).gotoAndPlay(1);
         this.setupMeterTooltips();
      }
      
      protected function setupTabFrames() : void
      {
         var breedingXpGameButton:FarmAnimatedTextButton = null;
         var sheepPenButton:FarmAnimatedTextButton = new FarmAnimatedTextButton(m_window.generic0_bt,ZLocUtils.t("Dialogs",this.m_featureName + "_Inventory"),null);
         addWidget(sheepPenButton);
         this.m_renderFrame = new BreedingRenderFrame(m_window.frame_inventory_mc,this);
         addWidget(this.m_renderFrame);
         this.m_toggleManager = new ZwToggleManager();
         if(m_window.generic1_bt != null)
         {
            breedingXpGameButton = new FarmAnimatedTextButton(m_window.generic1_bt,ZLocUtils.t("Dialogs",this.m_featureName + "_Progress"),null);
            addWidget(breedingXpGameButton);
            this.m_penProgressFrame = new BreedingProgressFrame(m_window.frame_progress_mc,this.m_skillState);
            addWidget(this.m_penProgressFrame,false);
            this.m_toggleManager.addToggle(new ZwVisibilityToggle(breedingXpGameButton,this.m_penProgressFrame));
         }
         var expandButton:FarmAnimatedTextButton = new FarmAnimatedTextButton(m_window.generic2_bt,ZLocUtils.t("Dialogs",this.m_featureName + "_Expansion"),null);
         addWidget(expandButton);
         this.m_expandFrame = new GenericExpandSlotFrame(m_window.frame_expand_mc,this.getExpansionData(),this,this.m_building,this.m_building.expand);
         this.m_expandFrame.setItemData(this.getExpansionData());
         addWidget(this.m_expandFrame,false);
         this.m_toggleManager.addToggle(new ZwVisibilityToggle(sheepPenButton,this.m_renderFrame),true);
         this.m_toggleManager.addToggle(new ZwVisibilityToggle(expandButton,this.m_expandFrame,this.onClickExpand));
      }
      
      private function setupMeterTooltips() : void
      {
         var points:int = 0;
         var nextLevel:int = this.m_skillState.level + 1;
         var xpForNextLevel:int = Global.animalBreedingSettings.getXpForLevel(nextLevel,this.m_skillState.featureName);
         var toolTipText:String = "";
         if(xpForNextLevel < int.MAX_VALUE)
         {
            points = xpForNextLevel - this.m_skillState.xp;
            toolTipText = ZLocUtils.t("Dialogs",this.m_featureName + "_remainingBreedingPoints",{
               "pointNum":points,
               "levelNum":nextLevel
            });
         }
         else
         {
            toolTipText = ZLocUtils.t("Dialogs","atMaxBreedingLevel");
         }
         var toolTip:FarmTextTooltip = new FarmTextTooltip(toolTipText);
         this.m_xpProgressBar.detachTooltip();
         this.m_xpProgressBar.attachTooltip(toolTip);
         this.m_xpMeter.detachTooltip();
         this.m_xpMeter.attachTooltip(toolTip);
      }
      
      private function onToastEnterFrame(event:Event) : void
      {
         if(this.m_xpToastAnimationFrame != null && this.m_xpToastAnimationFrame.element != null)
         {
            if((this.m_xpToastAnimationFrame.element as MovieClip).currentFrame >= (this.m_xpToastAnimationFrame.element as MovieClip).totalFrames)
            {
               (this.m_xpToastAnimationFrame.element as MovieClip).removeEventListener(Event.ENTER_FRAME,this.onToastEnterFrame);
               (this.m_xpToastAnimationFrame.element as MovieClip).stop();
            }
         }
      }
      
      protected function toggleUI(enable:Boolean = false) : void
      {
         var closeBut:ZwButton = getWidget(m_window.close_bt) as ZwButton;
         if(closeBut != null)
         {
            if(!enable)
            {
               closeBut.enabled = false;
            }
            else
            {
               closeBut.enabled = true;
            }
         }
         this.m_renderFrame.updateUI(enable);
      }
   }
}

