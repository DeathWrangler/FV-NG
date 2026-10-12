package Transactions
{
   import Classes.ZItem.FarmItem;
   import Display.GenericPopup;
   import Engine.Managers.StatsManager;
   import Events.GenericPopupEvent;
   import Managers.ThemeManager;
   
   public class TChangeTheme extends TFarmTransaction
   {
      
      public static const METHOD_CHANGE_THEME:String = "changeTheme";
      
      protected var m_item:FarmItem;
      
      public function TChangeTheme(item:String)
      {
         super();
         this.m_item = Global.farmGameSettingsManager.getFarmItemByName(item);
         if(this.m_item)
         {
            Global.world.setBackgroundTileAndColor(item);
         }
         else
         {
            canPerform = false;
         }
      }
      
      override public function perform() : void
      {
         signedCall("FarmService." + METHOD_CHANGE_THEME,this.m_item.name);
      }
      
      override public function getTransactionData() : Object
      {
         var result:Object = new Object();
         result.method = METHOD_CHANGE_THEME;
         result.item = this.m_item;
         return result;
      }
      
      override protected function onComplete(result:Object) : void
      {
         if(result != null && this.m_item.isLicenseGated)
         {
            ThemeManager.getInstance().showThemeShareFeedDialog(this.m_item,this.onShareThemeChangeDialogClose);
         }
      }
      
      private function onShareThemeChangeDialogClose(event:GenericPopupEvent) : void
      {
         var decision:String = "cancel";
         if(event.button == GenericPopup.YES)
         {
            ThemeManager.getInstance().publishThemeChangeFeed(this.m_item);
            decision = "accept";
         }
         StatsManager.count("dialog","landscape_changed",decision);
      }
   }
}

