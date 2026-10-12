package Display
{
   import Classes.EmbeddedArt;
   import Classes.PigpenBuilding;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Engine.Constants;
   import Engine.Managers.LoadingManager;
   import Engine.Utilities;
   import Events.GenericPopupEvent;
   import Managers.FarmGameSettingsManager;
   import Managers.FarmStatsManager;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.Managers.ZwToggleManager;
   import Widgets.Core.Toggles.ZwVisibilityToggle;
   import flash.display.DisplayObject;
   import flash.display.Loader;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.text.TextField;
   import flash.utils.Dictionary;
   import flash.utils.Timer;
   
   public class PigpenDialog extends Dialog
   {
      
      private static const SLEEP_SLOTS_TOTAL:int = 5;
      
      private static const PANEL_BORDER_EDGE:int = 260;
      
      private static const HUNT_X_OFFSET:int = 50;
      
      private static const HUNT_X_MAX_OFFSET:int = 140;
      
      private static const HUNT_Y_OFFSET:int = 50;
      
      public static const MAX_CAPACITY:int = 40;
      
      public static const DEFAULT_ENTRY:String = "default";
      
      public static const EXPAND_ENTRY:String = "expand";
      
      private var m_restingPigs:Array = new Array();
      
      private var m_readyPigs:Array;
      
      private var m_genericSleepRemovalButtons:Array = new Array();
      
      private var m_showWhatIsThisDialogOnLoad:Boolean = false;
      
      private var m_hasClickedAPig:Boolean = false;
      
      private var m_onInit:Boolean = true;
      
      private var m_contents:Dictionary;
      
      private var m_bouncingArrow:DisplayObject;
      
      private var m_whatIsThis:GenericButton;
      
      private var m_huntBtn:GenericButton;
      
      private var m_removeBtn:GenericButton;
      
      private var m_curtain:GenericButtonBouncingArrow;
      
      private var m_makeSlopBtn:GenericButtonBouncingArrow;
      
      private var m_maxSlop:int;
      
      private var m_sleepIndex:int = 0;
      
      private var m_sleepPagingMax:int;
      
      private var m_currentlySleeping:int;
      
      private var m_inventoryBtn:FarmAnimatedTextButton;
      
      private var m_expandBtn:FarmAnimatedTextButton;
      
      private var m_huntingPanel:MovieClip;
      
      private var m_inventoryPanel:MovieClip;
      
      private var m_expansionPanel:MovieClip;
      
      private var m_toggleManager:ZwToggleManager;
      
      private var m_sleepPanel:MovieClip;
      
      private var m_pigLevel:MovieClip;
      
      private var m_tiredPigs:MovieClip;
      
      private var m_feedPanel:MovieClip;
      
      private var m_slopBar:MovieClip;
      
      private var m_sleepCounter:MovieClip;
      
      private var m_pigs:MovieClip;
      
      private var m_resultpanel:MovieClip;
      
      private var m_chosenPig:Number;
      
      private var m_timestamp:Number;
      
      private var m_pigpenBldg:PigpenBuilding;
      
      private var m_entryPoint:String;
      
      private var m_title_tf:TextField;
      
      private var m_counter_tf:TextField;
      
      private var m_label_tf:TextField;
      
      private var m_feedCounter_tf:TextField;
      
      private var m_sleepCountDownTimer:Timer = null;
      
      public function PigpenDialog(pigpenBldg:PigpenBuilding, entryPoint:String = "default", showWhatIsThisDialog:Boolean = false, modal:Boolean = true, bAddClickBlocker:Boolean = false)
      {
         m_dialogAsset = "assets/dialogs/FV_PigPen.swf";
         this.m_pigpenBldg = pigpenBldg;
         this.m_entryPoint = entryPoint;
         this.m_showWhatIsThisDialogOnLoad = showWhatIsThisDialog;
         super(modal,bAddClickBlocker);
         FarmStatsManager.count("pigpen","mainDialog","open");
      }
      
      override protected function onLoadComplete() : void
      {
         super.onLoadComplete();
         ZLocUtils.setText(m_window,"whatisthis_mc.generic_tf","Dialogs","HowDoesThisWork");
         ZLocUtils.setText(m_window,"frame_inventory_mc.feedPanel_mc.makeSlop_btn.generic_tf","Dialogs","FV_PigPen.key1");
         ZLocUtils.setText(m_window,"frame_inventory_mc.sleepPanel_mc.morePigs_btn.generic_tf","Dialogs","FV_PigPen.key2");
         ZLocUtils.setText(m_window,"frame_inventory_mc.sleepPanel_mc.previous_btn.generic_tf","Dialogs","FV_PigPen.key3");
         ZLocUtils.setText(m_window,"frame_inventory_mc.sleepCounter_mc.label_tf","Dialogs","FV_PigPen.key4");
         ZLocUtils.setText(m_window,"frame_inventory_mc.pigLevel_mc.hunt_btn.title_tf","Dialogs","FV_PigPen.key5");
         ZLocUtils.setText(m_window,"title_tf","Dialogs","PigpenTitle");
         ZLocUtils.setText(m_window,"frame_expand_mc.giftPanel1.buy_bt.generic_tf","Dialogs","Buy");
         ZLocUtils.setText(m_window,"frame_expand_mc.giftPanel2.buy_bt.generic_tf","Dialogs","Buy");
         ZLocUtils.setText(m_window,"frame_expand_mc.giftPanel3.buy_bt.generic_tf","Dialogs","Buy");
         ZLocUtils.setText(m_window,"frame_expand_mc.giftPanel4.buy_bt.generic_tf","Dialogs","Buy");
         ZLocUtils.setText(m_window,"frame_expand_mc.giftPanel1.completeNow_bt.generic_tf","Dialogs","CompleteNow");
         ZLocUtils.setText(m_window,"frame_expand_mc.giftPanel2.completeNow_bt.generic_tf","Dialogs","CompleteNow");
         ZLocUtils.setText(m_window,"frame_expand_mc.giftPanel3.completeNow_bt.generic_tf","Dialogs","CompleteNow");
         ZLocUtils.setText(m_window,"frame_expand_mc.giftPanel4.completeNow_bt.generic_tf","Dialogs","CompleteNow");
         this.initalizePanel();
      }
      
      private function initalizePanel() : void
      {
         var expandEntryBool:Boolean = false;
         var inventoryBtnLabel:String = ZLocUtils.t("Dialogs","PigpenBuildingMyInventoryButton");
         this.m_inventoryBtn = new FarmAnimatedTextButton(m_window.inventory_bt,inventoryBtnLabel,this.onMyInventoryClick);
         var expandBtnLabel:String = ZLocUtils.t("Dialogs","PigpenBuildingExpandBuildingButton");
         this.m_expandBtn = new FarmAnimatedTextButton(m_window.expand_bt,expandBtnLabel,this.onExpandClick);
         if(this.m_pigpenBldg.capacity == MAX_CAPACITY)
         {
            this.m_expandBtn.enabled = false;
         }
         this.m_inventoryPanel = m_window.frame_inventory_mc;
         this.m_inventoryPanel.visible = true;
         this.m_expansionPanel = m_window.frame_expand_mc;
         this.m_expansionPanel.visible = false;
         this.m_inventoryBtn.visible = false;
         this.m_expandBtn.visible = false;
         var inventoryFrame:ZwFrame = new ZwFrame(this.m_inventoryPanel);
         var expandFrame:ZwFrame = new ZwFrame(this.m_expansionPanel);
         this.m_expansionPanel.generic_tf.text = ZLocUtils.t("Dialogs","PigpenExpandDialogText");
         this.m_expansionPanel.generic_tf.visible = true;
         this.m_huntingPanel = this.m_inventoryPanel.huntingPanel_mc;
         this.m_huntingPanel.visible = false;
         this.m_resultpanel = this.m_inventoryPanel.resultsPanel_mc;
         if(this.m_resultpanel == null)
         {
            this.m_resultpanel = this.m_huntingPanel;
         }
         else
         {
            this.m_resultpanel.visible = false;
         }
         this.m_sleepPanel = this.m_inventoryPanel.sleepPanel_mc;
         this.m_sleepPanel.visible = false;
         this.m_pigLevel = this.m_inventoryPanel.pigLevel_mc;
         this.m_pigLevel.visible = false;
         this.m_huntBtn = new GenericButton(this.m_pigLevel.hunt_btn,this.onHuntClick);
         this.m_huntBtn.toggleDisable(false);
         this.m_removeBtn = new GenericButton(this.m_pigLevel.remove_btn,this.onRemoveClick);
         this.m_removeBtn.toggleDisable(false);
         this.m_pigLevel.close_bt.addEventListener(MouseEvent.CLICK,this.onCloseLevel);
         this.m_tiredPigs = this.m_inventoryPanel.tiredPigs_mc;
         this.m_tiredPigs.visible = false;
         this.m_feedPanel = this.m_inventoryPanel.feedPanel_mc;
         this.m_feedPanel.visible = true;
         this.m_slopBar = this.m_feedPanel.slopBar_mc;
         this.m_sleepCounter = this.m_inventoryPanel.sleepCounter_mc;
         this.m_sleepCounter.visible = true;
         this.m_pigs = this.m_inventoryPanel.pigs_mc;
         this.m_pigs.visible = true;
         this.m_whatIsThis = new GenericButton(m_window.whatisthis_mc,this.onWhatIsThisClick);
         this.m_makeSlopBtn = new GenericButtonBouncingArrow(this.m_feedPanel.makeSlop_btn,this.onMakeSlopClick);
         this.m_makeSlopBtn.useGrayOnDisabled = true;
         this.m_curtain = new GenericButtonBouncingArrow(this.m_inventoryPanel.curtain_mc,this.onCurtainClick,"","",20,-5);
         this.m_curtain.toggleDisable(false);
         this.m_curtain.turnOff();
         m_window.close_bt.addEventListener(MouseEvent.CLICK,this.onCloseClick);
         this.m_title_tf = m_window.title_tf;
         this.m_feedCounter_tf = this.m_feedPanel.counter_tf;
         this.updateFeedCounter();
         this.m_counter_tf = this.m_sleepCounter.counter_tf;
         if(this.m_entryPoint == EXPAND_ENTRY)
         {
            expandEntryBool = true;
         }
         else
         {
            expandEntryBool = false;
         }
         this.m_toggleManager = new ZwToggleManager();
         this.m_toggleManager.addToggle(new ZwVisibilityToggle(this.m_inventoryBtn,inventoryFrame),!expandEntryBool);
         if(this.m_pigpenBldg.capacity != MAX_CAPACITY)
         {
            this.m_toggleManager.addToggle(new ZwVisibilityToggle(this.m_expandBtn,expandFrame),expandEntryBool);
         }
         if(expandEntryBool)
         {
            this.onExpandClick();
         }
         if(!Global.player.getSeenFlag("PigHuntOnboarding"))
         {
            this.m_bouncingArrow = new EmbeddedArt.bouncing_arrow() as DisplayObject;
            this.m_bouncingArrow.x = 5;
            this.m_bouncingArrow.y = -70;
            this.m_bouncingArrow.scaleX = 1;
            this.m_bouncingArrow.scaleY = 1;
         }
         this.updateSlopBar();
         this.updateSleepCounter();
         this.attachReadyPigs();
         this.setupEncourageHunt();
         this.sleepCountDownTimerStart();
         if(this.m_showWhatIsThisDialogOnLoad)
         {
            this.onWhatIsThisClick();
            this.m_showWhatIsThisDialogOnLoad = false;
         }
      }
      
      private function onMyInventoryClick(evt:MouseEvent = null) : void
      {
         this.m_inventoryPanel.visible = true;
         this.m_expansionPanel.visible = false;
      }
      
      private function onExpandClick(evt:MouseEvent = null) : void
      {
         this.m_inventoryPanel.visible = false;
         new PigpenExpansionWithdrawal(this.m_pigpenBldg,this.m_expansionPanel,this);
      }
      
      private function makeSlopOnboarding() : void
      {
         var slopCount:int = this.m_pigpenBldg.getSlopCount();
         if(slopCount == 0 && !Global.player.getSeenFlag("MakeSlopOnboarding") && Global.player.getSeenFlag("PigHuntOnboarding") && Global.player.getSeenFlag("RestingCurtainOnboarding"))
         {
            this.m_makeSlopBtn.showArrow();
         }
      }
      
      private function clearAllPigs() : void
      {
         var length:int = int(this.m_readyPigs.length);
         for(var idx:int = 0; idx < length; idx++)
         {
            Utilities.removeAllChildren(this.m_pigs["pigHolder" + (idx + 1) + "_mc"]);
         }
      }
      
      private function updateSleepCounter() : void
      {
         var key:String = null;
         var sleeping:int = 0;
         var totalPigs:int = 0;
         var contentArray:Array = this.m_pigpenBldg.getContents();
         var length:int = int(contentArray.length);
         for(var contentIdx:int = 0; contentIdx < length; contentIdx++)
         {
            totalPigs += contentArray[contentIdx].num;
         }
         var readyPigs:Object = this.m_pigpenBldg.getReadyPigs();
         var readyCount:int = 0;
         for(key in readyPigs)
         {
            readyCount += readyPigs[key];
         }
         sleeping = totalPigs - readyCount;
         this.m_counter_tf.text = sleeping + "/" + totalPigs;
         this.m_currentlySleeping = sleeping;
         if(sleeping > 0)
         {
            if(!Global.player.getSeenFlag("RestingCurtainOnboarding"))
            {
               this.m_curtain.showArrow();
            }
            this.showSleepingCurtain(true);
         }
         else
         {
            this.showSleepingCurtain(false);
         }
         this.updateAllTiredMessage();
         if(this.m_onInit)
         {
            this.m_onInit = false;
            this.updateAllTiredMessage();
         }
      }
      
      public function showFailedHuntDialog(sMsg:String, sTitleToken:String) : void
      {
         this.m_resultpanel.generic_tf.text = ZLocUtils.t("Dialogs",sTitleToken);
         this.m_resultpanel.generic2_tf.text = ZLocUtils.t("Dialogs",sMsg);
         var okayBt:FarmAnimatedButton = new FarmAnimatedButton(this.m_resultpanel.okay_bt,this.onFailDialogClose);
         this.m_resultpanel.visible = true;
      }
      
      private function onFailDialogClose(evt:MouseEvent = null) : void
      {
         this.m_resultpanel.visible = false;
      }
      
      public function updateAllTiredMessage() : void
      {
         var key:String = null;
         var sleeping:int = 0;
         var totalPigs:int = 0;
         var contentArray:Array = this.m_pigpenBldg.getContents();
         var length:int = int(contentArray.length);
         for(var contentIdx:int = 0; contentIdx < length; contentIdx++)
         {
            totalPigs += contentArray[contentIdx].num;
         }
         var readyPigs:Object = this.m_pigpenBldg.getReadyPigs();
         var readyCount:int = 0;
         for(key in readyPigs)
         {
            readyCount += readyPigs[key];
         }
         sleeping = totalPigs - readyCount;
         if(sleeping == totalPigs)
         {
            this.showAllTiredMessage(true);
         }
         else
         {
            this.showAllTiredMessage();
         }
      }
      
      private function setupEncourageHunt() : void
      {
         this.m_inventoryPanel.pigRoll_mc.generic_tf.text = ZLocUtils.t("Dialogs","PigpenEncourageHunt");
         this.m_inventoryPanel.pigRoll_mc.generic_tf.mouseEnabled = false;
         this.m_inventoryPanel.pigRoll_mc.generic_tf.selectable = false;
         this.refreshEncourageHuntText();
      }
      
      private function refreshEncourageHuntText() : void
      {
         if(this.m_readyPigs != null && this.m_readyPigs.length > 0 && this.m_pigpenBldg.getSlopCount() > 0 && !this.m_hasClickedAPig)
         {
            this.m_inventoryPanel.pigRoll_mc.visible = true;
         }
         else
         {
            this.m_inventoryPanel.pigRoll_mc.visible = false;
         }
      }
      
      private function showAllTiredMessage(bool:Boolean = false) : void
      {
         this.m_tiredPigs.visible = bool;
      }
      
      private function showSleepingCurtain(bool:Boolean = false) : void
      {
         this.m_curtain.toggleDisable(bool);
         if(bool)
         {
            this.m_curtain.turnOn();
         }
         else
         {
            this.m_curtain.turnOff();
         }
      }
      
      private function attachReadyPigs() : void
      {
         var key:String = null;
         var length:int = 0;
         var farmItem:FarmItem = null;
         var assetURL:String = null;
         var isInDataSourceExperiment:Boolean = false;
         var pigIdx:int = 0;
         var count:int = 0;
         var idx:int = 0;
         var path:String = null;
         var container:MovieClip = null;
         var readyPigs:Object = this.m_pigpenBldg.getReadyPigs();
         this.m_readyPigs = new Array();
         for(key in readyPigs)
         {
            count = int(readyPigs[key]);
            for(idx = 0; idx < count; idx++)
            {
               this.m_readyPigs.push(Global.farmGameSettingsManager.getFarmItemByCode(key));
            }
         }
         this.clearAllPigs();
         length = int(this.m_readyPigs.length);
         isInDataSourceExperiment = FarmGameSettingsManager.isInDataSourceExperiment();
         for(pigIdx = 0; pigIdx < length; pigIdx++)
         {
            farmItem = Global.farmGameSettingsManager.getFarmItemByCode(this.m_readyPigs[pigIdx].code);
            if(isInDataSourceExperiment)
            {
               assetURL = farmItem.getStringAtIndexFromDataSource("url",0,"image");
            }
            else
            {
               assetURL = farmItem.xml.image[0].@url;
            }
            path = Global.getAssetURL(assetURL);
            container = this.m_pigs["pigHolder" + (pigIdx + 1) + "_mc"];
            this.addPigAsset(path,container,this.m_readyPigs[pigIdx]);
         }
         if(length > 0 && !Global.player.getSeenFlag("PigHuntOnboarding"))
         {
            Global.player.setSeenFlag("PigHuntOnboarding");
            this.m_pigs.pigHolder1_mc.addChild(this.m_bouncingArrow);
         }
         this.addEventHandlersToPigs();
      }
      
      private function addPigAsset(path:String, container:MovieClip, pigItem:FarmItem) : void
      {
         var icon:Loader = null;
         icon = LoadingManager.load(path,function(event:Event):void
         {
            var dispObj:* = icon.content;
            var scale:* = 2 * Constants.TILE_WIDTH / dispObj.width;
            if(pigItem.imageScale > 0)
            {
               scale *= pigItem.imageScale;
            }
            dispObj.scaleX = dispObj.scaleY = scale;
            container.addChild(dispObj);
            container.visible = true;
         });
      }
      
      private function addPigIcon(path:String, container:MovieClip) : void
      {
         var icon:Loader = null;
         icon = LoadingManager.load(path,function(event:Event):void
         {
            var dispObj:* = icon.content;
            dispObj.width = dispObj.height = 25;
            container.addChild(dispObj);
            container.visible = true;
         });
      }
      
      private function addEventHandlersToPigs() : void
      {
         var length:int = int(this.m_readyPigs.length);
         for(var pigIdx:int = 0; pigIdx < length; pigIdx++)
         {
            this.m_pigs["pigHolder" + (pigIdx + 1) + "_mc"].addEventListener(MouseEvent.CLICK,this.onPigClick);
            this.m_pigs["pigHolder" + (pigIdx + 1) + "_mc"].buttonMode = true;
         }
      }
      
      private function removeEventHandlersToPigs() : void
      {
         var length:int = int(this.m_readyPigs.length);
         for(var pigIdx:int = 0; pigIdx < length; pigIdx++)
         {
            this.m_pigs["pigHolder" + (pigIdx + 1) + "_mc"].removeEventListener(MouseEvent.CLICK,this.onPigClick);
            this.m_pigs["pigHolder" + (pigIdx + 1) + "_mc"].buttonMode = false;
         }
      }
      
      private function onPigClick(event:MouseEvent) : void
      {
         var targetName:String = null;
         var pigIdx:String = null;
         if(!this.m_huntingPanel.visible)
         {
            if(Global.player.getSeenFlag("PigHuntOnboarding"))
            {
               if(this.m_pigs.pigHolder1_mc.numChildren == 2)
               {
                  this.m_pigs.pigHolder1_mc.removeChildAt(0);
               }
            }
            targetName = event.currentTarget.name;
            pigIdx = targetName.split("pigHolder")[1].split("_")[0];
            this.showPigPopup(pigIdx);
         }
      }
      
      private function showPigPopup(pigIdx:String) : void
      {
         var truffleType:String = null;
         var pigXML:XML = null;
         var targetClip:MovieClip = this.m_pigs["pigHolder" + pigIdx + "_mc"];
         this.m_chosenPig = Number(pigIdx) - 1;
         var pigItem:FarmItem = this.m_readyPigs[this.m_chosenPig];
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            truffleType = pigItem.getStringFromDataSource("truffleType");
         }
         else
         {
            pigXML = pigItem.xml;
            truffleType = pigXML.truffleType;
         }
         var truffleTypeName:String = Global.farmGameSettingsManager.getFarmItemByName(truffleType).friendlyName;
         this.m_pigLevel.level_tf.text = ZLocUtils.tk_pk_asTitle(truffleTypeName);
         this.m_pigLevel.pigTitle_tf.text = pigItem.friendlyTitle;
         var containerXoffset:int = this.m_pigs.x;
         var containerYoffset:int = this.m_pigs.y;
         this.m_pigLevel.x = targetClip.x + HUNT_X_OFFSET + containerXoffset;
         if(this.m_pigLevel.x > PANEL_BORDER_EDGE)
         {
            this.m_pigLevel.x = HUNT_X_MAX_OFFSET;
         }
         this.m_pigLevel.y = targetClip.y - HUNT_Y_OFFSET + containerYoffset;
         this.m_huntBtn.toggleDisable(true);
         this.m_removeBtn.toggleDisable(true);
         this.m_pigLevel.visible = true;
         this.m_hasClickedAPig = true;
         this.refreshEncourageHuntText();
      }
      
      private function onHuntClick(event:MouseEvent) : void
      {
         var pigItem:FarmItem = null;
         var code:String = null;
         this.m_pigLevel.visible = false;
         if(this.m_pigpenBldg.hasHuntedToCapacity())
         {
            this.m_pigpenBldg.openDialogHuntMaxHuntsReached(this.m_pigpenBldg.maxNumHuntsPerDay());
            return;
         }
         var slopCount:int = this.m_pigpenBldg.getSlopCount();
         if(slopCount > 0)
         {
            pigItem = this.m_readyPigs[this.m_chosenPig];
            code = pigItem.code;
            this.m_pigpenBldg.hunt(code);
            this.showWaitingPig();
         }
         else
         {
            this.m_pigpenBldg.openDialogSlopOutOfSlop();
         }
      }
      
      private function onRemoveClick(event:MouseEvent) : void
      {
         var pigItem:FarmItem = this.m_readyPigs[this.m_chosenPig];
         this.m_pigpenBldg.attemptPigPlacementForPigRemoval(pigItem.code);
         this.onCloseClick(null);
      }
      
      private function onCurtainClick(event:MouseEvent) : void
      {
         var msg:String = null;
         var genPop:GenericPopup = null;
         if(!Global.player.getSeenFlag("RestingCurtainOnboarding"))
         {
            this.m_curtain.hideArrow();
            Global.player.setSeenFlag("RestingCurtainOnboarding");
            msg = ZLocUtils.t("Dialogs","PigpenCurtainOnboarding");
            genPop = new GenericPopup(msg,GenericPopup.TYPE_OK,this.showSleepingPanel,GenericPopup.GENERIC_ASSET,"",false,true);
            UI.displayPopup(genPop,false,"CurtainOnboarding",true);
         }
         else
         {
            this.showSleepingPanel();
         }
      }
      
      private function showSleepingPanel(event:GenericPopupEvent = null) : void
      {
         this.setSleepPanel();
         this.m_sleepPanel.visible = true;
         this.m_sleepPanel.close_bt.addEventListener(MouseEvent.CLICK,this.onCloseSleep);
      }
      
      private function onCloseSleep(event:MouseEvent) : void
      {
         if(!Global.player.getSeenFlag("MakeSlopOnboarding"))
         {
            this.makeSlopOnboarding();
         }
         this.m_sleepPanel.visible = false;
         this.m_sleepPanel.close_bt.removeEventListener(MouseEvent.CLICK,this.onCloseSleep);
      }
      
      private function setSleepPanel() : void
      {
         this.setSleepingPigArray();
         this.setSleepLocaleText();
         this.m_sleepPagingMax = Math.floor((this.m_currentlySleeping - 1) / SLEEP_SLOTS_TOTAL);
         if(this.m_sleepPagingMax > 0)
         {
            this.setPagingArrows(true);
         }
         else
         {
            this.setPagingArrows(false);
         }
         this.setSleepIcons();
         this.updateSleepTime();
      }
      
      private function setSleepLocaleText() : void
      {
         var restingPigIdx:int = 0;
         this.m_sleepPanel.sleepTitle_mc.text = ZLocUtils.t("Dialogs","PigpenSleepTitle");
         for(var idx:int = 1; idx <= SLEEP_SLOTS_TOTAL; idx++)
         {
            restingPigIdx = this.m_sleepIndex * SLEEP_SLOTS_TOTAL + idx - 1;
            if(restingPigIdx >= this.m_restingPigs.length)
            {
               break;
            }
            this.m_sleepPanel["pig" + idx + "_mc"].copy_tf.text = ZLocUtils.tk_pk_asTitle(this.m_restingPigs[restingPigIdx].friendlyName);
            this.m_sleepPanel["pig" + idx + "_mc"].remove_btn.title_tf.text = ZLocUtils.t("Dialogs","PigpenSleepRemove");
         }
      }
      
      private function setSleepingPigArray() : void
      {
         var key:String = null;
         var count:int = 0;
         var idx:int = 0;
         var restingPigs:Dictionary = this.m_pigpenBldg.getRestingPigs();
         this.m_restingPigs = new Array();
         for(key in restingPigs)
         {
            count = int(restingPigs[key]);
            for(idx = 0; idx < count; idx++)
            {
               this.m_restingPigs.push(Global.farmGameSettingsManager.getFarmItemByCode(key));
            }
         }
      }
      
      private function setSleepIcons() : void
      {
         var farmItem:FarmItem = null;
         var assetURL:String = null;
         var path:String = null;
         var can:Boolean = false;
         var mc:MovieClip = null;
         var gb:GenericButton = null;
         var container:MovieClip = null;
         this.clearIcons();
         this.m_genericSleepRemovalButtons = new Array();
         for(var idx:int = 1; idx <= SLEEP_SLOTS_TOTAL; idx++)
         {
            this.m_sleepPanel["pig" + idx + "_mc"].visible = false;
            this.m_genericSleepRemovalButtons.push(new GenericButton(this.m_sleepPanel["pig" + idx + "_mc"].remove_btn,this.onSleepRemoveClick));
         }
         var startRange:int = this.m_sleepIndex * SLEEP_SLOTS_TOTAL + 1;
         var topRange:int = this.m_sleepIndex * SLEEP_SLOTS_TOTAL + SLEEP_SLOTS_TOTAL;
         var containerIdx:int = 1;
         var isInDataSourceExperiment:Boolean = FarmGameSettingsManager.isInDataSourceExperiment();
         for(var iconIdx:int = startRange; iconIdx <= topRange; iconIdx++)
         {
            if(this.m_currentlySleeping >= iconIdx)
            {
               farmItem = Global.farmGameSettingsManager.getFarmItemByCode(this.m_restingPigs[iconIdx - 1].code);
               if(isInDataSourceExperiment)
               {
                  assetURL = farmItem.getStringAtIndexFromDataSource("url",5,"image");
               }
               else
               {
                  assetURL = farmItem.xml.image[5].@url;
               }
               path = Global.getAssetURL(assetURL);
               this.m_sleepPanel["pig" + containerIdx + "_mc"].visible = true;
               can = this.canRemove(this.m_restingPigs[iconIdx - 1].code);
               gb = this.m_genericSleepRemovalButtons[containerIdx - 1];
               mc = gb.getButton();
               if(can)
               {
                  mc.visible = true;
                  this.m_genericSleepRemovalButtons[containerIdx - 1].toggleDisable(true);
               }
               else
               {
                  mc.visible = false;
                  this.m_genericSleepRemovalButtons[containerIdx - 1].toggleDisable(false);
               }
               container = this.m_sleepPanel["pig" + containerIdx + "_mc"].pigIcon1_mc;
               containerIdx++;
               this.addPigIcon(path,container);
            }
         }
      }
      
      private function setRemoveButtonVisibleStates() : void
      {
         for(var idx:int = 0; idx < SLEEP_SLOTS_TOTAL; idx++)
         {
         }
      }
      
      private function onSleepRemoveClick(event:MouseEvent) : void
      {
         var btnNum:int = int(event.currentTarget.parent.name.split("_")[0].split("pig")[1]) + this.m_sleepIndex * SLEEP_SLOTS_TOTAL;
         var pigItem:FarmItem = this.m_restingPigs[btnNum - 1];
         this.m_pigpenBldg.attemptPigPlacementForPigRemoval(pigItem.code);
         this.onCloseClick(new MouseEvent(MouseEvent.CLICK));
      }
      
      private function canRemove(code:String) : Boolean
      {
         var can:Boolean = true;
         var length:int = int(this.m_readyPigs.length);
         for(var idx:int = 0; idx < length; idx++)
         {
            if(code == this.m_readyPigs[idx].code)
            {
               can = false;
               break;
            }
         }
         return can;
      }
      
      private function clearIcons() : void
      {
         var mc:MovieClip = null;
         for(var idx:int = 1; idx <= SLEEP_SLOTS_TOTAL; idx++)
         {
            mc = this.m_sleepPanel["pig" + idx + "_mc"].pigIcon1_mc;
            Utilities.removeAllChildren(mc);
         }
      }
      
      private function sleepCountDownTimerStart() : void
      {
         if(this.m_sleepCountDownTimer == null)
         {
            this.m_sleepCountDownTimer = new Timer(1000);
         }
         this.m_sleepCountDownTimer.addEventListener(TimerEvent.TIMER,this.onSleepCountDownTimer);
         this.m_sleepCountDownTimer.reset();
         this.m_sleepCountDownTimer.start();
      }
      
      private function onSleepCountDownTimer(e:TimerEvent) : void
      {
         this.updateSleepTime();
      }
      
      private function sleepCountDownTimerStop() : void
      {
         this.m_sleepCountDownTimer.removeEventListener(TimerEvent.TIMER,this.onSleepCountDownTimer);
         this.m_sleepCountDownTimer.stop();
      }
      
      private function updateSleepTime() : void
      {
         var sCountDown:String = this.m_pigpenBldg.getCoolDownTimeLeft();
         this.m_sleepPanel.timer_tf.text = sCountDown;
         this.m_sleepPanel.readyHunt_tf.text = ZLocUtils.t("Dialogs","PigpenSleepReady");
         if(sCountDown == "00:00:00")
         {
            this.sleepCountDownTimerStop();
            if(this.m_restingPigs.length > 0)
            {
               this.makeRestingPigsReady();
            }
         }
      }
      
      private function makeRestingPigsReady() : void
      {
         if(this.m_sleepPanel.visible == true)
         {
            this.onCloseSleep(new MouseEvent(MouseEvent.CLICK));
         }
         this.setSleepingPigArray();
         var length:int = int(this.m_restingPigs.length);
         for(var idx:int = 0; idx < length; idx++)
         {
            this.m_readyPigs.push(this.m_restingPigs[0]);
            this.m_restingPigs.splice(0,1);
         }
         var newReadyPigObject:Object = new Object();
         var len:int = int(this.m_readyPigs.length);
         for(var rIdx:int = 0; rIdx < len; rIdx++)
         {
            if(newReadyPigObject.hasOwnProperty(this.m_readyPigs[rIdx].code))
            {
               ++newReadyPigObject[this.m_readyPigs[rIdx].code];
            }
            else
            {
               newReadyPigObject[this.m_readyPigs[rIdx].code] = 1;
            }
         }
         this.m_pigpenBldg.clearRestingPigsCache();
         this.m_pigpenBldg.setReadyPigs(newReadyPigObject);
         this.onTransactionComplete();
      }
      
      private function setPagingArrows(bool:Boolean) : void
      {
         if(bool)
         {
            this.m_sleepPanel.previous_btn.buttonMode = true;
            this.m_sleepPanel.morePigs_btn.buttonMode = true;
            if(this.m_sleepIndex == 0)
            {
               this.m_sleepPanel.previous_btn.visible = false;
               this.m_sleepPanel.previous_btn.removeEventListener(MouseEvent.CLICK,this.onPreviousClick);
               this.m_sleepPanel.morePigs_btn.visible = true;
               this.m_sleepPanel.morePigs_btn.addEventListener(MouseEvent.CLICK,this.onMoreClick);
            }
            else if(this.m_sleepIndex == this.m_sleepPagingMax)
            {
               this.m_sleepPanel.previous_btn.visible = true;
               this.m_sleepPanel.previous_btn.addEventListener(MouseEvent.CLICK,this.onPreviousClick);
               this.m_sleepPanel.morePigs_btn.visible = false;
               this.m_sleepPanel.morePigs_btn.removeEventListener(MouseEvent.CLICK,this.onMoreClick);
            }
            else
            {
               this.m_sleepPanel.previous_btn.visible = true;
               this.m_sleepPanel.previous_btn.addEventListener(MouseEvent.CLICK,this.onPreviousClick);
               this.m_sleepPanel.morePigs_btn.visible = true;
               this.m_sleepPanel.morePigs_btn.addEventListener(MouseEvent.CLICK,this.onMoreClick);
            }
         }
         else
         {
            this.m_sleepPanel.previous_btn.visible = false;
            this.m_sleepPanel.previous_btn.removeEventListener(MouseEvent.CLICK,this.onPreviousClick);
            this.m_sleepPanel.morePigs_btn.visible = false;
            this.m_sleepPanel.morePigs_btn.removeEventListener(MouseEvent.CLICK,this.onMoreClick);
         }
      }
      
      private function onMoreClick(event:MouseEvent) : void
      {
         ++this.m_sleepIndex;
         this.setSleepPanel();
      }
      
      private function onPreviousClick(event:MouseEvent) : void
      {
         --this.m_sleepIndex;
         this.setSleepPanel();
      }
      
      private function showWaitingPig() : void
      {
         this.m_huntingPanel.visible = true;
      }
      
      private function hideWaitingPig() : void
      {
         this.m_huntingPanel.visible = false;
      }
      
      private function onCloseLevel(event:MouseEvent) : void
      {
         this.m_pigLevel.visible = false;
      }
      
      public function onTransactionComplete() : void
      {
         this.updateFeedCounter();
         this.updateSlopBar();
         this.updateSleepCounter();
         this.clearAllPigs();
         this.attachReadyPigs();
         this.refreshEncourageHuntText();
         this.hideWaitingPig();
         this.sleepCountDownTimerStart();
      }
      
      public function updateFeedCounter() : void
      {
         this.m_feedCounter_tf.text = this.m_pigpenBldg.getSlopCount() + "/" + this.m_pigpenBldg.getMaxSlop();
      }
      
      public function updateSlopBar() : void
      {
         this.m_feedCounter_tf.text = this.m_pigpenBldg.getSlopCount() + "/" + this.m_pigpenBldg.getMaxSlop();
         this.m_slopBar.scaleX = this.m_pigpenBldg.getSlopCount() / this.m_pigpenBldg.getMaxSlop();
         this.makeSlopOnboarding();
         this.m_makeSlopBtn.disabled = this.m_pigpenBldg.getSlopCount() >= this.m_pigpenBldg.getMaxSlop();
         this.refreshEncourageHuntText();
      }
      
      override public function onCloseClick(evt:MouseEvent) : void
      {
         super.onCloseClick(evt);
         this.clearAllPigs();
         this.clearIcons();
         close();
         FarmStatsManager.count("pigpen","mainDialog","exit");
      }
      
      private function onWhatIsThisClick(evt:MouseEvent = null) : void
      {
         this.disableAllButtons();
         var msg:String = ZLocUtils.t("Dialogs","pigpenFinished_WhatIsThis");
         var whatIsThis:GenericPopup = new GenericPopup(msg,GenericPopup.TYPE_OK,this.onWhatIsThisClose,GenericPopup.GENERIC_ASSET_LRG);
         UI.displayPopup(whatIsThis,false,"whatIsThisPopup",true);
      }
      
      private function onWhatIsThisClose(event:Event) : void
      {
         this.enableAllButtons();
      }
      
      private function disableAllButtons() : void
      {
         this.m_whatIsThis.toggleDisable(false);
         this.m_makeSlopBtn.toggleDisable(false);
         m_window.close_bt.removeEventListener(MouseEvent.CLICK,this.onCloseClick);
      }
      
      private function enableAllButtons() : void
      {
         this.m_whatIsThis.toggleDisable(true);
         this.m_makeSlopBtn.toggleDisable(true);
         m_window.close_bt.addEventListener(MouseEvent.CLICK,this.onCloseClick);
      }
      
      private function onMakeSlopClick(evt:MouseEvent) : void
      {
         var msg:String = null;
         var genPop:GenericPopup = null;
         if(!Global.player.getSeenFlag("MakeSlopOnboarding") && this.m_pigpenBldg.getSlopCount() == 0)
         {
            this.m_makeSlopBtn.hideArrow();
            Global.player.setSeenFlag("MakeSlopOnboarding");
            msg = ZLocUtils.t("Dialogs","PigpenMakeSlopOnboarding");
            genPop = new GenericPopup(msg,GenericPopup.TYPE_OK,this.openMakeSlopDialog,GenericPopup.GENERIC_ASSET,"",false,true);
            UI.displayPopup(genPop,false,"SlopOnboarding",true);
         }
         else
         {
            this.openMakeSlopDialog();
         }
      }
      
      private function openMakeSlopDialog(event:GenericPopupEvent = null) : void
      {
         this.m_pigpenBldg.openDialogSlopMakeSlop();
      }
   }
}

