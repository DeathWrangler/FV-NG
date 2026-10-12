package GameMode
{
   import Classes.StorageBuilding;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Managers.FarmGameSettingsManager;
   import Transactions.TPaintBuilding;
   
   public class GMPaintBuilding extends GMModifyBuilding
   {
      
      public function GMPaintBuilding(itemName:String, isGift:Boolean)
      {
         super(itemName,"horsestablewhite",isGift);
      }
      
      override protected function canModifyBuilding(building:Object) : Boolean
      {
         var canModify:Boolean = false;
         var buildingInstance:StorageBuilding = building as StorageBuilding;
         if(Boolean(buildingInstance) && buildingInstance.isPaintable(m_itemName))
         {
            canModify = true;
         }
         else
         {
            UI.displayMessage(ZLocUtils.t("Dialogs","HorseStableCannotPaint"));
         }
         return canModify;
      }
      
      override protected function modifyBuilding() : void
      {
         var item:FarmItem = null;
         var paintColor:String = null;
         if(!m_building.isBuilding())
         {
            item = Global.farmGameSettingsManager.getFarmItemByName(m_itemName);
            if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               paintColor = item.getStringFromDataSource("paintColor");
            }
            else if(item.xml.paintColor)
            {
               paintColor = item.xml.paintColor.toString();
            }
            if(paintColor)
            {
               m_building.setPaintColor(paintColor);
               TransactionManager.addTransaction(new TPaintBuilding(m_building,m_itemName));
            }
         }
      }
      
      override protected function onFinishModifyBuilding(modifiedBuilding:Boolean, hasABuilding:Boolean, isFirstEntry:Boolean) : void
      {
         var item:FarmItem = null;
         if(modifiedBuilding)
         {
            item = Global.farmGameSettingsManager.getFarmItemByName(m_itemName);
            Global.player.tryBuy(null,m_isGift,item);
            m_building.reloadImage();
         }
      }
   }
}

