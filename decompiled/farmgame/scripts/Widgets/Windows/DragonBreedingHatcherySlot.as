package Widgets.Windows
{
   import Classes.Constants.ZLocConstants;
   import Classes.DragonBreeding.DragonBreedingSession;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Managers.DragonBreedingConfigManager;
   import Managers.DragonBreedingManager;
   import Widgets.Buttons.FarmAnimatedCashButton;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   
   public class DragonBreedingHatcherySlot extends ZwSlotFrame
   {
      
      private const LOCK_MC:String = "lock_mc";
      
      private const LOCK_UNLOCK_TF:String = "unlock_tf";
      
      private const BREEDING_MC:String = "dragonbreeding_mc";
      
      private const HATCHERY_MC:String = "slot_0_mc";
      
      private const BUY_CASH_BT:String = "buyCash_bt";
      
      private const TOOLTIP_MC:String = "tooltip_mc";
      
      private const TOOLTIP_ICON_MALE:String = "icon_mc_0";
      
      private const TOOLTIP_ICON_FEMALE:String = "icon_mc_1";
      
      private const TOOLTIP_ICON_OFFSPRING:String = "icon_mc_2";
      
      private const TOOLTIP_ICON_RANDOM:String = "randomdragon_mc";
      
      private const TOOLTIP_ICON_VISITING_MALE:String = "visitingicon_mc_0";
      
      private const TOOLTIP_ICON_VISITING_FEMALE:String = "visitingicon_mc_1";
      
      private var m_window:DragonBreedingWindow;
      
      private var m_isUnlocked:Boolean = false;
      
      private var m_unlockLevel:int = 0;
      
      private var m_maleDragon:String;
      
      private var m_femaleDragon:String;
      
      private var m_offspringCode:Number;
      
      private var m_iconMale:FarmIcon;
      
      private var m_iconFemale:FarmIcon;
      
      private var m_iconOffspring:FarmIcon;
      
      private var m_breedingSlot:DragonBreedingStationSlot;
      
      private var m_hatcherySlot:DragonBreedingMystreeSlot;
      
      private var m_lock:MovieClip;
      
      private var m_lockTF:ZwTextField;
      
      private var m_buyButton:FarmAnimatedCashButton;
      
      private var m_callback:Function;
      
      private var m_tooltipMC:MovieClip;
      
      private var m_tooltipTimer:Timer;
      
      private var m_featureName:String = "";
      
      public function DragonBreedingHatcherySlot(element:DisplayObject, hatcheryCallback:Function, window:DragonBreedingWindow)
      {
         this.m_window = window;
         if(Boolean(this.m_window) && this.m_window.featureName != "")
         {
            this.m_featureName = this.m_window.featureName;
         }
         super(element);
         this.m_callback = hatcheryCallback;
         this.setupBreedingSlot();
         this.setupHatcherySlot();
         this.setupToolTip();
         if(m_element.hasOwnProperty(this.LOCK_MC))
         {
            this.m_lock = m_element[this.LOCK_MC] as MovieClip;
            if(this.m_lock)
            {
               this.m_lockTF = addWidget(new ZwTextField(this.m_lock[this.LOCK_UNLOCK_TF],"Unlock at Level 999")) as ZwTextField;
            }
         }
      }
      
      private function setupToolTip() : void
      {
         if(m_element.hasOwnProperty(this.TOOLTIP_MC))
         {
            this.m_tooltipMC = m_element[this.TOOLTIP_MC];
            this.m_tooltipMC.visible = false;
         }
      }
      
      private function killTimer() : void
      {
         if(this.m_tooltipTimer)
         {
            this.m_tooltipTimer.stop();
            this.m_tooltipTimer.removeEventListener(TimerEvent.TIMER,this.hideToolTip);
            this.m_tooltipTimer = null;
         }
      }
      
      private function resetTimer() : void
      {
         this.killTimer();
         this.m_tooltipTimer = new Timer(1500);
         this.m_tooltipTimer.addEventListener(TimerEvent.TIMER,this.hideToolTip);
      }
      
      private function restartTimer() : void
      {
         if(this.m_tooltipTimer)
         {
            this.m_tooltipTimer.reset();
            this.m_tooltipTimer.start();
         }
      }
      
      private function enableToolTip() : void
      {
         if(Boolean(this.m_maleDragon) && Boolean(this.m_femaleDragon))
         {
            this.registerEventListener(MouseEvent.MOUSE_OVER,this.showToolTip);
            this.resetTimer();
         }
         else
         {
            this.disableToolTip();
         }
      }
      
      private function disableToolTip() : void
      {
         this.hideToolTip();
         this.unregisterEventListener(MouseEvent.MOUSE_OVER,this.showToolTip);
         this.killTimer();
      }
      
      private function populateToolTip(breedingSession:DragonBreedingSession) : void
      {
         var maleItem:FarmItem = null;
         var femaleItem:FarmItem = null;
         var offspringImage:String = null;
         if(breedingSession)
         {
            this.m_maleDragon = breedingSession.getDragonBreedObject(DragonBreedingConfigManager.GENDER_CODE_MALE);
            this.m_femaleDragon = breedingSession.getDragonBreedObject(DragonBreedingConfigManager.GENDER_CODE_FEMALE);
            this.m_offspringCode = breedingSession.getOffspringCode();
            if(!this.m_iconMale)
            {
               this.m_iconMale = new FarmIcon(this.m_tooltipMC[this.TOOLTIP_ICON_MALE],"");
            }
            if(!this.m_iconFemale)
            {
               this.m_iconFemale = new FarmIcon(this.m_tooltipMC[this.TOOLTIP_ICON_FEMALE],"");
            }
            if(!this.m_iconOffspring)
            {
               this.m_iconOffspring = new FarmIcon(this.m_tooltipMC[this.TOOLTIP_ICON_OFFSPRING],"");
            }
            if(Boolean(this.m_maleDragon) && Boolean(this.m_femaleDragon))
            {
               maleItem = Global.farmGameSettingsManager.getFarmItemByCode(this.m_maleDragon);
               if(Boolean(maleItem) && Boolean(this.m_tooltipMC[this.TOOLTIP_ICON_MALE]))
               {
                  this.m_iconMale.loadIcon(maleItem.getImageByName("icon"));
               }
               femaleItem = Global.farmGameSettingsManager.getFarmItemByCode(this.m_femaleDragon);
               if(Boolean(femaleItem) && Boolean(this.m_tooltipMC[this.TOOLTIP_ICON_FEMALE]))
               {
                  this.m_iconFemale.loadIcon(femaleItem.getImageByName("icon"));
               }
               offspringImage = "";
               if(breedingSession.patternGuarantee)
               {
                  offspringImage = DragonBreedingManager.getInstance(this.m_featureName).getImageForOffspring(maleItem.name,femaleItem.name,this.m_offspringCode);
               }
               if(offspringImage != "")
               {
                  if(this.m_tooltipMC[this.TOOLTIP_ICON_RANDOM])
                  {
                     this.m_tooltipMC[this.TOOLTIP_ICON_RANDOM].visible = false;
                  }
                  if(this.m_iconOffspring)
                  {
                     this.m_iconOffspring.loadIcon(offspringImage);
                  }
               }
               else if(this.m_tooltipMC[this.TOOLTIP_ICON_RANDOM])
               {
                  this.m_tooltipMC[this.TOOLTIP_ICON_RANDOM].visible = true;
               }
               this.hideVDIcons();
               if(breedingSession.isMaleVD != "")
               {
                  this.showMaleVDIcon();
               }
               if(breedingSession.isFemaleVD != "")
               {
                  this.showFemaleVDIcon();
               }
            }
         }
         else
         {
            this.m_maleDragon = null;
            this.m_femaleDragon = null;
            this.m_offspringCode = 0;
         }
      }
      
      private function showMaleVDIcon() : void
      {
         if(this.m_tooltipMC[this.TOOLTIP_ICON_VISITING_MALE])
         {
            this.m_tooltipMC[this.TOOLTIP_ICON_VISITING_MALE].visible = true;
         }
      }
      
      private function showFemaleVDIcon() : void
      {
         if(this.m_tooltipMC[this.TOOLTIP_ICON_VISITING_FEMALE])
         {
            this.m_tooltipMC[this.TOOLTIP_ICON_VISITING_FEMALE].visible = true;
         }
      }
      
      private function hideVDIcons() : void
      {
         if(this.m_tooltipMC[this.TOOLTIP_ICON_VISITING_FEMALE])
         {
            this.m_tooltipMC[this.TOOLTIP_ICON_VISITING_FEMALE].visible = false;
         }
         if(this.m_tooltipMC[this.TOOLTIP_ICON_VISITING_MALE])
         {
            this.m_tooltipMC[this.TOOLTIP_ICON_VISITING_MALE].visible = false;
         }
      }
      
      private function showToolTip(e:MouseEvent = null) : void
      {
         if(this.m_tooltipMC.visible == false)
         {
            this.m_tooltipMC.visible = true;
            m_element.gotoAndPlay(0);
            this.restartTimer();
         }
      }
      
      private function hideToolTip(e:TimerEvent = null) : void
      {
         this.m_tooltipMC.visible = false;
         if(this.m_tooltipTimer)
         {
            this.m_tooltipTimer.stop();
         }
      }
      
      override public function populate(data:Object) : void
      {
         this.disableToolTip();
         this.m_isUnlocked = false;
         this.m_unlockLevel = 0;
         if(data.isUnlocked)
         {
            this.m_isUnlocked = data.isUnlocked;
         }
         if(data.unlockLevel)
         {
            this.m_unlockLevel = data.unlockLevel;
         }
         if(data.breedingData)
         {
            this.m_breedingSlot.populate(data.breedingData);
            this.populateToolTip(data.breedingData as DragonBreedingSession);
         }
         else
         {
            this.m_breedingSlot.populate(null);
            this.populateToolTip(null);
         }
         if(data.hatcheryData)
         {
            this.m_hatcherySlot.populate(data.hatcheryData);
         }
         this.refresh();
      }
      
      private function setupBreedingSlot() : void
      {
         if(m_element.hasOwnProperty(this.BREEDING_MC))
         {
            this.m_breedingSlot = new DragonBreedingStationSlot(m_element[this.BREEDING_MC],this.m_callback,this.m_window);
         }
      }
      
      private function setupHatcherySlot() : void
      {
         if(m_element.hasOwnProperty(this.HATCHERY_MC))
         {
            this.m_hatcherySlot = new DragonBreedingMystreeSlot(m_element[this.HATCHERY_MC],DragonBreedingManager.FEATURE_HATCHERY_NAME,this.m_featureName,this.m_window);
         }
      }
      
      private function stateLocked() : void
      {
         if(this.m_buyButton)
         {
            this.m_buyButton.visible = true;
         }
         if(this.m_lock)
         {
            this.m_lock.visible = true;
            if(this.m_lockTF)
            {
               this.m_lockTF.text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_window.featureName + "_UnlockText",{"level":this.m_unlockLevel});
               this.m_lockTF.visible = true;
            }
         }
         this.m_breedingSlot.visible = false;
         this.m_hatcherySlot.visible = false;
      }
      
      private function stateUnlocked() : void
      {
         if(this.m_buyButton)
         {
            this.m_buyButton.visible = false;
         }
         this.m_breedingSlot.visible = true;
         this.m_hatcherySlot.visible = true;
         if(this.m_lock)
         {
            this.m_lock.visible = false;
         }
      }
      
      override public function release() : void
      {
         this.disableToolTip();
         super.release();
      }
      
      private function refresh() : void
      {
         if(this.m_isUnlocked)
         {
            this.stateUnlocked();
            this.enableToolTip();
         }
         else
         {
            this.stateLocked();
            this.disableToolTip();
         }
      }
      
      private function onLockClick(e:Event) : void
      {
         if(this.m_isUnlocked && Boolean(this.m_breedingSlot))
         {
            this.m_breedingSlot.populate(this.testHatchingState());
            this.m_hatcherySlot.onPlantClick(e);
         }
      }
      
      private function testIdleState() : Object
      {
         var breedData:Object = new Object();
         breedData.start_ts = 0;
         breedData.finish_ts = 0;
         breedData.numPotions = 0;
         breedData.buildingId = 0;
         breedData.suiteSlot = 0;
         breedData.isComplete = false;
         breedData.breedObjs = {};
         return breedData;
      }
      
      private function testBreedingState() : Object
      {
         var breedData:Object = new Object();
         breedData.start_ts = GlobalEngine.serverTime / 1000;
         breedData.finish_ts = breedData.start_ts + 3600;
         breedData.numPotions = 0;
         breedData.buildingId = 0;
         breedData.suiteSlot = 0;
         breedData.isComplete = false;
         breedData.breedObjs = {};
         breedData.breedObjs[DragonBreedingConfigManager.GENDER_CODE_MALE] = "abcd";
         breedData.breedObjs[DragonBreedingConfigManager.GENDER_CODE_FEMALE] = "efgh";
         breedData.breedObjs[DragonBreedingConfigManager.CODE_OFFSPRING] = "hijk";
         return breedData;
      }
      
      private function testReadyState() : Object
      {
         var breedData:Object = new Object();
         breedData.start_ts = 1424865360;
         breedData.finish_ts = 1424865360 + 3600;
         breedData.numPotions = 0;
         breedData.buildingId = 0;
         breedData.suiteSlot = 0;
         breedData.isComplete = false;
         breedData.breedObjs = {};
         breedData.breedObjs[DragonBreedingConfigManager.GENDER_CODE_MALE] = "abcd";
         breedData.breedObjs[DragonBreedingConfigManager.GENDER_CODE_FEMALE] = "efgh";
         breedData.breedObjs[DragonBreedingConfigManager.CODE_OFFSPRING] = "hijk";
         return breedData;
      }
      
      private function testHatchingState() : Object
      {
         var breedData:Object = new Object();
         breedData.start_ts = 1424865360;
         breedData.finish_ts = 1424865360 + 3600;
         breedData.numPotions = 0;
         breedData.buildingId = 0;
         breedData.suiteSlot = 0;
         breedData.isComplete = true;
         breedData.breedObjs = {};
         breedData.breedObjs[DragonBreedingConfigManager.GENDER_CODE_MALE] = "abcd";
         breedData.breedObjs[DragonBreedingConfigManager.GENDER_CODE_FEMALE] = "efgh";
         breedData.breedObjs[DragonBreedingConfigManager.CODE_OFFSPRING] = "hijk";
         return breedData;
      }
   }
}

