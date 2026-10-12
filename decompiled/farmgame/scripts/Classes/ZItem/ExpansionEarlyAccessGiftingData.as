package Classes.ZItem
{
   import Classes.Quest.PrerequisiteUtility;
   
   public class ExpansionEarlyAccessGiftingData
   {
      
      private var m_mainDialog:String;
      
      private var m_giftDialog:String;
      
      private var m_congratsDiaog:String;
      
      private var m_itemName:String;
      
      private var m_prereqs:Array;
      
      private var m_featureFrequency:int = 28800;
      
      private var m_maxShowTimes:int = 3;
      
      private var m_expansionId:String;
      
      public function ExpansionEarlyAccessGiftingData(expansionId:String, config:XML)
      {
         var node:XML = null;
         super();
         this.m_expansionId = expansionId;
         for each(node in config.dialog)
         {
            switch(String(node.@type))
            {
               case "main":
                  this.m_mainDialog = String(node.@asset);
                  break;
               case "gifting":
                  this.m_giftDialog = String(node.@asset);
                  break;
               case "congrats":
                  this.m_congratsDiaog = String(node.@asset);
            }
         }
         this.m_prereqs = PrerequisiteUtility.parseXmlNodePrereqs(config.prereqs.prereq);
         this.m_itemName = String(config.@item);
         if(config.hasOwnProperty("@frequency"))
         {
            this.m_featureFrequency = int(config.@frequency);
         }
         if(config.hasOwnProperty("@maxShowTimes"))
         {
            this.m_maxShowTimes = int(config.@maxShowTimes);
         }
      }
      
      public function get mainDialogAssetURL() : String
      {
         return this.m_mainDialog;
      }
      
      public function get giftDialogAssetURL() : String
      {
         return this.m_giftDialog;
      }
      
      public function get congratsDiaogAssetURL() : String
      {
         return this.m_congratsDiaog;
      }
      
      public function get itemName() : String
      {
         return this.m_itemName;
      }
      
      public function get prereqs() : Array
      {
         return this.m_prereqs;
      }
      
      public function get featureFrequency() : int
      {
         return this.m_featureFrequency;
      }
      
      public function get expansionId() : String
      {
         return this.m_expansionId;
      }
      
      public function get maxShowTimes() : int
      {
         return this.m_maxShowTimes;
      }
   }
}

