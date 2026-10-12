package Classes.ZItem
{
   import DataSources.BaseDataSource;
   
   public class ExpansionAccessItem extends FarmItem
   {
      
      public function ExpansionAccessItem(itemXML:XML = null, itemData:BaseDataSource = null)
      {
         super(itemXML,itemData);
      }
      
      private function getMOTDSeenFlag() : String
      {
         var result:String = null;
         var access:ExpansionAccess = null;
         var expansionData:ExpansionData = Global.farmGameSettingsManager.getExpansionData(this.worldType);
         if(expansionData)
         {
            access = expansionData.getAccessOfType(ExpansionAccess.TYPE_EARLY);
            if(access)
            {
               result = access.motdSeenFlag;
            }
         }
         return result;
      }
      
      override public function get isVisible() : Boolean
      {
         return isInExperiment && checkMarketPrereqs();
      }
      
      public function get worldType() : String
      {
         return subType;
      }
      
      public function get motdSeenFlag() : String
      {
         return this.getMOTDSeenFlag();
      }
      
      public function getMOTDData() : Object
      {
         var motdSeenFlag:String = this.getMOTDSeenFlag();
         return {
            "worldType":this.worldType,
            "motdSeenFlag":motdSeenFlag
         };
      }
      
      override public function get buyableWithoutDateCheck() : Boolean
      {
         return true;
      }
   }
}

