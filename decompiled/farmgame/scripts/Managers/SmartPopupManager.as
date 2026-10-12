package Managers
{
   import Display.Dialogs.SmartPopupMarketing;
   import Display.FarmDynamicDialog;
   import com.troyer.widget.controller.BaseWidgetController;
   import com.troyer.widget.event.WidgetControllerEvent;
   
   public class SmartPopupManager
   {
      
      private static var m_instance:SmartPopupManager;
      
      private static const MARKETING_DIALOG_FREQUENCY:String = "marketingDialogFrequency";
      
      private static const MARKETING_DIALOG_CANCEL_COUNT:String = "marketingDialogCancelCount";
      
      private static const TAG_CANCEL:String = "_cancel";
      
      private static const TAG_CANCEL_MARKETING:String = "_cancel_marketing";
      
      private static const TAG_MODE:String = "_suppressMode";
      
      private static const TAG_TIMESTAMP:String = "_suppressTime";
      
      private static const MARKETING_EXPERIENCED:String = "smartpopup_marketing_experienced";
      
      private static const SUPPRESS_OFF:String = "SUPPRESS_OFF";
      
      private static const SUPPRESS_POPUP:String = "SUPPRESS_POPUP";
      
      private static const SUPPRESS_MARKETING:String = "SUPPRESS_MARKETING";
      
      private static const RESET_ITEMFLAG_VALUE:String = "0";
      
      private static const EXPERIMENT_SMART_POPUPS:String = "fv_smart_popups";
      
      private static var m_allowInstantiation:Boolean = false;
      
      private const NUM_MARKETING_POPUPS_SKIP:int = 3;
      
      private const MAX_MARKETING_POPUPS:int = 3;
      
      private var m_skipMarketingPopups:int;
      
      private var m_marketingPopupsShown:int;
      
      private var m_dialog:SmartPopupMarketing = null;
      
      private var m_experimentTable:Array;
      
      private var m_validSuppress:Array;
      
      public function SmartPopupManager()
      {
         var smartPopupsValidSuppressionsXml:XMLList = null;
         var smartPopupsExperimentsXml:XMLList = null;
         var smartPopupExperimentXml:XML = null;
         var smartPopupValidSuppressionXml:XML = null;
         var experiment:Object = null;
         var number:int = 0;
         this.m_experimentTable = new Array();
         this.m_validSuppress = new Array();
         super();
         if(!m_allowInstantiation)
         {
            throw new Error("Attempt to instantiate Smart Popup Manager outside of manager");
         }
         m_allowInstantiation = false;
         this.m_skipMarketingPopups = 0;
         this.m_marketingPopupsShown = 0;
         var xml:XML = Global.farmGameSettingsManager.getXML();
         if(xml)
         {
            smartPopupsValidSuppressionsXml = xml.smartPopups.validSuppress.popup;
            smartPopupsExperimentsXml = xml.smartPopups.experiments.variant;
            for each(smartPopupExperimentXml in smartPopupsExperimentsXml)
            {
               experiment = new Object();
               number = int(smartPopupExperimentXml.@num);
               experiment["cancels"] = int(smartPopupExperimentXml.@cancels);
               experiment["days"] = int(smartPopupExperimentXml.@days);
               experiment["skipMarketing"] = int(smartPopupExperimentXml.@skipMarketing) > 0;
               this.m_experimentTable[number] = experiment;
            }
            for each(smartPopupValidSuppressionXml in smartPopupsValidSuppressionsXml)
            {
               this.m_validSuppress.push(String(smartPopupValidSuppressionXml.@trackerKey));
            }
         }
      }
      
      public static function getInstance() : SmartPopupManager
      {
         if(m_instance == null)
         {
            m_allowInstantiation = true;
            m_instance = new SmartPopupManager();
         }
         return m_instance;
      }
      
      public function popupViewed(trackingKey:String) : void
      {
         FarmStatsManager.count("dialog",trackingKey,"View");
      }
      
      public function popupAccepted(trackingKey:String, buttonName:String) : void
      {
         if(this.smartPopupsEnabled() && this.validSuppression(trackingKey))
         {
            this.handleAccept(trackingKey);
         }
         FarmStatsManager.count("dialog",trackingKey,buttonName);
      }
      
      public function popupDeclined(trackingKey:String, buttonName:String) : void
      {
         if(this.smartPopupsEnabled() && this.validSuppression(trackingKey) && !this.isSuppressed(trackingKey,true))
         {
            this.incrementCancelCount(trackingKey + TAG_CANCEL);
            if(this.shouldSuppressDialog(trackingKey))
            {
               Global.player.setItemFlag(trackingKey + TAG_CANCEL,RESET_ITEMFLAG_VALUE);
               this.sendMarketingPopup(trackingKey);
            }
         }
         FarmStatsManager.count("dialog",trackingKey,buttonName);
      }
      
      public function suppressPopup(trackingKey:String) : Boolean
      {
         var suppress:Boolean = false;
         if(this.smartPopupsEnabled() && this.validSuppression(trackingKey) && this.isSuppressed(trackingKey,false))
         {
            FarmStatsManager.count("dialog",trackingKey,"Suppress");
            suppress = true;
         }
         return suppress;
      }
      
      private function isSuppressed(trackingKey:String, marketing:Boolean) : Boolean
      {
         var suppressed:Boolean = false;
         var mode:String = Global.player.getItemFlag(trackingKey + TAG_MODE);
         if(mode != SUPPRESS_OFF)
         {
            if(this.checkSuppressionExpired(trackingKey))
            {
               this.clearSuppression(trackingKey);
            }
            else if(marketing && mode == SUPPRESS_MARKETING || !marketing && mode == SUPPRESS_POPUP)
            {
               suppressed = true;
            }
         }
         return suppressed;
      }
      
      private function checkSuppressionExpired(trackingKey:String) : Boolean
      {
         var showInterval:Number = NaN;
         var time:Number = Global.player.getFeatureLastShown(trackingKey + TAG_TIMESTAMP);
         var mode:String = Global.player.getItemFlag(trackingKey + TAG_MODE);
         var expired:Boolean = false;
         if(mode != SUPPRESS_OFF)
         {
            if(mode == SUPPRESS_POPUP)
            {
               showInterval = this.getDaysSuppressed() * 60 * 60 * 24;
            }
            else
            {
               showInterval = Global.farmGameSettingsManager.getNumber(MARKETING_DIALOG_FREQUENCY,2592000);
            }
            expired = GlobalEngine.serverTime / 1000 > time + showInterval;
         }
         return expired;
      }
      
      private function incrementCancelCount(itemFlag:String) : void
      {
         var cancelCount:int = parseInt(Global.player.getItemFlag(itemFlag));
         cancelCount++;
         Global.player.setItemFlag(itemFlag,cancelCount.toString());
      }
      
      private function handleAccept(trackingKey:String) : void
      {
         Global.player.setItemFlag(trackingKey + TAG_CANCEL,RESET_ITEMFLAG_VALUE);
         Global.player.setItemFlag(trackingKey + TAG_CANCEL_MARKETING,RESET_ITEMFLAG_VALUE);
      }
      
      private function shouldSuppressDialog(trackingKey:String) : Boolean
      {
         return !this.isSuppressed(trackingKey,false) && parseInt(Global.player.getItemFlag(trackingKey + TAG_CANCEL)) >= this.getCancelClicksRequired();
      }
      
      private function startSuppressDialog(trackingKey:String, marketing:Boolean) : void
      {
         Global.player.setItemFlag(trackingKey + TAG_CANCEL,RESET_ITEMFLAG_VALUE);
         Global.player.setFeatureLastShown(trackingKey + TAG_TIMESTAMP,Math.round(GlobalEngine.serverTime / 1000),true);
         if(marketing)
         {
            Global.player.setItemFlag(trackingKey + TAG_MODE,SUPPRESS_MARKETING);
            Global.player.setItemFlag(trackingKey + TAG_CANCEL_MARKETING,RESET_ITEMFLAG_VALUE);
         }
         else
         {
            Global.player.setItemFlag(trackingKey + TAG_MODE,SUPPRESS_POPUP);
         }
      }
      
      private function clearSuppression(trackingKey:String) : void
      {
         Global.player.setItemFlag(trackingKey + TAG_MODE,SUPPRESS_OFF);
      }
      
      private function getCancelClicksRequired() : int
      {
         return this.getPropertyFromExperimentTable("cancels");
      }
      
      private function getDaysSuppressed() : int
      {
         return this.getPropertyFromExperimentTable("days");
      }
      
      private function getPropertyFromExperimentTable(propertyName:String) : int
      {
         var variant:int = Global.experimentManager.getExperimentVariant(EXPERIMENT_SMART_POPUPS);
         var propertyValue:int = 0;
         if(this.m_experimentTable[variant] != null)
         {
            propertyValue = int(this.m_experimentTable[variant][propertyName]);
         }
         return propertyValue;
      }
      
      private function validSuppression(trackingKey:String) : Boolean
      {
         return this.m_validSuppress.indexOf(trackingKey) != -1;
      }
      
      private function smartPopupsEnabled() : Boolean
      {
         var variant:int = Global.experimentManager.getExperimentVariant(EXPERIMENT_SMART_POPUPS);
         return variant > 0 && this.getCancelClicksRequired() > 0 && this.getDaysSuppressed() > 0;
      }
      
      private function skipMarketingDialog() : Boolean
      {
         var variant:int = Global.experimentManager.getExperimentVariant(EXPERIMENT_SMART_POPUPS);
         var skip:Boolean = false;
         if(this.m_experimentTable[variant] != null)
         {
            skip = Boolean(this.m_experimentTable[variant]["skipMarketing"]);
         }
         return skip;
      }
      
      private function sendMarketingPopup(trackingKey:String) : void
      {
         var controller:BaseWidgetController = null;
         if(this.m_skipMarketingPopups <= 0 && this.m_marketingPopupsShown < this.MAX_MARKETING_POPUPS && !this.skipMarketingDialog())
         {
            this.m_dialog = FarmDynamicDialog.createDialog("SmartPopup",SmartPopupMarketing) as SmartPopupMarketing;
            this.m_dialog.setTrackerKey(trackingKey);
            this.m_dialog.setup();
            controller = null;
            controller = this.m_dialog.findChildControllerByName("showFewerButton");
            if(controller != null)
            {
               controller.listen(WidgetControllerEvent.BUTTON_PRESSED,this.onMarketingPopupAccept);
            }
            controller = this.m_dialog.findChildControllerByName("cancelButton");
            if(controller != null)
            {
               controller.listen(WidgetControllerEvent.BUTTON_PRESSED,this.onMarketingPopupDecline);
            }
            controller = this.m_dialog.findChildControllerByName("CloseButtonView");
            if(controller != null)
            {
               controller.listen(WidgetControllerEvent.BUTTON_PRESSED,this.onMarketingPopupDecline);
            }
            this.m_dialog.show();
            ++this.m_marketingPopupsShown;
            this.m_skipMarketingPopups = this.NUM_MARKETING_POPUPS_SKIP;
         }
         else
         {
            if(this.m_marketingPopupsShown < this.MAX_MARKETING_POPUPS)
            {
               --this.m_skipMarketingPopups;
            }
            this.marketingPopupAccept(trackingKey);
         }
         Global.player.setSeenFlag(MARKETING_EXPERIENCED);
      }
      
      public function onMarketingPopupAccept(event:WidgetControllerEvent) : void
      {
         var trackerKey:String = this.m_dialog.getTrackerKey();
         this.m_dialog.destroy();
         this.marketingPopupAccept(trackerKey);
      }
      
      public function onMarketingPopupDecline(event:WidgetControllerEvent) : void
      {
         var trackerKey:String = this.m_dialog.getTrackerKey();
         this.m_dialog.destroy();
         this.marketingPopupDecline(trackerKey);
      }
      
      private function marketingPopupAccept(trackingKey:String) : void
      {
         this.startSuppressDialog(trackingKey,false);
      }
      
      private function marketingPopupDecline(trackingKey:String) : void
      {
         this.incrementCancelCount(trackingKey + TAG_CANCEL_MARKETING);
         if(parseInt(Global.player.getItemFlag(trackingKey + TAG_CANCEL_MARKETING)) >= Global.farmGameSettingsManager.getNumber(MARKETING_DIALOG_CANCEL_COUNT,2))
         {
            this.startSuppressDialog(trackingKey,true);
         }
      }
   }
}

