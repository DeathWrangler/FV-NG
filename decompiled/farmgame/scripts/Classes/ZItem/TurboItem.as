package Classes.ZItem
{
   import Classes.Constants.WorldsConstants;
   import Classes.util.ZLocUtils;
   import DataSources.BaseDataSource;
   import Display.GenericPopup;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Managers.FarmGameSettingsManager;
   import Transactions.TBuyTurboChargers;
   
   public class TurboItem extends ConsumableItem
   {
      
      public function TurboItem(itemXML:XML = null, itemData:BaseDataSource = null)
      {
         super(itemXML,itemData);
      }
      
      override public function onBuy(name:String, extraData:Object = null) : Boolean
      {
         var returnVal:Boolean = true;
         if(Global.world.getEquipment() == null && Global.worldManager.currentWorldType == WorldsConstants.WORLD_ID_HOME)
         {
            UI.displayMessage(ZLocUtils.t("Dialogs","MustOwnTractor"),GenericPopup.TYPE_OK,null,"",true);
            returnVal = false;
         }
         else
         {
            TransactionManager.addTransaction(new TBuyTurboChargers(name,false));
         }
         return returnVal;
      }
      
      override public function onUse(buildingId:int = 0, extraData:Object = null) : void
      {
         TransactionManager.addTransaction(new TBuyTurboChargers(name,true));
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

