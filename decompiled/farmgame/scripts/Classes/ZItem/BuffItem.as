package Classes.ZItem
{
   import DataSources.BaseDataSource;
   import Managers.FarmGameSettingsManager;
   
   public class BuffItem extends FarmItem
   {
      
      public function BuffItem(itemXML:XML = null, itemData:BaseDataSource = null)
      {
         super(itemXML,itemData);
      }
      
      public function get buffExpires() : Number
      {
         var retVal:Number = NaN;
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            retVal = m_dataSource.getNumber("buffExpires");
         }
         else
         {
            retVal = Number(m_itemXML.buffExpires);
         }
         return retVal;
      }
   }
}

