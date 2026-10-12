package Widgets.Tooltips
{
   import Classes.Constants.ZLocConstants;
   import Classes.FarmVillageFactoryBuilding;
   import Classes.FarmVillageFactoryObject;
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.TutorialUI;
   import Display.UI;
   import Engine.Helpers.Vector3;
   import Events.GenericPopupEvent;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Buttons.FarmAnimatedCashButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import Widgets.Windows.HoverOverWindow;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   
   public class FarmVillageFactoryBuildingToolTip extends HoverOverWindow
   {
      
      private static const WINDOW_ASSET:String = "assets/dialogs/Village/FV_factories_tooltip_xfv.swf";
      
      private static const TUTORIAL_ASSET_PATH_PREFIX:String = "assets/dialogs/FV_Support/FV_FarmVillageFactory/FarmVillageFactory";
      
      private static const HOVER_MENU_TIME_MS:int = 800;
      
      private static const FIND_ME_IN_GIFTBOX_TIME_MS:int = 2000;
      
      private static const OFFSET_Y:int = 310;
      
      private static const OFFSET_X:int = 60;
      
      private var m_name:ZwTextField = null;
      
      private var m_levelValue:ZwTextField = null;
      
      private var m_levelUpInfo:ZwTextField = null;
      
      private var m_upgradeButton:FarmAnimatedTextButton = null;
      
      private var m_speedUpFrame:ZwFrame = null;
      
      private var m_harvestFrame:ZwFrame = null;
      
      private var m_speedUpInfoText:ZwTextField = null;
      
      private var m_speedUpButton:FarmAnimatedCashButton = null;
      
      private var m_harvestButton:FarmAnimatedCashButton = null;
      
      private var m_harvestReadyText:ZwTextField = null;
      
      private var m_icon:FarmIcon = null;
      
      private var m_harvestValueText:ZwTextField = null;
      
      private var m_factoryObject:FarmVillageFactoryObject = null;
      
      private var m_giftboxMovieClip:ZwWidget = null;
      
      private var m_hideTimer:Timer = null;
      
      public function FarmVillageFactoryBuildingToolTip(originPoint:Vector3, factoryBuilding:FarmVillageFactoryBuilding)
      {
         super(originPoint,WINDOW_ASSET,HOVER_MENU_TIME_MS);
         m_offsetY = OFFSET_Y;
         m_offsetX = OFFSET_X;
         var factoryName:String = factoryBuilding.getItemName();
         this.m_factoryObject = new FarmVillageFactoryObject(factoryName,factoryBuilding);
      }
      
      override protected function postLoadComplete() : void
      {
         var main_mc:MovieClip = null;
         var mainFrame:ZwFrame = null;
         super.postLoadComplete();
         if(Boolean(m_window) && m_window.hasOwnProperty("main_mc"))
         {
            main_mc = m_window.main_mc;
            mainFrame = addWidget(new ZwFrame(main_mc)) as ZwFrame;
            if(main_mc.hasOwnProperty("name_tf"))
            {
               this.m_name = mainFrame.addWidget(new ZwTextField(main_mc.name_tf,"")) as ZwTextField;
            }
            if(main_mc.hasOwnProperty("upgrade_bt") && this.m_factoryObject.canLevelUp())
            {
               this.m_upgradeButton = mainFrame.addWidget(new FarmAnimatedTextButton(main_mc.upgrade_bt,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"FeatureBuildingUpgrade"),this.onUpgradeButtonClick)) as FarmAnimatedTextButton;
            }
            if(main_mc.hasOwnProperty("levelValue_tf"))
            {
               this.m_levelValue = mainFrame.addWidget(new ZwTextField(main_mc.levelValue_tf,"")) as ZwTextField;
            }
            if(main_mc.hasOwnProperty("levelText_tf"))
            {
               mainFrame.addWidget(new ZwTextField(main_mc.levelText_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"FarmVillageFactoryBuildingToolTipLevel")));
            }
            if(main_mc.hasOwnProperty("levelUpInfo_tf"))
            {
               this.m_levelUpInfo = mainFrame.addWidget(new ZwTextField(main_mc.levelUpInfo_tf,"")) as ZwTextField;
            }
            if(main_mc.hasOwnProperty("speedUp_mc"))
            {
               this.m_speedUpFrame = mainFrame.addWidget(new ZwFrame(main_mc.speedUp_mc as DisplayObject)) as ZwFrame;
               if(main_mc.speedUp_mc.hasOwnProperty("speedUpInfo_tf"))
               {
                  this.m_speedUpInfoText = this.m_speedUpFrame.addWidget(new ZwTextField(main_mc.speedUp_mc.speedUpInfo_tf,"")) as ZwTextField;
               }
               if(main_mc.speedUp_mc.hasOwnProperty("speedUp_bt"))
               {
                  this.m_speedUpButton = this.m_speedUpFrame.addWidget(new FarmAnimatedCashButton(main_mc.speedUp_mc.speedUp_bt,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"FarmVillageFactoryBuildingToolTipSpeedUp"),"0",this.onSpeedUpButtonClick,false,false,true)) as FarmAnimatedCashButton;
               }
            }
            if(main_mc.hasOwnProperty("icon_mc"))
            {
               this.m_icon = mainFrame.addWidget(new FarmIcon(main_mc.icon_mc,"")) as FarmIcon;
            }
            if(main_mc.hasOwnProperty("harvest_mc"))
            {
               this.m_harvestFrame = mainFrame.addWidget(new ZwFrame(main_mc.harvest_mc as DisplayObject)) as ZwFrame;
               if(main_mc.harvest_mc.hasOwnProperty("harvest_bt"))
               {
                  this.m_harvestButton = this.m_harvestFrame.addWidget(new FarmAnimatedCashButton(main_mc.harvest_mc.harvest_bt,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"Trade"),"0",this.onHarvestButtonClick)) as FarmAnimatedCashButton;
               }
               if(main_mc.harvest_mc.hasOwnProperty("generic_tf"))
               {
                  this.m_harvestReadyText = this.m_harvestFrame.addWidget(new ZwTextField(main_mc.harvest_mc.generic_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"ReadyToHarvest"))) as ZwTextField;
               }
            }
            if(main_mc.hasOwnProperty("harvestValue_tf"))
            {
               this.m_harvestValueText = mainFrame.addWidget(new ZwTextField(main_mc.harvestValue_tf,"")) as ZwTextField;
            }
            if(main_mc.hasOwnProperty("whatisthis_mc"))
            {
               mainFrame.addWidget(new FarmAnimatedButton(main_mc.whatisthis_mc,this.onOpenWhatIsThis));
            }
            if(main_mc.hasOwnProperty("giftbox_mc"))
            {
               this.m_giftboxMovieClip = mainFrame.addWidget(new ZwWidget(main_mc.giftbox_mc)) as ZwWidget;
            }
            this.show();
         }
      }
      
      override public function show() : void
      {
         this.update();
         super.show();
      }
      
      public function beginCloseTimer() : void
      {
         if(m_timerTime > -1 && Boolean(m_fadeOutTimer))
         {
            m_fadeOutTimer.start();
         }
      }
      
      private function update() : void
      {
         var timeRemaining:Number = NaN;
         var isHarvestable:Boolean = false;
         var costPerHarvestString:String = null;
         var timeRemainingText:String = null;
         var rewardObject:Object = null;
         var rewardItem:FarmItem = null;
         var rewardQuantity:int = 0;
         var canLevelUp:Boolean = false;
         if(this.m_factoryObject)
         {
            if(this.m_name)
            {
               this.m_name.text = this.m_factoryObject.factoryFarmItem.friendlyTitle;
            }
            if(Boolean(this.m_speedUpFrame) && Boolean(this.m_harvestFrame))
            {
               timeRemaining = this.m_factoryObject.getTimeRemaining();
               isHarvestable = timeRemaining == 0;
               if(isHarvestable)
               {
                  if(this.m_harvestReadyText)
                  {
                     this.m_harvestReadyText.visible = true;
                  }
                  if(this.m_harvestButton)
                  {
                     costPerHarvestString = this.m_factoryObject.costPerHarvest().toString();
                     this.m_harvestButton.setAmountText(costPerHarvestString);
                     this.m_harvestButton.buyConfirmationText = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"VillageCurrencyBuyConfirmation",{"price":costPerHarvestString});
                     this.m_harvestButton.visible = true;
                  }
               }
               else
               {
                  timeRemainingText = FarmGameUtil.toFriendlyTime(timeRemaining);
                  if(this.m_speedUpInfoText)
                  {
                     this.m_speedUpInfoText.text = ZLocUtils.t("Crafting","CraftingMain_ReadyTime",{"time":timeRemainingText});
                  }
                  if(this.m_speedUpButton)
                  {
                     this.m_speedUpButton.setAmountText(this.m_factoryObject.getSpeedUpPrice().toString());
                     this.m_speedUpButton.visible = true;
                  }
               }
               this.m_speedUpFrame.visible = !isHarvestable;
               this.m_harvestFrame.visible = isHarvestable;
            }
            if(this.m_levelValue)
            {
               this.m_levelValue.text = (this.m_factoryObject.getFactoryLevel() + 1).toString();
            }
            if(Boolean(this.m_icon) && Boolean(this.m_harvestValueText))
            {
               rewardObject = this.m_factoryObject.getReward();
               if(rewardObject)
               {
                  rewardItem = Global.farmGameSettingsManager.getFarmItemByCode(rewardObject.value);
                  rewardQuantity = int(rewardObject.quantity);
                  this.m_icon.loadIcon(rewardItem.iconUrl);
                  this.m_harvestValueText.text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"Quantity",{"quantity":rewardQuantity.toString()});
               }
            }
            if(this.m_factoryObject)
            {
               canLevelUp = this.m_factoryObject.canLevelUp();
               if(this.m_levelUpInfo)
               {
                  if(canLevelUp)
                  {
                     this.m_levelUpInfo.text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"HarvestsNeededToLevelUp",{"quantity":this.m_factoryObject.harvestsNeededToLevelUp().toString()});
                  }
                  else
                  {
                     this.m_levelUpInfo.text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"factory_max_level_text");
                  }
               }
               if(this.m_upgradeButton)
               {
                  this.m_upgradeButton.visible = canLevelUp;
               }
            }
         }
      }
      
      private function onUpgradeButtonClick(event:MouseEvent) : void
      {
         if(this.m_factoryObject)
         {
            UI.displayMessage(ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"FarmCashBuyConfirmation",{"price":this.m_factoryObject.getLevelupPrice()}),GenericPopup.TYPE_ACCEPTCANCEL,this.onAcceptUpgradeConfirmation,"farmVillageFactoryBuildingCashConfirmation",true,true);
         }
      }
      
      private function onAcceptUpgradeConfirmation(event:GenericPopupEvent) : void
      {
         if(event.button == GenericPopup.ACCEPT)
         {
            if(this.m_factoryObject)
            {
               this.m_factoryObject.onInstantLevelUp();
            }
         }
         hide();
      }
      
      private function onSpeedUpButtonClick(event:Event) : void
      {
         if(this.m_factoryObject)
         {
            this.m_factoryObject.onSpeedUpHarvesting();
         }
         hide();
      }
      
      private function onHarvestButtonClick(event:Event) : void
      {
         if(this.m_factoryObject)
         {
            this.m_factoryObject.onHarvest();
            this.m_giftboxMovieClip.visible = true;
            (this.m_giftboxMovieClip.element as MovieClip).gotoAndPlay(2);
            this.m_hideTimer = new Timer(FIND_ME_IN_GIFTBOX_TIME_MS);
            this.m_hideTimer.addEventListener(TimerEvent.TIMER,this.hideCallback);
            this.m_hideTimer.start();
         }
      }
      
      private function hideCallback(event:TimerEvent) : void
      {
         if(this.m_hideTimer)
         {
            this.m_hideTimer.removeEventListener(TimerEvent.TIMER,this.hideCallback);
         }
         hide();
      }
      
      private function onOpenWhatIsThis(event:Event) : void
      {
         TutorialUI.displayBundleTutorialWindow(ZLocConstants.DIALOG_UTIL_PKG,"FarmVillageFactoryBuilding",TUTORIAL_ASSET_PATH_PREFIX,true);
      }
   }
}

