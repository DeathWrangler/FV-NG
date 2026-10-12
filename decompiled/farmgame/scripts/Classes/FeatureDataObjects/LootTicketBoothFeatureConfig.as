package Classes.FeatureDataObjects
{
   import Classes.Quest.PrerequisiteUtility;
   
   public class LootTicketBoothFeatureConfig
   {
      
      public var dialogBackgroundUrl:String;
      
      public var resultDialogUrl:String;
      
      private var m_stages:Array;
      
      public function LootTicketBoothFeatureConfig(rawXML:XML)
      {
         var stageXML:XML = null;
         super();
         this.dialogBackgroundUrl = rawXML.dialogBackgroundUrl.toString();
         this.resultDialogUrl = rawXML.resultDialogUrl.toString();
         this.m_stages = [];
         for each(stageXML in rawXML.stage)
         {
            this.m_stages.push(new LootTicketBoothStageConfig(stageXML));
         }
      }
      
      public function getStages(checkPrereqs:Boolean = true) : Array
      {
         var stage:LootTicketBoothStageConfig = null;
         var result:Array = [];
         for each(stage in this.m_stages)
         {
            if(!checkPrereqs || !stage.prereqs || PrerequisiteUtility.arePrerequisitesMet(stage.prereqs))
            {
               result.push(stage);
            }
         }
         return result;
      }
      
      public function getStageByIndex(index:int) : LootTicketBoothStageConfig
      {
         var result:LootTicketBoothStageConfig = null;
         if(index >= 0 && index < this.m_stages.length)
         {
            result = this.m_stages[index];
         }
         return result;
      }
      
      public function getStageByName(stageName:String) : LootTicketBoothStageConfig
      {
         var result:LootTicketBoothStageConfig = null;
         var stage:LootTicketBoothStageConfig = null;
         for each(stage in this.m_stages)
         {
            if(stage.name == stageName)
            {
               result = stage;
               break;
            }
         }
         return result;
      }
   }
}

