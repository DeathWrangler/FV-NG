package Widgets.Slots
{
   import Classes.Animal;
   import Classes.Constants.ZLocConstants;
   import Classes.DragonBreeding.DragonBreedingSkillState;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Display.Dialogs.GenericDialog;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Managers.DragonBreedingConfigManager;
   import Managers.DragonBreedingManager;
   import Managers.FarmStatsManager;
   import Transactions.BreedingProjects.TPurchaseDragonBreedingLevel;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.ResourcePreviewFrame;
   import Widgets.ProgressBars.FarmProgressBar;
   import com.troyer.widget.event.WidgetControllerEvent;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class DragonBreedingProgressSlot extends ZwSlotFrame
   {
      
      private static const BIG_PRIZE_LOCKED_FRAME:int = 1;
      
      private static const BIG_PRIZE_UNLOCKED_FRAME:int = 2;
      
      private static const MAX_EPIC_LEVEL:int = 30;
      
      private var m_levelTextField:ZwTextField = null;
      
      private var m_levelNumberTextField:ZwTextField = null;
      
      private var m_progressBar:FarmProgressBar = null;
      
      private var m_prizeIcon:ResourcePreviewFrame = null;
      
      private var m_prizeName:ZwTextField = null;
      
      private var m_cashUnlockButton:FarmAnimatedTextButton = null;
      
      private var m_lockIcon:ZwFrame = null;
      
      private var m_featureName:String = "";
      
      private var m_level:int = 0;
      
      private var m_neededXp:int = 0;
      
      private var m_confirmBuyWindow:GenericDialog;
      
      private var m_isNextBigReward:Boolean = false;
      
      private var m_cashCost:int = 0;
      
      private var m_addNestMc:ZwFrame = null;
      
      private var m_nestText:ZwTextField = null;
      
      private const GENERIC_TF:String = "generic_tf";
      
      private const LEVEL_TF:String = "level_tf";
      
      private const BAR_GROUP_MC:String = "barGroup_mc";
      
      private const PRIZE_ICON_MC:String = "prizeIcon_mc";
      
      private const ITEM_NAME_TF:String = "itemName_tf";
      
      private const UNLOCK_BTN:String = "unlock_bt";
      
      private const UNLOCK_ICON_MC:String = "lockIcon_mc";
      
      private const NEST_MC:String = "addnest_mc";
      
      private const NEST_TF:String = "nest_tf";
      
      private var m_skillState:DragonBreedingSkillState = null;
      
      public function DragonBreedingProgressSlot(element:DisplayObject, featureName:String)
      {
         this.m_featureName = featureName;
         this.m_skillState = DragonBreedingManager.getInstance(featureName).getBreedingSkillState();
         super(element);
         if(m_element.hasOwnProperty(this.GENERIC_TF))
         {
            this.m_levelTextField = new ZwTextField(m_element[this.GENERIC_TF],"Level");
            addWidget(this.m_levelTextField);
         }
         if(m_element.hasOwnProperty(this.LEVEL_TF))
         {
            this.m_levelNumberTextField = new ZwTextField(m_element[this.LEVEL_TF],"");
            addWidget(this.m_levelNumberTextField);
         }
         if(m_element.hasOwnProperty(this.BAR_GROUP_MC))
         {
            this.m_progressBar = new FarmProgressBar(m_element[this.BAR_GROUP_MC]);
            addWidget(this.m_progressBar);
         }
         if(m_element.hasOwnProperty(this.ITEM_NAME_TF))
         {
            this.m_prizeName = new ZwTextField(m_element[this.ITEM_NAME_TF]);
            addWidget(this.m_prizeName);
         }
         if(m_element.hasOwnProperty(this.UNLOCK_BTN))
         {
            this.m_cashUnlockButton = new FarmAnimatedTextButton(m_element[this.UNLOCK_BTN],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"BreedingUnlockNow"),this.onUnlockClick);
            addWidget(this.m_cashUnlockButton);
         }
         if(m_element.hasOwnProperty(this.UNLOCK_ICON_MC))
         {
            this.m_lockIcon = new ZwFrame(m_element[this.UNLOCK_ICON_MC]);
            addWidget(this.m_lockIcon);
         }
         if(m_element.hasOwnProperty(this.NEST_MC))
         {
            this.m_addNestMc = new ZwFrame(m_element[this.NEST_MC]);
            addWidget(this.m_addNestMc);
            if(this.m_addNestMc.element.hasOwnProperty(this.NEST_TF))
            {
               this.m_nestText = new ZwTextField(this.m_addNestMc.element[this.NEST_TF],"+1\nNEST");
               addWidget(this.m_nestText);
            }
         }
      }
      
      override public function release() : void
      {
         super.release();
         this.m_levelTextField = null;
         this.m_levelNumberTextField = null;
         this.m_progressBar = null;
         this.m_prizeIcon = null;
         this.m_prizeName = null;
         this.m_cashUnlockButton = null;
         this.m_lockIcon = null;
         this.m_confirmBuyWindow = null;
         this.m_addNestMc = null;
      }
      
      override public function populate(data:Object) : void
      {
         var levelText:String = null;
         super.populate(data);
         this.m_level = data.level;
         if(data.hasOwnProperty("isNextBigReward"))
         {
            this.m_isNextBigReward = data.isNextBigReward;
         }
         if(this.m_level == 0)
         {
            alpha = 0;
         }
         else
         {
            alpha = 1;
         }
         if(this.m_levelNumberTextField != null)
         {
            levelText = this.m_level.toString();
            this.m_levelNumberTextField.text = levelText;
            this.m_levelNumberTextField.visible = true;
         }
         if(this.m_levelTextField != null)
         {
            this.m_levelTextField.visible = true;
         }
         if(this.m_level % 5 == 0)
         {
            if(this.m_isNextBigReward)
            {
               this.m_cashCost = DragonBreedingManager.getInstance(this.m_featureName).getUnlockLevelCostByXp();
            }
            else
            {
               this.m_cashCost = DragonBreedingManager.getInstance(this.m_featureName).getUnlockCostForLevel(this.m_level);
            }
         }
         this.setUpProgressBar(data);
         this.setUpPrizeInfo(data);
         if(null != this.m_skillState)
         {
            this.m_neededXp = this.m_skillState.getXpNeededForLevel(this.m_level);
         }
         if(this.m_prizeIcon != null)
         {
            if(this.m_level == MAX_EPIC_LEVEL)
            {
            }
         }
      }
      
      private function setUpProgressBar(data:Object) : void
      {
         var skillLevelLessThanSlot:Boolean = false;
         var isLocked:Boolean = false;
         var skillStateLevel:int = this.m_skillState.level;
         var thisSlotsLevel:int = this.m_level;
         if(this.m_progressBar != null)
         {
            this.m_progressBar.minimum = 0;
            this.m_progressBar.maximum = thisSlotsLevel > 0 ? DragonBreedingConfigManager.getInstance(this.m_featureName).getXpForLevel(thisSlotsLevel) : 0;
            if(thisSlotsLevel < skillStateLevel)
            {
               this.m_progressBar.progress = this.m_progressBar.maximum;
            }
            else if(thisSlotsLevel > skillStateLevel)
            {
               this.m_progressBar.progress = this.m_progressBar.minimum;
            }
            else
            {
               this.m_progressBar.progress = this.m_skillState.xp;
            }
            this.m_progressBar.visible = true;
         }
         else
         {
            if(thisSlotsLevel <= skillStateLevel)
            {
               (m_element as MovieClip).gotoAndStop(BIG_PRIZE_UNLOCKED_FRAME);
               if(this.m_lockIcon != null)
               {
                  this.m_lockIcon.visible = false;
               }
            }
            else
            {
               (m_element as MovieClip).gotoAndStop(BIG_PRIZE_LOCKED_FRAME);
               if(this.m_lockIcon != null)
               {
                  this.m_lockIcon.visible = true;
               }
            }
            if(this.m_cashUnlockButton != null)
            {
               skillLevelLessThanSlot = skillStateLevel < thisSlotsLevel;
               isLocked = skillLevelLessThanSlot;
               this.m_cashUnlockButton.enabled = isLocked && this.m_isNextBigReward;
               this.m_cashUnlockButton.visible = skillLevelLessThanSlot;
               this.m_cashUnlockButton.text = this.m_cashCost + " Unlock";
            }
         }
      }
      
      private function setUpPrizeInfo(data:Object) : void
      {
         var rewards:Array = null;
         var reward:Object = null;
         var item:FarmItem = null;
         var exportedName:String = null;
         var skillStateLevel:int = this.m_skillState.level;
         var thisSlotsLevel:int = int(data.level);
         if(this.m_addNestMc != null && this.m_nestText != null)
         {
            this.m_addNestMc.visible = false;
            this.m_nestText.visible = false;
         }
         if(this.m_prizeName != null)
         {
            if(thisSlotsLevel % 5 == 0)
            {
               rewards = DragonBreedingConfigManager.getInstance(this.m_featureName).getRewardsForLevel(thisSlotsLevel);
               for each(reward in rewards)
               {
                  if(reward.hasOwnProperty("bigReward") && reward.bigReward == "true")
                  {
                     item = Global.farmGameSettingsManager.getFarmItemByCode(reward.value);
                     if(item != null)
                     {
                        if(m_element.hasOwnProperty(this.PRIZE_ICON_MC))
                        {
                           this.m_prizeIcon = getWidget(m_element[this.PRIZE_ICON_MC]) as ResourcePreviewFrame;
                           if(this.m_prizeIcon)
                           {
                              removeWidget(this.m_prizeIcon);
                           }
                           exportedName = item.overrideExportName + "_" + Animal.STATE_FRONT_IDLE;
                           this.m_prizeIcon = new ResourcePreviewFrame(m_element[this.PRIZE_ICON_MC],item.imageRelativeUrl(Animal.STATE_FRONT_IDLE),exportedName);
                           addWidget(this.m_prizeIcon,true);
                        }
                        this.m_prizeName.text = item.friendlyTitle;
                        this.m_prizeName.visible = true;
                     }
                  }
                  if(reward.hasOwnProperty("type") && reward["type"] == "breedingslot_unlock" && this.m_addNestMc != null && this.m_nestText != null)
                  {
                     this.m_addNestMc.visible = true;
                     this.m_nestText.visible = true;
                  }
               }
            }
         }
      }
      
      private function onUnlockClick(event:Event) : void
      {
         if(null == this.m_confirmBuyWindow)
         {
            this.m_cashUnlockButton.enabled = false;
            if(Global.player.canBuyCash(this.m_cashCost))
            {
               this.m_confirmBuyWindow = UI.showMessage(ZLocUtils.t("Dialogs","BreedingBuyUnlockConfirm",{"quantity":this.m_cashCost}),UI.BUTTON_LAYOUT_YES_NO,null,null,false,this.onBuyConfirm);
               this.m_confirmBuyWindow.listen(WidgetControllerEvent.DIALOG_DESTROY,this.onBuyCancel);
            }
         }
         FarmStatsManager.count("Dragonbreeding","dialog","progress_frame","click_buy_level");
      }
      
      private function onBuyConfirm(event:WidgetControllerEvent) : void
      {
         TransactionManager.addTransaction(new TPurchaseDragonBreedingLevel(this.m_featureName,this.m_level));
         Global.player.cash -= this.m_cashCost;
         this.m_cashCost = 0;
         DragonBreedingManager.getInstance(this.m_featureName).grantBreedingXp(this.m_neededXp);
         this.m_confirmBuyWindow.destroy();
         closeParentWindow();
      }
      
      private function onBuyCancel(event:WidgetControllerEvent) : void
      {
         if(this.m_cashUnlockButton != null)
         {
            this.m_cashUnlockButton.enabled = true;
         }
         this.m_confirmBuyWindow = null;
      }
   }
}

