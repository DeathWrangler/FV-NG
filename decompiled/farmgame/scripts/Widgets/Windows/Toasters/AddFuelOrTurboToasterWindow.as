package Widgets.Windows.Toasters
{
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Display.UI;
   import Managers.FarmStatsManager;
   import Managers.ToasterManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Windows.ToasterWindow;
   import flash.events.Event;
   
   public class AddFuelOrTurboToasterWindow extends ToasterWindow
   {
      
      public static const TURBO:String = "turbo";
      
      public static const FUEL:String = "fuel";
      
      private static const TURBO_DIALOG_URL:String = "assets/dialogs/FV_BannerAd_addTurbo.swf";
      
      private static const FUEL_DIALOG_URL:String = "assets/dialogs/FV_BannerAd_addFuel.swf";
      
      private static const ADDFUELORTURBOTOASTERWINDOW:String = "AddFuelOrTurboToasterWindow";
      
      private static const GRACEPERIOD_SECONDS:int = 120;
      
      public static const THRESHHOLD:int = 10;
      
      private var m_dialogType:String;
      
      private const IGNORE_BACKUPTIME_SECONDS:int = 86400;
      
      public function AddFuelOrTurboToasterWindow(type:String)
      {
         this.m_dialogType = type;
         super(this.m_dialogType == TURBO ? TURBO_DIALOG_URL : FUEL_DIALOG_URL);
      }
      
      public static function showToasterWindow(type:String) : void
      {
         var toaster:ToasterWindow = null;
         var lastShownDelta:Number = GlobalEngine.currentTime / FarmGameUtil.NUM_MSECS_IN_SECOND - Global.player.getFeatureLastShown(ADDFUELORTURBOTOASTERWINDOW);
         if(lastShownDelta > GRACEPERIOD_SECONDS)
         {
            Global.player.setFeatureLastShown("AddFuelOrTurboToasterWindow",GlobalEngine.currentTime / FarmGameUtil.NUM_MSECS_IN_SECOND,false);
            if(GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND > Global.player.getFeatureLastShown(ADDFUELORTURBOTOASTERWINDOW + type))
            {
               toaster = new AddFuelOrTurboToasterWindow(type);
               ToasterManager.getInstance().add(toaster);
            }
         }
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         addWidget(new FarmAnimatedTextButton(m_window.accept_bt,ZLocUtils.t("Dialogs","AddFuelOrTurboToasterWindow_Button"),this.handleAcceptedClicked));
         if(this.m_dialogType == FUEL && m_window.hasOwnProperty("animation_mc"))
         {
            m_window.animation_mc.visible = true;
            m_window.animation_mc.gotoAndPlay(2);
         }
         Global.player.incrementActionCount(ADDFUELORTURBOTOASTERWINDOW + this.m_dialogType);
      }
      
      private function handleAcceptedClicked(e:Event) : void
      {
         UI.displayMarketDialog(ADDFUELORTURBOTOASTERWINDOW,"aide",null,"fuel");
         super.onClose(e);
      }
      
      override protected function onShow() : void
      {
         super.onShow();
         FarmStatsManager.count("dialog","AddFuelOrTurboToasterWindow","toaster","appeared","view");
      }
      
      override protected function onClose(event:Event) : void
      {
         super.onClose(event);
         var count:int = Global.player.getActionCount(ADDFUELORTURBOTOASTERWINDOW + this.m_dialogType);
         Global.player.setFeatureLastShown(ADDFUELORTURBOTOASTERWINDOW + this.m_dialogType,GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND + this.IGNORE_BACKUPTIME_SECONDS * count,false);
      }
   }
}

