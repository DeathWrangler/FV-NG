package Transactions
{
   import Classes.ZItem.FarmItem;
   import Display.GenericPopup;
   import Engine.Managers.StatsManager;
   import Events.GenericPopupEvent;
   import Managers.LicenseManager;
   import Managers.ThemeManager;
   
   public class TBuyTheme extends TFarmTransaction
   {
      
      public static const METHOD_BUY_THEME:String = "buyTheme";
      
      protected var m_item:FarmItem;
      
      public function TBuyTheme(item:String)
      {
         super();
         this.m_item = Global.farmGameSettingsManager.getFarmItemByName(item);
         if(this.m_item)
         {
            if(!Global.player.tryBuy(null,false,this.m_item))
            {
               canPerform = false;
               this.m_item = null;
               throw new Error("TBuyTheme::cannot afford the item");
            }
            Global.world.setBackgroundTileAndColor(item);
         }
         else
         {
            canPerform = false;
         }
      }
      
      override public function perform() : void
      {
         signedCall("FarmService." + METHOD_BUY_THEME,this.m_item.name);
      }
      
      override public function getTransactionData() : Object
      {
         var result:Object = new Object();
         result.method = METHOD_BUY_THEME;
         result.item = this.m_item;
         return result;
      }
      
      override protected function onComplete(result:Object) : void
      {
         if(Boolean(result != null) && Boolean(result.timeExpires) && this.m_item.isLicenseGated)
         {
            LicenseManager.getInstance().addLicense(this.m_item.code,result.timeExpires);
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
         StatsManager.count("dialog","landscape_purchased",decision);
      }
   }
}

