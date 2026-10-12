package Widgets.Windows
{
   import Classes.Constants.ZLocConstants;
   import Classes.DragonBreeding.DragonBreedingSession;
   import Classes.FeatureBuilding;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Display.TutorialUI;
   import Display.UI;
   import Managers.DragonBreedingConfigManager;
   import Managers.DragonBreedingManager;
   import Managers.FarmStatsManager;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwBaseWidget;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.DragonBreedingLairFrame;
   import Widgets.Slots.DragonBreedingSlot;
   import Widgets.Tooltips.FarmTextTooltip;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.Matrix;
   import flash.geom.Point;
   
   public class DragonBreedingWindow extends FarmWindow implements IMystreeReskinWindow
   {
      
      public static const TAB_LAIR:int = 1;
      
      public static const TAB_HATCHERY:int = 2;
      
      public static const VISITING_DRAGON_STEP_1:int = 1;
      
      public static const VISITING_DRAGON_STEP_2:int = 2;
      
      public static const TUTORIAL_NOT_RUNNING:int = -1;
      
      public static const TUTORIAL_INTRO:int = 0;
      
      public static const TUTORIAL_STEP_1:int = 1;
      
      public static const TUTORIAL_STEP_2:int = 2;
      
      public static const TUTORIAL_STEP_3:int = 3;
      
      public static const TUTORIAL_STEP_4:int = 4;
      
      public static const TUTORIAL_STEP_5:int = 5;
      
      public static const TUTORIAL_STEP_6:int = 6;
      
      public static const TUTORIAL_STEP_7:int = 7;
      
      public static const TUTORIAL_STEP_8:int = 8;
      
      public static const TUTORIAL_STEP_9:int = 9;
      
      public static const TUTORIAL_STEP_10:int = 10;
      
      private const BG_HATCHERY:String = "bghatchery_mc";
      
      private const BG_LAIR:String = "bglair_mc";
      
      private const TITLE_TF:String = "title_tf";
      
      private const GENERIC_TF:String = "generic_tf";
      
      private const WHATISTHIS_MC:String = "whatisthis_mc";
      
      private const FAMILY_BT:String = "family_bt";
      
      private const LAIR_HATCHERY_BT:String = "lairhatchery_bt";
      
      private const PROGRESS_BT:String = "progress_bt";
      
      private const FIRE_MC:String = "fire_mc";
      
      private const HERBSOFLOVE_MC:String = "herbsoflove_mc";
      
      private const LAIR_MC:String = "lair_mc";
      
      private const DRAGON_SELET_BTN:String = "selectdragon_bt";
      
      private const MALE_SLOTS_MC:String = "slots_male_mc";
      
      private const FEMALE_SLOTS_MC:String = "slots_female_mc";
      
      private const CRAFTPOTION_BTN:String = "craftpotion_bt";
      
      private const CRAFTFIRE_BTN:String = "craftfire_bt";
      
      private const CRAFT_HERB_ASK_BTN:String = "ask_bt";
      
      private const CRAFT_HERB_BUY_BTN:String = "buyCash_bt";
      
      private const CRAFT_FIRE_ASK_BTN:String = "ask_bt_0";
      
      private const CRAFT_FIRE_BUY_BTN:String = "buyCash_bt_0";
      
      private const CRAFT_HERB_COUNT_TF:String = "bucketcount_tf";
      
      private const CRAFT_FIRE_COUNT_TF:String = "bucketcount_tf_0";
      
      private const EGG_METER_MC:String = "eggmeter_mc";
      
      private const LEVEL_UP_ANIMATION:String = "levelupAnimation_mc";
      
      private const BREED_UP_ANIMATION:String = "breedingadd_mc";
      
      private const EGG_AVAILABLE:int = 1;
      
      private const EGG_NOT_AVAILABLE:int = 2;
      
      private const VISITING_DRAGON_TUTORIAL_STEP_1:String = "visitingdragontut_1";
      
      private const VISITING_DRAGON_TUTORIAL_STEP_2:String = "visitingdragontut_2";
      
      private const VISITING_DRAGON_TUT_STEP_1_BTN:String = "okay_bt";
      
      private const VISITING_DRAGON_TUT_STEP_1_TXT:String = "task_tf";
      
      private var m_featureName:String = null;
      
      private var m_lair:MovieClip;
      
      private var m_hatchery:DragonBreedingHatcheryFrame;
      
      private var m_activeTab:int = 1;
      
      private var m_defaultTab:int = 1;
      
      private var m_familyTreeBtn:FarmAnimatedTextButton;
      
      private var m_hatcheryBtn:FarmAnimatedTextButton;
      
      private var m_whatIsThis_mc:FarmAnimatedButton;
      
      private var m_progressBtn:FarmAnimatedTextButton;
      
      private var m_fireMC:MovieClip;
      
      private var m_herbsOfLove_mc:MovieClip;
      
      private var m_selectDragonBtn:FarmAnimatedTextButton;
      
      private var m_craftHerbBtn:FarmAnimatedTextButton;
      
      private var m_craftFireBtn:FarmAnimatedTextButton;
      
      private var m_askHerbBtn:FarmAnimatedTextButton;
      
      private var m_buyHerbBtn:FarmAnimatedTextButton;
      
      private var m_askFireBtn:FarmAnimatedTextButton;
      
      private var m_buyFireBtn:FarmAnimatedTextButton;
      
      private var m_maleDragonSlots:DragonBreedingLairFrame;
      
      private var m_femaleDragonSlots:DragonBreedingLairFrame;
      
      private var m_selectedMaleDragonId:String = "";
      
      private var m_selectedFemaleDragonId:String = "";
      
      private var m_bgLairMC:MovieClip;
      
      private var m_bgHatcheryMC:MovieClip;
      
      private var m_featureBuilding:FeatureBuilding;
      
      private var m_fireCount_text:ZwTextField;
      
      private var m_herbCount_text:ZwTextField;
      
      private var m_genericTitle:ZwTextField;
      
      private const NO_OF_PANELS:int = 4;
      
      private var m_dragonSelectionWindow:DragonBreedingSelectionWindow = null;
      
      private var m_eggMeterMc:ZwWidget;
      
      private var m_levelUpAnimation:MovieClip;
      
      private var m_breedUpAnimation:MovieClip;
      
      private var m_levelUpBreedingSession:DragonBreedingSession = null;
      
      private var m_isOpenWindow:Boolean = false;
      
      private var m_visitingDragonTutorialStep1:MovieClip;
      
      private var m_visitingDragonTutorialStep2:MovieClip;
      
      private var m_vdTutorialStep1Btn:FarmAnimatedTextButton;
      
      private var m_vdTutorialStep2Btn:FarmAnimatedTextButton;
      
      private var m_lastSeen:Number;
      
      private var m_lastSeenFire:Number;
      
      private var m_lastRequestedTutorialIndex:int = -1;
      
      public function DragonBreedingWindow(featureName:String)
      {
         this.m_featureName = featureName;
         super(DragonBreedingManager.getInstance(this.m_featureName).getMainDialogAssetURL());
         if(this.m_featureName != null || this.m_featureName != "")
         {
            DragonBreedingManager.getInstance(this.m_featureName).initialize();
            DragonBreedingManager.getHatcheryManager(this.m_featureName).initialize();
         }
         this.m_isOpenWindow = true;
      }
      
      public function get featureName() : String
      {
         return this.m_featureName;
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         if(m_window.hasOwnProperty(this.TITLE_TF))
         {
            addWidget(new ZwTextField(m_window[this.TITLE_TF],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_subtitle")),true);
         }
         if(m_window.hasOwnProperty(this.GENERIC_TF))
         {
            addWidget(this.m_genericTitle = new ZwTextField(m_window[this.GENERIC_TF],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_title")),true);
         }
         if(m_window.hasOwnProperty(this.WHATISTHIS_MC))
         {
            this.m_whatIsThis_mc = addWidget(new FarmAnimatedButton(m_window[this.WHATISTHIS_MC],this.howDoesThisWorkClick),true) as FarmAnimatedButton;
         }
         if(m_window.hasOwnProperty(this.FAMILY_BT))
         {
            this.m_familyTreeBtn = addWidget(new FarmAnimatedTextButton(m_window[this.FAMILY_BT],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_main_familyBtnTxt"),this.openFamilyTreeWindow),true) as FarmAnimatedTextButton;
         }
         if(m_window.hasOwnProperty(this.LAIR_HATCHERY_BT))
         {
            this.m_hatcheryBtn = addWidget(new FarmAnimatedTextButton(m_window[this.LAIR_HATCHERY_BT],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "main_visitBtnTxt1"),this.switchToTab),true) as FarmAnimatedTextButton;
         }
         if(m_window.hasOwnProperty(this.PROGRESS_BT))
         {
            this.m_progressBtn = addWidget(new FarmAnimatedTextButton(m_window[this.PROGRESS_BT],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_main_progBtnTxt"),this.openProgressWindow),true) as FarmAnimatedTextButton;
         }
         if(m_window.hasOwnProperty(this.VISITING_DRAGON_TUTORIAL_STEP_1))
         {
            this.m_visitingDragonTutorialStep1 = m_window[this.VISITING_DRAGON_TUTORIAL_STEP_1];
            this.m_visitingDragonTutorialStep1.visible = false;
            if(this.m_visitingDragonTutorialStep1.hasOwnProperty(this.VISITING_DRAGON_TUT_STEP_1_BTN))
            {
               this.m_vdTutorialStep1Btn = addWidget(new FarmAnimatedTextButton(this.m_visitingDragonTutorialStep1[this.VISITING_DRAGON_TUT_STEP_1_BTN],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_vd_tutorial1_btn_txt"),this.onVdTutorialStep1BtnClick),false) as FarmAnimatedTextButton;
            }
         }
         if(m_window.hasOwnProperty(this.VISITING_DRAGON_TUTORIAL_STEP_2))
         {
            this.m_visitingDragonTutorialStep2 = m_window[this.VISITING_DRAGON_TUTORIAL_STEP_2];
            this.m_visitingDragonTutorialStep2.visible = false;
         }
         if(m_window.hasOwnProperty(this.FIRE_MC))
         {
            this.m_fireMC = m_window[this.FIRE_MC];
            this.m_fireMC.visible = true;
            if(this.m_fireMC.hasOwnProperty(this.CRAFTFIRE_BTN))
            {
               this.m_craftFireBtn = addWidget(new FarmAnimatedTextButton(this.m_fireMC[this.CRAFTFIRE_BTN],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_craftFire"),this.openCraftFireWindow),true) as FarmAnimatedTextButton;
            }
            if(this.m_fireMC.hasOwnProperty(this.CRAFT_FIRE_ASK_BTN))
            {
               this.m_askFireBtn = addWidget(new FarmAnimatedTextButton(this.m_fireMC[this.CRAFT_FIRE_ASK_BTN],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_selected_herbsoflove_AskButtonText"),this.onAskFireClickHandler),true) as FarmAnimatedTextButton;
            }
            if(this.m_fireMC.hasOwnProperty(this.CRAFT_FIRE_BUY_BTN))
            {
               this.m_buyFireBtn = addWidget(new FarmAnimatedTextButton(this.m_fireMC[this.CRAFT_FIRE_BUY_BTN],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_selected_herbsoflove_BuyButtonText"),this.openFireBuyWindow),true) as FarmAnimatedTextButton;
            }
            if(this.m_fireMC.hasOwnProperty(this.CRAFT_FIRE_COUNT_TF))
            {
               addWidget(this.m_fireCount_text = new ZwTextField(this.m_fireMC[this.CRAFT_FIRE_COUNT_TF],"0"));
               this.updateSunshineBuckets();
            }
         }
         if(m_window.hasOwnProperty(this.HERBSOFLOVE_MC))
         {
            this.m_herbsOfLove_mc = m_window[this.HERBSOFLOVE_MC];
            this.m_herbsOfLove_mc.visible = true;
            if(this.m_herbsOfLove_mc.hasOwnProperty(this.CRAFTPOTION_BTN))
            {
               this.m_craftHerbBtn = addWidget(new FarmAnimatedTextButton(this.m_herbsOfLove_mc[this.CRAFTPOTION_BTN],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_main_craftHerbBtnTxt"),this.openCraftHerbWindow),true) as FarmAnimatedTextButton;
            }
            if(this.m_herbsOfLove_mc.hasOwnProperty(this.CRAFT_HERB_ASK_BTN))
            {
               this.m_askHerbBtn = addWidget(new FarmAnimatedTextButton(this.m_herbsOfLove_mc[this.CRAFT_HERB_ASK_BTN],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_selected_herbsoflove_AskButtonText"),this.onAskHerbClickHandler),true) as FarmAnimatedTextButton;
            }
            if(this.m_herbsOfLove_mc.hasOwnProperty(this.CRAFT_HERB_BUY_BTN))
            {
               this.m_buyHerbBtn = addWidget(new FarmAnimatedTextButton(this.m_herbsOfLove_mc[this.CRAFT_HERB_BUY_BTN],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_selected_herbsoflove_BuyButtonText"),this.openHerbBuyWindow),true) as FarmAnimatedTextButton;
            }
            if(this.m_herbsOfLove_mc.hasOwnProperty(this.CRAFT_HERB_COUNT_TF))
            {
               addWidget(this.m_herbCount_text = new ZwTextField(this.m_herbsOfLove_mc[this.CRAFT_HERB_COUNT_TF],"0"));
               this.updateLovePotion();
            }
         }
         if(m_window.hasOwnProperty(this.EGG_METER_MC))
         {
            this.m_eggMeterMc = new ZwWidget(m_window[this.EGG_METER_MC] as MovieClip);
         }
         if(m_window.hasOwnProperty(this.LEVEL_UP_ANIMATION))
         {
            this.m_levelUpAnimation = m_window[this.LEVEL_UP_ANIMATION] as MovieClip;
            this.m_levelUpAnimation.visible;
         }
         if(m_window.hasOwnProperty(this.BREED_UP_ANIMATION))
         {
            this.m_breedUpAnimation = m_window[this.BREED_UP_ANIMATION] as MovieClip;
            this.m_breedUpAnimation.visible = false;
            this.m_breedUpAnimation.y = 375;
         }
         this.updateProgressBtnText();
         this.setEggMeter();
         this.updateEggMeter();
         this.initializeLair();
         this.initializeHatchery();
         this.switchToTab(null,this.m_defaultTab);
         if(this.isInTutorial())
         {
            this.displayTutorialMessage();
         }
         this.registerEventListeners();
      }
      
      private function canShowVDTutorialStep2() : void
      {
         if(DragonBreedingManager.getInstance(this.m_featureName).canShowVisitingDragonTutorialStep2())
         {
            this.toggleVisitingDragonTutorial(VISITING_DRAGON_STEP_2,true);
            this.showVisitingDragonTutorialBySlot();
         }
      }
      
      private function hideVisitingDragonTutorial() : void
      {
         var i:int = 0;
         if(this.m_visitingDragonTutorialStep2)
         {
            for(i = 1; i <= 6; i++)
            {
               if(this.m_visitingDragonTutorialStep2.hasOwnProperty("slot" + i + "_mc"))
               {
                  this.m_visitingDragonTutorialStep2["slot" + i + "_mc"].visible = false;
               }
            }
         }
      }
      
      private function testVisitingDragonTutorial() : void
      {
         this.toggleVisitingDragonTutorial(VISITING_DRAGON_STEP_2,true);
         this.showVisitingDragonTutorialBySlot();
      }
      
      public function checkAskFireEnabled() : void
      {
         var timeRemaining:Array = null;
         if(this.m_askFireBtn)
         {
            this.m_askFireBtn.enabled = false;
            if(!this.isInTutorial())
            {
               if(DragonBreedingManager.getInstance(this.m_featureName).canAskForFire())
               {
                  this.m_askFireBtn.enabled = true;
               }
               else
               {
                  this.m_askFireBtn.enabled = false;
                  this.m_askFireBtn.element.mouseEnabled = this.m_askFireBtn.element.mouseChildren = true;
                  timeRemaining = DragonBreedingManager.getInstance(this.m_featureName).getTimeUntilPostFeedEnabled(DragonBreedingManager.FIRE_ITEM_CODE);
                  this.m_askFireBtn.attachTooltip(new FarmTextTooltip(ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"asksnowflake_timeleft",{
                     "hrs":timeRemaining[1],
                     "min":timeRemaining[2]
                  })));
               }
            }
         }
      }
      
      public function checkAskHerbEnabled() : void
      {
         var timeRemaining:Array = null;
         if(this.m_askHerbBtn)
         {
            this.m_askHerbBtn.enabled = false;
            if(!this.isInTutorial())
            {
               if(DragonBreedingManager.getInstance(this.m_featureName).canAskForLovePotions())
               {
                  this.m_askHerbBtn.enabled = true;
               }
               else
               {
                  this.m_askHerbBtn.enabled = false;
                  this.m_askHerbBtn.element.mouseEnabled = this.m_askHerbBtn.element.mouseChildren = true;
                  timeRemaining = DragonBreedingManager.getInstance(this.m_featureName).getTimeUntilPostFeedEnabled(DragonBreedingManager.LOVE_POTION_ITEM_CODE);
                  this.m_askHerbBtn.attachTooltip(new FarmTextTooltip(ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"asksnowflake_timeleft",{
                     "hrs":timeRemaining[1],
                     "min":timeRemaining[2]
                  })));
               }
            }
         }
      }
      
      private function registerEventListeners() : void
      {
         DragonBreedingManager.getInstance(this.featureName).addEventListener(DragonBreedingManager.EVENT_INVENTORY_REFRESH,this.updateInventoryCount);
      }
      
      private function unregisterEventListeners() : void
      {
         DragonBreedingManager.getInstance(this.featureName).removeEventListener(DragonBreedingManager.EVENT_INVENTORY_REFRESH,this.updateInventoryCount);
      }
      
      private function updateInventoryCount(e:Event) : void
      {
         untintWindow();
         this.enableInput = true;
         this.updateLovePotion();
         this.updateSunshineBuckets();
         this.setEggMeter();
         this.updateEggMeter();
         this.updateProgressBtnText();
      }
      
      public function setEggMeter() : void
      {
         var eggMc:MovieClip = null;
         for(var i:int = 0; i < DragonBreedingManager.MAX_XP_PER_LEVEL; i++)
         {
            if(this.m_eggMeterMc.element.hasOwnProperty("egg_" + i))
            {
               eggMc = this.m_eggMeterMc.element["egg_" + i] as MovieClip;
               if(eggMc)
               {
                  eggMc.visible = false;
                  eggMc.gotoAndStop(this.EGG_NOT_AVAILABLE);
               }
            }
         }
      }
      
      public function updateEggMeter() : void
      {
         var i:int = 0;
         var eggMc:MovieClip = null;
         this.m_eggMeterMc.visible = true;
         var currentLevel:int = DragonBreedingManager.getInstance(this.featureName).getPlayerCurrentLevel();
         var gainedXp:int = DragonBreedingManager.getInstance(this.featureName).getPlayerCurrentXp();
         var totalXpNeededPerLevel:int = DragonBreedingConfigManager.getInstance(this.m_featureName).getXpForLevel(currentLevel);
         this.m_eggMeterMc.detachTooltip();
         if(currentLevel < DragonBreedingManager.getInstance(this.featureName).getMaxProgressLevel())
         {
            this.m_eggMeterMc.attachTooltip(new FarmTextTooltip(ZLoc.t(ZLocConstants.DIALOG_UTIL_PKG,this.featureName + "_main_eggMeterTooltip",{
               "xp":totalXpNeededPerLevel - gainedXp,
               "level":currentLevel + 1
            })));
            for(i = 0; i < totalXpNeededPerLevel; i++)
            {
               if(this.m_eggMeterMc.element.hasOwnProperty("egg_" + i))
               {
                  eggMc = this.m_eggMeterMc.element["egg_" + i] as MovieClip;
                  if(eggMc)
                  {
                     eggMc.visible = true;
                     eggMc.gotoAndStop(this.EGG_NOT_AVAILABLE);
                     if(i < gainedXp)
                     {
                        eggMc.gotoAndStop(this.EGG_AVAILABLE);
                     }
                  }
               }
            }
         }
      }
      
      public function updateProgressBtnText() : void
      {
         var progressDisplayLevel:String = DragonBreedingManager.getInstance(this.featureName).getPlayerCurrentLevel().toString() + "/" + DragonBreedingConfigManager.getInstance(this.featureName).getMaxLevel().toString();
         if(this.m_progressBtn)
         {
            this.m_progressBtn.text = ZLoc.t(ZLocConstants.DIALOG_UTIL_PKG,this.featureName + "_main_progBtnTxt") + "\n" + progressDisplayLevel;
         }
      }
      
      private function openCraftFireWindow(e:Event) : void
      {
         this.openCraftWindow(DragonBreedingManager.FIRE_ITEM_NAME);
      }
      
      private function onAskFireClickHandler(e:Event) : void
      {
         this.m_lastSeenFire = Global.player.getFeatureLastShown("dragonBreeding_fire");
         if(Boolean(this.m_askFireBtn) && this.m_askFireBtn.enabled)
         {
            this.m_askFireBtn.enabled = false;
         }
         DragonBreedingManager.getInstance(this.featureName).askForFire("UI",this.checkAskFireEnabled);
      }
      
      private function openFireBuyWindow(e:Event) : void
      {
         this.openCraftBuyWindow(DragonBreedingManager.FIRE_ITEM_NAME);
      }
      
      private function openCraftHerbWindow(e:Event) : void
      {
         this.openCraftWindow(DragonBreedingManager.HERB_ITEM_NAME);
      }
      
      private function onAskHerbClickHandler(e:Event) : void
      {
         this.m_lastSeen = Global.player.getFeatureLastShown("dragonBreeding_lovePotion");
         if(this.m_askHerbBtn)
         {
            this.m_askHerbBtn.enabled = false;
         }
         DragonBreedingManager.getInstance(this.featureName).askForLovePotions("UI",this.checkAskHerbEnabled);
      }
      
      private function enableAskOnCancel() : void
      {
         Global.player.setFeatureLastShown("dragonBreeding_lovePotion",this.m_lastSeen,true);
         if(this.m_askHerbBtn)
         {
            this.m_askHerbBtn.enabled = true;
         }
      }
      
      private function enableAskFireOnCancel() : void
      {
         Global.player.setFeatureLastShown("dragonBreeding_fire",this.m_lastSeenFire,true);
         if(this.m_askFireBtn)
         {
            this.m_askFireBtn.enabled = true;
         }
      }
      
      private function openHerbBuyWindow(e:Event) : void
      {
         this.openCraftBuyWindow(DragonBreedingManager.HERB_ITEM_NAME);
      }
      
      private function openCraftWindow(craftItem:String) : void
      {
         if(DragonBreedingManager.getInstance(this.featureName).showCraftingWindowWithItem(craftItem))
         {
            this.close();
         }
      }
      
      private function openCraftBuyWindow(craftItem:String) : void
      {
         tintWindow();
         this.enableInput = false;
         var craftBuyWindow:DragonBreedingBuyCraftWindow = new DragonBreedingBuyCraftWindow(DragonBreedingManager.getInstance(this.featureName).getCraftBuyDialogURL(),this.featureName,craftItem,this);
         UI.displayPopup(craftBuyWindow,false,"",true);
      }
      
      private function onDragonSelectHandler(e:Event = null) : void
      {
         if(DragonBreedingManager.getInstance(this.featureName).getSelectionDialogURL() != "")
         {
            this.m_dragonSelectionWindow = new DragonBreedingSelectionWindow(this.featureName,null,this);
            UI.displayPopup(this.m_dragonSelectionWindow,false);
            tintWindow();
            enableInput = false;
            UI.stopPopups(true);
            if(this.isInTutorial())
            {
               if(this.assertTutorialIndexIs(TUTORIAL_STEP_3))
               {
                  this.displayTutorialMessage(TUTORIAL_STEP_4);
               }
            }
         }
      }
      
      private function initializeLair() : void
      {
         if(m_window.hasOwnProperty(this.LAIR_MC))
         {
            this.m_lair = m_window[this.LAIR_MC];
            if(this.m_lair.hasOwnProperty(this.DRAGON_SELET_BTN))
            {
               this.m_selectDragonBtn = addWidget(new FarmAnimatedTextButton(this.m_lair[this.DRAGON_SELET_BTN],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_main_selecteBtnTxt"),this.onDragonSelectHandler),true) as FarmAnimatedTextButton;
               this.m_selectDragonBtn.enabled = false;
            }
            if(this.m_lair.hasOwnProperty(this.MALE_SLOTS_MC))
            {
               addWidget(this.m_maleDragonSlots = new DragonBreedingLairFrame(this.m_lair[this.MALE_SLOTS_MC],this.m_featureName,this,DragonBreedingConfigManager.GENDER_CODE_MALE),true);
            }
            if(this.m_lair.hasOwnProperty(this.FEMALE_SLOTS_MC))
            {
               addWidget(this.m_femaleDragonSlots = new DragonBreedingLairFrame(this.m_lair[this.FEMALE_SLOTS_MC],this.m_featureName,this,DragonBreedingConfigManager.GENDER_CODE_FEMALE),true);
            }
            if(m_window.hasOwnProperty(this.BG_LAIR))
            {
               this.m_bgLairMC = m_window[this.BG_LAIR];
            }
            this.updateSelectDragonBtn();
         }
      }
      
      public function refreshLairWindow() : void
      {
         if(Boolean(this.m_maleDragonSlots) && Boolean(this.m_maleDragonSlots.selectedSlot))
         {
            DragonBreedingManager.getInstance(this.featureName).selectedMaleDragonId = this.m_maleDragonSlots.selectedSlot.itemCode;
            this.m_selectedMaleDragonId = this.m_maleDragonSlots.selectedSlot.itemCode;
         }
         else
         {
            DragonBreedingManager.getInstance(this.featureName).selectedMaleDragonId = "";
            this.m_selectedMaleDragonId = "";
         }
         if(Boolean(this.m_femaleDragonSlots) && Boolean(this.m_femaleDragonSlots.selectedSlot))
         {
            DragonBreedingManager.getInstance(this.featureName).selectedFemaleDragonId = this.m_femaleDragonSlots.selectedSlot.itemCode;
            this.m_selectedFemaleDragonId = this.m_femaleDragonSlots.selectedSlot.itemCode;
         }
         else
         {
            DragonBreedingManager.getInstance(this.featureName).selectedFemaleDragonId = "";
            this.m_selectedFemaleDragonId = "";
         }
         if(this.isInTutorial())
         {
            if(this.m_maleDragonSlots.selectedSlot)
            {
               this.m_maleDragonSlots.selectedSlot.setSelectState(true);
            }
            if(this.m_femaleDragonSlots.selectedSlot)
            {
               this.m_femaleDragonSlots.selectedSlot.setSelectState(true);
            }
         }
         this.updateSelectDragonBtn();
      }
      
      public function updateSelectDragonBtn() : void
      {
         var suiteSlot:Number = NaN;
         this.m_selectDragonBtn.text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_main_selecteBtnTxt");
         if(Boolean(this.m_selectedFemaleDragonId && this.m_selectedFemaleDragonId != "") && Boolean(this.m_selectedMaleDragonId) && this.m_selectedMaleDragonId != "")
         {
            suiteSlot = DragonBreedingManager.getInstance(this.featureName).findFreeSlot();
            if(suiteSlot > -1)
            {
               this.m_selectDragonBtn.enabled = true;
               this.m_selectDragonBtn.text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_main_selecteBtnTxt");
            }
            else
            {
               this.m_selectDragonBtn.enabled = false;
               this.m_selectDragonBtn.text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_main_selecteBtnTxtDisabled");
            }
            if(!this.m_maleDragonSlots.isSelectedSlotVisible || !this.m_femaleDragonSlots.isSelectedSlotVisible)
            {
               this.m_selectDragonBtn.enabled = false;
            }
         }
         else
         {
            this.m_selectDragonBtn.enabled = false;
         }
      }
      
      private function onSelectDragonBtnOver(e:MouseEvent) : void
      {
         this.m_selectDragonBtn.attachTooltip(new FarmTextTooltip("All Slot are full"));
      }
      
      private function onSelectDragonBtnOut(e:MouseEvent) : void
      {
         this.m_selectDragonBtn.detachTooltip();
      }
      
      public function switchToTab(e:Event = null, tabIndex:int = 0) : void
      {
         if(!tabIndex)
         {
            if(this.m_activeTab == TAB_LAIR)
            {
               tabIndex = TAB_HATCHERY;
            }
            else if(this.m_activeTab == TAB_HATCHERY)
            {
               tabIndex = TAB_LAIR;
            }
         }
         switch(tabIndex)
         {
            case TAB_LAIR:
               this.openLairWindow();
               this.m_hatcheryBtn.text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_main_visitBtnTxt1");
               this.m_genericTitle.text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_title");
               break;
            case TAB_HATCHERY:
               this.openHatcheryWindow();
               this.m_hatcheryBtn.text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_main_visitBtnTxt2");
               this.m_genericTitle.text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_main_tabBtnTxt");
         }
         this.checkAskFireEnabled();
         this.checkAskHerbEnabled();
      }
      
      private function initializeHatchery() : void
      {
         if(m_window.hasOwnProperty("hatchery_mc"))
         {
            this.m_hatchery = addWidget(new DragonBreedingHatcheryFrame(m_window.hatchery_mc,this,this.m_featureName)) as DragonBreedingHatcheryFrame;
            this.m_hatchery.visible = false;
         }
         if(m_window.hasOwnProperty(this.BG_HATCHERY))
         {
            this.m_bgHatcheryMC = m_window[this.BG_HATCHERY];
         }
      }
      
      private function openLairWindow(e:Event = null) : void
      {
         this.resetHatcheryWindow();
         this.animateToLair();
         this.showLair();
         this.canShowVDTutorialStep2();
         this.m_activeTab = TAB_LAIR;
      }
      
      private function openHatcheryWindow(e:Event = null) : void
      {
         this.resetLairWindow();
         this.animateToHatchery();
         this.showHatchery();
         this.m_activeTab = TAB_HATCHERY;
      }
      
      private function resetHatcheryWindow() : void
      {
         if(this.m_hatchery)
         {
            this.m_hatchery.visible = false;
         }
      }
      
      private function animateToLair() : void
      {
         if(this.m_bgLairMC)
         {
            this.m_bgLairMC.visible = true;
         }
         if(this.m_bgHatcheryMC)
         {
            this.m_bgHatcheryMC.visible = false;
         }
      }
      
      private function showLair() : void
      {
         if(this.m_lair)
         {
            this.m_lair.visible = true;
            this.m_maleDragonSlots.refresh();
            this.m_femaleDragonSlots.refresh();
         }
         if(this.m_bgLairMC)
         {
            this.m_bgLairMC.visible = true;
         }
      }
      
      private function resetLairWindow() : void
      {
         if(this.m_lair)
         {
            this.m_lair.visible = false;
         }
      }
      
      private function animateToHatchery() : void
      {
         if(this.m_bgLairMC)
         {
            this.m_bgLairMC.visible = false;
         }
         if(this.m_bgHatcheryMC)
         {
            this.m_bgHatcheryMC.visible = true;
         }
      }
      
      private function showHatchery() : void
      {
         this.m_hatchery.visible = true;
         this.m_hatchery.refresh();
      }
      
      public function openFamilyTreeWindow(e:Event = null) : void
      {
         if(DragonBreedingManager.getInstance(this.featureName).getFamilyTreeDialogURL() != "")
         {
            UI.displayPopup(new DragonBreedingFamilyWindow(this.m_featureName,DragonBreedingManager.MAIN_WINDOW,new DragonBreedingSelectionWindow(this.m_featureName),this),false);
            tintWindow();
            enableInput = false;
            UI.stopPopups(true);
         }
      }
      
      private function openProgressWindow(e:Event = null) : void
      {
         if(DragonBreedingManager.getInstance(this.featureName).getProgressDialogURL() != "")
         {
            UI.displayPopup(new DragonBreedingProgressWindow(this.m_featureName,null,this),false);
            tintWindow();
            enableInput = false;
            UI.stopPopups(true);
         }
      }
      
      private function onClosPopup() : void
      {
         untintWindow();
         enableInput = true;
         UI.stopPopups(false);
      }
      
      private function howDoesThisWorkClick(e:Event = null) : void
      {
         var items:Array = [];
         var i:int = 1;
         for(i = 1; i <= this.NO_OF_PANELS; i++)
         {
            items.push({
               "overview":this.m_featureName + "_Slot" + i + "Overview",
               "title":this.m_featureName + "_Slot" + i + "Title",
               "body":this.m_featureName + "_Slot" + i + "Body",
               "imageUrl":DragonBreedingManager.getInstance(this.featureName).getFourPanelPath() + i.toString() + ".jpg",
               "buttonTitle":"",
               "buttonUrl":"",
               "localiztionBundle":"Dialogs"
            });
         }
         TutorialUI.displayTutorialOnePageWindow(items,ZLocUtils.t("Dialogs",this.m_featureName + "_title"),false,false,null,null,false,ZLoc.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_tutorial_faq"));
      }
      
      public function enableSpeedUp(value:Boolean) : void
      {
      }
      
      public function updateSunshineBuckets() : void
      {
         var item:FarmItem = null;
         if(this.m_fireCount_text)
         {
            item = Global.farmGameSettingsManager.getFarmItemByCode(DragonBreedingManager.FIRE_ITEM_CODE);
            this.m_fireCount_text.text = DragonBreedingManager.getHatcheryManager(this.featureName).getNumberOfBuckets() + "/" + item.limit.toString();
         }
      }
      
      public function updateLovePotion() : void
      {
         var item:FarmItem = null;
         if(Boolean(this.m_herbCount_text) && Boolean(this.featureName) && this.featureName.length > 0)
         {
            item = Global.farmGameSettingsManager.getFarmItemByCode(DragonBreedingManager.LOVE_POTION_ITEM_CODE);
            this.m_herbCount_text.text = DragonBreedingManager.getInstance(this.featureName).getLovePotionItemCount().toString() + "/" + item.limit.toString();
         }
      }
      
      public function isNPCAnimationAvailable() : Boolean
      {
         return false;
      }
      
      public function get selectedMaleDragonId() : String
      {
         return this.m_selectedMaleDragonId;
      }
      
      public function get selectedFemaleDragonId() : String
      {
         return this.m_selectedFemaleDragonId;
      }
      
      public function set selectedMaleDragonId(id:String) : void
      {
         this.m_selectedMaleDragonId = id;
      }
      
      public function set selectedFemaleDragonId(id:String) : void
      {
         this.m_selectedFemaleDragonId = id;
      }
      
      public function get selectedMaleDragonSlot() : DragonBreedingSlot
      {
         return this.m_maleDragonSlots.selectedSlot;
      }
      
      public function get selectedFemaleDragonSlot() : DragonBreedingSlot
      {
         return this.m_femaleDragonSlots.selectedSlot;
      }
      
      public function animateNpc(npcAnimationCallback:Function) : void
      {
      }
      
      override protected function release() : void
      {
         if(this.m_selectDragonBtn)
         {
            this.m_selectDragonBtn.unregisterEventListener(MouseEvent.MOUSE_OVER,this.onSelectDragonBtnOver);
            this.m_selectDragonBtn.unregisterEventListener(MouseEvent.MOUSE_OVER,this.onSelectDragonBtnOut);
            this.m_selectDragonBtn = null;
         }
         this.unregisterEventListeners();
         this.m_activeTab = 0;
         this.m_askFireBtn = null;
         this.m_askHerbBtn = null;
         this.m_bgHatcheryMC = null;
         this.m_bgLairMC = null;
         this.m_buyFireBtn = null;
         this.m_buyHerbBtn = null;
         this.m_craftFireBtn = null;
         this.m_craftHerbBtn = null;
         this.m_defaultTab = 0;
         this.m_familyTreeBtn = null;
         this.m_femaleDragonSlots = null;
         this.m_fireCount_text = null;
         this.m_fireMC = null;
         this.m_hatchery = null;
         this.m_hatcheryBtn = null;
         this.m_herbCount_text = null;
         this.m_herbsOfLove_mc = null;
         this.m_lair = null;
         this.m_maleDragonSlots = null;
         this.m_progressBtn = null;
         this.m_whatIsThis_mc = null;
         super.release();
      }
      
      override public function close() : void
      {
         this.m_selectedMaleDragonId = "";
         this.m_selectedFemaleDragonId = "";
         TutorialUI.closeTutorialWindow();
         TutorialUI.removeBouncingArrowsForDragonBreeding(m_window);
         UI.stopPopups(false);
         DragonBreedingManager.getInstance(this.m_featureName).dragonBreedingWindow = null;
         super.close();
      }
      
      public function set isOpenWindow(val:Boolean) : void
      {
         this.m_isOpenWindow = val;
      }
      
      public function get isOpenWindow() : Boolean
      {
         return this.m_isOpenWindow;
      }
      
      public function isInTutorial() : Boolean
      {
         return DragonBreedingManager.getInstance(this.featureName).isTutorialMode();
      }
      
      public function assertTutorialIndexIs(expectedIndex:int) : Boolean
      {
         return this.m_lastRequestedTutorialIndex == expectedIndex;
      }
      
      public function displayTutorialMessage(tutorialIndex:int = 1) : void
      {
         this.m_lastRequestedTutorialIndex = tutorialIndex;
         var msg:String = "";
         var dialogUrl:String = DragonBreedingManager.getInstance(this.featureName).getTutorialDialogURL();
         switch(tutorialIndex)
         {
            case TUTORIAL_STEP_1:
               FarmStatsManager.count(this.m_featureName,"FTUE","tutorialstep1");
               this.enableWindow(false);
               msg = ZLoc.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_tutorial_msg_1");
               this.m_femaleDragonSlots.setEnabled(false);
               this.m_femaleDragonSlots.setEnabled(true,0,true);
               this.m_maleDragonSlots.setEnabled(false);
               this.m_maleDragonSlots.setEnabled(true,0);
               TutorialUI.addBouncingArrowsForDragonBreeding(m_window,new Matrix(0,1,1,0,m_window.x - 40,m_window.y + 150));
               TutorialUI.displayDragonBreedingTutorialWindow(msg,new Point(387,42),dialogUrl);
               break;
            case TUTORIAL_STEP_2:
               TutorialUI.closeTutorialWindow();
               TutorialUI.removeBouncingArrowsForDragonBreeding(m_window);
               FarmStatsManager.count(this.m_featureName,"FTUE","tutorialstep2");
               this.enableWindow(false);
               msg = ZLoc.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_tutorial_msg_2");
               this.m_maleDragonSlots.setEnabled(false);
               this.m_femaleDragonSlots.setEnabled(true,0);
               this.m_maleDragonSlots.selectedSlot.setSelectState(true);
               TutorialUI.addBouncingArrowsForDragonBreeding(m_window,new Matrix(0,1,1,0,m_window.x - 40,m_window.y + 335));
               TutorialUI.displayDragonBreedingTutorialWindow(msg,new Point(387,42),dialogUrl);
               break;
            case TUTORIAL_STEP_3:
               TutorialUI.closeTutorialWindow();
               TutorialUI.removeBouncingArrowsForDragonBreeding(m_window);
               FarmStatsManager.count(this.m_featureName,"FTUE","tutorialstep3");
               this.enableWindow(false,this.m_selectDragonBtn);
               msg = ZLoc.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_tutorial_msg_3");
               this.m_maleDragonSlots.setEnabled(false);
               this.m_femaleDragonSlots.setEnabled(false);
               this.m_maleDragonSlots.selectedSlot.setSelectState(true);
               this.m_femaleDragonSlots.selectedSlot.setSelectState(true);
               TutorialUI.addBouncingArrowsForDragonBreeding(m_window,new Matrix(0,1,1,0,m_window.x + 150,m_window.y + 450));
               TutorialUI.displayDragonBreedingTutorialWindow(msg,new Point(387,42),dialogUrl);
               break;
            case TUTORIAL_STEP_4:
               TutorialUI.closeTutorialWindow();
               TutorialUI.removeBouncingArrowsForDragonBreeding(m_window);
               FarmStatsManager.count(this.m_featureName,"FTUE","tutorialstep4");
               msg = ZLoc.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_tutorial_msg_4");
               if(this.m_dragonSelectionWindow)
               {
                  UI.stopPopups(false);
                  TutorialUI.displayDragonBreedingTutorialWindow(msg,new Point(387,42),dialogUrl);
               }
               break;
            case TUTORIAL_STEP_5:
               TutorialUI.closeTutorialWindow();
               FarmStatsManager.count(this.m_featureName,"FTUE","tutorialstep5");
               msg = ZLoc.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_tutorial_msg_5");
               if(this.m_dragonSelectionWindow)
               {
                  UI.stopPopups(false);
                  TutorialUI.displayDragonBreedingTutorialWindow(msg,new Point(387,42),dialogUrl);
               }
               break;
            case TUTORIAL_STEP_6:
               TutorialUI.closeTutorialWindow();
               FarmStatsManager.count(this.m_featureName,"FTUE","tutorialstep6");
               msg = ZLoc.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_tutorial_msg_6");
               TutorialUI.addBouncingArrowsForDragonBreeding(m_window,new Matrix(0,1,1,0,m_window.x - 60,m_window.y + 365));
               TutorialUI.displayDragonBreedingTutorialWindow(msg,new Point(387,42),dialogUrl);
               if(this.m_hatchery)
               {
                  this.m_hatchery.setEnabled(false);
               }
               break;
            case TUTORIAL_STEP_7:
               TutorialUI.closeTutorialWindow();
               TutorialUI.removeBouncingArrowsForDragonBreeding(m_window);
               FarmStatsManager.count(this.m_featureName,"FTUE","tutorialstep7");
               msg = ZLoc.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_tutorial_msg_7");
               TutorialUI.addBouncingArrowsForDragonBreeding(m_window,new Matrix(0,1,1,0,m_window.x - 60,m_window.y + 365));
               TutorialUI.displayDragonBreedingTutorialWindow(msg,new Point(387,42),dialogUrl);
               if(this.m_hatchery)
               {
                  this.m_hatchery.setEnabled(false);
               }
               break;
            case TUTORIAL_STEP_8:
               TutorialUI.closeTutorialWindow();
               TutorialUI.removeBouncingArrowsForDragonBreeding(m_window);
               FarmStatsManager.count(this.m_featureName,"FTUE","tutorialstep8");
               msg = ZLoc.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_tutorial_msg_8");
               TutorialUI.addBouncingArrowsForDragonBreeding(m_window,new Matrix(0,1,1,0,m_window.x - 60,m_window.y + 365));
               TutorialUI.displayDragonBreedingTutorialWindow(msg,new Point(387,42),dialogUrl);
               if(this.m_hatchery)
               {
                  this.m_hatchery.setEnabled(false);
               }
               break;
            case TUTORIAL_STEP_9:
               TutorialUI.closeTutorialWindow();
               TutorialUI.removeBouncingArrowsForDragonBreeding(m_window);
               FarmStatsManager.count(this.m_featureName,"FTUE","tutorialstep9");
               msg = ZLoc.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_tutorial_msg_9",{"user":ZLocUtils.tn(Global.player.name)});
               TutorialUI.displayDragonBreedingTutorialWindow(msg,new Point(387,42),dialogUrl);
               if(this.m_hatchery)
               {
                  this.m_hatchery.setEnabled(false);
               }
               break;
            case TUTORIAL_STEP_10:
               FarmStatsManager.count(this.m_featureName,"FTUE","tutorialstep10");
               TutorialUI.closeTutorialWindow();
               TutorialUI.removeBouncingArrowsForDragonBreeding(m_window);
               this.switchToTab(null,TAB_LAIR);
               if(this.m_hatchery)
               {
                  this.m_hatchery.setEnabled(true);
               }
               this.enableWindow(true);
               this.enableInput = true;
               this.m_maleDragonSlots.setEnabled(true,0);
               this.m_femaleDragonSlots.setEnabled(true,0);
               this.m_maleDragonSlots.selectedSlot = null;
               this.m_femaleDragonSlots.selectedSlot = null;
               this.refreshLairWindow();
         }
      }
      
      public function toggleVisitingDragonTutorial(step:int = 1, toggle:Boolean = false) : void
      {
         if(Boolean(step == VISITING_DRAGON_STEP_1) && Boolean(this.m_visitingDragonTutorialStep1) && Boolean(this.m_vdTutorialStep1Btn))
         {
            this.m_visitingDragonTutorialStep1.visible = toggle;
            this.m_vdTutorialStep1Btn.visible = toggle;
            if(this.m_visitingDragonTutorialStep1.hasOwnProperty("task1_tf"))
            {
               addWidget(new ZwTextField(this.m_visitingDragonTutorialStep1["task1_tf"],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_vd_tutorial1_txt")),true);
            }
         }
         else if(step == VISITING_DRAGON_STEP_2 && Boolean(this.m_visitingDragonTutorialStep2))
         {
            this.m_visitingDragonTutorialStep2.visible = toggle;
         }
      }
      
      private function onVdTutorialStep1BtnClick(e:Event) : void
      {
         DragonBreedingManager.getInstance(this.m_featureName).setVisitingDragonByTutorial();
         this.m_visitingDragonTutorialStep1.visible = false;
         this.m_vdTutorialStep1Btn.visible = false;
         this.switchToTab(null,TAB_LAIR);
      }
      
      private function showVisitingDragonTutorialBySlot() : void
      {
         var genderSlot:DragonBreedingLairFrame = null;
         var vdItemCodes:Array = DragonBreedingManager.getInstance(this.m_featureName).getVisitingDragonItemCodeAsArray();
         var itemCode:String = "";
         var gender:String = "";
         var visitingDragonSlot:Number = -1;
         var visibleTutorialSlot:int = 0;
         if(Boolean(vdItemCodes) && vdItemCodes.length > 0)
         {
            itemCode = vdItemCodes[0];
            gender = DragonBreedingManager.getInstance(this.m_featureName).getVisitingDragonGenderType(itemCode);
            if(gender == DragonBreedingConfigManager.GENDER_CODE_MALE)
            {
               genderSlot = this.m_maleDragonSlots;
            }
            else if(gender == DragonBreedingConfigManager.GENDER_CODE_FEMALE)
            {
               genderSlot = this.m_femaleDragonSlots;
            }
            if(itemCode != "" && gender != "" && Boolean(genderSlot))
            {
               visitingDragonSlot = genderSlot.getSlotIdByItemCode(itemCode);
               if(gender == DragonBreedingConfigManager.GENDER_CODE_FEMALE)
               {
                  if(visitingDragonSlot == 0)
                  {
                     visibleTutorialSlot = 2;
                  }
                  else if(visitingDragonSlot == 1)
                  {
                     visibleTutorialSlot = 4;
                  }
                  else if(visitingDragonSlot == 2)
                  {
                     visibleTutorialSlot = 6;
                  }
               }
               else if(gender == DragonBreedingConfigManager.GENDER_CODE_MALE)
               {
                  if(visitingDragonSlot == 0)
                  {
                     visibleTutorialSlot = 1;
                  }
                  else if(visitingDragonSlot == 1)
                  {
                     visibleTutorialSlot = 3;
                  }
                  else if(visitingDragonSlot == 2)
                  {
                     visibleTutorialSlot = 5;
                  }
               }
               this.toggleVDTutorialStep2(true,visibleTutorialSlot,itemCode);
            }
         }
      }
      
      private function toggleVDTutorialStep2(toggle:Boolean, slotName:int = 0, itemCode:String = "") : void
      {
         var visitingDragonPopup:MovieClip = null;
         var itemName:String = null;
         if(this.m_visitingDragonTutorialStep2)
         {
            this.m_visitingDragonTutorialStep2.visible = true;
            this.hideVisitingDragonTutorial();
            if(slotName != 0 && this.m_visitingDragonTutorialStep2.hasOwnProperty("slot" + slotName + "_mc"))
            {
               visitingDragonPopup = this.m_visitingDragonTutorialStep2["slot" + slotName + "_mc"] as MovieClip;
               visitingDragonPopup.visible = toggle;
               if(visitingDragonPopup.hasOwnProperty("okay" + slotName + "_bt"))
               {
                  if(!this.m_vdTutorialStep2Btn)
                  {
                     this.m_vdTutorialStep2Btn = addWidget(new FarmAnimatedTextButton(visitingDragonPopup["okay" + slotName + "_bt"],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_vd_tutorial2_btn_txt"),this.onVdTutorialStep2BtnClick),true) as FarmAnimatedTextButton;
                  }
                  if(itemCode != "")
                  {
                     itemName = Global.farmGameSettingsManager.getFarmItemByCode(itemCode).friendlyTitle;
                     addWidget(new ZwTextField(visitingDragonPopup["task_tf"],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_vd_tutorial2_txt",{"dragonName":itemName})),true);
                  }
               }
            }
         }
      }
      
      private function onVdTutorialStep2BtnClick(e:Event) : void
      {
         this.m_visitingDragonTutorialStep2.visible = false;
         removeWidget(this.m_visitingDragonTutorialStep2);
         DragonBreedingManager.getInstance(this.m_featureName).setVisitingDragonTutorialSeenFlag();
      }
      
      public function enableWindow(enable:Boolean, displayObj:ZwBaseWidget = null) : void
      {
         this.m_whatIsThis_mc.enabled = enable;
         this.m_hatcheryBtn.enabled = enable;
         this.m_askFireBtn.enabled = enable;
         this.m_askHerbBtn.enabled = enable;
         this.m_buyFireBtn.enabled = enable;
         this.m_buyHerbBtn.enabled = enable;
         this.m_craftFireBtn.enabled = enable;
         this.m_craftHerbBtn.enabled = enable;
         this.m_familyTreeBtn.enabled = enable;
         this.m_progressBtn.enabled = enable;
         this.m_selectDragonBtn.enabled = enable;
         if(m_closeButton)
         {
            m_closeButton.visible = enable;
         }
         else if(m_window.hasOwnProperty("close_bt"))
         {
            m_window.close_bt.visible = enable;
         }
         if(displayObj)
         {
            displayObj.enabled = true;
         }
      }
      
      public function showXpUpAnimation(breedingSession:DragonBreedingSession) : void
      {
         if(breedingSession)
         {
            this.m_levelUpBreedingSession = breedingSession;
         }
         if(this.m_breedUpAnimation)
         {
            this.m_breedUpAnimation.visible = true;
            this.m_breedUpAnimation.play();
            (this.m_breedUpAnimation as MovieClip).addEventListener(Event.ENTER_FRAME,this.onXpUpAnimationPlay);
         }
      }
      
      public function onXpUpAnimationPlay(e:Event) : void
      {
         if(Boolean(this.m_breedUpAnimation) && this.m_breedUpAnimation.currentFrame == this.m_breedUpAnimation.totalFrames - 1)
         {
            (this.m_breedUpAnimation as MovieClip).removeEventListener(Event.ENTER_FRAME,this.onXpUpAnimationPlay);
            this.m_breedUpAnimation.visible = false;
            this.m_breedUpAnimation.mouseEnabled = false;
            if(this.m_levelUpBreedingSession)
            {
               DragonBreedingManager.getInstance(this.featureName).onLevelUpAnimationComplete(this.m_levelUpBreedingSession,this);
            }
         }
      }
      
      public function showLevelUpAnimation() : void
      {
         if(this.m_levelUpAnimation)
         {
            this.m_levelUpAnimation.visible = true;
            this.m_levelUpAnimation.play();
            this.m_levelUpAnimation.mouseEnabled = false;
         }
      }
      
      public function refreshHatcheryWindow() : void
      {
         if(this.m_hatchery)
         {
            this.m_hatchery.refresh();
         }
      }
      
      public function enableWatchToSpeedup(value:Boolean) : void
      {
      }
   }
}

