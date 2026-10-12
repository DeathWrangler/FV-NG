package Widgets.Slots.Breeding
{
   import Classes.ZItem.FarmItem;
   import Classes.breeding.AnimalBreedingSkillState;
   import Classes.util.ZLocUtils;
   import Display.Dialogs.GenericDialog;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Managers.FarmStatsManager;
   import Managers.breeding.AnimalBreedingManager;
   import Transactions.BreedingProjects.TPurchaseBreedingLevel;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import Widgets.ProgressBars.FarmProgressBar;
   import com.troyer.widget.event.WidgetControllerEvent;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class BreedingProgressSlot extends ZwSlotFrame
   {
      
      private static const BIG_PRIZE_LOCKED_FRAME:int = 1;
      
      private static const BIG_PRIZE_UNLOCKED_FRAME:int = 2;
      
      private static const MAX_EPIC_LEVEL:int = 30;
      
      private var m_levelTextField:ZwTextField = null;
      
      private var m_levelNumberTextField:ZwTextField = null;
      
      private var m_progressBar:FarmProgressBar = null;
      
      private var m_prizeIcon:FarmIcon = null;
      
      private var m_prizeName:ZwTextField = null;
      
      private var m_cashUnlockButton:FarmAnimatedButton = null;
      
      private var m_lockIcon:ZwFrame = null;
      
      private var m_featureName:String = "";
      
      private var m_level:int = 0;
      
      private var m_neededXp:int = 0;
      
      private var m_confirmBuyWindow:GenericDialog;
      
      private var m_isNextBigReward:Boolean = false;
      
      private var m_cashCost:int = 0;
      
      public function BreedingProgressSlot(element:DisplayObject)
      {
         super(element);
         if(m_element.hasOwnProperty("generic_tf"))
         {
            this.m_levelTextField = new ZwTextField(m_element.generic_tf,"Level");
            addWidget(this.m_levelTextField);
         }
         if(m_element.hasOwnProperty("level_tf"))
         {
            this.m_levelNumberTextField = new ZwTextField(m_element.level_tf,"");
            addWidget(this.m_levelNumberTextField);
         }
         if(m_element.hasOwnProperty("barGroup_mc"))
         {
            this.m_progressBar = new FarmProgressBar(m_element.barGroup_mc);
            addWidget(this.m_progressBar);
         }
         if(m_element.hasOwnProperty("prizeIcon_mc"))
         {
            this.m_prizeIcon = new FarmIcon(m_element.prizeIcon_mc);
            addWidget(this.m_prizeIcon);
         }
         if(m_element.hasOwnProperty("itemName_tf"))
         {
            this.m_prizeName = new ZwTextField(m_element.itemName_tf);
            addWidget(this.m_prizeName);
         }
         if(m_element.hasOwnProperty("unlock_bt"))
         {
            this.m_cashUnlockButton = new FarmAnimatedButton(m_element.unlock_bt,this.onUnlockClick);
            addWidget(this.m_cashUnlockButton);
         }
         if(m_element.hasOwnProperty("lockIcon_mc"))
         {
            this.m_lockIcon = new ZwFrame(m_element.lockIcon_mc);
            addWidget(this.m_lockIcon);
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
      }
      
      override public function populate(data:Object) : void
      {
         var levelText:String = null;
         var unlockComboAsset:String = null;
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
         this.setUpProgressBar(data);
         this.setUpPrizeInfo(data);
         var skillState:AnimalBreedingSkillState = data.skillState;
         if(null != skillState)
         {
            this.m_featureName = skillState.featureName;
            this.m_neededXp = skillState.getXpNeededForLevel(this.m_level);
         }
         if(this.m_prizeIcon != null)
         {
            if(this.m_level == MAX_EPIC_LEVEL)
            {
               unlockComboAsset = AnimalBreedingManager.BASE_BREEDING_DIALOG_ASSET_PATH + this.m_featureName + "/100unlockCombo.png";
               this.m_prizeIcon.loadIcon(Global.getAssetURL(unlockComboAsset));
               this.m_prizeIcon.visible = true;
            }
         }
      }
      
      private function setUpProgressBar(data:Object) : void
      {
         var skillLevelLessThanSlot:Boolean = false;
         var isLocked:Boolean = false;
         var skillState:AnimalBreedingSkillState = data.skillState;
         var skillStateLevel:int = skillState.level;
         var thisSlotsLevel:int = this.m_level;
         if(this.m_progressBar != null)
         {
            this.m_progressBar.minimum = 0;
            this.m_progressBar.maximum = thisSlotsLevel > 0 ? Global.animalBreedingSettings.getXpForLevel(thisSlotsLevel + 1,skillState.featureName) : 0;
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
               this.m_progressBar.progress = skillState.xp;
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
            }
         }
      }
      
      private function setUpPrizeInfo(data:Object) : void
      {
         var rewards:Array = null;
         var reward:Object = null;
         var item:FarmItem = null;
         var skillState:AnimalBreedingSkillState = data.skillState;
         var skillStateLevel:int = skillState.level;
         var thisSlotsLevel:int = int(data.level);
         if(this.m_prizeIcon != null && this.m_prizeName != null)
         {
            if(thisSlotsLevel % 5 == 0)
            {
               rewards = Global.animalBreedingSettings.getRewardsForLevel(thisSlotsLevel,skillState.featureName);
               for each(reward in rewards)
               {
                  if(reward.hasOwnProperty("bigReward") && reward.bigReward == "true")
                  {
                     item = Global.farmGameSettingsManager.getFarmItemByCode(reward.value);
                     if(item != null)
                     {
                        this.m_prizeIcon.loadIcon(item.iconUrl);
                        this.m_prizeIcon.visible = true;
                        this.m_prizeName.text = item.friendlyTitle;
                        this.m_prizeName.visible = true;
                     }
                  }
               }
            }
         }
      }
      
      private function onUnlockClick(event:Event) : void
      {
         var costPerXp:int = 0;
         var xpPerAction:int = 0;
         if(null == this.m_confirmBuyWindow)
         {
            this.m_cashUnlockButton.enabled = false;
            costPerXp = parseInt(Global.animalBreedingSettings.getFeatureConfigAttr(this.m_featureName,"xpCost").toString());
            xpPerAction = parseInt(Global.animalBreedingSettings.getFeatureConfigAttr(this.m_featureName,"xpBreedSuccess").toString());
            this.m_cashCost = Math.ceil(costPerXp * this.m_neededXp / xpPerAction);
            if(Global.player.canBuyCash(this.m_cashCost))
            {
               this.m_confirmBuyWindow = UI.showMessage(ZLocUtils.t("Dialogs","BreedingBuyUnlockConfirm",{"quantity":this.m_cashCost}),UI.BUTTON_LAYOUT_YES_NO,null,null,false,this.onBuyConfirm);
               this.m_confirmBuyWindow.listen(WidgetControllerEvent.DIALOG_DESTROY,this.onBuyCancel);
            }
         }
         FarmStatsManager.count("breeding","dialog","progress_frame","click_buy_level");
      }
      
      private function onBuyConfirm(event:WidgetControllerEvent) : void
      {
         TransactionManager.addTransaction(new TPurchaseBreedingLevel(this.m_featureName,this.m_level));
         Global.player.cash -= this.m_cashCost;
         this.m_cashCost = 0;
         AnimalBreedingManager.getInstance().grantBreedingXp(this.m_featureName,this.m_neededXp);
         this.m_confirmBuyWindow.destroy();
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

