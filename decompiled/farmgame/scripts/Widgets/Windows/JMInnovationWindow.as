package Widgets.Windows
{
   import Classes.Constants.Experiments;
   import Classes.Constants.ZLocConstants;
   import Classes.FeatureBuilding;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.HUD.HUD;
   import Display.JMConfirmationPopup;
   import Display.UI;
   import Events.GenericPopupEvent;
   import Managers.FarmStatsManager;
   import Managers.JMInnovationManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Buttons.FarmButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.JMInnovationCraftConsumableSlotFrame;
   import Widgets.Frames.JMInnovationHarvestStationSlotFrame;
   import Widgets.Frames.JMInnovationRecipeStationSlotFrame;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   
   public class JMInnovationWindow extends FarmWindowWithTutorial
   {
      
      private static const NUM_TUTORIAL_SCENES:int = 5;
      
      private static const INNOVATION_FEATURE_SEEN_FLAG:String = "JMInnovation_Tutorial";
      
      private static const FEATURE_NAME:String = "JMInnovation";
      
      protected var m_featureName:String;
      
      private const WHATISTHIS_MC:String = "whatisthis_mc";
      
      private const TITLE_TF:String = "title_tf";
      
      private const CRAFTCONSUMABLE_MC:String = "craftConsumable_mc";
      
      private const CONSUMABLE_MC:String = "consumable_mc";
      
      private const TOTEM_MC:String = "totem_mc";
      
      private const HARVESTSTATION_MC:String = "harvestStation_mc";
      
      private const CARD_MC:String = "card_mc";
      
      private const CLOSE_HS_BT:String = "closeHS_bt";
      
      private const RECIPESTATION_MC:String = "recipeStation_mc";
      
      private const TITLE_0_TF:String = "title_0_tf";
      
      private const SUBTITLE_0_TF:String = "subtitle_0_tf";
      
      private const TITLE_1_TF:String = "title_1_tf";
      
      private const SUBTITLE_1_TF:String = "subtitle_1_tf";
      
      private const TITLE_2_TF:String = "title_2_tf";
      
      private const SUBTITLE_2_TF:String = "subtitle_2_tf";
      
      private const TITLE_3_TF:String = "title_3_tf";
      
      private const SUBTITLE_3_TF:String = "subtitle_3_tf";
      
      private const TIMER_TF:String = "timer_tf";
      
      private const CRAFT_BT:String = "craft_bt";
      
      private const ANIM_MC:String = "anim_mc";
      
      private const TREASURE_EFFECT_MC:String = "treasure_effect_mc";
      
      private const VIEW_BT:String = "view_bt";
      
      private const GEMSBUY_BT:String = "gemsBuy_bt";
      
      private const SPELLCOUNT_TF:String = "spellCount_tf";
      
      private const TEXT_TITLE:String = "_title";
      
      private const TEXT_WHATISTHIS:String = "HowDoesThisWork";
      
      private const TEXT_COLLECT_HOVER:String = "_collect_button_hover";
      
      private const TEXT_COLLECT_LIMIT_HOVER:String = "_craft_collect_button_hover";
      
      private const TEXT_CRAFT_LOCKED_HOVER:String = "_craft_locked_button_hover";
      
      private var m_craftConsumableFrame:JMInnovationCraftConsumableSlotFrame;
      
      private var m_harvestStationFrame:JMInnovationHarvestStationSlotFrame;
      
      private var m_recipeStationFrame:JMInnovationRecipeStationSlotFrame;
      
      private var m_viewButton:FarmAnimatedTextButton;
      
      private var m_buyButton:FarmAnimatedTextButton;
      
      private var m_closeHavestStation:FarmButton;
      
      private var m_craftButton:FarmAnimatedTextButton;
      
      private var m_totemFrame:ZwFrame;
      
      private var m_animMc:MovieClip;
      
      private var m_treasureEffect:MovieClip;
      
      private var m_timerTf:ZwTextField;
      
      private var m_spellCountTf:ZwTextField;
      
      private var m_timer:Timer;
      
      private var m_craftState:int;
      
      private var m_maxCraftLimit:Boolean = false;
      
      private var m_state:Array = new Array(0,0,0);
      
      public function JMInnovationWindow(building:FeatureBuilding, featureName:String = "JMInnovation", assetPath:String = "")
      {
         if(building != null)
         {
            assetPath = building.getItem().getDialogConfig("storage").path;
         }
         this.m_featureName = featureName;
         var tutorialPage:int = NUM_TUTORIAL_SCENES;
         if(!Global.player.getSeenFlag(INNOVATION_FEATURE_SEEN_FLAG))
         {
            tutorialPage++;
         }
         this.manager.initialize();
         super(this.m_featureName,assetPath,tutorialPage,true,true);
      }
      
      override protected function postLoadComplete() : void
      {
         if(m_window.hasOwnProperty(this.TITLE_TF))
         {
            addWidget(new ZwTextField(m_window[this.TITLE_TF],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + this.TEXT_TITLE)));
         }
         if(m_window.hasOwnProperty(this.WHATISTHIS_MC))
         {
            addWidget(new FarmAnimatedTextButton(m_window[this.WHATISTHIS_MC],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.TEXT_WHATISTHIS),this.howDoesThisWorkClick));
         }
         if(m_window.hasOwnProperty(this.CRAFTCONSUMABLE_MC))
         {
            m_window[this.CRAFTCONSUMABLE_MC].visible = true;
            if(m_window[this.CRAFTCONSUMABLE_MC].hasOwnProperty(this.CONSUMABLE_MC))
            {
               addWidget(this.m_craftConsumableFrame = new JMInnovationCraftConsumableSlotFrame(this.m_featureName,m_window[this.CRAFTCONSUMABLE_MC][this.CONSUMABLE_MC],this));
            }
            if(m_window[this.CRAFTCONSUMABLE_MC].hasOwnProperty(this.TOTEM_MC))
            {
               addWidget(this.m_totemFrame = new ZwFrame(m_window[this.CRAFTCONSUMABLE_MC][this.TOTEM_MC]));
               if(this.m_totemFrame.element.hasOwnProperty(this.TIMER_TF))
               {
                  this.m_totemFrame.addWidget(this.m_timerTf = new ZwTextField(this.m_totemFrame.element[this.TIMER_TF]),false);
               }
               if(this.m_totemFrame.element.hasOwnProperty(this.TREASURE_EFFECT_MC))
               {
                  this.m_treasureEffect = this.m_totemFrame.element[this.TREASURE_EFFECT_MC] as MovieClip;
                  this.disableTreasureEffect();
               }
               if(this.m_totemFrame.element.hasOwnProperty(this.ANIM_MC))
               {
                  this.m_animMc = this.m_totemFrame.element[this.ANIM_MC] as MovieClip;
                  this.disableAnimationEffect();
               }
               if(this.m_totemFrame.element.hasOwnProperty(this.CRAFT_BT))
               {
                  addWidget(this.m_craftButton = new FarmAnimatedTextButton(this.m_totemFrame.element[this.CRAFT_BT],"Craft",this.onClickCraftButton));
               }
               this.updateTotemFrameAndCraftButtonState();
            }
            if(m_window[this.CRAFTCONSUMABLE_MC].hasOwnProperty(this.VIEW_BT))
            {
               addWidget(this.m_viewButton = new FarmAnimatedTextButton(m_window[this.CRAFTCONSUMABLE_MC][this.VIEW_BT],"View Gatherers",this.onClickViewButton));
            }
         }
         if(m_window.hasOwnProperty(this.HARVESTSTATION_MC))
         {
            m_window[this.HARVESTSTATION_MC].visible = false;
            if(m_window[this.HARVESTSTATION_MC].hasOwnProperty(this.CARD_MC))
            {
               addWidget(this.m_harvestStationFrame = new JMInnovationHarvestStationSlotFrame(this.m_featureName,m_window[this.HARVESTSTATION_MC][this.CARD_MC],this));
            }
            if(m_window[this.HARVESTSTATION_MC].hasOwnProperty(this.CLOSE_HS_BT))
            {
               addWidget(this.m_closeHavestStation = new FarmButton(m_window[this.HARVESTSTATION_MC][this.CLOSE_HS_BT],this.onCloseHarvestStation),false);
            }
         }
         if(m_window.hasOwnProperty(this.RECIPESTATION_MC))
         {
            addWidget(this.m_recipeStationFrame = new JMInnovationRecipeStationSlotFrame(this.m_featureName,m_window[this.RECIPESTATION_MC],this));
            this.setupSpellText();
         }
         var variant:int = Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_JMINNOVATION_GEMSBUY);
         if(Boolean(variant) && variant == 1)
         {
            if(m_window.hasOwnProperty(this.GEMSBUY_BT))
            {
               addWidget(this.m_buyButton = new FarmAnimatedTextButton(m_window[this.GEMSBUY_BT],"Buy Gems",this.onClickBuyGems),true);
            }
         }
         super.postLoadComplete();
         this.startTimer();
      }
      
      private function howDoesThisWorkClick(event:Event) : void
      {
         showTutorial();
      }
      
      private function onClickViewButton(event:Event) : void
      {
         if(m_window[this.HARVESTSTATION_MC].visible)
         {
            m_window[this.HARVESTSTATION_MC].visible = false;
            this.m_viewButton.text = "View Gatherers";
            FarmStatsManager.count(this.m_featureName,"ui_toggle","view_recipe_book","click");
         }
         else
         {
            FarmStatsManager.count(this.m_featureName,"ui_toggle","view_gathers","click");
            m_window[this.HARVESTSTATION_MC].visible = true;
            this.m_viewButton.text = "View Recipe Book";
         }
      }
      
      private function onClickBuyGems(event:Event) : void
      {
         tintWindow();
         enableInput = false;
         this.manager.openBuyWindow(this);
      }
      
      private function onCloseHarvestStation(event:Event) : void
      {
         m_window[this.HARVESTSTATION_MC].visible = false;
      }
      
      private function updateTotemFrameAndCraftButtonState() : void
      {
         var totemState:int = 0;
         var craftState:int = this.manager.getAndUpdateStateForCrafting();
         if(this.m_craftState != craftState)
         {
            if(craftState == JMInnovationManager.STATE_IDLE)
            {
               this.m_craftButton.text = "Craft";
               this.m_craftButton.enabled = true;
               this.m_craftButton.detachTooltip();
               this.m_craftButton.callback = this.onClickCraftButton;
            }
            else if(craftState == JMInnovationManager.STATE_CRAFT)
            {
               this.m_craftButton.visible = false;
               this.m_timerTf.text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + this.TEXT_COLLECT_HOVER,{"time":HUD.getformattedTimeLeft(this.manager.getTimeLeftForCraftSlot())});
               this.m_timerTf.visible = true;
            }
            else if(craftState == JMInnovationManager.STATE_COLLECT)
            {
               this.m_timerTf.visible = false;
               this.m_craftButton.text = "Collect";
               this.m_craftButton.visible = true;
               this.m_craftButton.enabled = true;
               this.m_craftButton.detachTooltip();
               this.m_craftButton.callback = this.onClickCollectBuff;
               if(this.manager.hasMaxCapRechedForBuffs())
               {
                  this.m_craftButton.callback = null;
                  this.m_maxCraftLimit = true;
                  FarmGameUtil.disableButtonAndShowTooltip(this.m_craftButton,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + this.TEXT_COLLECT_LIMIT_HOVER));
               }
            }
            else if(craftState == JMInnovationManager.STATE_LOCKED)
            {
               this.m_craftButton.text = "Craft";
               this.m_craftButton.callback = null;
               FarmGameUtil.disableButtonAndShowTooltip(this.m_craftButton,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + this.TEXT_CRAFT_LOCKED_HOVER));
            }
            this.m_craftState = craftState;
         }
         if(craftState == JMInnovationManager.STATE_COLLECT && this.m_maxCraftLimit)
         {
            if(!this.manager.hasMaxCapRechedForBuffs())
            {
               this.m_maxCraftLimit = false;
               this.m_craftButton.enabled = true;
               this.m_craftButton.detachTooltip();
               this.m_craftButton.callback = this.onClickCollectBuff;
            }
         }
         if(craftState == JMInnovationManager.STATE_CRAFT)
         {
            this.m_timerTf.text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + this.TEXT_COLLECT_HOVER,{"time":HUD.getformattedTimeLeft(this.manager.getTimeLeftForCraftSlot())});
         }
         if(this.m_totemFrame)
         {
            totemState = this.getTotemState(craftState);
            (this.m_totemFrame.element as MovieClip).gotoAndStop(totemState);
         }
      }
      
      private function getTotemState(craftState:int) : int
      {
         var result:int = 0;
         switch(craftState)
         {
            case JMInnovationManager.STATE_CRAFT:
               result = 2;
               break;
            case JMInnovationManager.STATE_IDLE:
            case JMInnovationManager.STATE_LOCKED:
               result = 3;
               break;
            case JMInnovationManager.STATE_COLLECT:
               result = 4;
         }
         return result;
      }
      
      private function onClickCraftButton(event:Event) : void
      {
         var confirmationText:String = null;
         var counterText:String = null;
         if(this.manager.gemConsumableInInventory >= this.manager.gemConsumableRequiredForCraft)
         {
            confirmationText = ZLocUtils.t("Dialogs",this.m_featureName + "_use_gem_confirm");
            counterText = this.manager.gemConsumableInInventory.toString() + "/" + this.manager.gemConsumableRequiredForCraft.toString();
            UI.displayPopup(new JMConfirmationPopup(confirmationText,GenericPopup.TYPE_ACCEPTCANCEL,this.beginCraft,this.manager.craftConfirmWindow,counterText),false);
         }
         else
         {
            this.beginCraft(null);
         }
      }
      
      private function beginCraft(event:GenericPopupEvent = null) : void
      {
         if(event != null && event.button == GenericPopup.ACCEPT)
         {
            this.manager.craft(true);
         }
         else
         {
            this.manager.craft(false);
         }
         FarmStatsManager.count(this.m_featureName,"feature_ui","craft_button","click");
         this.m_craftConsumableFrame.refresh();
         this.updateTotemFrameAndCraftButtonState();
      }
      
      private function onClickCollectBuff(event:Event) : void
      {
         this.manager.collectBuff(this);
         this.enableWindow(false);
      }
      
      override public function refreshWindow() : void
      {
         var state:int = 0;
         this.m_craftConsumableFrame.refresh();
         this.m_recipeStationFrame.refresh();
         this.updateTotemFrameAndCraftButtonState();
         for(var slotIndex:int = 1; slotIndex < this.manager.buildingNameArray.length; slotIndex++)
         {
            state = this.manager.getStateForBuilding(slotIndex);
            if(this.m_state[slotIndex - 1] != state)
            {
               this.m_harvestStationFrame.refresh();
               this.m_state[slotIndex - 1] = state;
            }
         }
         if(this.m_spellCountTf)
         {
            this.m_spellCountTf.text = "(" + this.manager.totalBuffCount + "/" + JMInnovationManager.TOTAL_BUFF_COUNT + " Spells)";
         }
      }
      
      public function enableWindow(enable:Boolean) : void
      {
         this.enableInput = enable;
         if(enable)
         {
            untintWindow();
         }
         else
         {
            tintWindow();
         }
      }
      
      private function get manager() : JMInnovationManager
      {
         return JMInnovationManager.getInstance(this.m_featureName);
      }
      
      override public function close() : void
      {
         if(this.m_timer)
         {
            this.m_timer.stop();
            this.m_timer.removeEventListener(TimerEvent.TIMER,this.onTimer);
            this.m_timer = null;
         }
         FarmStatsManager.count(this.m_featureName,"feature_ui","main_ui_close","click");
         super.close();
      }
      
      private function onTimer(event:TimerEvent) : void
      {
         this.refreshWindow();
      }
      
      private function startTimer() : void
      {
         if(this.m_timer == null)
         {
            this.m_timer = new Timer(1000);
            this.m_timer.addEventListener(TimerEvent.TIMER,this.onTimer);
            this.m_timer.start();
         }
      }
      
      private function setupSpellText() : void
      {
         if(this.m_recipeStationFrame.element.hasOwnProperty(this.TITLE_0_TF))
         {
            this.m_recipeStationFrame.element[this.TITLE_0_TF].text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_" + this.TITLE_0_TF);
            this.m_recipeStationFrame.element[this.TITLE_0_TF].visible = true;
         }
         if(this.m_recipeStationFrame.element.hasOwnProperty(this.TITLE_1_TF))
         {
            this.m_recipeStationFrame.element[this.TITLE_1_TF].text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_" + this.TITLE_1_TF);
            this.m_recipeStationFrame.element[this.TITLE_1_TF].visible = true;
         }
         if(this.m_recipeStationFrame.element.hasOwnProperty(this.TITLE_2_TF))
         {
            this.m_recipeStationFrame.element[this.TITLE_2_TF].text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_" + this.TITLE_2_TF);
            this.m_recipeStationFrame.element[this.TITLE_2_TF].visible = true;
         }
         if(this.m_recipeStationFrame.element.hasOwnProperty(this.TITLE_3_TF))
         {
            this.m_recipeStationFrame.element[this.TITLE_3_TF].text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_" + this.TITLE_3_TF);
            this.m_recipeStationFrame.element[this.TITLE_3_TF].visible = true;
         }
         if(this.m_recipeStationFrame.element.hasOwnProperty(this.SUBTITLE_0_TF))
         {
            this.m_recipeStationFrame.element[this.SUBTITLE_0_TF].text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_" + this.SUBTITLE_0_TF);
            this.m_recipeStationFrame.element[this.SUBTITLE_0_TF].visible = true;
         }
         if(this.m_recipeStationFrame.element.hasOwnProperty(this.SUBTITLE_1_TF))
         {
            this.m_recipeStationFrame.element[this.SUBTITLE_1_TF].text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_" + this.SUBTITLE_1_TF);
            this.m_recipeStationFrame.element[this.SUBTITLE_1_TF].visible = true;
         }
         if(this.m_recipeStationFrame.element.hasOwnProperty(this.SUBTITLE_2_TF))
         {
            this.m_recipeStationFrame.element[this.SUBTITLE_2_TF].text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_" + this.SUBTITLE_2_TF);
            this.m_recipeStationFrame.element[this.SUBTITLE_2_TF].visible = true;
         }
         if(this.m_recipeStationFrame.element.hasOwnProperty(this.SUBTITLE_3_TF))
         {
            this.m_recipeStationFrame.element[this.SUBTITLE_3_TF].text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_" + this.SUBTITLE_3_TF);
            this.m_recipeStationFrame.element[this.SUBTITLE_3_TF].visible = true;
         }
         if(this.m_recipeStationFrame.element.hasOwnProperty(this.SPELLCOUNT_TF))
         {
            addWidget(this.m_spellCountTf = new ZwTextField(this.m_recipeStationFrame.element[this.SPELLCOUNT_TF],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + this.TITLE_TF)));
         }
      }
      
      private function disableTreasureEffect() : void
      {
         if(this.m_treasureEffect)
         {
            this.m_treasureEffect.stop();
            this.m_treasureEffect.visible = false;
         }
      }
      
      private function enableTreasureEffect() : void
      {
         if(this.m_treasureEffect)
         {
            this.m_treasureEffect.play();
            this.m_treasureEffect.visible = true;
         }
      }
      
      private function disableAnimationEffect() : void
      {
         if(this.m_animMc)
         {
            this.m_animMc.stop();
            this.m_animMc.visible = false;
         }
      }
      
      private function enableAnimationEffect() : void
      {
         if(this.m_animMc)
         {
            this.m_animMc.play();
            this.m_animMc.visible = true;
         }
      }
   }
}

