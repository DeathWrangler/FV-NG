package Classes.ZItem
{
   import Classes.Constants.WorldsConstants;
   import Classes.util.ZLocUtils;
   import DataSources.BaseDataSource;
   import Display.GenericPopup;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Managers.FarmGameSettingsManager;
   import Transactions.TBuyFuel;
   import Transactions.TFuelForCoinsShare;
   
   public class FuelItem extends ConsumableItem
   {
      
      public static const FUEL_CANS_FARMING_ENTRY:String = "fuelcans";
      
      public function FuelItem(itemXML:XML = null, itemData:BaseDataSource = null)
      {
         super(itemXML,itemData);
      }
      
      public static function OwnsFuelVehicle() : Boolean
      {
         return Global.world.getEquipment() != null;
      }
      
      public static function isAFuelCan(itemName:String) : Boolean
      {
         var result:Boolean = false;
         var fuelLootItemNames:Array = Global.farmGameSettingsManager.getString(FUEL_CANS_FARMING_ENTRY).split(",");
         if(fuelLootItemNames != null && fuelLootItemNames.length > 0 && fuelLootItemNames.indexOf(itemName) != -1)
         {
            result = true;
         }
         return result;
      }
      
      override public function onBuy(name:String, extraData:Object = null) : Boolean
      {
         var currentTime:Number = NaN;
         var returnVal:Boolean = true;
         if(Global.world.getEquipment() == null && Global.worldManager.currentWorldType == WorldsConstants.WORLD_ID_HOME)
         {
            UI.displayMessage(ZLocUtils.t("Dialogs","MustOwnTractor"),GenericPopup.TYPE_OK,null,"",true);
            returnVal = false;
         }
         else
         {
            if(name == "fuel1coin" || name == "fuel5coin")
            {
               currentTime = GlobalEngine.serverTime / 1000;
               Global.player.setFeatureLastShown("Bought" + name,currentTime,false);
               TransactionManager.addTransaction(new TFuelForCoinsShare(),true);
            }
            TransactionManager.addTransaction(new TBuyFuel(name,false));
            Global.hud.highlightFuel();
         }
         return returnVal;
      }
      
      override public function onUse(buildingId:int = 0, extraData:Object = null) : void
      {
         var currentTime:Number = NaN;
         if(name == "fuel1coin" || name == "fuel5coin")
         {
            currentTime = GlobalEngine.serverTime / 1000;
            Global.player.setFeatureLastShown("Bought" + name,currentTime,false);
            TransactionManager.addTransaction(new TFuelForCoinsShare(),true);
         }
         TransactionManager.addTransaction(new TBuyFuel(name,true),true);
         Global.hud.highlightFuel();
      }
      
      override public function get friendlyName() : String
      {
         var name:String = null;
         if(m_friendlyName == null)
         {
            if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               name = m_dataSource.getString("name");
            }
            else
            {
               name = m_itemXML.@name;
            }
            m_friendlyName = "Items:" + name + "_friendlyName";
         }
         return m_friendlyName;
      }
   }
}

