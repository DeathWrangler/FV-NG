package Managers
{
   import Classes.Buff;
   import Classes.Constants.Experiments;
   import Classes.ZItem.FarmItem;
   import Classes.buffs.BXpPowerHour;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Display.GenericPopupTitle;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Transactions.TGenericTransaction;
   import Widgets.Windows.IconTitleToasterWindow;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   import flash.utils.getDefinitionByName;
   
   public class PowerHourManager
   {
      
      private static const XP_BUFF_KEY:String = "PowerHourXpBuff";
      
      private static var m_instance:PowerHourManager = null;
      
      private static var m_initialized:Boolean = false;
      
      private static var m_experimentVariant:int = -1;
      
      private const POWER_HOUR_LENGTH:int = 61;
      
      private const START_HOUR:int = 17;
      
      private const CAP_TIME:int = 58;
      
      private const ONBOARD_SEEN_FLAG:String = "Retention_PowerHour_seenOnboard";
      
      private const TOASTER_ASSET:String = "assets/dialogs/FV_BannerAd_Power_generic.swf";
      
      private var m_timer:Timer;
      
      private var m_timeOffset:int = 0;
      
      private var m_buffItem:FarmItem;
      
      private var m_seenToaster30:Boolean = false;
      
      private var m_seenToaster5:Boolean = false;
      
      public function PowerHourManager()
      {
         super();
         if(!m_initialized)
         {
            m_initialized = true;
            return;
         }
         throw new Error("Error: Instantiation failed: Use PowerHourManager.getInstance() instead of new.");
      }
      
      public static function getInstance() : PowerHourManager
      {
         if(m_instance == null)
         {
            m_instance = new PowerHourManager();
         }
         return m_instance;
      }
      
      public static function inExperiment() : Boolean
      {
         if(m_experimentVariant == -1)
         {
            m_experimentVariant = Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_POWER_HOUR);
         }
         return RetentionMasterManager.inMasterExperiment() && (m_experimentVariant == 2 || m_experimentVariant == 4);
      }
      
      public static function getXpBuff() : int
      {
         var powerHourXpBuffs:Array = null;
         var result:int = 1;
         if(inExperiment())
         {
            powerHourXpBuffs = Global.player.getBuffsByClass(BXpPowerHour);
            if(powerHourXpBuffs.length > 0)
            {
               result *= Global.farmGameSettingsManager.getInt(XP_BUFF_KEY,1);
            }
         }
         return result;
      }
      
      public function initialize() : void
      {
         var delta:int = 0;
         var title:String = null;
         var message:String = null;
         var popup:GenericPopupTitle = null;
         var now:Date = new Date();
         var hours:int = now.getHours();
         var minutes:int = now.getMinutes();
         var startHour:int = this.START_HOUR;
         if(!Global.player.getSeenFlag(this.ONBOARD_SEEN_FLAG))
         {
            title = ZLocUtils.t("Dialogs","PowerHourTitle");
            message = ZLocUtils.t("Dialogs","PowerHourOnboard");
            popup = new GenericPopupTitle(title,message,true);
            popup.setAcceptTextName("Okay");
            UI.displayPopup(popup,true);
            Global.player.setSeenFlag(this.ONBOARD_SEEN_FLAG);
            FarmStatsManager.count("retention_happy_hour","initial_msg_view");
         }
         if(hours == startHour && minutes < this.CAP_TIME)
         {
            this.onStart(null);
         }
         else if(hours < startHour)
         {
            if(minutes == 0)
            {
               delta = (startHour - hours) * FarmGameUtil.NUM_MSECS_IN_HOUR;
            }
            else
            {
               delta = (startHour - hours - 1) * FarmGameUtil.NUM_MSECS_IN_HOUR + (60 - minutes) * FarmGameUtil.NUM_MSECS_IN_MINUTE;
            }
            this.m_timer = new Timer(delta);
            this.m_timer.addEventListener(TimerEvent.TIMER,this.onStart);
            this.m_timer.start();
         }
      }
      
      private function onStart(event:TimerEvent) : void
      {
         if(this.m_timer)
         {
            this.m_timer.stop();
            this.m_timer.removeEventListener(TimerEvent.TIMER,this.onStart);
            this.m_timer = null;
         }
         var now:Date = new Date();
         var minutes:int = now.getMinutes();
         this.m_timeOffset = minutes * FarmGameUtil.NUM_SECS_IN_MINUTE;
         TransactionManager.addTransaction(new TGenericTransaction("UserService","onActivatePowerHour",this.onComplete,[this.m_timeOffset]));
      }
      
      private function onComplete(result:Object) : void
      {
         var buffItemName:String = null;
         var buffClass:String = null;
         var tempClass:Class = null;
         var buff:Buff = null;
         var title:String = null;
         var message:String = null;
         var popup:GenericPopupTitle = null;
         if(result.hasOwnProperty("success") && result.success == true)
         {
            if(Boolean(result.hasOwnProperty("buffName")) && Boolean(result.buffName) && result.buffName != "")
            {
               buffItemName = result.buffName;
               this.m_buffItem = Global.farmGameSettingsManager.getFarmItemByName(buffItemName);
               if(this.m_buffItem)
               {
                  buffClass = this.m_buffItem.className;
                  tempClass = getDefinitionByName("Classes.buffs." + buffClass) as Class;
                  buff = new tempClass(buffItemName);
                  if(buff)
                  {
                     buff.apply();
                  }
                  title = ZLocUtils.t("Dialogs","PowerHourTitle");
                  message = ZLocUtils.t("Dialogs","PowerHourBody",{"bonus":this.m_buffItem.friendlyTitle});
                  popup = new GenericPopupTitle(title,message,true);
                  popup.setAcceptTextName("PowerHourAction");
                  UI.displayPopup(popup);
                  FarmStatsManager.count("retention_happy_hour",buffItemName);
               }
            }
         }
      }
      
      public function terminate() : void
      {
         var toaster:IconTitleToasterWindow = null;
         if(this.m_buffItem)
         {
            toaster = new IconTitleToasterWindow(ZLocUtils.t("Dialogs","PowerHourTitle"),ZLocUtils.t("Dialogs","PowerHourToasterEnd",{"bonus":this.m_buffItem.friendlyTitle}),"",this.TOASTER_ASSET);
            ToasterManager.getInstance().addImmediate(toaster);
         }
         TransactionManager.addTransaction(new TGenericTransaction("UserService","onTerminatePowerHour",null));
      }
      
      public function get timeOffset() : int
      {
         return this.m_timeOffset;
      }
      
      public function update(timeRemaining:int) : void
      {
         var toaster:IconTitleToasterWindow = null;
         var minutes:int = Math.floor(timeRemaining / FarmGameUtil.NUM_SECS_IN_MINUTE);
         if(minutes == 30 && !this.m_seenToaster30)
         {
            if(this.m_buffItem)
            {
               toaster = new IconTitleToasterWindow(ZLocUtils.t("Dialogs","PowerHourTitle"),ZLocUtils.t("Dialogs","PowerHourToaster30",{"bonus":this.m_buffItem.friendlyTitle}),"",this.TOASTER_ASSET);
               ToasterManager.getInstance().add(toaster);
            }
         }
         else if(minutes == 5 && !this.m_seenToaster5)
         {
            if(this.m_buffItem)
            {
               toaster = new IconTitleToasterWindow(ZLocUtils.t("Dialogs","PowerHourTitle"),ZLocUtils.t("Dialogs","PowerHourToaster5",{"bonus":this.m_buffItem.friendlyTitle}),"",this.TOASTER_ASSET);
               ToasterManager.getInstance().add(toaster);
            }
         }
      }
   }
}

