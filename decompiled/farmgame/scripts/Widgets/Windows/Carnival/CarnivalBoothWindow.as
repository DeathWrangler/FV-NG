package Widgets.Windows.Carnival
{
   import Classes.Constants.Experiments;
   import Classes.MarketPromotion;
   import Classes.Minigames.MinigameManager;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.MysteryBoxBalloonDialog;
   import Display.UI;
   import Engine.Managers.ErrorManager;
   import Managers.FarmStatsManager;
   import Managers.LotteryManager;
   import Managers.SocialRaffleManager;
   import Managers.ToasterManager;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.Market.MarketPromoSlotFrame;
   import Widgets.Windows.FCSlotMachineWindow;
   import Widgets.Windows.FarmWindow;
   import Widgets.Windows.LESlotMachineWindow;
   import Widgets.Windows.NeedleHaystack.NeedleHaystackWindow;
   import Widgets.Windows.PearUp.PearUpWindow;
   import Widgets.Windows.Pigo.PigoWindow;
   import Widgets.Windows.PrizeMachine.PrizeMachineWindow;
   import Widgets.Windows.ScratchCardWindow;
   import Widgets.Windows.SimpleToasterWindow;
   import Widgets.Windows.SocialRaffle.SocialRaffleWindow;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class CarnivalBoothWindow extends FarmWindow
   {
      
      public static const CARNIVAL_BOOTH_ASSET_URL:String = "assets/dialogs/FV_CarnivalMain.swf";
      
      public static const CARNIVAL_BOOTH_TOASTER_ASSET_URL:String = "assets/dialogs/FV_Carnival_BannerAd.swf";
      
      public static const CARNIVAL_TOASTER_VIEW_TIME:Number = 4000;
      
      public static const CARNIVAL_LAUNCH_ACTION_COUNT:String = "CarnivalActionCount";
      
      public static const CARNIVAL_STAT_COUNTER:String = "dialog";
      
      public static const CARNIVAL_STAT_KINGDOM:String = "fv_carnival_booth";
      
      public static const CARNIVAL_STAT_MAIN_PHYLUM:String = "Main";
      
      public static const CARNIVAL_STAT_CLICK_PHYLUM:String = "Click";
      
      private static const DECLARE_KNOWN_TYPES:Array = [NeedleHaystackWindow,PearUpWindow];
      
      protected var m_promoSlotFrame:MarketPromoSlotFrame;
      
      private var m_loadingUI:GenericPopup = null;
      
      public function CarnivalBoothWindow()
      {
         FarmStatsManager.count(CARNIVAL_STAT_COUNTER,CARNIVAL_STAT_KINGDOM,CARNIVAL_STAT_MAIN_PHYLUM,"View");
         var dialogURL:String = CARNIVAL_BOOTH_ASSET_URL;
         super(dialogURL);
      }
      
      public static function promoteCarnivalBooth() : void
      {
         var carnivalBooth:FarmItem = null;
         var toaster:SimpleToasterWindow = null;
         if(Global.player.getActionCount(CARNIVAL_LAUNCH_ACTION_COUNT) < 1 && Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_CARNIVAL_BOOTH_SURFACING) == 1)
         {
            carnivalBooth = Global.farmGameSettingsManager.getFarmItemByName("carnivalbooth");
            toaster = new SimpleToasterWindow("carnivalbooth",ZLocUtils.t("Dialogs","CarnivalBooth_Toaster_Text"),CARNIVAL_BOOTH_TOASTER_ASSET_URL,launchCarnivalBooth,CARNIVAL_TOASTER_VIEW_TIME);
            ToasterManager.getInstance().add(toaster);
         }
         Global.player.resetActionCount(CARNIVAL_LAUNCH_ACTION_COUNT);
      }
      
      public static function launchCarnivalBooth() : void
      {
         UI.displayPopup(new CarnivalBoothWindow(),true,"CarnivalBooth",true);
      }
      
      override protected function postLoadComplete() : void
      {
         var marketPromoMC:MovieClip = m_window.promoCards_mc;
         this.m_promoSlotFrame = addWidget(new MarketPromoSlotFrame(marketPromoMC,this.onPromoClickCallback)) as MarketPromoSlotFrame;
         this.m_promoSlotFrame.items = Global.marketConfigSettings.getActiveCarnivalPromotions();
         addWidget(new ZwTextField(m_window.title_tf,ZLocUtils.t("Dialogs","CarnivalBooth_Dialog_Title")));
         addWidget(new ZwTextField(m_window.Description_tf,ZLocUtils.t("Dialogs","CarnivalBooth_Dialog_Desc")));
      }
      
      override protected function onClose(event:Event) : void
      {
         FarmStatsManager.count(CARNIVAL_STAT_COUNTER,CARNIVAL_STAT_KINGDOM,CARNIVAL_STAT_MAIN_PHYLUM,"X");
         super.onClose(event);
      }
      
      public function onPromoClickCallback(promoData:MarketPromotion) : void
      {
         if(promoData)
         {
            FarmStatsManager.count(CARNIVAL_STAT_COUNTER,CARNIVAL_STAT_KINGDOM,CARNIVAL_STAT_CLICK_PHYLUM,promoData.name);
            if(this[promoData.action] != null && this[promoData.action] is Function)
            {
               this[promoData.action](promoData);
            }
         }
      }
      
      private function prepareGameLaunch() : void
      {
         Global.player.setActionCount(CARNIVAL_LAUNCH_ACTION_COUNT,1);
      }
      
      private function openLoadScreen(loadingMessage:String) : void
      {
         this.m_loadingUI = new GenericPopup(loadingMessage,GenericPopup.TYPE_MODAL,null,GenericPopup.GENERIC_ASSET,"",false,false,true);
         UI.displayPopup(this.m_loadingUI,false);
      }
      
      private function closeLoadScreen() : void
      {
         if(this.m_loadingUI != null)
         {
            this.m_loadingUI.close();
            this.m_loadingUI = null;
         }
      }
      
      private function openMysteryGame(promoData:MarketPromotion) : void
      {
         this.prepareGameLaunch();
         MysteryBoxBalloonDialog.openDefaultMysteryGame(null);
         close();
      }
      
      private function openPigoGame(promoData:MarketPromotion = null) : void
      {
         PigoWindow.displayActiveGame("carnival",true);
         close();
      }
      
      private function openSlotMachine(promoData:MarketPromotion) : void
      {
         this.prepareGameLaunch();
         UI.displayPopup(new LESlotMachineWindow());
         close();
      }
      
      private function openFCSlotMachine(promoData:MarketPromotion) : void
      {
         this.prepareGameLaunch();
         UI.displayPopup(new FCSlotMachineWindow(FCSlotMachineWindow.ENTRY_POINT_GAME_TENT),true,FCSlotMachineWindow.WINDOW_NAME,true);
         close();
      }
      
      private function openSocialRaffle(promoData:MarketPromotion) : void
      {
         this.prepareGameLaunch();
         this.openLoadScreen(ZLocUtils.t("Dialogs","socialrafflebuilding_Loading"));
         SocialRaffleManager.getInstance().reloadData(this.onSocialRaffleDataLoaded);
         close();
      }
      
      private function onSocialRaffleDataLoaded() : void
      {
         this.closeLoadScreen();
         UI.displayPopup(new SocialRaffleWindow(null),true);
      }
      
      private function openSweepstakes(promoData:MarketPromotion) : void
      {
         this.prepareGameLaunch();
         this.openLoadScreen(ZLocUtils.t("Dialogs","LotteryUI_Loading"));
         LotteryManager.instance.queueMainUI(this.onSweepstakesLoaded);
         close();
      }
      
      private function openPrizeMachine(promoData:MarketPromotion) : void
      {
         var prizeMachineWindow:PrizeMachineWindow = new PrizeMachineWindow();
         UI.displayPopup(prizeMachineWindow,false,"PrizeMachineWindow",true);
         close();
      }
      
      private function openNeedleHaystack(promoData:MarketPromotion) : void
      {
         this.openGenericMiniGame(promoData);
      }
      
      private function openGenericMiniGame(promoData:MarketPromotion) : void
      {
         var gameName:String = null;
         var params:Array = promoData.actionParams;
         if(params.length > 0)
         {
            gameName = params[0];
            if(MinigameManager.instance.launchMinigameWindow(gameName,"carnival_booth"))
            {
               close();
            }
            else
            {
               ErrorManager.addError("CarnivalBoothWindow.as :: openGenericMiniGame() error: failed launchMinigameWindow(" + gameName + ").");
            }
         }
         else
         {
            ErrorManager.addError("CarnivalBoothWindow.as :: openGenericMiniGame() error: MarketData.xml " + promoData.name + ": click action=openGenericMiniGame needs to have params defined.");
         }
      }
      
      private function onSweepstakesLoaded() : void
      {
         this.closeLoadScreen();
      }
      
      private function openScratchCard(promoData:MarketPromotion) : void
      {
         this.prepareGameLaunch();
         UI.displayPopup(new ScratchCardWindow(ScratchCardWindow.SCRATCH_CARD_ENTRY_DESCRIPTOR_GAMETENT),true,ScratchCardWindow.POPUP_NAME,true);
         close();
      }
      
      private function openComingSoon(promoData:MarketPromotion) : void
      {
      }
   }
}

