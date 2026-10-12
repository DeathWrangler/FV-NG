package Display
{
   import Classes.TurkeyRoostBuilding;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Engine.Constants;
   import Engine.Managers.LoadingManager;
   import Engine.Utilities;
   import GameMode.GMAnimalPlace;
   import Managers.FarmGameSettingsManager;
   import Managers.FarmStatsManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.Managers.ZwToggleManager;
   import Widgets.Core.Toggles.ZwVisibilityToggle;
   import flash.display.Loader;
   import flash.display.MovieClip;
   import flash.display.SimpleButton;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   
   public class TurkeyRoostDialog extends Dialog
   {
      
      private static const PANEL_BORDER_EDGE:int = 567;
      
      private static const HUNT_X_OFFSET:int = 50;
      
      private static const HUNT_Y_OFFSET:int = 50;
      
      private static const NUM_SLOTS:int = 4;
      
      public static const MAX_CAPACITY:int = 40;
      
      public static const INITIAL_CAPACITY:int = 20;
      
      public static const ROOST_ENTRY:String = "roost";
      
      public static const EXPAND_ENTRY:String = "expand";
      
      private static const TURKEY_WHAT_SEEN_FLAG:String = "TurkeyRoostWhatIsThis";
      
      private var m_turkeyArray:Array;
      
      private var m_tiles:Array;
      
      private var m_askBtn:GenericButton;
      
      private var m_removeBtn:GenericButton;
      
      private var m_whatIsThis:GenericButton;
      
      private var m_myTurkeysBtn:FarmAnimatedTextButton;
      
      private var m_expandBtn:FarmAnimatedTextButton;
      
      private var m_inventoryPanel:MovieClip;
      
      private var m_expansionPanel:MovieClip;
      
      private var m_infoPanel:MovieClip;
      
      private var m_rollover:MovieClip;
      
      private var m_progressBar:MovieClip;
      
      private var m_twentyContainer:MovieClip;
      
      private var m_fortyContainer:MovieClip;
      
      private var m_chosenTurkey:Number;
      
      private var m_rolloverCloseBtn:SimpleButton;
      
      private var m_entryPoint:String;
      
      private var m_infoTitleText:TextField;
      
      private var m_infoCounterText:TextField;
      
      private var m_rolloverTitleText:TextField;
      
      private var m_mainTitleText:TextField;
      
      private var m_toggleManager:ZwToggleManager;
      
      private var m_turkeyRoostBldg:TurkeyRoostBuilding;
      
      public function TurkeyRoostDialog(turkeyRoostBldg:TurkeyRoostBuilding, entryPoint:String = "roost", modal:Boolean = true, bAddClickBlocker:Boolean = false)
      {
         m_dialogAsset = "assets/dialogs/FV_TurkeyRoost_Complete.swf";
         this.m_turkeyRoostBldg = turkeyRoostBldg;
         this.m_entryPoint = entryPoint;
         super(modal,bAddClickBlocker);
         FarmStatsManager.count("turkeyroost","mainDialog","open");
      }
      
      override protected function onLoadComplete() : void
      {
         this.initalizePanel();
      }
      
      private function initalizePanel() : void
      {
         var entryBool:Boolean = false;
         var turkeyBtnLabel:String = ZLocUtils.t("Dialogs","TurkeyRoostMyTurkeys");
         this.m_myTurkeysBtn = new FarmAnimatedTextButton(m_window.myTurkeys_bt,turkeyBtnLabel,this.onMyTurkeysClick);
         var expandBtnLabel:String = ZLocUtils.t("Dialogs","TurkeyRoostExpandRoost");
         this.m_expandBtn = new FarmAnimatedTextButton(m_window.expand_bt,expandBtnLabel,this.onExpandClick);
         if(this.m_turkeyRoostBldg.capacity == MAX_CAPACITY)
         {
            this.m_expandBtn.enabled = false;
         }
         this.m_inventoryPanel = m_window.frame_inventory_mc;
         this.m_inventoryPanel.visible = true;
         this.m_twentyContainer = this.m_inventoryPanel.items20_mc;
         this.m_fortyContainer = this.m_inventoryPanel.items40_mc;
         this.m_expansionPanel = m_window.frame_expand_mc;
         this.m_expansionPanel.visible = false;
         this.m_infoPanel = this.m_inventoryPanel.infoPanel_mc;
         this.m_askBtn = new GenericButton(this.m_infoPanel.ask_btn,this.onAskClick);
         this.m_askBtn.text = ZLocUtils.t("Dialogs","TurkeyRoostAskForTurkeys");
         if(this.getTurkeyCount() == MAX_CAPACITY)
         {
            this.m_askBtn.toggleDisable(false);
         }
         this.m_infoTitleText = this.m_infoPanel.generic_tf;
         this.m_infoCounterText = this.m_infoPanel.counter_tf;
         this.m_progressBar = this.m_infoPanel.slopBar_mc;
         this.m_rollover = this.m_inventoryPanel.rollover_mc;
         this.m_rollover.visible = false;
         this.m_rolloverCloseBtn = this.m_rollover.close_bt;
         this.m_rolloverCloseBtn.addEventListener(MouseEvent.CLICK,this.onRolloverCloseClick);
         this.m_removeBtn = new GenericButton(this.m_rollover.removel_bt,this.onRemoveClick);
         this.m_rolloverTitleText = this.m_rollover.title_tf;
         this.m_whatIsThis = new GenericButton(m_window.whatisthis_mc,this.onWhatIsThisClick);
         m_window.close_bt.addEventListener(MouseEvent.CLICK,this.onCloseClick);
         this.m_mainTitleText = m_window.title_tf;
         this.m_mainTitleText.text = ZLocUtils.t("Dialogs","TurkeyRoostTitle");
         var turkeyFrame:ZwFrame = new ZwFrame(this.m_inventoryPanel);
         var expandFrame:ZwFrame = new ZwFrame(this.m_expansionPanel);
         this.m_infoPanel.visible = true;
         this.m_twentyContainer.visible = true;
         this.m_fortyContainer.visible = true;
         if(this.m_entryPoint == ROOST_ENTRY)
         {
            entryBool = true;
         }
         else
         {
            entryBool = false;
         }
         this.m_toggleManager = new ZwToggleManager();
         this.m_toggleManager.addToggle(new ZwVisibilityToggle(this.m_myTurkeysBtn,turkeyFrame),entryBool);
         if(this.m_turkeyRoostBldg.capacity != MAX_CAPACITY)
         {
            this.m_toggleManager.addToggle(new ZwVisibilityToggle(this.m_expandBtn,expandFrame),!entryBool);
         }
         if(!entryBool)
         {
            this.onExpandClick();
         }
         this.updateProgressBar();
         this.attachTurkeys();
         if(!Global.player.getSeenFlag(TURKEY_WHAT_SEEN_FLAG))
         {
            Global.player.setSeenFlag(TURKEY_WHAT_SEEN_FLAG);
            this.onWhatIsThisClick();
         }
      }
      
      public function updateProgressBar() : void
      {
         var currentTurkeyCount:int = this.getTurkeyCount();
         var turkeyCapacity:Number = this.m_turkeyRoostBldg.capacity;
         this.m_infoCounterText.text = String(currentTurkeyCount) + "/" + String(turkeyCapacity);
         this.m_progressBar.scaleX = currentTurkeyCount / turkeyCapacity;
      }
      
      private function getTurkeyCount() : int
      {
         var turkeyAmount:int = 0;
         var key:String = null;
         var count:int = 0;
         var idx:int = 0;
         var turkeys:Object = this.m_turkeyRoostBldg.getContents();
         this.m_turkeyArray = new Array();
         for(key in turkeys)
         {
            count = int(turkeys[key].num);
            for(idx = 0; idx < count; idx++)
            {
               this.m_turkeyArray.push(Global.farmGameSettingsManager.getFarmItemByCode(turkeys[key].item.code));
            }
         }
         return int(this.m_turkeyArray.length);
      }
      
      private function getTurkeyContainer() : MovieClip
      {
         var turkeyContainer:MovieClip = null;
         if(this.m_turkeyRoostBldg.capacity == INITIAL_CAPACITY)
         {
            turkeyContainer = this.m_twentyContainer;
         }
         else
         {
            turkeyContainer = this.m_fortyContainer;
         }
         return turkeyContainer;
      }
      
      private function attachTurkeys() : void
      {
         var farmItem:FarmItem = null;
         var assetURL:String = null;
         var path:String = null;
         var container:MovieClip = null;
         this.clearAllTurkeys();
         var length:int = int(this.m_turkeyArray.length);
         var mc:MovieClip = this.getTurkeyContainer();
         var isInDataSourceExperiment:Boolean = FarmGameSettingsManager.isInDataSourceExperiment();
         for(var turkeyIdx:int = 0; turkeyIdx < length; turkeyIdx++)
         {
            farmItem = Global.farmGameSettingsManager.getFarmItemByCode(this.m_turkeyArray[turkeyIdx].code);
            if(isInDataSourceExperiment)
            {
               assetURL = farmItem.getStringAtIndexFromDataSource("url",0,"image");
            }
            else
            {
               assetURL = farmItem.xml.image[0].@url;
            }
            path = Global.getAssetURL(assetURL);
            container = mc["holder" + (turkeyIdx + 1) + "_mc"];
            this.addTurkeyAsset(path,container,this.m_turkeyArray[turkeyIdx]);
         }
         this.addEventHandlersToTurkeys();
      }
      
      private function clearAllTurkeys() : void
      {
         var length:int = int(this.m_turkeyArray.length);
         var mc:MovieClip = this.getTurkeyContainer();
         for(var idx:int = 0; idx < length; idx++)
         {
            Utilities.removeAllChildren(mc["holder" + (idx + 1) + "_mc"]);
         }
      }
      
      private function addTurkeyAsset(path:String, container:MovieClip, turkeyItem:FarmItem) : void
      {
         var icon:Loader = null;
         icon = LoadingManager.load(path,function(event:Event):void
         {
            var dispObj:* = icon.content;
            var scale:* = 2 * Constants.TILE_WIDTH / dispObj.width;
            if(turkeyItem.imageScale > 0)
            {
               scale = scale * turkeyItem.imageScale * 0.75;
            }
            dispObj.scaleX = dispObj.scaleY = scale;
            container.addChild(dispObj);
            container.visible = true;
         });
      }
      
      private function addEventHandlersToTurkeys() : void
      {
         var length:int = int(this.m_turkeyArray.length);
         var mc:MovieClip = this.getTurkeyContainer();
         for(var turkeyIdx:int = 0; turkeyIdx < length; turkeyIdx++)
         {
            mc["holder" + (turkeyIdx + 1) + "_mc"].addEventListener(MouseEvent.CLICK,this.onTurkeyClick);
            mc["holder" + (turkeyIdx + 1) + "_mc"].buttonMode = true;
         }
      }
      
      private function showTurkeyPopup(turkeyIdx:String) : void
      {
         var mc:MovieClip = this.getTurkeyContainer();
         var targetClip:MovieClip = mc["holder" + turkeyIdx + "_mc"];
         this.m_chosenTurkey = Number(turkeyIdx) - 1;
         var turkeyItem:FarmItem = this.m_turkeyArray[this.m_chosenTurkey];
         this.m_rolloverTitleText.text = ZLocUtils.tk_pk_asTitle(turkeyItem.friendlyName);
         var containerXoffset:int = mc.x;
         var containerYoffset:int = mc.y;
         this.m_rollover.x = targetClip.x + HUNT_X_OFFSET + containerXoffset;
         if(this.m_rollover.x > PANEL_BORDER_EDGE)
         {
            this.m_rollover.x = PANEL_BORDER_EDGE;
         }
         this.m_rollover.y = targetClip.y - HUNT_Y_OFFSET + containerYoffset;
         this.m_removeBtn.toggleDisable(true);
         this.m_rollover.visible = true;
      }
      
      private function garbageCollection() : void
      {
         this.m_turkeyArray = null;
         this.m_tiles = null;
         this.m_askBtn = null;
         this.m_removeBtn = null;
         this.m_whatIsThis = null;
         this.m_myTurkeysBtn = null;
         this.m_expandBtn = null;
         this.m_inventoryPanel = null;
         m_window = null;
         this.m_expansionPanel = null;
         this.m_infoPanel = null;
         this.m_rollover = null;
         this.m_progressBar = null;
         this.m_twentyContainer = null;
         this.m_fortyContainer = null;
         this.m_chosenTurkey = NaN;
         this.m_rolloverCloseBtn = null;
         this.m_entryPoint = null;
         this.m_infoTitleText = null;
         this.m_infoCounterText = null;
         this.m_rolloverTitleText = null;
         this.m_mainTitleText = null;
         this.m_toggleManager = null;
         this.m_turkeyRoostBldg = null;
      }
      
      public function onAskClick(evt:MouseEvent = null) : void
      {
         this.m_turkeyRoostBldg.onAskClick();
      }
      
      private function onRolloverCloseClick(evt:MouseEvent) : void
      {
         this.m_rollover.visible = false;
      }
      
      private function onRemoveClick(evt:MouseEvent) : void
      {
         var type:String = this.m_turkeyArray[this.m_chosenTurkey].name;
         Global.world.addGameMode(new GMAnimalPlace(type,false,this.m_turkeyRoostBldg.getId()));
         this.onCloseClick(null);
      }
      
      private function onWhatIsThisClick(evt:MouseEvent = null) : void
      {
         var msg:String = ZLocUtils.t("Dialogs","turkeyroostFinished_WhatIsThis");
         var dialog:GenericXMLDialog = new GenericXMLDialog(null,null,null,null,NaN,NaN,msg,null,false,ZLocUtils.t("Dialogs","Okay"));
         UI.displayPopup(dialog,false);
      }
      
      override public function onCloseClick(evt:MouseEvent) : void
      {
         super.onCloseClick(evt);
         this.clearAllTurkeys();
         FarmStatsManager.count("turkeyroost","mainDialog","exit");
         this.garbageCollection();
         close();
      }
      
      private function onTurkeyClick(evt:MouseEvent) : void
      {
         var targetName:String = evt.currentTarget.name;
         var turkeyIdx:String = targetName.split("holder")[1].split("_")[0];
         this.showTurkeyPopup(turkeyIdx);
      }
      
      private function onMyTurkeysClick(evt:MouseEvent = null) : void
      {
         this.m_inventoryPanel.visible = true;
         this.m_expansionPanel.visible = false;
      }
      
      private function onExpandClick(evt:MouseEvent = null) : void
      {
         this.m_inventoryPanel.visible = false;
         new TurkeyRoostExpansionWithdrawal(this.m_turkeyRoostBldg,this.m_expansionPanel,this);
      }
   }
}

