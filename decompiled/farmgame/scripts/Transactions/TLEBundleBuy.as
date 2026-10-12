package Transactions
{
   import Classes.Constants.ToasterIconPaths;
   import Classes.LESaleBundle;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Managers.ToasterManager;
   import Widgets.Windows.IconToasterWindow;
   
   public class TLEBundleBuy extends TFarmTransaction
   {
      
      protected var m_itemCodes:Array;
      
      protected var m_saleBundle:LESaleBundle;
      
      public function TLEBundleBuy(saleBundle:LESaleBundle, itemCodes:Array)
      {
         this.m_saleBundle = saleBundle;
         this.m_itemCodes = itemCodes;
         super();
      }
      
      override public function perform() : void
      {
         var farmItem:FarmItem = null;
         signedCall("UserService.buyLEBundleItems",this.m_itemCodes);
         for(var index:int = 0; index < this.m_itemCodes.length; index++)
         {
            farmItem = Global.farmGameSettingsManager.getFarmItemByCode(this.m_itemCodes[index]);
            Global.player.addGift(farmItem.name,"0",1);
            Global.player.xp += farmItem.buyXp;
            Global.player.cash -= this.m_saleBundle.getSalePrice(farmItem);
         }
         ToasterManager.getInstance().add(new IconToasterWindow(ToasterIconPaths.CASH_MINI_ICON,ZLocUtils.t("Dialogs","LESaleBundle_ToasterMessage")));
      }
   }
}

