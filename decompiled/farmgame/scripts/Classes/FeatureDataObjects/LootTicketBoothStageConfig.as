package Classes.FeatureDataObjects
{
   import Classes.Quest.PrerequisiteUtility;
   
   public class LootTicketBoothStageConfig
   {
      
      public var name:String;
      
      public var dialogBackgroundUrl:String;
      
      public var lootTableName:String;
      
      public var lootPartReplacement:String;
      
      public var partItemName:String;
      
      public var partItemNeeded:int;
      
      public var prereqs:Array;
      
      public var ticketItemName:String;
      
      public var ticketItemNeeded:int;
      
      public var ticketItemLimit:int;
      
      public function LootTicketBoothStageConfig(rawXML:XML)
      {
         super();
         this.name = rawXML.@name.toString();
         this.dialogBackgroundUrl = rawXML.dialogBackgroundUrl.toString();
         this.lootTableName = rawXML.lootTableName.toString();
         this.lootPartReplacement = rawXML.lootPartReplacement.toString();
         this.partItemName = rawXML.partItemName.toString();
         this.partItemNeeded = int(rawXML.partItemNeeded);
         this.ticketItemName = rawXML.ticketItemName.toString();
         this.ticketItemNeeded = int(rawXML.ticketItemNeeded);
         this.ticketItemLimit = int(rawXML.ticketItemLimit);
         if(rawXML.hasOwnProperty("prereqs") && rawXML.prereqs.hasOwnProperty("prereq"))
         {
            this.prereqs = PrerequisiteUtility.parseXmlNodePrereqs(rawXML.prereqs.prereq);
         }
      }
   }
}

