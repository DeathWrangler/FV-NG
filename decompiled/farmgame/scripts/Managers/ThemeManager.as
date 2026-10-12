package Managers
{
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.UI;
   
   public class ThemeManager
   {
      
      private static var s_instance:ThemeManager = null;
      
      private static var m_canInstantiate:Boolean = false;
      
      public function ThemeManager()
      {
         super();
      }
      
      public static function getInstance() : ThemeManager
      {
         if(null == s_instance)
         {
            m_canInstantiate = true;
            s_instance = new ThemeManager();
            m_canInstantiate = false;
         }
         return s_instance;
      }
      
      public function showThemeShareFeedDialog(item:FarmItem, closeCallback:Function = null) : void
      {
         var message:String = ZLocUtils.t("Dialogs","Share_Theme_Change",{"themeName":ZLocUtils.tk_pk(item.friendlyName)});
         var popup:GenericPopup = new GenericPopup(message,GenericPopup.TYPE_SHARECANCEL,closeCallback,GenericPopup.GENERIC_ASSET);
         popup.setTrackerKey("landscape_changed");
         UI.displayPopup(popup);
      }
      
      public function publishThemeChangeFeed(item:FarmItem) : void
      {
         var messageType:String = "SeeMyTheme";
         var bundleData:Object = {
            "images":[{
               "href":"{SN_APP_URL}index.php?visitId=" + Global.player.uid,
               "src":item.icon
            }],
            "themeName":item.friendlyName
         };
         GlobalEngine.socialNetwork.publishFeedStory(messageType,bundleData,[],false);
      }
   }
}

