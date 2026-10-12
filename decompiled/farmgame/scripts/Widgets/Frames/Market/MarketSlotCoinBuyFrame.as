package Widgets.Frames.Market
{
   import Classes.Constants.Experiments;
   import Classes.Constants.PrerequisiteConstants;
   import Classes.ItemRequirement;
   import Classes.LockedExplanation;
   import Classes.ZItem.BuildingItem;
   import Classes.ZItem.FarmItem;
   import Classes.ZItem.FarmItemLock;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Engine.Utilities;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Constants.Market.Currency;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Tooltips.Market.MarketTooltip;
   import Widgets.Windows.Market.MarketPreviewWindow;
   import flash.display.FrameLabel;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.filters.ColorMatrixFilter;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   
   public class MarketSlotCoinBuyFrame extends MarketSlotBaseBuyFarm
   {
      
      private static const PADDING:int = 4;
      
      private var m_cost:int = 0;
      
      private var m_donatable:Boolean = false;
      
      private var m_hasLicense:Boolean = false;
      
      private var m_icon:ZwWidget;
      
      private var m_costTextField:ZwTextField;
      
      private var m_actionButton:FarmAnimatedTextButton;
      
      private var m_lockedMessage:String;
      
      private var m_unlockButton:FarmAnimatedTextButton;
      
      private var m_donateButton:FarmAnimatedTextButton;
      
      private var m_clickableUnlockButton:Boolean = false;
      
      private var m_nectarIcon:ZwWidget;
      
      public function MarketSlotCoinBuyFrame(element:MovieClip, callback:Function)
      {
         super(element);
         this.m_icon = addWidget(new ZwWidget(m_element.icon_mc)) as ZwWidget;
         this.m_costTextField = addWidget(new ZwTextField(m_element.cost_tf)) as ZwTextField;
         (this.m_costTextField.element as TextField).autoSize = TextFieldAutoSize.RIGHT;
         (this.m_costTextField.element as TextField).multiline = false;
         (this.m_costTextField.element as TextField).wordWrap = false;
         m_buyButton = addWidget(new FarmAnimatedTextButton(m_element.buy_bt,ZLocUtils.t("Dialogs","MarketCardBuyButton"),callback)) as FarmAnimatedTextButton;
         this.m_actionButton = addWidget(new FarmAnimatedTextButton(m_element.action_bt," ",callback),false) as FarmAnimatedTextButton;
         (this.m_actionButton.element as MovieClip).addEventListener(MouseEvent.MOUSE_OUT,this.onActionButtonMouseOut,false,0,true);
         this.m_actionButton.attachTooltip(new MarketTooltip());
         m_lockedButton = addWidget(new FarmAnimatedTextButton(m_element.locked_bt,ZLocUtils.t("Dialogs","MarketCardLockedButton"))) as FarmAnimatedTextButton;
         m_lockedButton.attachTooltip(new MarketTooltip());
         this.m_unlockButton = addWidget(new FarmAnimatedTextButton(m_element.unlock_bt,ZLocUtils.t("Dialogs","MarketCardUnlockedButton"),callback),false) as FarmAnimatedTextButton;
         (this.m_unlockButton.element as MovieClip).addEventListener(MouseEvent.MOUSE_OVER,this.onUnlockButtonMouseOver,false,0,true);
         if(m_element.donate_bt)
         {
            this.m_donateButton = addWidget(new FarmAnimatedTextButton(m_element.donate_bt,ZLocUtils.t("Dialogs","Donate").toUpperCase(),callback),false) as FarmAnimatedTextButton;
         }
         if(m_element.hasOwnProperty("nectarIcon_mc"))
         {
            this.m_nectarIcon = addWidget(new ZwWidget(m_element.nectarIcon_mc)) as ZwWidget;
            this.m_nectarIcon.visible = false;
         }
         var travelLiteExpReq:Boolean = Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_TRAVEL_LITE) == 2;
         if(travelLiteExpReq && m_element.hasOwnProperty("travel_bt"))
         {
            m_travelButton = addWidget(new FarmAnimatedTextButton(m_element.travel_bt,"TRAVEL",callback)) as FarmAnimatedTextButton;
         }
      }
      
      public function set currencyType(type:String) : void
      {
         var frameLabel:FrameLabel = null;
         var bHasLabel:Boolean = false;
         var frameLabels:Array = m_element.icon_mc.currentLabels;
         for each(frameLabel in frameLabels)
         {
            if(frameLabel.name == type)
            {
               bHasLabel = true;
               break;
            }
         }
         if(bHasLabel)
         {
            m_element.icon_mc.gotoAndStop(type);
         }
         else
         {
            m_element.icon_mc.gotoAndStop(0);
         }
      }
      
      public function set cost(value:int) : void
      {
         this.m_cost = value;
         this.m_costTextField.text = Utilities.formatNumber(value);
         this.refresh();
      }
      
      public function get cost() : int
      {
         return Number(this.m_costTextField.text);
      }
      
      override public function setLocked(locked:Boolean, tooltipText:String = "", worldType:String = "") : void
      {
         var currentText:String = null;
         var lowerCaseFirstWordArr:Array = null;
         var isUnlockedWorld:Boolean = false;
         m_locked = locked;
         m_worldType = worldType;
         if(m_travelButton)
         {
            m_travelButton.enabled = false;
            m_travelButton.visible = false;
         }
         if(m_locked && (!m_worldType || m_worldType == ""))
         {
            currentText = (m_lockedButton.tooltip as MarketTooltip).getText();
            if(currentText != "" && tooltipText != "")
            {
               lowerCaseFirstWordArr = new Array();
               switch(this.m_requirementType)
               {
                  case ItemRequirement.COMPARE_TYPE_ALL:
                     currentText += "\nAlso, ";
                     lowerCaseFirstWordArr = tooltipText.split(" ");
                     lowerCaseFirstWordArr[0] = lowerCaseFirstWordArr[0].toString().toLowerCase();
                     tooltipText = lowerCaseFirstWordArr.join(" ");
                     break;
                  case ItemRequirement.COMPARE_TYPE_ANY:
                     currentText += "\n";
                     lowerCaseFirstWordArr = tooltipText.split(" ");
                     lowerCaseFirstWordArr[0] = lowerCaseFirstWordArr[0].toString().toLowerCase();
                     tooltipText = lowerCaseFirstWordArr.join(" ");
                     break;
                  default:
                     currentText += "\n";
               }
            }
            (m_lockedButton.tooltip as MarketTooltip).setText(currentText + tooltipText);
            m_unlockable = false;
            m_buyButton.enabled = false;
         }
         if(Boolean(m_worldType) && m_worldType.length > 0)
         {
            m_unlockable = false;
            m_buyButton.enabled = false;
            isUnlockedWorld = Global.worldManager.hasUnlockedWorld(m_worldType);
            if(Boolean(m_travelButton) && isUnlockedWorld)
            {
               m_travelButton.enabled = true;
               m_travelButton.visible = true;
               if(!m_travelButton.tooltip)
               {
                  m_travelButton.attachTooltip(new MarketTooltip());
               }
               (m_travelButton.tooltip as MarketTooltip).setText(tooltipText);
            }
         }
         this.refresh();
      }
      
      override public function setUnlockable(unlockable:Boolean, actionButtonText:String = "", tooltipText:String = "") : void
      {
         m_unlockable = unlockable;
         if(m_unlockable)
         {
            this.m_actionButton.text = actionButtonText;
            (this.m_actionButton.tooltip as MarketTooltip).setText(tooltipText);
            m_locked = false;
            m_buyButton.enabled = false;
         }
         this.refresh();
      }
      
      public function get unlockButton() : FarmAnimatedTextButton
      {
         return this.m_unlockButton;
      }
      
      public function get travelButton() : FarmAnimatedTextButton
      {
         return m_travelButton;
      }
      
      public function get actionButton() : FarmAnimatedTextButton
      {
         return this.m_actionButton;
      }
      
      public function get buyButton() : FarmAnimatedTextButton
      {
         return m_buyButton;
      }
      
      private function onUnlockButtonMouseOver(evt:MouseEvent) : void
      {
         if(!this.clickableUnlockButton)
         {
            if(!this.m_actionButton.visible)
            {
               this.m_actionButton.visible = true;
               this.m_unlockButton.visible = false;
            }
         }
      }
      
      public function set donatable(value:Boolean) : void
      {
         this.m_donatable = value;
         this.refresh();
      }
      
      private function get clickableUnlockButton() : Boolean
      {
         return this.m_clickableUnlockButton;
      }
      
      private function set clickableUnlockButton(clickable:Boolean) : void
      {
         this.m_clickableUnlockButton = clickable;
      }
      
      private function onActionButtonMouseOut(evt:MouseEvent) : void
      {
         if(!this.clickableUnlockButton)
         {
            if(!FarmGameUtil.isDescendant(this.m_actionButton.element as MovieClip,evt.relatedObject))
            {
               this.m_actionButton.visible = false;
               this.m_unlockButton.visible = true;
            }
         }
      }
      
      public function get donateButton() : FarmAnimatedTextButton
      {
         return this.m_donateButton;
      }
      
      public function set hasLicense(value:Boolean) : void
      {
         this.m_hasLicense = value;
         this.refresh();
      }
      
      public function restoreDefaults() : void
      {
         m_locked = false;
         m_unlockable = false;
         this.m_donatable = false;
         this.m_hasLicense = false;
         m_buyButton.enabled = true;
         m_buyButton.detachTooltip();
         if(m_travelButton)
         {
            m_travelButton.detachTooltip();
         }
         this.clickableUnlockButton = false;
      }
      
      override protected function refresh() : void
      {
         if(m_locked)
         {
            if(Boolean(m_worldType) && m_worldType.length > 0)
            {
               this.m_costTextField.x = this.m_unlockButton.x - this.m_costTextField.width - PADDING;
            }
            else
            {
               this.m_costTextField.x = m_lockedButton.x - this.m_costTextField.width - PADDING;
            }
         }
         else if(m_unlockable)
         {
            this.m_costTextField.x = this.m_unlockButton.x - this.m_costTextField.width - PADDING;
         }
         else
         {
            this.m_costTextField.x = m_buyButton.x - this.m_costTextField.width - PADDING;
         }
         this.m_icon.x = this.m_costTextField.x - PADDING;
         m_lockedButton.visible = m_locked;
         this.m_unlockButton.visible = m_unlockable;
         if(this.m_donatable)
         {
            if(this.m_hasLicense)
            {
               if(this.m_donateButton)
               {
                  this.m_donateButton.visible = false;
               }
               this.m_costTextField.visible = true;
               m_buyButton.visible = true;
               this.m_icon.visible = true;
            }
            else
            {
               if(this.m_donateButton)
               {
                  this.m_donateButton.visible = true;
                  m_lockedButton.visible = false;
               }
               this.m_costTextField.visible = false;
               m_buyButton.visible = false;
               this.m_icon.visible = false;
            }
         }
         else
         {
            if(this.m_donateButton)
            {
               this.m_donateButton.visible = false;
            }
            this.m_costTextField.visible = true;
            m_buyButton.visible = true;
            this.m_icon.visible = true;
         }
         if(m_locked && this.m_cost <= 0 || this.clickableUnlockButton)
         {
            this.m_costTextField.visible = false;
            m_buyButton.visible = false;
            this.m_icon.visible = false;
         }
         if(Boolean(m_worldType) && m_worldType.length > 0)
         {
            m_buyButton.visible = false;
            if(m_travelButton)
            {
               m_travelButton.visible = true;
            }
            m_lockedButton.visible = false;
            this.m_icon.element.filters = [new ColorMatrixFilter([0.3086,0.6094,0.082,0,0,0.3086,0.6094,0.082,0,0,0.3086,0.6094,0.082,0,0,0,0,0,1,0])];
            m_costTextColor = this.m_costTextField.color;
            this.m_costTextField.color = 13421772;
         }
         else
         {
            if(m_travelButton)
            {
               m_travelButton.visible = false;
            }
            this.m_icon.element.filters = [];
            this.m_costTextField.color = m_costTextColor;
         }
      }
      
      override public function release() : void
      {
         (this.m_actionButton.element as MovieClip).removeEventListener(MouseEvent.MOUSE_OUT,this.onActionButtonMouseOut);
         (this.m_unlockButton.element as MovieClip).removeEventListener(MouseEvent.MOUSE_OVER,this.onUnlockButtonMouseOver);
         this.m_icon = null;
         this.m_costTextField = null;
         m_buyButton = null;
         this.m_actionButton = null;
         m_lockedButton = null;
         this.m_unlockButton = null;
         this.m_donateButton = null;
         if(m_travelButton)
         {
            m_travelButton = null;
         }
         super.release();
      }
      
      public function get unlockable() : Boolean
      {
         return m_unlockable;
      }
      
      public function get locked() : Boolean
      {
         return m_locked;
      }
      
      public function resetLockStates() : void
      {
         m_locked = false;
         m_unlockable = false;
         m_buyButton.enabled = true;
      }
      
      public function get currency() : String
      {
         return Global.worldManager.currentWorldCurrency;
      }
      
      override public function setupLockState(data:FarmItem, preview:Boolean = false) : void
      {
         var tooltip:MarketTooltip = null;
         var lastPreReqTested:Object = null;
         var key:String = null;
         var lastType:String = null;
         var lastContext:String = null;
         var lastValue:String = null;
         var lastQuantity:String = null;
         var message:String = null;
         var explanation:LockedExplanation = null;
         var buildingItem:BuildingItem = null;
         var hasTierData:Boolean = false;
         var licenseNeededString:String = null;
         MarketPreviewWindow.marketPreviewActive = preview;
         var locks:Array = data.getLockedStates(data);
         var lock:String = "";
         (m_lockedButton.tooltip as MarketTooltip).setText("");
         if(Boolean(m_travelButton) && Boolean(m_travelButton.tooltip))
         {
            (m_travelButton.tooltip as MarketTooltip).setText("");
            tooltip = m_travelButton.detachTooltip() as MarketTooltip;
            tooltip.detach();
            tooltip.release();
            tooltip = null;
         }
         for(var i:Number = 0; i < locks.length; i++)
         {
            lock = locks[i];
            switch(lock)
            {
               case FarmItemLock.SUPER_CROP:
                  break;
               case FarmItemLock.LOCKED:
                  this.setLocked(true,ZLocUtils.t("Dialogs","ComingSoon"));
                  break;
               case FarmItemLock.LOCKED_HIDDEN_PRICE:
                  this.setLocked(true,ZLocUtils.t("Dialogs","ComingSoon"));
                  this.m_costTextField.text = ZLocUtils.t("FarmGame","TBD");
                  this.refresh();
                  break;
               case FarmItemLock.LIMIT_HIT:
                  this.setLocked(true,ZLocUtils.t("Dialogs","LimitHit",{"quantity":data.limit}));
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
                     if(ZLocUtils.hasString("Dialogs",key))
                     {
                        message = ZLocUtils.t("Dialogs",key,{
                           "type":lastType,
                           "value":lastValue,
                           "context":lastContext,
                           "quantity":lastQuantity
                        });
                     }
                     explanation = Global.marketConfigSettings.getLockExplanation(lastType,lastValue);
                     if(Boolean(explanation) && explanation.isActive())
                     {
                        this.clickableUnlockButton = true;
                        this.setUnlockable(true);
                     }
                     else
                     {
                        this.setLocked(true,message);
                     }
                  }
                  break;
               case FarmItemLock.LEVEL:
               case FarmItemLock.MAFIA_BANGKOK:
               case FarmItemLock.MAFIA_LEVEL:
               case FarmItemLock.MAFIA_LEVEL_CHANGE:
                  this.setLocked(true,ZLocUtils.t("Dialogs","LevelNeeded",{"quantity":data.requiredLevel}));
                  break;
               case FarmItemLock.NEIGHBOR:
               case FarmItemLock.LEVEL_AND_NEIGHBOR:
               case FarmItemLock.LEVEL_OR_NEIGHBOR:
                  if(data.minNeighbors > Global.friendManager.neighborCount)
                  {
                     this.setUnlockable(true,ZLocUtils.t("Dialogs","MarketCardAddXNeighborsButton",{"quantity":data.minNeighbors - Global.friendManager.neighborCount}),ZLocUtils.t("Dialogs","NeighborsNeeded",{
                        "quantity":data.minNeighbors,
                        "quantityTotal":Global.friendManager.neighborCount
                     }));
                  }
                  else
                  {
                     this.setUnlockable(false);
                  }
                  break;
               case FarmItemLock.EMAIL:
                  this.setUnlockable(true,ZLocUtils.t("Dialogs","AllowEmailButton"),ZLocUtils.t("Dialogs","EmailOnly"));
                  break;
               case FarmItemLock.INSTANCE_TIERED:
                  buildingItem = data as BuildingItem;
                  if(buildingItem)
                  {
                     hasTierData = buildingItem.hasItemTierData(1);
                     if(!hasTierData)
                     {
                        this.setLocked(true,ZLocUtils.t("Dialogs","LimitHit",{"quantity":buildingItem.totalTiers}));
                     }
                     else if(buildingItem.levelRequired > Global.player.level)
                     {
                        this.setLocked(true,ZLocUtils.t("Dialogs","LevelNeeded",{"quantity":buildingItem.levelRequired}));
                     }
                     else
                     {
                        this.setUnlockable(true,ZLocUtils.t("Dialogs","MarketCardAddXNeighborsButton",{"quantity":buildingItem.neighborsRequired - Global.friendManager.neighborCount}),ZLocUtils.t("Dialogs","NeighborsNeeded",{
                           "quantity":buildingItem.neighborsRequired,
                           "quantityTotal":Global.friendManager.neighborCount
                        }));
                     }
                  }
                  break;
               case FarmItemLock.LICENSE:
                  licenseNeededString = "LicenseNeeded_" + data.name;
                  if(ZLocUtils.hasString("Dialogs",licenseNeededString))
                  {
                     this.setLocked(true,ZLocUtils.t("Dialogs",licenseNeededString));
                  }
                  else
                  {
                     this.setLocked(true,ZLocUtils.t("Dialogs","LicenseNeeded"));
                  }
                  break;
               default:
                  super.setupLockState(data,preview);
            }
         }
         if(data.marketIsNectar)
         {
            if(Global.player.getWorldCurrencyTotal(Currency.NECTAR) < data.realCost)
            {
               this.setLocked(true,ZLocUtils.t("Dialogs","flower_shack_market_locked_tooltip"));
            }
         }
         if(data.marketIsBerry)
         {
            if(Global.player.getWorldCurrencyTotal(Currency.BERRY) < data.realCost)
            {
               this.setLocked(true,ZLocUtils.t("Dialogs","bobsberry_marketLocked"));
            }
         }
      }
      
      public function showNectarCurrencyIcon() : void
      {
         this.m_icon.visible = false;
         if(this.m_nectarIcon)
         {
            this.m_nectarIcon.visible = true;
            this.m_nectarIcon.x = this.m_costTextField.x - this.m_nectarIcon.width - 1;
         }
      }
   }
}

