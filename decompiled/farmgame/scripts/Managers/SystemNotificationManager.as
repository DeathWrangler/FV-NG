package Managers
{
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Transactions.TResetSystemNotifications;
   
   public class SystemNotificationManager
   {
      
      private static const LOCALIZATION_PREFIX:String = "SystemNotification_";
      
      private static const NOTIFICATION_ASSET_URL:String = "assets/dialogs/FV_GenericLrgPopUp.swf";
      
      private static const SYSTEM_NOTIFICATION_HANDLE_DEFAULT:String = "defaultNotif";
      
      private static var m_instance:SystemNotificationManager = null;
      
      private static var m_allowInstantiation:Boolean = false;
      
      private static var m_needReset:Boolean = false;
      
      private var m_staticSystemNotifications:Object = null;
      
      private var m_dynamicSystemNotifications:Object = null;
      
      public function SystemNotificationManager()
      {
         super();
         if(!m_allowInstantiation)
         {
            throw new Error("Error: Instantiation failed: Use getInstance() instead of new.");
         }
      }
      
      public static function getInstance() : SystemNotificationManager
      {
         if(m_instance == null)
         {
            m_allowInstantiation = true;
            m_instance = new SystemNotificationManager();
            m_allowInstantiation = false;
         }
         return m_instance;
      }
      
      private static function displayStaticNotification(notificationHandle:String) : void
      {
         var message:String = null;
         var logMessage:String = null;
         var messagePackage:String = "FarmGame";
         var messageKey:String = LOCALIZATION_PREFIX + notificationHandle;
         if(ZLocUtils.hasString(messagePackage,messageKey))
         {
            message = ZLocUtils.t(messagePackage,messageKey);
            if(message)
            {
               UI.displayPopup(new GenericPopup(message,GenericPopup.TYPE_OK,null,NOTIFICATION_ASSET_URL,null,true));
            }
         }
         else
         {
            logMessage = "Localization value missing for " + messagePackage + ":" + messageKey;
            GlobalEngine.log("SystemNotificationManager",logMessage);
            FarmGameUtil.reportClientLog("SystemNotificationManager.displayStaticNotification - " + logMessage);
         }
      }
      
      private static function displayDynamicNotification(notificationMessage:String) : void
      {
         if(notificationMessage == SYSTEM_NOTIFICATION_HANDLE_DEFAULT)
         {
            displayStaticNotification(notificationMessage);
         }
         else if(notificationMessage)
         {
            UI.displayPopup(new GenericPopup(notificationMessage,GenericPopup.TYPE_OK,null,NOTIFICATION_ASSET_URL,null,true));
         }
      }
      
      public function load(staticNotificationData:Object, dynamicNotificationData:Object) : void
      {
         this.m_staticSystemNotifications = staticNotificationData;
         this.m_dynamicSystemNotifications = dynamicNotificationData;
      }
      
      public function hasPendingStaticNotifications() : Boolean
      {
         return this.m_staticSystemNotifications != null;
      }
      
      public function hasPendingDynamicNotifications() : Boolean
      {
         return this.m_dynamicSystemNotifications != null;
      }
      
      public function displayPendingNotifications() : void
      {
         var notificationHandle:String = null;
         var notificationMessage:String = null;
         if(this.hasPendingStaticNotifications())
         {
            for each(notificationHandle in this.m_staticSystemNotifications)
            {
               displayStaticNotification(notificationHandle);
            }
            m_needReset = true;
         }
         if(this.hasPendingDynamicNotifications())
         {
            for each(notificationMessage in this.m_dynamicSystemNotifications)
            {
               displayDynamicNotification(notificationMessage);
            }
            m_needReset = true;
         }
      }
      
      public function resetNotifications() : void
      {
         if(m_needReset)
         {
            this.m_staticSystemNotifications = null;
            this.m_dynamicSystemNotifications = null;
            m_needReset = false;
            TransactionManager.addTransaction(new TResetSystemNotifications(),false);
         }
      }
   }
}

