package Classes
{
   import Classes.Constants.Experiments;
   import Classes.util.ZLocUtils;
   import Display.ActionMenu;
   import Display.AddNeighbor;
   import Display.EmailPopup;
   import Display.FarmDynamicDialog;
   import Display.MOTD;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Events.ActionMenuEvent;
   import Managers.EmailManager;
   import Managers.FarmStatsManager;
   import Transactions.TGenericTransaction;
   import Widgets.Windows.FarmWindow;
   import com.troyer.widget.controller.ImageController;
   import com.troyer.widget.event.WidgetControllerEvent;
   import com.troyer.widget.view.TextFieldView;
   import flash.events.Event;
   
   public class TutController
   {
      
      protected static var s_instance:TutController = null;
      
      public static var DEFAULT_PLANT_SEED_ITEM:String = "soybeans";
      
      public static var DIALOG_INTRO:int = 1;
      
      public static var DIALOG_ADDFRIENDS:int = 2;
      
      public static var DIALOG_MOTD:int = 3;
      
      protected static var SEEN_FLAG_FTUE_COMPLETE:String = "ftue_complete";
      
      public static var TUTORIAL_PROGRESS_ACTION_FLAG:String = "tutorialProgress";
      
      protected var m_state:TutState = null;
      
      protected var m_bobbleHead:BobbleHead = null;
      
      protected var m_skipButton:SkipWindow = null;
      
      protected var m_dialog:Object = null;
      
      public function TutController()
      {
         super();
         this.m_bobbleHead = new BobbleHead();
         this.m_skipButton = new SkipWindow(this);
         this.m_bobbleHead.setAbsolutePos(6,85);
         Global.hud.addChild(this.m_bobbleHead);
         this.m_skipButton.setAbsolutePos(6,Global.stage.stageHeight - 200);
         Global.hud.addChild(this.m_skipButton);
         Global.hud.conditionallyRefreshHUD(true);
         this.m_state = new TutState(this);
         this.m_state.initialize();
         FarmStatsManager.count("Tutorial","begin_tutorial");
         this.refreshControls();
      }
      
      public static function createTutorial() : void
      {
         var seenFlagVal:Boolean = Global.player.getSeenFlag(SEEN_FLAG_FTUE_COMPLETE);
         if(!seenFlagVal)
         {
            if(Global.player.level == 1)
            {
               if(null != Global.player.avatar && null == s_instance)
               {
                  s_instance = new TutController();
               }
            }
            else
            {
               Global.player.setSeenFlag(SEEN_FLAG_FTUE_COMPLETE);
            }
         }
      }
      
      public static function hasFinishedTutorial() : Boolean
      {
         return Global.player.getSeenFlag(SEEN_FLAG_FTUE_COMPLETE);
      }
      
      protected function onDialogClosed(event:Event) : void
      {
         this.m_dialog = null;
         AsyncCall.call(this.m_state.onTriggerDialog);
      }
      
      protected function on4DDialogClosed(event:WidgetControllerEvent) : void
      {
         var dynDialog:FarmDynamicDialog = this.m_dialog as FarmDynamicDialog;
         dynDialog.destroy();
         this.m_dialog = null;
         AsyncCall.call(this.m_state.onTriggerDialog);
      }
      
      public function stop() : void
      {
         this.m_state.stop();
         Global.hud.removeChild(this.m_bobbleHead);
         Global.hud.removeChild(this.m_skipButton);
         FarmStatsManager.count("Tutorial","complete_tutorial");
         if(Boolean(Global.flashHotParams["STATS_NANIGANS_ENABLE"]) && Boolean(Global.flashHotParams["STATS_NANIGANS_ENABLE"] == true) && Boolean(Global.player.nanPid))
         {
            TransactionManager.addTransaction(new TGenericTransaction("StatsNanigansService","ftueCompleteTrack"));
         }
         EmailManager.displayEmailPermissionPrompt(EmailPopup.EMAIL_NEW_USER);
         if(!Global.player.getSeenFlag(SEEN_FLAG_FTUE_COMPLETE))
         {
            Global.player.setSeenFlag(SEEN_FLAG_FTUE_COMPLETE);
         }
         Global.hud.conditionallyRefreshHUD(true);
         if(CIPStartNow.canShowGDP() && Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_CIP_START_NOW_GDP) == 2)
         {
            CIPStartNow.showStarterPack();
         }
      }
      
      public function refreshControls() : void
      {
         this.refreshActionMenu();
         this.refreshPlots();
         this.refreshBobbleHead();
         this.refreshSkipButton();
         this.refreshDialogs();
         this.refreshTransactions();
      }
      
      private function refreshActionMenu() : void
      {
         var button:String = this.m_state.button;
         var menu:ActionMenu = Global.ui.getActionMenu();
         menu.getWalkButton().setArrow(button == ActionMenuEvent.ONWALK);
         menu.getPlowButton().setArrow(button == ActionMenuEvent.ONPLOW);
      }
      
      private function refreshPlots() : void
      {
         var plot:Plot = null;
         var plotToHighlight:Plot = this.m_state.plot;
         var plots:Array = Global.world.getObjectsByClass(Plot);
         for each(plot in plots)
         {
            plot.showArrow(plotToHighlight === plot);
         }
      }
      
      private function refreshBobbleHead() : void
      {
         var locId:String = this.m_state.localizationId;
         if(null != locId)
         {
            this.m_bobbleHead.text = ZLocUtils.t("FarmGame",AssetSkinner.getInstance().skinLocId(locId));
         }
         this.refreshFarmWindow(this.m_bobbleHead,null != locId);
      }
      
      private function refreshSkipButton() : void
      {
         this.refreshFarmWindow(this.m_skipButton,this.m_state.showSkipButton);
      }
      
      private function refreshFarmWindow(farmWindow:FarmWindow, showWindow:Boolean) : void
      {
         if(showWindow)
         {
            if(!farmWindow.visible)
            {
               farmWindow.show();
            }
         }
         else if(farmWindow.visible)
         {
            farmWindow.hide();
         }
      }
      
      private function refreshDialogs() : void
      {
         var attributes:Array = null;
         var introDialog:FarmDynamicDialog = null;
         var skinner:AssetSkinner = null;
         var i:* = 0;
         var addDialog:AddNeighbor = null;
         var currentMOTD:Object = null;
         var dialogId:int = this.m_state.dialog;
         if(0 != dialogId && null == this.m_dialog)
         {
            switch(dialogId)
            {
               case DIALOG_INTRO:
                  attributes = new Array({
                     "name":"title",
                     "locId":"FTUEIntro_Title"
                  },{
                     "name":"AcceptButton",
                     "locId":"FTUEIntro_Accept"
                  },{
                     "name":"box1",
                     "locId":"FTUE_Box1"
                  },{
                     "name":"box2",
                     "locId":"FTUE_Box2"
                  },{
                     "name":"box3",
                     "locId":"FTUE_Box3"
                  },{
                     "name":"logo_pic",
                     "pic":"assets/dialogs/4d_elements/FTUE/ftue_welcome_logo.png"
                  },{
                     "name":"bg_pic",
                     "pic":"assets/dialogs/4d_elements/FTUE/ftue_welcome_bg.png"
                  },{
                     "name":"box1_pic",
                     "pic":"assets/dialogs/4d_elements/FTUE/ftue_welcome_slot1.png"
                  },{
                     "name":"box2_pic",
                     "pic":"assets/dialogs/4d_elements/FTUE/ftue_welcome_slot2.png"
                  },{
                     "name":"box3_pic",
                     "pic":"assets/dialogs/4d_elements/FTUE/ftue_welcome_slot3.png"
                  });
                  introDialog = FarmDynamicDialog.createDialog("FTUEIntro",FarmDynamicDialog);
                  introDialog.setup();
                  skinner = AssetSkinner.getInstance();
                  for(i = int(attributes.length - 1); 0 <= i; i--)
                  {
                     if(null != attributes[i].locId)
                     {
                        introDialog.setShortcutAttribute(attributes[i].name,TextFieldView.ATTRIBUTE_TEXT,ZLocUtils.t("Dialogs",skinner.skinLocId(attributes[i].locId)));
                     }
                     if(null != attributes[i].pic)
                     {
                        introDialog.setShortcutAttribute(attributes[i].name,ImageController.ATTRIBUTE_SOURCE,skinner.skinAssetUrl(attributes[i].pic));
                     }
                  }
                  introDialog.setShortcutListener("AcceptButton",WidgetControllerEvent.BUTTON_PRESSED,this.on4DDialogClosed);
                  this.m_dialog = introDialog;
                  introDialog.show();
                  break;
               case DIALOG_ADDFRIENDS:
                  addDialog = new AddNeighbor();
                  addDialog.addEventListener(Event.CLOSE,this.onDialogClosed);
                  this.m_dialog = addDialog;
                  UI.displayPopup(addDialog);
                  break;
               case DIALOG_MOTD:
                  currentMOTD = Global.player.currentMOTD;
                  if(currentMOTD)
                  {
                     UI.displayPopup(new MOTD(currentMOTD));
                  }
                  AsyncCall.call(this.m_state.onTriggerDialog);
            }
         }
      }
      
      private function refreshTransactions() : void
      {
         var transactionClass:String = this.m_state.transaction;
         if(null != transactionClass)
         {
            switch(transactionClass)
            {
               case "TTutAddNeighbor":
                  TransactionManager.addTransaction(new TTutAddNeighbor());
                  AsyncCall.call(this.m_state.onTriggerTransaction);
            }
         }
      }
   }
}

import Classes.util.ZLocUtils;
import Display.ActionButton;
import Display.GenericIconPopup;
import Display.GenericPopup;
import Display.UI;
import Engine.Transactions.Transaction;
import Events.ActionMenuEvent;
import Events.GenericPopupEvent;
import Events.PlotEvent;
import Managers.FarmStatsManager;
import Widgets.Buttons.FarmButton;
import Widgets.Core.Frames.ZwFrame;
import Widgets.Core.TextFields.ZwTextField;
import Widgets.Windows.FarmWindow;
import flash.events.Event;

class BobbleHead extends FarmWindow
{
   
   protected static const ASSET_PATH:String = "assets/dialogs/4d_elements/FTUE/FV_FTUE_bubble.swf";
   
   protected var m_textField:ZwTextField = null;
   
   protected var m_msg:String = "";
   
   public function BobbleHead()
   {
      super(AssetSkinner.getInstance().skinAssetUrl(ASSET_PATH),false,false);
      this.shouldFreeze = false;
   }
   
   public function set text(msg:String) : void
   {
      this.m_msg = msg;
      if(this.m_textField)
      {
         this.m_textField.text = this.m_msg;
      }
   }
   
   public function get text() : String
   {
      return this.m_msg;
   }
   
   override protected function postLoadComplete() : void
   {
      super.postLoadComplete();
      addWidget(new ZwFrame(m_window.avatar_mc));
      addWidget(new ZwFrame(m_window.bubble_3_mc));
      this.m_textField = new ZwTextField(m_window.bubble_3_mc.generic_tf);
      this.m_textField.wordWrap = true;
      addWidget(this.m_textField);
      this.m_textField.text = this.m_msg;
   }
}

class SkipWindow extends FarmWindow
{
   
   protected static const ASSET_PATH:String = "assets/tutorial/skipTutorialBT.swf";
   
   protected var m_controller:TutController;
   
   public function SkipWindow(controller:TutController)
   {
      super(ASSET_PATH,false,false);
      this.m_controller = controller;
      this.shouldFreeze = false;
   }
   
   override protected function postLoadComplete() : void
   {
      super.postLoadComplete();
      addWidget(new FarmButton(m_window.skipTutBT_MC,this.onClickSkipButton));
      var tf:ZwTextField = new ZwTextField(m_window.skipTutBT_MC.generic_tf);
      addWidget(tf);
      tf.text = ZLocUtils.t("FarmGame","TutSkipButtonText");
   }
   
   protected function onClickSkipButton(event:Event) : void
   {
      var skipDialog:GenericPopup = new GenericPopup(ZLocUtils.t("FarmGame","TutSkipDialogText"),GenericPopup.TYPE_ACCEPTCANCEL,this.onCloseSkipDialog);
      skipDialog.setAcceptTextName("Skip");
      FarmStatsManager.count("Tutorial","skip_tutorial","hud_icon_clicks");
      UI.displayPopup(skipDialog,true,"SkipTutorial",true);
   }
   
   protected function onCloseSkipDialog(event:GenericPopupEvent) : void
   {
      if(event.button == GenericPopup.ACCEPT)
      {
         FarmStatsManager.count("Tutorial","skip_tutorial","skip");
         AsyncCall.call(this.m_controller.stop);
      }
      else
      {
         FarmStatsManager.count("Tutorial","skip_tutorial","do_not_skip");
      }
   }
}

class TutState
{
   
   protected static const STATE_FIRST:int = 0;
   
   protected static const STATE_INTRO_DIALOG:int = 0;
   
   protected static const STATE_HARVEST_PROMPT:int = 1;
   
   protected static const STATE_HARVEST:int = 2;
   
   protected static const STATE_PLOW_PROMPT:int = 3;
   
   protected static const STATE_PLOW:int = 4;
   
   protected static const STATE_PLANT_PROMPT:int = 5;
   
   protected static const STATE_PLANT:int = 6;
   
   protected static const STATE_PLACE_PROMPT:int = 7;
   
   protected static const STATE_PLACE:int = 8;
   
   protected static const STATE_NEIGHBOR_PROMPT:int = 9;
   
   protected static const STATE_AUTO_NEIGHBOR:int = 10;
   
   protected static const STATE_MOTD:int = 11;
   
   protected static const STATE_END:int = 12;
   
   protected static const STATE_MAX:int = 13;
   
   protected static const PLOT_COND_PLOWABLE:int = 1;
   
   protected static const PLOT_COND_HARVESTABLE:int = 2;
   
   protected static const PLOT_COND_PLANTABLE:int = 3;
   
   private var m_controller:TutController = null;
   
   private var m_state:int = 0;
   
   private var m_needRefresh:Boolean = false;
   
   private var m_pphCount:int = 0;
   
   private var m_lastButton:String = null;
   
   private var m_suggestedPlot:Plot = null;
   
   protected var m_dataTable:Array = new Array({
      "enabled":true,
      "button":null,
      "locId":null,
      "plotCond":null,
      "pphEvent":null,
      "pphCount":0,
      "dialog":TutController.DIALOG_INTRO,
      "transaction":null,
      "stat":null,
      "substat":null
   },{
      "enabled":true,
      "button":ActionMenuEvent.ONWALK,
      "locId":"TutNotesText_Harvest",
      "plotCond":null,
      "pphEvent":PlotEvent.PLOT_HARVESTED,
      "pphCount":1,
      "dialog":0,
      "transaction":null,
      "stat":null,
      "substat":null
   },{
      "enabled":true,
      "button":null,
      "locId":"TutNotesText_Harvest",
      "plotCond":PLOT_COND_HARVESTABLE,
      "pphEvent":PlotEvent.PLOT_HARVESTED,
      "pphCount":0,
      "dialog":0,
      "transaction":null,
      "stat":"complete_harvest",
      "substat":null
   },{
      "enabled":true,
      "button":ActionMenuEvent.ONPLOW,
      "locId":"TutNotesText_Plow",
      "plotCond":null,
      "pphEvent":PlotEvent.PLOT_PLOWED,
      "pphCount":1,
      "dialog":0,
      "transaction":null,
      "stat":null,
      "substat":null
   },{
      "enabled":true,
      "button":null,
      "locId":"TutNotesText_Plow",
      "plotCond":PLOT_COND_PLOWABLE,
      "pphEvent":PlotEvent.PLOT_PLOWED,
      "pphCount":0,
      "dialog":0,
      "transaction":null,
      "stat":"complete_plow",
      "substat":null
   },{
      "enabled":true,
      "button":ActionMenuEvent.ONWALK,
      "locId":"TutNotesText_PlantPrompt",
      "plotCond":null,
      "pphEvent":PlotEvent.PLOT_PLANTED,
      "pphCount":1,
      "dialog":0,
      "transaction":null,
      "stat":null,
      "substat":null
   },{
      "enabled":true,
      "button":null,
      "locId":"TutNotesText_Plant",
      "plotCond":PLOT_COND_PLANTABLE,
      "pphEvent":PlotEvent.PLOT_PLANTED,
      "pphCount":0,
      "dialog":0,
      "transaction":null,
      "stat":"complete_seed",
      "substat":null
   },{
      "enabled":true,
      "button":ActionMenuEvent.ONPLOW,
      "locId":"TutNotesText_Place",
      "plotCond":null,
      "pphEvent":PlotEvent.PLOT_PLOWED,
      "pphCount":1,
      "dialog":0,
      "transaction":null,
      "stat":null,
      "substat":null
   },{
      "enabled":true,
      "button":null,
      "locId":"TutNotesText_Place",
      "plotCond":null,
      "pphEvent":PlotEvent.PLOT_PLOWED,
      "pphCount":2,
      "dialog":0,
      "transaction":null,
      "stat":"complete_plow_extra",
      "substat":null
   },{
      "enabled":true,
      "button":null,
      "locId":null,
      "plotCond":null,
      "pphEvent":null,
      "pphCount":0,
      "dialog":TutController.DIALOG_ADDFRIENDS,
      "transaction":null,
      "stat":null,
      "substat":null
   },{
      "enabled":true,
      "button":null,
      "locId":null,
      "plotCond":null,
      "pphEvent":null,
      "pphCount":0,
      "dialog":0,
      "transaction":"TTutAddNeighbor",
      "stat":"add_neighbors",
      "substat":"auto_add_friend"
   },{
      "enabled":false,
      "button":null,
      "locId":null,
      "plotCond":null,
      "pphEvent":null,
      "pphCount":0,
      "dialog":TutController.DIALOG_MOTD,
      "transaction":null,
      "stat":null,
      "substat":null
   },{
      "enabled":true,
      "button":null,
      "locId":null,
      "plotCond":null,
      "pphEvent":null,
      "pphCount":0,
      "dialog":0,
      "transaction":null,
      "stat":null,
      "substat":null
   },{
      "enabled":true,
      "button":null,
      "locId":null,
      "plotCond":null,
      "pphEvent":null,
      "pphCount":0,
      "dialog":0,
      "transaction":null,
      "stat":null,
      "substat":null
   });
   
   public function TutState(controller:TutController)
   {
      super();
      this.m_controller = controller;
   }
   
   public function initialize() : void
   {
      this.disableStatesPerExperiments();
      if(CIPStartNow.shouldAutoNeighbor())
      {
         this.m_dataTable[STATE_NEIGHBOR_PROMPT].enabled = false;
      }
      Global.world.addEventListener(PlotEvent.PLOT_PLOWED,this.onTriggerPPH);
      Global.world.addEventListener(PlotEvent.PLOT_HARVESTED,this.onTriggerPPH);
      Global.world.addEventListener(PlotEvent.PLOT_PLANTED,this.onTriggerPPH);
      Global.ui.getActionMenu().addEventListener(ActionMenuEvent.ONPLOW,this.onTriggerActionMenu);
      Global.ui.getActionMenu().addEventListener(ActionMenuEvent.ONWALK,this.onTriggerActionMenu);
      this.m_state = Global.player.getActionCount(TutController.TUTORIAL_PROGRESS_ACTION_FLAG);
      this.step();
   }
   
   public function stop() : void
   {
      Global.world.removeEventListener(PlotEvent.PLOT_PLOWED,this.onTriggerPPH);
      Global.world.removeEventListener(PlotEvent.PLOT_HARVESTED,this.onTriggerPPH);
      Global.world.removeEventListener(PlotEvent.PLOT_PLANTED,this.onTriggerPPH);
      Global.ui.getActionMenu().removeEventListener(ActionMenuEvent.ONPLOW,this.onTriggerActionMenu);
      Global.ui.getActionMenu().removeEventListener(ActionMenuEvent.ONWALK,this.onTriggerActionMenu);
      this.m_state = STATE_MAX;
      this.step();
   }
   
   protected function disableStatesPerExperiments() : void
   {
      this.m_dataTable[STATE_INTRO_DIALOG].enabled = false;
      this.m_dataTable[STATE_AUTO_NEIGHBOR].enabled = false;
      if(AssetSkinner.getInstance().isProjectUnicornEnabled())
      {
         this.m_dataTable[STATE_INTRO_DIALOG].enabled = true;
         this.m_dataTable[STATE_MOTD].enabled = true;
      }
   }
   
   public function onTriggerDialog() : void
   {
      if(0 != this.m_dataTable[this.m_state].dialog)
      {
         ++this.m_state;
         Global.player.incrementActionCount(TutController.TUTORIAL_PROGRESS_ACTION_FLAG,true);
         this.step();
      }
   }
   
   public function onTriggerTransaction() : void
   {
      if(null != this.m_dataTable[this.m_state].dialog)
      {
         ++this.m_state;
         Global.player.incrementActionCount(TutController.TUTORIAL_PROGRESS_ACTION_FLAG,true);
         this.step();
      }
   }
   
   public function onTriggerActionMenu(event:ActionMenuEvent) : void
   {
      event.stopPropagation();
      this.m_lastButton = event.type;
      this.step();
   }
   
   protected function onTriggerPPH(event:PlotEvent) : void
   {
      event.stopPropagation();
      if(event.type == this.m_dataTable[this.m_state].pphEvent)
      {
         ++this.m_pphCount;
         this.step();
      }
   }
   
   public function get plot() : Plot
   {
      return this.m_suggestedPlot;
   }
   
   public function get button() : String
   {
      return this.m_dataTable[this.m_state].button;
   }
   
   public function get localizationId() : String
   {
      return this.m_dataTable[this.m_state].locId;
   }
   
   public function get dialog() : int
   {
      return this.m_dataTable[this.m_state].dialog;
   }
   
   public function get transaction() : String
   {
      return this.m_dataTable[this.m_state].transaction;
   }
   
   public function get showSkipButton() : Boolean
   {
      return STATE_INTRO_DIALOG < this.m_state && STATE_END > this.m_state;
   }
   
   protected function step() : void
   {
      var stat:String = null;
      var substat:String = null;
      var incrementState:Boolean = false;
      var buttonId:String = this.m_dataTable[this.m_state].button;
      var pphCount:int = int(this.m_dataTable[this.m_state].pphCount);
      var plotCond:int = int(this.m_dataTable[this.m_state].plotCond);
      this.m_needRefresh = true;
      if(!incrementState)
      {
         if(!this.m_dataTable[this.m_state].enabled)
         {
            incrementState = true;
         }
      }
      if(!incrementState && null != buttonId)
      {
         if(this.m_lastButton == buttonId)
         {
            incrementState = true;
         }
      }
      if(!incrementState && 0 != pphCount)
      {
         if(pphCount <= this.m_pphCount)
         {
            incrementState = true;
         }
      }
      if(!incrementState && 0 != plotCond)
      {
         this.m_suggestedPlot = this.calcPlot(plotCond);
         if(null == this.m_suggestedPlot)
         {
            incrementState = true;
         }
      }
      if(incrementState && STATE_MAX > this.m_state)
      {
         if(this.m_dataTable[this.m_state].enabled)
         {
            stat = this.m_dataTable[this.m_state].stat;
            if(null != stat)
            {
               substat = null != this.m_dataTable[this.m_state].substat ? this.m_dataTable[this.m_state].substat : "";
               FarmStatsManager.count("Tutorial",stat,substat);
            }
         }
         ++this.m_state;
         Global.player.incrementActionCount(TutController.TUTORIAL_PROGRESS_ACTION_FLAG,true);
         this.m_pphCount = 0;
         this.m_lastButton = null;
         this.m_suggestedPlot = null;
         this.step();
      }
      if(this.m_needRefresh)
      {
         this.m_needRefresh = false;
         if(STATE_END == this.m_state)
         {
            AsyncCall.call(this.m_controller.stop);
         }
         else
         {
            AsyncCall.call(this.m_controller.refreshControls);
         }
      }
   }
   
   protected function calcButton(buttonId:int) : ActionButton
   {
      var button:ActionButton = null;
      switch(buttonId)
      {
         case ActionMenuEvent.ONWALK:
            button = Global.ui.getActionMenu().getWalkButton();
            break;
         case ActionMenuEvent.ONPLOW:
            button = Global.ui.getActionMenu().getPlowButton();
      }
      return button;
   }
   
   protected function calcPlot(plotCond:int) : Plot
   {
      var select:Boolean = false;
      var plots:Array = null;
      var plot:Plot = null;
      var suggested:Plot = null;
      if(0 != plotCond)
      {
         select = false;
         plots = Global.world.getObjectsByClass(Plot);
         for each(plot in plots)
         {
            switch(plotCond)
            {
               case PLOT_COND_PLOWABLE:
                  select = plot.isPlowable();
                  break;
               case PLOT_COND_HARVESTABLE:
                  select = plot.isHarvestable();
                  break;
               case PLOT_COND_PLANTABLE:
                  select = plot.isPlantable();
            }
            if(select)
            {
               suggested = plot;
               break;
            }
         }
      }
      return suggested;
   }
}

class TTutAddNeighbor extends Transaction
{
   
   public function TTutAddNeighbor()
   {
      super();
   }
   
   override public function perform() : void
   {
      signedCall("NeighboringService.tutAddNeighbor");
   }
   
   override protected function onComplete(result:Object) : void
   {
      var friend:Friend = null;
      if(result.neighborInfo)
      {
         friend = Global.friendManager.promoteFriendToNeighbor(result.neighborInfo);
         if(friend)
         {
            UI.displayPopup(new GenericIconPopup(ZLocUtils.t("FarmGame",AssetSkinner.getInstance().skinLocId("TutAutoNeighboredDialogText"),{"friend":ZLocUtils.tn(friend.firstName,ZLocUtils.tg(friend.snUser.gender))}),GenericPopup.TYPE_OK,null,friend.picture),false);
         }
      }
   }
}

class AssetSkinner
{
   
   private static var s_instance:AssetSkinner = null;
   
   private var m_suffix:String = null;
   
   private var m_prefix:String = null;
   
   public function AssetSkinner()
   {
      super();
      if(this.isProjectUnicornEnabled())
      {
         this.m_suffix = "_uni";
         this.m_prefix = "uni_";
      }
   }
   
   public static function getInstance() : AssetSkinner
   {
      if(null == s_instance)
      {
         s_instance = new AssetSkinner();
      }
      return s_instance;
   }
   
   public function isProjectUnicornEnabled() : Boolean
   {
      return true;
   }
   
   public function skinLocId(locId:String) : String
   {
      if(null != this.m_suffix)
      {
         locId += this.m_suffix;
      }
      return locId;
   }
   
   public function skinAssetUrl(url:String) : String
   {
      var lastSlash:int = 0;
      if(null != this.m_prefix)
      {
         lastSlash = url.lastIndexOf("/");
         if(-1 != lastSlash)
         {
            url = url.substring(0,lastSlash + 1) + this.m_prefix + url.substring(lastSlash + 1);
         }
      }
      return url;
   }
}
