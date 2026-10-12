package Classes
{
   import Classes.Constants.XMLKeys;
   import DataSources.BaseDataSource;
   import Managers.FarmGameSettingsManager;
   
   public class NextExpandAwardData
   {
      
      private var m_itemName:String;
      
      private var m_quantity:int;
      
      private var m_awardDialog:String;
      
      private var m_awardDialogBackground:String;
      
      private var m_addToBuilding:Boolean;
      
      public function NextExpandAwardData(nextLevelXML:XML, nextLevelDataSource:BaseDataSource = null)
      {
         var awardDataSource:BaseDataSource = null;
         var awardData:XML = null;
         super();
         this.m_itemName = "";
         this.m_quantity = 1;
         this.m_awardDialog = null;
         this.m_addToBuilding = false;
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            if(nextLevelDataSource)
            {
               awardDataSource = nextLevelDataSource.getData("award");
               if(awardDataSource)
               {
                  this.m_itemName = awardDataSource.getString("name");
                  if(awardDataSource.hasProperty("number"))
                  {
                     this.m_quantity = awardDataSource.getInt("number");
                  }
                  if(awardDataSource.hasProperty("dialog"))
                  {
                     this.m_awardDialog = awardDataSource.getString("dialog");
                  }
                  if(awardDataSource.hasProperty("dialogBackground"))
                  {
                     this.m_awardDialogBackground = awardDataSource.getString("dialogBackground");
                  }
                  this.m_addToBuilding = awardDataSource.getBoolean("addToBuilding");
               }
            }
         }
         else if(nextLevelXML)
         {
            awardData = nextLevelXML.award[0];
            if(awardData)
            {
               this.m_itemName = awardData[XMLKeys.ATTR_NAME];
               if(awardData.hasOwnProperty("@number"))
               {
                  this.m_quantity = awardData["@number"];
               }
               if(awardData.hasOwnProperty("@dialog"))
               {
                  this.m_awardDialog = awardData["@dialog"];
               }
               if(awardData.hasOwnProperty("@dialogBackground"))
               {
                  this.m_awardDialogBackground = awardData["@dialogBackground"];
               }
               if(awardData.hasOwnProperty("@addToBuilding"))
               {
                  this.m_addToBuilding = awardData["@addToBuilding"];
               }
            }
         }
      }
      
      public function get itemName() : String
      {
         return this.m_itemName;
      }
      
      public function get quantity() : int
      {
         return this.m_quantity;
      }
      
      public function get awardDialog() : String
      {
         return this.m_awardDialog;
      }
      
      public function get awardDialogBackground() : String
      {
         return this.m_awardDialogBackground;
      }
      
      public function get addToBuilding() : Boolean
      {
         return this.m_addToBuilding;
      }
      
      public function set itemName(itemName:String) : void
      {
         this.m_itemName = itemName;
      }
      
      public function set quantity(quantity:int) : void
      {
         this.m_quantity = quantity;
      }
      
      public function set addToBuilding(addToBuilding:Boolean) : void
      {
         this.m_addToBuilding = addToBuilding;
      }
   }
}

