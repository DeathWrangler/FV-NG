package Widgets.Frames.Market
{
   import Classes.Constants.Experiments;
   import Classes.Constants.PrerequisiteConstants;
   import Classes.Constants.ZLocConstants;
   import Classes.ItemRequirement;
   import Classes.LockedExplanation;
   import Classes.WorldRequirement;
   import Classes.ZItem.FarmItem;
   import Classes.ZItem.FarmItemLock;
   import Classes.ZItem.SeedItem;
   import Classes.util.ZLocUtils;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Tooltips.Market.MarketTooltip;
   import Widgets.Windows.Market.MarketPreviewWindow;
   import flash.display.DisplayObject;
   
   public class MarketSlotBaseBuyFarm extends ZwFrame
   {
      
      protected var m_buyButton:FarmAnimatedTextButton;
      
      protected var m_locked:Boolean = false;
      
      protected var m_lockedButton:FarmAnimatedTextButton;
      
      protected var m_unlockable:Boolean = false;
      
      protected var m_requirementType:String;
      
      protected var m_worldType:String;
      
      protected var m_travelButton:FarmAnimatedTextButton;
      
      protected var m_costTextColor:uint = 4416041;
      
      public function MarketSlotBaseBuyFarm(element:DisplayObject)
      {
         super(element);
      }
      
      protected function clearLockedStateToolTip() : void
      {
         var tooltip:MarketTooltip = null;
         (this.m_lockedButton.tooltip as MarketTooltip).setText("");
         if(Boolean(this.m_travelButton) && Boolean(this.m_travelButton.tooltip))
         {
            tooltip = this.m_travelButton.detachTooltip() as MarketTooltip;
            tooltip.detach();
            tooltip.release();
            tooltip = null;
         }
      }
      
      protected function refresh() : void
      {
      }
      
      public function setLocked(locked:Boolean, tooltipText:String = "", worldType:String = "") : void
      {
         var currentText:String = null;
         var isUnlockedWorld:Boolean = false;
         this.m_locked = locked;
         this.m_worldType = worldType;
         if(this.m_travelButton)
         {
            this.m_travelButton.visible = false;
            this.m_travelButton.enabled = false;
         }
         if(this.m_locked && (!this.m_worldType || this.m_worldType == ""))
         {
            currentText = (this.m_lockedButton.tooltip as MarketTooltip).getText();
            if(currentText != "")
            {
               currentText += "\n";
            }
            (this.m_lockedButton.tooltip as MarketTooltip).setText(currentText + tooltipText);
            this.m_lockedButton.visible = true;
            this.m_unlockable = false;
            this.m_buyButton.enabled = false;
         }
         if(this.m_worldType != "" && this.m_worldType.length > 0)
         {
            this.m_unlockable = false;
            this.m_buyButton.enabled = false;
            isUnlockedWorld = Global.worldManager.hasUnlockedWorld(this.m_worldType);
            if(Boolean(this.m_travelButton) && isUnlockedWorld)
            {
               this.m_travelButton.enabled = true;
               this.m_travelButton.visible = true;
               if(!this.m_travelButton.tooltip)
               {
                  this.m_travelButton.attachTooltip(new MarketTooltip());
               }
               (this.m_travelButton.tooltip as MarketTooltip).setText(tooltipText);
            }
         }
         this.refresh();
      }
      
      public function setUnlockable(unlockable:Boolean, actionButtonText:String = "", tooltipText:String = "") : void
      {
      }
      
      public function setupLockState(data:FarmItem, preview:Boolean = false) : void
      {
         var itemRequirementLock:ItemRequirement = null;
         var unlockButtonText:String = null;
         var worldType:String = null;
         var lastPreReqTested:Object = null;
         var key:String = null;
         var lastType:String = null;
         var lastContext:String = null;
         var lastValue:String = null;
         var lastQuantity:String = null;
         var message:String = null;
         var explanation:LockedExplanation = null;
         MarketPreviewWindow.marketPreviewActive = preview;
         var locks:Array = data.getLockedStates();
         var lock:* = "";
         this.clearLockedStateToolTip();
         var shouldBeLocked:Boolean = false;
         this.m_requirementType = data.getRequirementCompareType();
         var experimentRequirement:Boolean = Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_TRAVEL_LITE) == 2;
         for(var i:Number = 0; i < locks.length; i++)
         {
            lock = locks[i];
            if(lock is ItemRequirement)
            {
               itemRequirementLock = lock as ItemRequirement;
               if(this.canItemRequirementTriggerLockState(itemRequirementLock) == true)
               {
                  unlockButtonText = itemRequirementLock.getMarketUnlockString();
                  worldType = "";
                  if(unlockButtonText)
                  {
                     this.setUnlockable(true,unlockButtonText,itemRequirementLock.getReadableMessage());
                  }
                  else
                  {
                     if(itemRequirementLock is WorldRequirement && experimentRequirement && data is SeedItem)
                     {
                        if(Global.player.level >= data.requiredLevel)
                        {
                           worldType = (itemRequirementLock as WorldRequirement).worldId;
                        }
                     }
                     if(!Global.worldManager.hasUnlockedWorld(worldType))
                     {
                        worldType = "";
                     }
                     this.setLocked(true,itemRequirementLock.getReadableMessage(),worldType);
                  }
                  shouldBeLocked = true;
               }
               else
               {
                  this.resetLockedState();
               }
               continue;
            }
            switch(lock)
            {
               case FarmItemLock.LIMIT_HIT:
                  shouldBeLocked = true;
                  this.setLocked(true,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"LimitHit",{"quantity":data.limit}));
                  break;
               case FarmItemLock.PURCHASE_PREREQ:
                  if(Global.flashHotParams["FIX_MARKET_PURCHASE_PREREQ"])
                  {
                     lastPreReqTested = data.diagnoseFailedPurchasePrereqs(data);
                  }
                  else
                  {
                     lastPreReqTested = data.diagnoseFailedPurchasePrereqs(this);
                  }
                  if(lastPreReqTested)
                  {
                     key = "MarketCard_PrereqLocked_Rollover";
                     lastType = "";
                     lastContext = "";
                     lastValue = "";
                     lastQuantity = "";
                     if(lastPreReqTested.hasOwnProperty(PrerequisiteConstants.KEY_TYPE))
                     {
                        lastType = lastPreReqTested[PrerequisiteConstants.KEY_TYPE];
                        key += "_" + lastType;
                     }
                     if(lastPreReqTested.hasOwnProperty(PrerequisiteConstants.KEY_CONTEXT_PATH))
                     {
                        lastContext = lastPreReqTested[PrerequisiteConstants.KEY_CONTEXT_PATH];
                        key += "_" + lastContext;
                     }
                     if(lastPreReqTested.hasOwnProperty(PrerequisiteConstants.KEY_VALUE))
                     {
                        lastValue = lastPreReqTested[PrerequisiteConstants.KEY_VALUE];
                        key += "_" + lastValue;
                     }
                     if(lastPreReqTested.hasOwnProperty(PrerequisiteConstants.KEY_QUANTITY))
                     {
                        lastQuantity = lastPreReqTested[PrerequisiteConstants.KEY_QUANTITY];
                     }
                     message = "";
                     if(Config.DEBUG_MODE)
                     {
                        message = "key not found: " + key;
                     }
                     if(ZLocUtils.hasString(ZLocConstants.DIALOG_UTIL_PKG,key))
                     {
                        message = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,key,{
                           "type":lastType,
                           "value":lastValue,
                           "context":lastContext,
                           "quantity":lastQuantity
                        });
                     }
                     explanation = Global.marketConfigSettings.getLockExplanation(lastType,lastValue);
                     if(Boolean(explanation) && explanation.isActive())
                     {
                        this.setUnlockable(true);
                     }
                     else
                     {
                        shouldBeLocked = true;
                        this.setLocked(true,message);
                     }
                  }
            }
         }
         if(!shouldBeLocked)
         {
            this.setLocked(false);
            this.setUnlockable(false);
            this.m_buyButton.enabled = true;
         }
      }
      
      protected function canItemRequirementTriggerLockState(itemRequirement:ItemRequirement) : Boolean
      {
         return true;
      }
      
      private function resetLockedState() : void
      {
         this.setLocked(false);
         this.setUnlockable(false);
         this.m_buyButton.enabled = true;
      }
      
      public function get worldType() : String
      {
         return this.m_worldType;
      }
      
      public function set worldType(value:String) : void
      {
         this.m_worldType = value;
      }
   }
}

